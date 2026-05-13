import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart';
import '/models/missao_model.dart';
import '/providers/missao_provider.dart';
import '/services/gamification_state.dart';

/// Exemplo de widget para listar e gerenciar missões
class MissoesListaWidget extends ConsumerWidget {
  final String pessoaId;
  final GamificationState? gamificationState;

  const MissoesListaWidget({
    Key? key,
    required this.pessoaId,
    this.gamificationState,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Carrega as atividades da pessoa
    final atividadesAsync = ref.watch(atividadesDaPessoaProvider(pessoaId));

    return atividadesAsync.when(
      data: (atividades) {
        if (atividades.isEmpty) {
          return const Center(child: Text('Nenhuma missão atribuída'));
        }

        return ListView.builder(
          itemCount: atividades.length,
          itemBuilder: (context, index) {
            final atividade = atividades[index];
            return MissaoItemCard(
              atividade: atividade,
              pessoaId: pessoaId,
              gamificationState: gamificationState,
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) =>
          Center(child: Text('Erro ao carregar missões: $error')),
    );
  }
}

/// Card para exibir uma missão individual
class MissaoItemCard extends ConsumerWidget {
  final PessoaMissao atividade;
  final String pessoaId;
  final GamificationState? gamificationState;

  const MissaoItemCard({
    Key? key,
    required this.atividade,
    required this.pessoaId,
    this.gamificationState,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        atividade.missaoTitulo ?? 'Missão',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (atividade.missaoDescricao != null &&
                          atividade.missaoDescricao!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            atividade.missaoDescricao!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(atividade.status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    atividade.status.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildButtons(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildButtons(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (atividade.isPending)
          ElevatedButton(
            onPressed: () => _iniciarMissao(context, ref),
            child: const Text('Iniciar'),
          ),
        if (atividade.isInProgress)
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: ElevatedButton(
              onPressed: () => _concluirMissao(context, ref),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Concluir'),
            ),
          ),
        if (atividade.isCompleted)
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 8),
                  Text(
                    'Concluída',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _iniciarMissao(BuildContext context, WidgetRef ref) async {
    try {
      final notifier = ref.read(missaoNotifierProvider.notifier);
      await notifier.iniciarMissao(pessoaId, atividade.id);

      // Recarrega as atividades
      ref.invalidate(atividadesDaPessoaProvider(pessoaId));

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Missão iniciada!')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro: $e')));
      }
    }
  }

  Future<void> _concluirMissao(BuildContext context, WidgetRef ref) async {
    try {
      final notifier = ref.read(missaoNotifierProvider.notifier);
      final concluida = await notifier.concluirMissao(
        pessoaId,
        atividade.id,
        rewardXp: 10,
        rewardCoins: 5,
      );

      context.read<GamificationState>().applyMissionCompletion(concluida);

      // Recarrega as atividades
      ref.invalidate(atividadesDaPessoaProvider(pessoaId));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Parabéns! Missão concluída! +10 XP +5 Moedas'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro: $e')));
      }
    }
  }

  Color _getStatusColor(AtividadeStatus status) {
    switch (status) {
      case AtividadeStatus.pendente:
        return Colors.orange;
      case AtividadeStatus.emAndamento:
        return Colors.blue;
      case AtividadeStatus.concluida:
        return Colors.green;
      case AtividadeStatus.cancelada:
        return Colors.red;
    }
  }
}
