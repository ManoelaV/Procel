import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart';
import '/models/missao_model.dart';
import '/providers/missao_provider.dart';
import '/providers/auth_provider.dart';
import '/services/gamification_state.dart';

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
          atividadesDaPessoaProvider(authData.userId),
        );

        return atividadesAsync.when(
          data: (atividades) {
            if (atividades.isEmpty) {
              return _buildEmptyState(context);
            }

            final proximasMissoes =
                atividades
                    .where(
                      (atividade) =>
                          atividade.status == AtividadeStatus.pendente ||
                          atividade.status == AtividadeStatus.emAndamento,
                    )
                    .toList()
                  ..sort((a, b) {
                    int rank(AtividadeStatus status) {
                      switch (status) {
                        case AtividadeStatus.pendente:
                          return 0;
                        case AtividadeStatus.emAndamento:
                          return 1;
                        case AtividadeStatus.concluida:
                          return 2;
                        case AtividadeStatus.cancelada:
                          return 3;
                      }
                    }

                    final diff = rank(a.status).compareTo(rank(b.status));
                    if (diff != 0) return diff;
                    return a.assignedAt.compareTo(b.assignedAt);
                  });

            final missaoCount = proximasMissoes.length;
            final totalVisiveis = proximasMissoes.length;
            final listaVisivel = proximasMissoes.take(maxMissoes).toList();

            if (totalVisiveis == 0) {
              return _buildEmptyState(context);
            }

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
                        '$missaoCount pendentes/em andamento',
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
                  itemCount: listaVisivel.length,
                  itemBuilder: (context, index) {
                    final missao = listaVisivel[index];
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
                'Nenhuma missão pendente ou em andamento',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Acesse a aba de missões para iniciar ou continuar uma missão.',
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
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE3ECEA)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          atividade.missaoTitulo ?? 'Missão',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          atividade.missaoDescricao ?? 'Missão atribuída',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: const Color(0xFF7A8A88)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  _buildIconBadge(),
                ],
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: _progressValue,
                  minHeight: 8,
                  backgroundColor: const Color(0xFFE8EEED),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getStatusColor(atividade.status),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (atividade.missaoValue > 0)
                    _RewardChip(
                      label: '${atividade.missaoValue} XP',
                      background: const Color(0xFFEAF6EA),
                      foreground: const Color(0xFF2E9D55),
                    ),
                  if (atividade.missaoValue > 0)
                    _RewardChip(
                      label: '+10 moedas',
                      background: const Color(0xFFFFF3E0),
                      foreground: const Color(0xFFF4A261),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _getActionCallback(context, ref),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A7A6E),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _buttonLabel,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconBadge() {
    final icon = switch (atividade.status) {
      AtividadeStatus.pendente => Icons.lightbulb_outline_rounded,
      AtividadeStatus.emAndamento => Icons.play_circle_fill_rounded,
      AtividadeStatus.concluida => Icons.check_circle_rounded,
      AtividadeStatus.cancelada => Icons.cancel_rounded,
    };

    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: _getStatusColor(atividade.status).withOpacity(0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: _getStatusColor(atividade.status), size: 24),
    );
  }

  double get _progressValue {
    switch (atividade.status) {
      case AtividadeStatus.pendente:
        return 0.18;
      case AtividadeStatus.emAndamento:
        return 0.55;
      case AtividadeStatus.concluida:
        return 1.0;
      case AtividadeStatus.cancelada:
        return 0.0;
    }
  }

  String get _buttonLabel {
    switch (atividade.status) {
      case AtividadeStatus.pendente:
        return 'Começar';
      case AtividadeStatus.emAndamento:
        return 'Continuar';
      case AtividadeStatus.concluida:
        return 'Concluída';
      case AtividadeStatus.cancelada:
        return 'Cancelar';
    }
  }

  VoidCallback? _getActionCallback(BuildContext context, WidgetRef ref) {
    if (atividade.isPending) {
      return () => _iniciarMissao(context, ref);
    } else if (atividade.isInProgress) {
      return () => _concluirMissao(context, ref);
    } else if (atividade.isCompleted) {
      return null;
    }
    return null;
  }

  Widget _RewardChip({
    required String label,
    required Color background,
    required Color foreground,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: foreground,
        ),
      ),
    );
  }

  Future<void> _iniciarMissao(BuildContext context, WidgetRef ref) async {
    try {
      final notifier = ref.read(missaoNotifierProvider.notifier);
      await notifier.iniciarMissao(pessoaId, atividade.id);
      ref.invalidate(atividadesDaPessoaProvider(pessoaId));
      ref.invalidate(atividadesPendentesProvider(pessoaId));
      ref.invalidate(atividadesEmAndamentoProvider(pessoaId));
      ref.invalidate(atividadesConcluidasProvider(pessoaId));
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
      final concluida = await notifier.concluirMissao(pessoaId, atividade.id);
      context.read<GamificationState>().applyMissionCompletion(concluida);
      ref.invalidate(atividadesDaPessoaProvider(pessoaId));
      ref.invalidate(atividadesPendentesProvider(pessoaId));
      ref.invalidate(atividadesEmAndamentoProvider(pessoaId));
      ref.invalidate(atividadesConcluidasProvider(pessoaId));
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
