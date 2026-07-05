import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/api_config.dart';
import '../../models/room_model.dart';
import '../../models/timetable_entry.dart';
import '../../pages/backend_auth_screen.dart';
import '../../services/backend_session.dart';
import '../../services/pdf_parser_service.dart';

class UploadPdfRoomsWidget extends StatefulWidget {
  const UploadPdfRoomsWidget({super.key});

  @override
  State<UploadPdfRoomsWidget> createState() => _UploadPdfRoomsWidgetState();
}

class _UploadPdfRoomsWidgetState extends State<UploadPdfRoomsWidget> {
  String? _status;
  List<Room> _rooms = [];
  bool _needsBackendLogin = false;
  bool _isProcessing = false;

  Future<void> _pickAndProcessPdf() async {
    if (_isProcessing || _needsBackendLogin) {
      return;
    }

    try {
      setState(() {
        _isProcessing = true;
        _status = 'Selecionando arquivo...';
        _rooms = [];
        _needsBackendLogin = false;
      });

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (result == null) {
        setState(() => _status = 'Seleção cancelada pelo usuário.');
        return;
      }

      final fileBytes = result.files.single.bytes;
      if (fileBytes == null) {
        setState(() => _status = 'Não foi possível ler o arquivo selecionado.');
        return;
      }

      setState(() => _status = 'Extraindo texto do PDF...');
      final text = await PdfParserService.extractTextFromBytes(fileBytes);

      setState(() => _status = 'Parseando horários do PDF...');
      final entries = PdfParserService.parseTimetableFromText(text);

      if (entries.isEmpty) {
        setState(() => _status = 'Nenhuma disciplina encontrada no PDF.');
        return;
      }

      setState(() => _status = 'Enviando dados para o servidor...');
      final mapping = await _fetchRoomsForSchedule(entries);

      setState(() {
        _status = 'Mapeamento concluído com sucesso!';
        _rooms = mapping.values.whereType<Room>().toList();
      });
      _showMappingResults(mapping);
    } catch (e) {
      final needsBackendLogin = e is _BackendLoginRequiredException;
      setState(() {
        _needsBackendLogin = needsBackendLogin;
        _status = _friendlyError(e);
      });
      print('Erro no upload de PDF: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  String _friendlyError(Object error) =>
      error.toString().replaceFirst('Exception: ', '');

  Future<Map<TimetableEntry, Room?>> _fetchRoomsForSchedule(
    List<TimetableEntry> entries,
  ) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}${ApiConfig.API_PREFIX}/schedule/rooms',
    );
    final body = jsonEncode({
      'entries': entries.map((e) => e.toJson()).toList(),
    });

    // Usa a mesma sessao salva pelo login do back-end.
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

    final headers = <String, String>{'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    } else {
      throw const _BackendLoginRequiredException(
        'Login do back-end ausente. Entre novamente no app e tente enviar o PDF.',
      );
    }

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode != 200) {
      if (response.statusCode == 401) {
        if (await _hasValidBackendSession(headers)) {
          throw const _ScheduleRoomsEndpointException(
            'O servidor aceitou seu login, mas nao disponibilizou o endpoint /api/schedule/rooms. Verifique ou publique esse endpoint no back-end.',
          );
        }

        await BackendSession.clear();
        throw const _BackendLoginRequiredException(
          'Sessao expirada. Entre novamente no app e tente enviar o PDF.',
        );
      }

      throw Exception(
        'Falha ao buscar salas: ${response.statusCode} - ${response.body}',
      );
    }

    final Map<String, dynamic> data = jsonDecode(response.body);
    final List<dynamic> roomsData = data['rooms'] ?? [];
    if (roomsData.length != entries.length) {
      throw Exception(
        'Número de salas retornado (${roomsData.length}) não coincide com o número de entradas (${entries.length})',
      );
    }

    Map<TimetableEntry, Room?> result = {};
    for (int i = 0; i < entries.length; i++) {
      final entry = entries[i];
      final roomJson = roomsData[i];
      Room? room;
      if (roomJson != null) {
        room = Room.fromJson(roomJson);
      }
      result[entry] = room;
    }
    return result;
  }

  Future<bool> _hasValidBackendSession(Map<String, String> headers) async {
    try {
      final uri = Uri.parse(
        '${ApiConfig.baseUrl}${ApiConfig.API_PREFIX}/missoes',
      );
      final response = await http
          .get(uri, headers: headers)
          .timeout(Duration(seconds: ApiConfig.TIMEOUT_SECONDS));
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      return false;
    }
  }

  void _showMappingResults(Map<TimetableEntry, Room?> mapping) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SizedBox(
        height: 400,
        child: ListView(
          children: mapping.entries.map((e) {
            final entry = e.key;
            final room = e.value;
            return ListTile(
              title: Text(entry.toString()),
              subtitle: Text(
                room != null ? 'Sala: ${room.name}' : 'Sala não encontrada',
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<void> _goToBackendLogin() async {
    await BackendSession.clear();
    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const BackendAuthScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton.icon(
          onPressed: _isProcessing || _needsBackendLogin
              ? null
              : _pickAndProcessPdf,
          icon: _isProcessing
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.upload_file),
          label: const Text('Enviar PDF de horários'),
        ),
        const SizedBox(height: 12),
        if (_status != null) Text(_status!),
        if (_needsBackendLogin) ...[
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _goToBackendLogin,
            icon: const Icon(Icons.login),
            label: const Text('Entrar novamente'),
          ),
        ],
        const SizedBox(height: 12),
        if (_rooms.isNotEmpty)
          ..._rooms.map(
            (r) => ListTile(
              title: Text(r.name),
              subtitle: Text('${r.building ?? ''} ${r.floor ?? ''}'),
            ),
          ),
      ],
    );
  }
}

class _BackendLoginRequiredException implements Exception {
  const _BackendLoginRequiredException(this.message);

  final String message;

  @override
  String toString() => message;
}

class _ScheduleRoomsEndpointException implements Exception {
  const _ScheduleRoomsEndpointException(this.message);

  final String message;

  @override
  String toString() => message;
}
