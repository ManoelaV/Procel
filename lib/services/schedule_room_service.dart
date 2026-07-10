import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/room_model.dart';
import '../models/timetable_entry.dart';
import 'backend_session.dart';

/// Service que consulta as salas das disciplinas usando os endpoints existentes.
///
/// Fluxo:
/// 1. Tenta GET /api/pessoas/{id}/disciplinas?periodoLetivo=AAAA/S
/// 2. Se vier vazio: busca disciplinas no catálogo e vincula automaticamente
/// 3. GET /api/catalog/disciplinas/{id}/periodos-aula
/// 4. Match por nome da disciplina (normalizado) + dia + horário
class ScheduleRoomService {
  static Future<Map<TimetableEntry, Room?>> fetchRoomsForSchedule({
    required List<TimetableEntry> entries,
    required String matricula,
    required String periodoLetivo,
  }) async {
    final headers = await _buildHeaders();

    // 1. Tenta buscar disciplinas já vinculadas ao aluno
    var disciplinasAluno = await _fetchDisciplinasDoAluno(
      matricula: matricula,
      periodoLetivo: periodoLetivo,
      headers: headers,
    );

    print(
      '[DEBUG] Disciplinas do aluno encontradas: ${disciplinasAluno.length}',
    );

    // 2. Se vazio, tenta vincular automaticamente
    if (disciplinasAluno.isEmpty) {
      print(
        '[DEBUG] Nenhuma disciplina vinculada. Buscando catálogo para auto-vínculo...',
      );
      await _autoVincularDisciplinas(
        entries: entries,
        matricula: matricula,
        periodoLetivo: periodoLetivo,
        headers: headers,
      );

      // Tenta novamente buscar as disciplinas do aluno
      disciplinasAluno = await _fetchDisciplinasDoAluno(
        matricula: matricula,
        periodoLetivo: periodoLetivo,
        headers: headers,
      );
      print(
        '[DEBUG] Após auto-vínculo, disciplinas encontradas: ${disciplinasAluno.length}',
      );
    }

    for (final d in disciplinasAluno) {
      print(
        '[DEBUG]   -> id=${d.disciplinaId} nome="${d.disciplinaNome}" turma="${d.turma}"',
      );
    }

    // 3. Busca períodos de cada disciplina
    final Map<int, List<_PeriodoInfo>> aulasPorDisciplina = {};

    for (final disc in disciplinasAluno) {
      final periodos = await _fetchPeriodosDaDisciplina(
        disciplinaId: disc.disciplinaId,
        headers: headers,
      );

      print(
        '[DEBUG] Disciplina ${disc.disciplinaId} (${disc.disciplinaNome}): ${periodos.length} períodos',
      );
      for (final p in periodos) {
        print(
          '[DEBUG]   -> data=${p.data} hora=${p.horaInicio}-${p.horaFim} sala="${p.compartimentoNome}" turma="${p.turma}"',
        );
        if (p.compartimentoNome != null && p.compartimentoNome!.isNotEmpty) {
          aulasPorDisciplina.putIfAbsent(disc.disciplinaId, () => []);
          aulasPorDisciplina[disc.disciplinaId]!.add(p);
        }
      }
    }

    // 4. Match
    final Map<TimetableEntry, Room?> result = {};

    for (final entry in entries) {
      print(
        '[DEBUG] Entry: codigo="${entry.codigo}" disciplina="${entry.disciplina}" turma="${entry.turma}" dia="${entry.dia}" horario=${entry.startTime}-${entry.endTime}',
      );
      final room = _findRoomForEntry(
        entry: entry,
        aulasPorDisciplina: aulasPorDisciplina,
        disciplinasAluno: disciplinasAluno,
      );
      print('[DEBUG]   -> Sala encontrada: ${room?.name ?? "NENHUMA"}');
      result[entry] = room;
    }

    return result;
  }

  /// Busca disciplinas no catálogo pelo código do PDF e vincula o aluno.
  static Future<void> _autoVincularDisciplinas({
    required List<TimetableEntry> entries,
    required String matricula,
    required String periodoLetivo,
    required Map<String, String> headers,
  }) async {
    // Agrupa entries únicas por código para não vincular duplicado
    final codigosUnicos = <String>{};
    for (final entry in entries) {
      if (entry.codigo != null && entry.codigo!.isNotEmpty) {
        codigosUnicos.add(entry.codigo!);
      }
    }

    // Busca catálogo de disciplinas
    final catalogUri = Uri.parse(
      '${ApiConfig.baseUrl}${ApiConfig.API_PREFIX}/catalog/disciplinas',
    );
    print('[DEBUG] GET $catalogUri');
    final catalogResponse = await http.get(catalogUri, headers: headers);
    print('[DEBUG] Status catálogo: ${catalogResponse.statusCode}');

    if (catalogResponse.statusCode != 200) return;

    final List<dynamic> catalogData = jsonDecode(catalogResponse.body);

    // Para cada código do PDF, tenta encontrar no catálogo e vincular
    for (final codigo in codigosUnicos) {
      final codigoInt = int.tryParse(codigo);
      if (codigoInt == null) continue;

      // Procura disciplina no catálogo pelo código (id)
      for (final disc in catalogData) {
        final discId = disc['id'] is int
            ? disc['id'] as int
            : int.tryParse(disc['id']?.toString() ?? '');

        if (discId == codigoInt) {
          // Encontrou! Agora descobre a turma desta disciplina no PDF
          String? turma;
          for (final entry in entries) {
            if (entry.codigo == codigo && entry.turma != null) {
              turma = entry.turma;
              break;
            }
          }

          if (turma == null) {
            print('[DEBUG] Pulando disciplina $codigo sem turma definida');
            continue;
          }

          // Vincula o aluno à disciplina
          await _vincularDisciplina(
            matricula: matricula,
            disciplinaId: codigoInt,
            turma: turma,
            periodoLetivo: periodoLetivo,
            headers: headers,
          );
          break; // Sai do loop do catálogo, já vinculou
        }
      }
    }
  }

  /// Vincula o aluno a uma disciplina via POST /api/pessoas/{matricula}/disciplinas
  static Future<void> _vincularDisciplina({
    required String matricula,
    required int disciplinaId,
    required String turma,
    required String periodoLetivo,
    required Map<String, String> headers,
  }) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}${ApiConfig.API_PREFIX}/pessoas/$matricula/disciplinas',
    );

    final body = jsonEncode({
      'disciplinaId': disciplinaId,
      'turma': turma,
      'periodoLetivo': periodoLetivo,
    });

    print('[DEBUG] POST $uri body=$body');
    final response = await http.post(uri, headers: headers, body: body);
    print('[DEBUG] Status vínculo: ${response.statusCode} - ${response.body}');

    if (response.statusCode == 409) {
      // 409 = já vinculado, tudo bem
      print('[DEBUG] Disciplina $disciplinaId já vinculada ao aluno');
    } else if (response.statusCode != 200) {
      print(
        '[DEBUG] Aviso: Falha ao vincular disciplina $disciplinaId: ${response.statusCode}',
      );
    }
  }

  static Future<Map<String, String>> _buildHeaders() async {
    String? token = await BackendSession.restoreToken();
    try {
      final prefs = await SharedPreferences.getInstance();
      final possibleKeys = [
        'procel_backend_access_token',
        'token',
        'auth_token',
        'access_token',
        'jwt_token',
        'api_token',
      ];
      for (var key in possibleKeys) {
        if (token != null && token.isNotEmpty) break;
        token = prefs.getString(key);
      }
    } catch (e) {
      print('Erro ao obter token: $e');
    }

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    } else {
      throw Exception('Login do back-end ausente. Entre novamente no app.');
    }

    return headers;
  }

  static Future<List<_DisciplinaAluno>> _fetchDisciplinasDoAluno({
    required String matricula,
    required String periodoLetivo,
    required Map<String, String> headers,
  }) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}${ApiConfig.API_PREFIX}/pessoas/$matricula/disciplinas'
      '?periodoLetivo=$periodoLetivo',
    );

    print('[DEBUG] GET $uri');
    final response = await http.get(uri, headers: headers);
    print('[DEBUG] Status: ${response.statusCode}');

    if (response.statusCode != 200) {
      throw Exception(
        'Falha ao buscar disciplinas do aluno: ${response.statusCode} - ${response.body}',
      );
    }

    final List<dynamic> data = jsonDecode(response.body);
    print('[DEBUG] Resposta: ${response.body}');
    return data.map((json) => _DisciplinaAluno.fromJson(json)).toList();
  }

  static Future<List<_PeriodoInfo>> _fetchPeriodosDaDisciplina({
    required int disciplinaId,
    required Map<String, String> headers,
  }) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}${ApiConfig.API_PREFIX}/catalog/disciplinas/$disciplinaId/periodos-aula',
    );

    print('[DEBUG] GET $uri');
    final response = await http.get(uri, headers: headers);
    print('[DEBUG] Status: ${response.statusCode}');

    if (response.statusCode != 200) {
      print(
        '[DEBUG] Aviso: Falha ao buscar períodos da disciplina $disciplinaId: ${response.statusCode}',
      );
      return [];
    }

    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => _PeriodoInfo.fromJson(json)).toList();
  }

  static Room? _findRoomForEntry({
    required TimetableEntry entry,
    required Map<int, List<_PeriodoInfo>> aulasPorDisciplina,
    required List<_DisciplinaAluno> disciplinasAluno,
  }) {
    final int? disciplinaId = _findDisciplinaId(entry, disciplinasAluno);
    print('[DEBUG] disciplinaId encontrado: $disciplinaId');
    if (disciplinaId == null) return null;

    final periodos = aulasPorDisciplina[disciplinaId];
    print(
      '[DEBUG] Períodos para disciplinaId $disciplinaId: ${periodos?.length ?? 0}',
    );
    if (periodos == null || periodos.isEmpty) return null;

    // a) turma + dia + horário
    for (final p in periodos) {
      final tMatch =
          entry.turma == null || p.turma == null || entry.turma == p.turma;
      final dMatch = entry.dia == null || _matchesDay(p, entry.dia!);
      final hMatch = _matchesTime(p, entry.startTime, entry.endTime);
      if (tMatch && dMatch && hMatch) return _periodoToRoom(p);
    }

    // b) dia + horário (qualquer turma)
    for (final p in periodos) {
      final dMatch = entry.dia == null || _matchesDay(p, entry.dia!);
      final hMatch = _matchesTime(p, entry.startTime, entry.endTime);
      if (dMatch && hMatch) return _periodoToRoom(p);
    }

    // c) só dia
    if (entry.dia != null) {
      for (final p in periodos) {
        if (_matchesDay(p, entry.dia!)) return _periodoToRoom(p);
      }
    }

    // d) fallback
    if (periodos.isNotEmpty) return _periodoToRoom(periodos.first);

    return null;
  }

  static int? _findDisciplinaId(
    TimetableEntry entry,
    List<_DisciplinaAluno> disciplinas,
  ) {
    // Tenta match pelo código
    if (entry.codigo != null && entry.codigo!.isNotEmpty) {
      final codigoInt = int.tryParse(entry.codigo!);
      if (codigoInt != null) {
        for (final disc in disciplinas) {
          if (disc.disciplinaId == codigoInt) return disc.disciplinaId;
        }
      }
    }

    // Fallback: match pelo nome
    if (entry.disciplina != null && entry.disciplina!.isNotEmpty) {
      final nomePdf = _normalizarNome(entry.disciplina!);

      for (final disc in disciplinas) {
        final nomeApi = _normalizarNome(disc.disciplinaNome);
        if (nomePdf == nomeApi) return disc.disciplinaId;
      }

      for (final disc in disciplinas) {
        final nomeApi = _normalizarNome(disc.disciplinaNome);
        if (nomePdf.contains(nomeApi) || nomeApi.contains(nomePdf)) {
          return disc.disciplinaId;
        }
      }

      for (final disc in disciplinas) {
        final palavrasPdf = nomePdf
            .split(' ')
            .where((w) => w.length >= 4)
            .toSet();
        final palavrasApi = _normalizarNome(
          disc.disciplinaNome,
        ).split(' ').where((w) => w.length >= 4).toSet();
        final overlap = palavrasPdf.intersection(palavrasApi);
        if (overlap.length >= 2 ||
            (overlap.length >= 1 && overlap.length == palavrasApi.length)) {
          return disc.disciplinaId;
        }
      }
    }

    return null;
  }

  static Room _periodoToRoom(_PeriodoInfo p) {
    return Room(
      id: p.compartimentoId ?? '',
      name: p.compartimentoNome ?? '',
      building: p.compartimentoNome,
    );
  }

  static String _normalizarNome(String nome) {
    return nome
        .toLowerCase()
        .replaceAll(RegExp(r'[áàâãä]'), 'a')
        .replaceAll(RegExp(r'[éèêë]'), 'e')
        .replaceAll(RegExp(r'[íìîï]'), 'i')
        .replaceAll(RegExp(r'[óòôõö]'), 'o')
        .replaceAll(RegExp(r'[úùûü]'), 'u')
        .replaceAll(RegExp(r'[ç]'), 'c')
        .replaceAll(RegExp(r'[^a-z0-9]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static bool _matchesDay(_PeriodoInfo periodo, String diaPdf) {
    if (periodo.data == null) return false;

    final diaMap = <String, int>{
      'domingo': 0,
      'segunda': 1,
      'terça': 2,
      'terca': 2,
      'quarta': 3,
      'quinta': 4,
      'sexta': 5,
      'sábado': 6,
      'sabado': 6,
    };

    final diaSemanaPdf = diaMap[diaPdf.toLowerCase()];
    if (diaSemanaPdf == null) return false;

    try {
      final parts = periodo.data!.split('-');
      if (parts.length != 3) return false;

      final date = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
      final apiDay = date.weekday == 7 ? 0 : date.weekday;

      return diaSemanaPdf == apiDay;
    } catch (_) {
      return false;
    }
  }

  static bool _matchesTime(
    _PeriodoInfo periodo,
    String? startPdf,
    String? endPdf,
  ) {
    if (startPdf == null || endPdf == null) return false;
    if (periodo.horaInicio == null || periodo.horaFim == null) return false;

    int toMin(String t) {
      final p = t.split(':');
      return p.length == 2 ? int.parse(p[0]) * 60 + int.parse(p[1]) : 0;
    }

    return toMin(startPdf) < toMin(periodo.horaFim!) &&
        toMin(endPdf) > toMin(periodo.horaInicio!);
  }
}

// ---- DTOs ----

class _DisciplinaAluno {
  final int disciplinaId;
  final String disciplinaNome;
  final String turma;
  final String? periodoLetivo;

  _DisciplinaAluno({
    required this.disciplinaId,
    required this.disciplinaNome,
    required this.turma,
    this.periodoLetivo,
  });

  factory _DisciplinaAluno.fromJson(Map<String, dynamic> json) {
    return _DisciplinaAluno(
      disciplinaId: json['disciplinaId'] is int
          ? json['disciplinaId'] as int
          : int.tryParse(json['disciplinaId']?.toString() ?? '') ?? 0,
      disciplinaNome: json['disciplinaNome'] as String? ?? '',
      turma: json['turma'] as String? ?? '',
      periodoLetivo: json['periodoLetivo'] as String?,
    );
  }
}

class _PeriodoInfo {
  final String? compartimentoId;
  final String? compartimentoNome;
  final String? data;
  final String? horaInicio;
  final String? horaFim;
  final String? turma;

  _PeriodoInfo({
    this.compartimentoId,
    this.compartimentoNome,
    this.data,
    this.horaInicio,
    this.horaFim,
    this.turma,
  });

  factory _PeriodoInfo.fromJson(Map<String, dynamic> json) {
    return _PeriodoInfo(
      compartimentoId: json['compartimentoId']?.toString(),
      compartimentoNome: json['compartimentoNome'] as String?,
      data: json['data'] as String?,
      horaInicio: json['horaInicio'] as String?,
      horaFim: json['horaFim'] as String?,
      turma: json['turma'] as String?,
    );
  }
}
