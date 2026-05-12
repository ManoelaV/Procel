import 'package:dio/dio.dart';
import '/models/missao_model.dart';
import '/config/api_config.dart';

/// Service para gerenciar missões via API
class MissaoService {
  final Dio _dio;

  MissaoService({Dio? dio}) : _dio = dio ?? Dio();

  /// Lista todas as missões ativas
  Future<List<Missao>> listarMissoes({bool? ativo}) async {
    try {
      final params = <String, dynamic>{};
      if (ativo != null) {
        params['ativo'] = ativo;
      }

      final response = await _dio.get(
        '${ApiConfig.baseUrl}/api/missoes',
        queryParameters: params,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final missoes = (data is List)
            ? data.map((m) => Missao.fromJson(m as Map<String, dynamic>)).toList()
            : [];
        return missoes;
      } else {
        throw Exception('Erro ao listar missões: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Erro de conexão ao listar missões: ${e.message}');
    } catch (e) {
      throw Exception('Erro ao listar missões: $e');
    }
  }

  /// Obtém uma missão específica
  Future<Missao> obterMissao(String missaoId) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.baseUrl}/api/missoes/$missaoId',
      );

      if (response.statusCode == 200) {
        return Missao.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Erro ao obter missão: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Erro de conexão ao obter missão: ${e.message}');
    } catch (e) {
      throw Exception('Erro ao obter missão: $e');
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

      final response = await _dio.get(
        '${ApiConfig.baseUrl}/api/pessoas/$pessoaId/atividades',
        queryParameters: params,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final atividades = (data is List)
            ? data.map((a) => PessoaMissao.fromJson(a as Map<String, dynamic>)).toList()
            : [];
        return atividades;
      } else {
        throw Exception('Erro ao listar atividades: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Erro de conexão ao listar atividades: ${e.message}');
    } catch (e) {
      throw Exception('Erro ao listar atividades: $e');
    }
  }

  /// Obtém uma atividade específica
  Future<PessoaMissao> obterAtividade(String pessoaId, String atividadeId) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.baseUrl}/api/pessoas/$pessoaId/atividades/$atividadeId',
      );

      if (response.statusCode == 200) {
        return PessoaMissao.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Erro ao obter atividade: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Erro de conexão ao obter atividade: ${e.message}');
    } catch (e) {
      throw Exception('Erro ao obter atividade: $e');
    }
  }

  /// Atribui uma missão a uma pessoa
  Future<PessoaMissao> atribuirMissaoAPessoa(
    String pessoaId,
    AtribuirMissaoRequest request,
  ) async {
    try {
      final response = await _dio.post(
        '${ApiConfig.baseUrl}/api/pessoas/$pessoaId/atividades',
        data: request.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return PessoaMissao.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Erro ao atribuir missão: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Erro de conexão ao atribuir missão: ${e.message}');
    } catch (e) {
      throw Exception('Erro ao atribuir missão: $e');
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
      final response = await _dio.put(
        '${ApiConfig.baseUrl}/api/pessoas/$pessoaId/atividades/$atividadeId',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        return PessoaMissao.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Erro ao atualizar atividade: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Erro de conexão ao atualizar atividade: ${e.message}');
    } catch (e) {
      throw Exception('Erro ao atualizar atividade: $e');
    }
  }

  /// Inicia uma missão (marca como EM_ANDAMENTO)
  Future<PessoaMissao> iniciarMissao(String pessoaId, String atividadeId) async {
    final request = UpdateAtividadeRequest(
      status: AtividadeStatus.emAndamento,
      startedAt: DateTime.now(),
    );
    return atualizarAtividade(pessoaId, atividadeId, request);
  }

  /// Conclui uma missão (marca como CONCLUIDA)
  Future<PessoaMissao> concluirMissao(String pessoaId, String atividadeId) async {
    final request = UpdateAtividadeRequest(
      status: AtividadeStatus.concluida,
      completedAt: DateTime.now(),
    );
    return atualizarAtividade(pessoaId, atividadeId, request);
  }

  /// Cancela uma atividade
  Future<PessoaMissao> cancelarAtividade(String pessoaId, String atividadeId) async {
    final request = UpdateAtividadeRequest(
      status: AtividadeStatus.cancelada,
    );
    return atualizarAtividade(pessoaId, atividadeId, request);
  }

  /// Remove uma atividade
  Future<void> removerAtividade(String pessoaId, String atividadeId) async {
    try {
      final response = await _dio.delete(
        '${ApiConfig.baseUrl}/api/pessoas/$pessoaId/atividades/$atividadeId',
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Erro ao remover atividade: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Erro de conexão ao remover atividade: ${e.message}');
    } catch (e) {
      throw Exception('Erro ao remover atividade: $e');
    }
  }
}
