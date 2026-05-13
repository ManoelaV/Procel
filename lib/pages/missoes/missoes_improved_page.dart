import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/models/missao_model.dart';
import '/providers/missao_provider.dart';
import '/providers/auth_provider.dart';
import '/services/gamification_state.dart';

/// Página melhorada de missões com tabs e gerenciamento completo
class MissoesImprovedPage extends ConsumerStatefulWidget {
  final GamificationState? gamificationState;

  const MissoesImprovedPage({Key? key, this.gamificationState})
    : super(key: key);

  @override
  ConsumerState<MissoesImprovedPage> createState() =>
      _MissoesImprovedPageState();
}

class _MissoesImprovedPageState extends ConsumerState<MissoesImprovedPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authDataAsync = ref.watch(authDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Missões'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Pendentes', icon: Icon(Icons.schedule)),
            Tab(text: 'Em Andamento', icon: Icon(Icons.play_circle)),
            Tab(text: 'Concluídas', icon: Icon(Icons.check_circle)),
            Tab(text: 'Disponíveis', icon: Icon(Icons.add_circle)),
          ],
        ),
      ),
      body: authDataAsync.when(
        data: (authData) {
          if (authData == null) {
            return const Center(child: Text('Você não está autenticado'));
          }

          return TabBarView(
            controller: _tabController,
            children: [
              // Tab 1: Pendentes
              _MissoesTab(
                pessoaId: authData.userId,
                status: AtividadeStatus.pendente,
                gamificationState: widget.gamificationState,
              ),
              // Tab 2: Em Andamento
              _MissoesTab(
                pessoaId: authData.userId,
                status: AtividadeStatus.emAndamento,
                gamificationState: widget.gamificationState,
              ),
              // Tab 3: Concluídas
              _MissoesTab(
                pessoaId: authData.userId,
                status: AtividadeStatus.concluida,
                gamificationState: widget.gamificationState,
              ),
              // Tab 4: Disponíveis para Atribuir
              _CatalogoDeMissoesTab(
                pessoaId: authData.userId,
                gamificationState: widget.gamificationState,
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            Center(child: Text('Erro ao carregar: $error')),
      ),
    );
  }
}

/// Tab com missões de um status específico
class _MissoesTab extends ConsumerWidget {
  final String pessoaId;
  final AtividadeStatus status;
  final GamificationState? gamificationState;

  const _MissoesTab({
    required this.pessoaId,
    required this.status,
    this.gamificationState,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final atividadesAsync = _getAtividadesByStatus(ref, pessoaId, status);

    return ref
        .watch(atividadesAsync)
        .when(
          data: (atividades) {
            if (atividades.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getIconForStatus(status),
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Nenhuma missão ${status.label.toLowerCase()}',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: atividades.length,
              itemBuilder: (context, index) {
                final atividade = atividades[index];
                return _MissaoCard(
                  atividade: atividade,
                  pessoaId: pessoaId,
                  gamificationState: gamificationState,
                  onAtualizar: () {
                    // Invalidar para recarregar
                    ref.invalidate(atividadesPendentesProvider(pessoaId));
                    ref.invalidate(atividadesEmAndamentoProvider(pessoaId));
                    ref.invalidate(atividadesConcluidasProvider(pessoaId));
                  },
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) =>
              Center(child: Text('Erro ao carregar: $error')),
        );
  }

  FutureProvider<List<PessoaMissao>> _getAtividadesByStatus(
    WidgetRef ref,
    String pessoaId,
    AtividadeStatus statusFilter,
  ) {
    switch (statusFilter) {
      case AtividadeStatus.pendente:
        return atividadesPendentesProvider(pessoaId);
      case AtividadeStatus.emAndamento:
        return atividadesEmAndamentoProvider(pessoaId);
      case AtividadeStatus.concluida:
        return atividadesConcluidasProvider(pessoaId);
      case AtividadeStatus.cancelada:
        return FutureProvider((ref) async {
          final service = ref.watch(missaoServiceProvider);
          return service.listarAtividadesDaPessoa(
            pessoaId,
            status: AtividadeStatus.cancelada,
          );
        });
    }
  }

  IconData _getIconForStatus(AtividadeStatus status) {
    switch (status) {
      case AtividadeStatus.pendente:
        return Icons.schedule;
      case AtividadeStatus.emAndamento:
        return Icons.play_circle;
      case AtividadeStatus.concluida:
        return Icons.check_circle;
      case AtividadeStatus.cancelada:
        return Icons.cancel;
    }
  }
}

/// Tab com catálogo de missões disponíveis para atribuição
class _CatalogoDeMissoesTab extends ConsumerWidget {
  final String pessoaId;
  final GamificationState? gamificationState;

  const _CatalogoDeMissoesTab({required this.pessoaId, this.gamificationState});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final missoesAsync = ref.watch(missoesCatalogoProvider);
    final atividadesAsync = ref.watch(atividadesDaPessoaProvider(pessoaId));

    return missoesAsync.when(
      data: (missoes) => atividadesAsync.when(
        data: (atividades) {
          // Filtrar missões que já estão atribuídas
          final missaoIdsAtribuidas = atividades.map((a) => a.missaoId).toSet();
          final missoesDisponiveis = missoes
              .where((m) => !missaoIdsAtribuidas.contains(m.id))
              .toList();

          if (missoesDisponiveis.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.done_all, size: 64, color: Colors.green),
                  const SizedBox(height: 16),
                  Text(
                    'Você tem todas as missões!',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: missoesDisponiveis.length,
            itemBuilder: (context, index) {
              final missao = missoesDisponiveis[index];
              return _MissaoDisponibleCard(
                missao: missao,
                pessoaId: pessoaId,
                onAtribuir: () {
                  ref.invalidate(atividadesDaPessoaProvider(pessoaId));
                  ref.invalidate(missoesCatalogoProvider);
                  ref.invalidate(atividadesPendentesProvider(pessoaId));
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Erro: $error')),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Erro ao carregar: $error')),
    );
  }
}

/// Card para uma missão em andamento/pendente
class _MissaoCard extends ConsumerWidget {
  final PessoaMissao atividade;
  final String pessoaId;
  final GamificationState? gamificationState;
  final VoidCallback onAtualizar;

  const _MissaoCard({
    required this.atividade,
    required this.pessoaId,
    this.gamificationState,
    required this.onAtualizar,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
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
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall,
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
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Atribuída em ${_formatData(atividade.assignedAt)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (atividade.isPending)
                  ElevatedButton(
                    onPressed: () => _iniciarMissao(context, ref),
                    child: const Text('Iniciar'),
                  )
                else if (atividade.isInProgress)
                  ElevatedButton(
                    onPressed: () => _concluirMissao(context, ref),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text('Concluir'),
                  )
                else if (atividade.isCompleted)
                  ElevatedButton(
                    onPressed: null,
                    child: const Text('✓ Concluída'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _iniciarMissao(BuildContext context, WidgetRef ref) async {
    try {
      final notifier = ref.read(missaoNotifierProvider.notifier);
      await notifier.iniciarMissao(pessoaId, atividade.id);
      onAtualizar();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Missão iniciada! Boa sorte!')),
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

  Future<void> _concluirMissao(BuildContext context, WidgetRef ref) async {
    try {
      final notifier = ref.read(missaoNotifierProvider.notifier);
      final concluida = await notifier.concluirMissao(pessoaId, atividade.id);
      gamificationState?.applyMissionCompletion(concluida);
      onAtualizar();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Parabéns! Missão concluída com sucesso!'),
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

  String _formatData(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// Card para uma missão disponível para atribuição
class _MissaoDisponibleCard extends ConsumerWidget {
  final Missao missao;
  final String pessoaId;
  final VoidCallback onAtribuir;

  const _MissaoDisponibleCard({
    required this.missao,
    required this.pessoaId,
    required this.onAtribuir,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              missao.titulo,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (missao.descricao.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  missao.descricao,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Criada em ${_formatData(missao.createdAt)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                ElevatedButton.icon(
                  onPressed: () => _atribuirMissao(context, ref),
                  icon: const Icon(Icons.add),
                  label: const Text('Atribuir'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _atribuirMissao(BuildContext context, WidgetRef ref) async {
    try {
      final notifier = ref.read(missaoNotifierProvider.notifier);
      await notifier.atribuirMissao(pessoaId, missao.id);
      onAtribuir();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Missão atribuída!'),
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

  String _formatData(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
