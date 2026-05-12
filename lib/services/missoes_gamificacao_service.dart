import 'package:flutter/material.dart';
import '/models/missao_model.dart';
import '/services/missao_service.dart';
import '/services/gamification_state.dart';

/// Service para integrar missões do backend com gamificação
class MissoesGamificacaoService {
  final MissaoService missaoService;
  final GamificationState gamificationState;

  MissoesGamificacaoService({
    required this.missaoService,
    required this.gamificationState,
  });

  /// Converte PessoaMissao para GamificationMission (compatível com UI existente)
  GamificationMission pessoaMissaoToGamification(PessoaMissao atividade) {
    final isCompleted = atividade.isCompleted;
    final isInProgress = atividade.isInProgress;

    // Estimar progresso baseado no status
    final progress = isCompleted
        ? 1.0
        : isInProgress
            ? 0.5
            : 0.0;

    // Botão de ação apropriado
    final buttonLabel = isCompleted
        ? 'Concluída'
        : isInProgress
            ? 'Continuar'
            : 'Começar';

    return GamificationMission(
      key: atividade.missaoId,
      title: atividade.missaoTitulo ?? 'Missão',
      icon: _getIconForMission(atividade.missaoTitulo),
      description: atividade.missaoDescricao ?? '',
      rewardXp: 25, // Padrão, pode ser customizado no backend
      rewardCoins: 10,
      progress: progress,
      buttonLabel: buttonLabel,
      completed: isCompleted,
    );
  }

  /// Obtém ícone baseado no título da missão
  String _getIconForMission(String? titulo) {
    if (titulo == null) return '🎯';

    final lower = titulo.toLowerCase();
    if (lower.contains('luz') || lower.contains('ilumina')) return '💡';
    if (lower.contains('temperatura') || lower.contains('clima')) return '❄️';
    if (lower.contains('sensor') || lower.contains('verificar')) return '🔍';
    if (lower.contains('repouso') || lower.contains('deslig')) return '🔌';
    if (lower.contains('educar') || lower.contains('compartilh')) return '💬';
    if (lower.contains('energia')) return '⚡';
    if (lower.contains('água')) return '💧';
    if (lower.contains('papel')) return '📄';
    if (lower.contains('transporte')) return '🚌';

    return '🎯';
  }

  /// Iniciar uma missão
  Future<PessoaMissao> iniciarMissao(
    String pessoaId,
    String atividadeId,
  ) async {
    final resultado = await missaoService.iniciarMissao(pessoaId, atividadeId);

    // Recarregar gamificação do backend
    await gamificationState.loadFromBackend();

    return resultado;
  }

  /// Concluir uma missão e atualizar pontos
  Future<PessoaMissao> concluirMissao(
    String pessoaId,
    String atividadeId, {
    int rewardXp = 25,
    int rewardCoins = 10,
  }) async {
    final resultado = await missaoService.concluirMissao(pessoaId, atividadeId);

    // Recarregar gamificação para pegar pontos atualizados
    await gamificationState.loadFromBackend();

    return resultado;
  }

  /// Cancelar uma atividade
  Future<PessoaMissao> cancelarAtividade(
    String pessoaId,
    String atividadeId,
  ) async {
    final resultado =
        await missaoService.cancelarAtividade(pessoaId, atividadeId);

    // Recarregar gamificação
    await gamificationState.loadFromBackend();

    return resultado;
  }

  /// Atribuir uma nova missão a uma pessoa
  Future<PessoaMissao> atribuirMissao(
    String pessoaId,
    String missaoId,
  ) async {
    final request = AtribuirMissaoRequest(missaoId: missaoId);
    final resultado = await missaoService.atribuirMissaoAPessoa(pessoaId, request);

    // Recarregar gamificação
    await gamificationState.loadFromBackend();

    return resultado;
  }

  /// Listar missões disponíveis para atribuição
  Future<List<Missao>> listarMissoesDisponiveis() async {
    return missaoService.listarMissoes(ativo: true);
  }

  /// Listar atividades atuais de uma pessoa
  Future<List<PessoaMissao>> listarAtividadesAtuais(String pessoaId) async {
    return missaoService.listarAtividadesDaPessoa(pessoaId);
  }

  /// Obter atividades filtradas por status
  Future<List<PessoaMissao>> obterAtividadesPorStatus(
    String pessoaId,
    AtividadeStatus status,
  ) async {
    return missaoService.listarAtividadesDaPessoa(
      pessoaId,
      status: status,
    );
  }

  /// Obter resumo de atividades (contadores)
  Future<Map<String, int>> obterResumoAtividades(String pessoaId) async {
    final todasAtividades =
        await missaoService.listarAtividadesDaPessoa(pessoaId);

    return {
      'total': todasAtividades.length,
      'pendentes':
          todasAtividades.where((a) => a.isPending).length,
      'em_andamento':
          todasAtividades.where((a) => a.isInProgress).length,
      'concluidas': todasAtividades.where((a) => a.isCompleted).length,
      'canceladas':
          todasAtividades.where((a) => a.isCanceled).length,
    };
  }
}
