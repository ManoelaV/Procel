import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/models/missao_model.dart';
import '/services/missao_service.dart';
import '/services/gamification_state.dart';

/// Provider para o serviço de missões
final missaoServiceProvider = Provider((ref) => MissaoService());

/// Provider para listar todas as missões ativas
final missoesCatalogoProvider = FutureProvider<List<Missao>>((ref) async {
  final service = ref.watch(missaoServiceProvider);
  return service.listarMissoes(ativo: true);
});

/// Provider para listar atividades de uma pessoa
final atividadesDaPessoaProvider =
    FutureProvider.family<List<PessoaMissao>, String>((ref, pessoaId) async {
      final service = ref.watch(missaoServiceProvider);
      return service.listarAtividadesDaPessoa(pessoaId);
    });

/// Provider para atividades pendentes de uma pessoa
final atividadesPendentesProvider =
    FutureProvider.family<List<PessoaMissao>, String>((ref, pessoaId) async {
      final service = ref.watch(missaoServiceProvider);
      return service.listarAtividadesDaPessoa(
        pessoaId,
        status: AtividadeStatus.pendente,
      );
    });

/// Provider para atividades em andamento de uma pessoa
final atividadesEmAndamentoProvider =
    FutureProvider.family<List<PessoaMissao>, String>((ref, pessoaId) async {
      final service = ref.watch(missaoServiceProvider);
      return service.listarAtividadesDaPessoa(
        pessoaId,
        status: AtividadeStatus.emAndamento,
      );
    });

/// Provider para atividades concluídas de uma pessoa
final atividadesConcluidasProvider =
    FutureProvider.family<List<PessoaMissao>, String>((ref, pessoaId) async {
      final service = ref.watch(missaoServiceProvider);
      return service.listarAtividadesDaPessoa(
        pessoaId,
        status: AtividadeStatus.concluida,
      );
    });

/// State notifier para gerenciar ações de missões
class MissaoNotifier extends StateNotifier<AsyncValue<void>> {
  final MissaoService service;
  final GamificationState? gamificationState;

  MissaoNotifier({required this.service, this.gamificationState})
    : super(const AsyncValue.data(null));

  /// Inicia uma missão
  Future<PessoaMissao> iniciarMissao(
    String pessoaId,
    String atividadeId,
  ) async {
    state = const AsyncValue.loading();
    try {
      final resultado = await service.iniciarMissao(pessoaId, atividadeId);
      state = const AsyncValue.data(null);
      return resultado;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Conclui uma missão e atualiza gamificação
  Future<PessoaMissao> concluirMissao(
    String pessoaId,
    String atividadeId, {
    int rewardXp = 10,
    int rewardCoins = 5,
  }) async {
    state = const AsyncValue.loading();
    try {
      final resultado = await service.concluirMissao(pessoaId, atividadeId);

      // Atualiza pontuação de gamificação se disponível
      if (gamificationState != null) {
        // A gamificação será atualizada ao chamar loadFromBackend
        // Você pode também adicionar lógica específica aqui
        await gamificationState!.loadFromBackend();
      }

      state = const AsyncValue.data(null);
      return resultado;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Cancela uma atividade
  Future<PessoaMissao> cancelarAtividade(
    String pessoaId,
    String atividadeId,
  ) async {
    state = const AsyncValue.loading();
    try {
      final resultado = await service.cancelarAtividade(pessoaId, atividadeId);
      state = const AsyncValue.data(null);
      return resultado;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Remove uma atividade
  Future<void> removerAtividade(String pessoaId, String atividadeId) async {
    state = const AsyncValue.loading();
    try {
      await service.removerAtividade(pessoaId, atividadeId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Atribui uma missão a uma pessoa
  Future<PessoaMissao> atribuirMissao(String pessoaId, String missaoId) async {
    state = const AsyncValue.loading();
    try {
      final request = AtribuirMissaoRequest(missaoId: missaoId);
      final resultado = await service.atribuirMissaoAPessoa(pessoaId, request);
      state = const AsyncValue.data(null);
      return resultado;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

/// Provider para o notifier de ações de missões
final missaoNotifierProvider =
    StateNotifierProvider<MissaoNotifier, AsyncValue<void>>((ref) {
      final service = ref.watch(missaoServiceProvider);
      // Se quiser integrar com gamificação, você pode injetar aqui
      return MissaoNotifier(service: service);
    });
