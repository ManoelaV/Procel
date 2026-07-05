import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/providers/missao_provider.dart';
import '/providers/auth_provider.dart';

/// Widget que exibe um resumo visual das missões (contadores por status)
class ResumoMissoesWidget extends ConsumerWidget {
  const ResumoMissoesWidget({Key? key}) : super(key: key);

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
            final contadores = {
              'total': atividades.length,
              'pendentes': atividades.where((a) => a.isPending).length,
              'em_andamento': atividades.where((a) => a.isInProgress).length,
              'concluidas': atividades.where((a) => a.isCompleted).length,
            };

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Resumo de Missões',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _ContadorCard(
                        icone: Icons.schedule,
                        cor: Colors.orange,
                        label: 'Pendentes',
                        valor: contadores['pendentes'] ?? 0,
                      ),
                      _ContadorCard(
                        icone: Icons.play_circle,
                        cor: Colors.blue,
                        label: 'Em Andamento',
                        valor: contadores['em_andamento'] ?? 0,
                      ),
                      _ContadorCard(
                        icone: Icons.check_circle,
                        cor: Colors.green,
                        label: 'Concluídas',
                        valor: contadores['concluidas'] ?? 0,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _BarraProgresso(
                    total: contadores['total'] ?? 1,
                    concluidas: contadores['concluidas'] ?? 0,
                  ),
                ],
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
          error: (error, _) => Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Não foi possível carregar seu resumo de atividades.'),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

/// Card individual mostrando um contador
class _ContadorCard extends StatelessWidget {
  final IconData icone;
  final Color cor;
  final String label;
  final int valor;

  const _ContadorCard({
    required this.icone,
    required this.cor,
    required this.label,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icone, color: cor, size: 32),
              const SizedBox(height: 8),
              Text(
                '$valor',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: cor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Barra de progresso visual de conclusão de missões
class _BarraProgresso extends StatelessWidget {
  final int total;
  final int concluidas;

  const _BarraProgresso({required this.total, required this.concluidas});

  @override
  Widget build(BuildContext context) {
    final percentual = total > 0 ? concluidas / total : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progresso',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              '${(percentual * 100).toStringAsFixed(0)}% ($concluidas/$total)',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: percentual,
            minHeight: 8,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              percentual >= 1.0 ? Colors.green : Colors.blue,
            ),
          ),
        ),
      ],
    );
  }
}
