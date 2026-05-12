import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/models/missao_model.dart';
import '/providers/missao_provider.dart';
import '/providers/auth_provider.dart';

/// Widget para exibir próximas missões em destaque na home
class ProximasMissoesWidget extends ConsumerWidget {
  final int maxMissoes;

  const ProximasMissoesWidget({Key? key, this.maxMissoes = 3})
    : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authDataAsync = ref.watch(authDataProvider);

    return authDataAsync.when(
      data: (authData) {
        if (authData == null) {
          return const SizedBox.shrink();
        }

        final atividadesAsync = ref.watch(
          atividadesEmAndamentoProvider(authData.userId),
        );

        return atividadesAsync.when(
          data: (atividades) {
            if (atividades.isEmpty) {
              return _buildEmptyState(context);
            }

            final proximasMissoes = atividades.take(maxMissoes).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Próximas Missões',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${atividades.where((a) => a.isInProgress).length} em andamento',
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: Colors.blue),
                      ),
                    ],
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: proximasMissoes.length,
                  itemBuilder: (context, index) {
                    final missao = proximasMissoes[index];
                    return _MissaoCardCompacto(
                      atividade: missao,
                      pessoaId: authData.userId,
                    );
                  },
                ),
              ],
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.all(16),
            child: SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
          error: (error, _) => Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Erro ao carregar missões: $error'),
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: SizedBox(
          height: 100,
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, _) => const SizedBox.shrink(),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(Icons.check_circle, size: 48, color: Colors.green[300]),
              const SizedBox(height: 8),
              Text(
                'Nenhuma missão em andamento',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Acesse a aba de missões para começar uma nova!',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Card compacto para exibir uma missão na home
class _MissaoCardCompacto extends ConsumerWidget {
  final PessoaMissao atividade;
  final String pessoaId;

  const _MissaoCardCompacto({required this.atividade, required this.pessoaId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Ícone de status
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getStatusColor(atividade.status).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.play_circle,
                  color: _getStatusColor(atividade.status),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              // Conteúdo
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      atividade.missaoTitulo ?? 'Missão',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (atividade.missaoDescricao != null &&
                        atividade.missaoDescricao!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          atividade.missaoDescricao!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Botão de ação
              _buildBotaoAcao(context, ref),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBotaoAcao(BuildContext context, WidgetRef ref) {
    if (atividade.isPending) {
      return TextButton(
        onPressed: () => _iniciarMissao(context, ref),
        child: const Text('Iniciar'),
      );
    } else if (atividade.isInProgress) {
      return TextButton(
        onPressed: () => _concluirMissao(context, ref),
        style: TextButton.styleFrom(foregroundColor: Colors.green),
        child: const Text('Concluir'),
      );
    } else if (atividade.isCompleted) {
      return Chip(
        label: const Text('✓'),
        backgroundColor: Colors.green.withOpacity(0.2),
      );
    }
    return const SizedBox.shrink();
  }

  Future<void> _iniciarMissao(BuildContext context, WidgetRef ref) async {
    try {
      final notifier = ref.read(missaoNotifierProvider.notifier);
      await notifier.iniciarMissao(pessoaId, atividade.id);
      ref.invalidate(atividadesEmAndamentoProvider(pessoaId));
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
      await notifier.concluirMissao(pessoaId, atividade.id);
      ref.invalidate(atividadesEmAndamentoProvider(pessoaId));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Missão concluída!'),
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
