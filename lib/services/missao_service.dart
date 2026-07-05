import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/models/missao_model.dart';
import '/config/api_config.dart';

/// Service para gerenciar missões via API
class MissaoService {
  final Dio _dio;

  MissaoService({Dio? dio}) : _dio = dio ?? Dio();

  /// Obtém o token de autorização do SharedPreferences
  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('procel_backend_access_token');
  }

  /// Prepara headers com autenticação
  Future<Map<String, dynamic>> _getAuthHeaders() async {
    final token = await _getAuthToken();
    final headers = <String, dynamic>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  /// Lista todas as missões ativas
  Future<List<Missao>> listarMissoes({bool? ativo}) async {
    try {
      final params = <String, dynamic>{};
      if (ativo != null) {
        params['ativo'] = ativo;
      }

      final headers = await _getAuthHeaders();
      final response = await _dio.get(
        '${ApiConfig.baseUrl}/api/missoes',
        queryParameters: params,
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return data
              .cast<Map<String, dynamic>>()
              .map((m) => Missao.fromJson(m))
              .toList();
        }
        return <Missao>[];
      } else {
        throw Exception('Não foi possível carregar as missões.');
      }
    } on DioException catch (e) {
      throw Exception('Não foi possível carregar as missões.');
    } catch (e) {
      throw Exception('Não foi possível carregar as missões.');
    }
  }

  /// Obtém uma missão específica
  Future<Missao> obterMissao(String missaoId) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await _dio.get(
        '${ApiConfig.baseUrl}/api/missoes/$missaoId',
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        return Missao.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Não foi possível abrir a missão.');
      }
    } on DioException catch (e) {
      throw Exception('Não foi possível abrir a missão.');
    } catch (e) {
      throw Exception('Não foi possível abrir a missão.');
    }
  }

  /// Lista todas as atividades (missões atribuídas) de uma pessoa
  Future<List<PessoaMissao>> listarAtividadesDaPessoa(
    String pessoaId, {
    AtividadeStatus? status,
  }) async {
    try {
      final params = <String, dynamic>{};
      if (status != null) {
        params['status'] = status.apiValue;
      }

      final headers = await _getAuthHeaders();
      final response = await _dio.get(
        '${ApiConfig.baseUrl}/api/pessoas/$pessoaId/atividades',
        queryParameters: params,
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return data
              .cast<Map<String, dynamic>>()
              .map((a) => PessoaMissao.fromJson(a))
              .toList();
        }
        return <PessoaMissao>[];
      } else {
        throw Exception('Não foi possível carregar suas atividades.');
      }
    } on DioException catch (e) {
      throw Exception('Não foi possível carregar suas atividades.');
    } catch (e) {
      throw Exception('Não foi possível carregar suas atividades.');
    }
  }

  /// Obtém uma atividade específica
  Future<PessoaMissao> obterAtividade(
    String pessoaId,
    String atividadeId,
  ) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await _dio.get(
        '${ApiConfig.baseUrl}/api/pessoas/$pessoaId/atividades/$atividadeId',
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        return PessoaMissao.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Não foi possível abrir a atividade.');
      }
    } on DioException catch (e) {
      throw Exception('Não foi possível abrir a atividade.');
    } catch (e) {
      throw Exception('Não foi possível abrir a atividade.');
    }
  }

  /// Atribui uma missão a uma pessoa
  Future<PessoaMissao> atribuirMissaoAPessoa(
    String pessoaId,
    AtribuirMissaoRequest request,
  ) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await _dio.post(
        '${ApiConfig.baseUrl}/api/pessoas/$pessoaId/atividades',
        data: request.toJson(),
        options: Options(headers: headers),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return PessoaMissao.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Não foi possível atribuir a missão.');
      }
    } on DioException catch (e) {
      throw Exception('Não foi possível atribuir a missão.');
    } catch (e) {
      throw Exception('Não foi possível atribuir a missão.');
    }
  }

  /// Atualiza o status/timestamps de uma atividade
  /// Isso inclui: iniciar missão, marcar como concluída, etc.
  Future<PessoaMissao> atualizarAtividade(
    String pessoaId,
    String atividadeId,
    UpdateAtividadeRequest request,
  ) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await _dio.put(
        '${ApiConfig.baseUrl}/api/pessoas/$pessoaId/atividades/$atividadeId',
        data: request.toJson(),
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        return PessoaMissao.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Não foi possível atualizar a atividade.');
      }
    } on DioException catch (e) {
      throw Exception('Não foi possível atualizar a atividade.');
    } catch (e) {
      throw Exception('Não foi possível atualizar a atividade.');
    }
  }

  /// Inicia uma missão (marca como EM_ANDAMENTO)
  Future<PessoaMissao> iniciarMissao(
    String pessoaId,
    String atividadeId,
  ) async {
    final request = UpdateAtividadeRequest(
      status: AtividadeStatus.emAndamento,
      startedAt: DateTime.now().toUtc(),
    );
    return atualizarAtividade(pessoaId, atividadeId, request);
  }

  /// Conclui uma missão (marca como CONCLUIDA)
  Future<PessoaMissao> concluirMissao(
    String pessoaId,
    String atividadeId,
  ) async {
    final request = UpdateAtividadeRequest(
      status: AtividadeStatus.concluida,
      completedAt: DateTime.now().toUtc(),
    );
    return atualizarAtividade(pessoaId, atividadeId, request);
  }

  /// Cancela uma atividade
  Future<PessoaMissao> cancelarAtividade(
    String pessoaId,
    String atividadeId,
  ) async {
    final request = UpdateAtividadeRequest(status: AtividadeStatus.cancelada);
    return atualizarAtividade(pessoaId, atividadeId, request);
  }

  /// Remove uma atividade
  Future<void> removerAtividade(String pessoaId, String atividadeId) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await _dio.delete(
        '${ApiConfig.baseUrl}/api/pessoas/$pessoaId/atividades/$atividadeId',
        options: Options(headers: headers),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Não foi possível remover a atividade.');
      }
    } on DioException catch (e) {
      throw Exception('Não foi possível remover a atividade.');
    } catch (e) {
      throw Exception('Não foi possível remover a atividade.');
    }
  }
}
