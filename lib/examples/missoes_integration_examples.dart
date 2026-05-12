/// EXEMPLO PRÁTICO: Como Integrar o Sistema de Missões no App PROCEL
///
/// Este arquivo mostra exemplos concretos de como usar os novos componentes
/// e providers de missões em diferentes telas do app.
///
/// ============================================================================

// ============================================================================
// 1. EXEMPLO NA HOME PAGE
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:procel/components/resumo_missoes_widget.dart';
import 'package:procel/components/proximas_missoes_widget.dart';
import 'package:procel/pages/missoes/missoes_improved_page.dart';
import 'package:procel/services/gamification_state.dart';

/// Home page melhorada com missões integradas
class HomePageExemplo extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PROCEL - Home'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Seção 1: Status do usuário (XP, Level, etc)
            _buildUserStatusCard(context, ref),
            const SizedBox(height: 24),

            // Seção 2: Resumo de missões com contadores
            ResumoMissoesWidget(),
            const SizedBox(height: 24),

            // Seção 3: Próximas 3 missões em destaque
            ProximasMissoesWidget(maxMissoes: 3),
            const SizedBox(height: 24),

            // Seção 4: Botão para abrir página completa de missões
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MissoesImprovedPage(
                        gamificationState:
                            context.read<GamificationState>(),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.list),
                label: const Text('Ver Todas as Missões'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildUserStatusCard(BuildContext context, WidgetRef ref) {
    // Obter status de gamificação (já existente no app)
    final gamificationState = context.watch<GamificationState>();

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              gamificationState.displayName,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              gamificationState.levelLabel,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: Colors.blue),
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: gamificationState.levelProgress,
              minHeight: 8,
            ),
            const SizedBox(height: 8),
            Text(
              gamificationState.xpLabel,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 2. EXEMPLO DE TELA CUSTOMIZADA DE MISSÕES
// ============================================================================

/// Tela customizada mostrando apenas missões em andamento com ações
class MinhasMissoesCustomPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Obter userId do usuário logado
    final authDataAsync = ref.watch(authDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Missões Ativas'),
      ),
      body: authDataAsync.when(
        data: (authData) {
          if (authData == null) {
            return const Center(
              child: Text('Você não está autenticado'),
            );
          }

          // Carregar missões em andamento
          final atividadesAsync = ref.watch(
            atividadesEmAndamentoProvider(authData.userId),
          );

          return atividadesAsync.when(
            data: (atividades) {
              if (atividades.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle, size: 64),
                      const SizedBox(height: 16),
                      const Text('Nenhuma missão em andamento'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          // Voltar para página de missões para atribuir novas
                          Navigator.pop(context);
                        },
                        child: const Text('Atribuir Nova Missão'),
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
                  return _buildMissaoCard(
                    context,
                    ref,
                    atividade,
                    authData.userId,
                  );
                },
              );
            },
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Erro: $e')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildMissaoCard(
    BuildContext context,
    WidgetRef ref,
    PessoaMissao atividade,
    String pessoaId,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        atividade.missaoTitulo ?? 'Missão',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      if (atividade.missaoDescricao != null)
                        Text(
                          atividade.missaoDescricao!,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
                Chip(
                  label: const Text('Em Andamento'),
                  backgroundColor: Colors.blue.withOpacity(0.2),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Tempo decorrido
            if (atividade.startedAt != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'Iniciada há ${_tempoDecorrido(atividade.startedAt!)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                ),
              ),

            // Botão de conclusão
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () =>
                    _concluirMissao(context, ref, pessoaId, atividade),
                icon: const Icon(Icons.check),
                label: const Text('Concluir Missão'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _tempoDecorrido(DateTime startedAt) {
    final duracao = DateTime.now().difference(startedAt);
    if (duracao.inHours > 0) {
      return '${duracao.inHours}h';
    } else if (duracao.inMinutes > 0) {
      return '${duracao.inMinutes}min';
    } else {
      return 'alguns segundos';
    }
  }

  Future<void> _concluirMissao(
    BuildContext context,
    WidgetRef ref,
    String pessoaId,
    PessoaMissao atividade,
  ) async {
    // Mostrar confirmação
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Concluir Missão?'),
        content: Text(
          'Tem certeza que deseja concluir "${atividade.missaoTitulo}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sim, Concluir'),
          ),
        ],
      ),
    );

    if (confirmou != true) return;

    try {
      final notifier = ref.read(missaoNotifierProvider.notifier);
      await notifier.concluirMissao(pessoaId, atividade.id);

      // Recarregar dados
      ref.invalidate(atividadesEmAndamentoProvider(pessoaId));

      // Sincronizar gamificação
      if (context.mounted) {
        context.read<GamificationState>().loadFromBackend();
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Parabéns! Missão concluída com sucesso!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao concluir missão: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// ============================================================================
// 3. EXEMPLO DE NOTIFICAÇÃO AO CONCLUIR MISSÃO
// ============================================================================

/// Widget que mostra uma animação/notificação ao concluir uma missão
class MissaoConcluídaNotificacao extends StatefulWidget {
  final String titulo;
  final int xpGanho;
  final int coinGanho;

  const MissaoConcluídaNotificacao({
    required this.titulo,
    required this.xpGanho,
    required this.coinGanho,
  });

  @override
  State<MissaoConcluídaNotificacao> createState() =>
      _MissaoConcluídaNotificacaoState();
}

class _MissaoConcluídaNotificacaoState
    extends State<MissaoConcluídaNotificacao>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _animationController.forward();

    // Fechar automaticamente após 4 segundos
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.5, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
      ),
      child: Dialog(
        backgroundColor: Colors.green[400],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, size: 80, color: Colors.white),
              const SizedBox(height: 16),
              Text(
                'Missão Concluída!',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.titulo,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      const Icon(Icons.star, color: Colors.yellow, size: 32),
                      const SizedBox(height: 4),
                      Text(
                        '+${widget.xpGanho} XP',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 32),
                  Column(
                    children: [
                      const Icon(Icons.monetization_on, color: Colors.yellow, size: 32),
                      const SizedBox(height: 4),
                      Text(
                        '+${widget.coinGanho} Moedas',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// 4. COMO USAR: Exemplo de Chamada na Main App
// ============================================================================

/*
// Na rota de missões do seu ShellPage/TabBar:

CupertinoTabScaffold(
  tabBar: CupertinoTabBar(
    items: [
      BottomNavigationBarItem(icon: Icon(Icons.home)),
      BottomNavigationBarItem(icon: Icon(Icons.videogame_asset)),  // Missões
      // ... outras abas
    ],
  ),
  tabBuilder: (context, index) {
    switch (index) {
      case 0:
        return HomePageExemplo();
      case 1:
        return MissoesImprovedPage(
          gamificationState: context.read<GamificationState>(),
        );
      // ... outras cases
    }
  },
);
*/

// ============================================================================
// 5. IMPORTS NECESSÁRIOS
// ============================================================================

/*
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:procel/models/missao_model.dart';
import 'package:procel/providers/auth_provider.dart';
import 'package:procel/providers/missao_provider.dart';
import 'package:procel/components/resumo_missoes_widget.dart';
import 'package:procel/components/proximas_missoes_widget.dart';
import 'package:procel/pages/missoes/missoes_improved_page.dart';
import 'package:procel/services/gamification_state.dart';
*/

// ============================================================================
// FIM DE EXEMPLOS
// ============================================================================
