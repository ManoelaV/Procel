import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'
    hide ChangeNotifierProvider;
import 'package:provider/provider.dart';

import 'pages/backend_auth_screen.dart';
import 'pages/upload_pdf_rooms/upload_pdf_rooms_widget.dart';
import 'services/backend_session.dart';
import 'services/gamification_state.dart';
import 'components/proximas_missoes_widget.dart';
import 'components/resumo_missoes_widget.dart';
import 'pages/missoes/missoes_improved_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await BackendSession.restoreToken();
  runApp(const EcoApp());
}

class EcoApp extends StatelessWidget {
  const EcoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: ChangeNotifierProvider(
        create: (_) => GamificationState(),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'PROCEL',
          theme: ThemeData(
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFFF7FBFA),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF1F7A75),
              brightness: Brightness.light,
            ),
          ),
          home: const BackendAuthScreen(),
          routes: {
            '/shell': (context) => const ShellPage(),
            '/upload-pdf-rooms': (context) =>
                const Scaffold(body: SafeArea(child: UploadPdfRoomsWidget())),
          },
        ),
      ),
    );
  }
}

class ShellPage extends StatefulWidget {
  const ShellPage({super.key});

  @override
  State<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends State<ShellPage> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const HomeScreen(),
      const MissionsScreen(),
      const RankingScreen(),
      const BadgesScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(
            icon: Icon(Icons.assignment_rounded),
            label: 'Missões',
          ),
          NavigationDestination(
            icon: Icon(Icons.leaderboard_rounded),
            label: 'Ranking',
          ),
          NavigationDestination(
            icon: Icon(Icons.military_tech_rounded),
            label: 'Badges',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_rounded),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gamification = context.watch<GamificationState>();
    return _PageScaffold(
      title: '👋 Olá, ${gamification.firstName}!',
      subtitle: gamification.levelLabel,
      progress: gamification.levelProgress,
      progressLabel: gamification.xpLabel,
      child: _HomeBody(),
    );
  }
}

class MissionsScreen extends ConsumerWidget {
  const MissionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamification = context.watch<GamificationState>();
    return _PageScaffold(
      title: '🎮 Missões',
      subtitle: 'Gerenciar e concluir suas missões individuais',
      progress: gamification.levelProgress,
      progressLabel: gamification.levelLabel,
      child: _MissionsBody(ref: ref),
    );
  }
}

class RankingScreen extends StatelessWidget {
  const RankingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gamification = context.watch<GamificationState>();
    return _PageScaffold(
      title: '🏆 Ranking',
      subtitle: 'Competição saudável e motivadora',
      progress: gamification.levelProgress,
      progressLabel: 'Você está em 3º lugar',
      child: _RankingBody(),
    );
  }
}

class BadgesScreen extends StatelessWidget {
  const BadgesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gamification = context.watch<GamificationState>();
    return _PageScaffold(
      title: '🎖️ Conquistas',
      subtitle: gamification.badgeProgressLabel,
      progress: gamification.unlockedBadgesCount / 4,
      progressLabel:
          '${(gamification.unlockedBadgesCount / 4 * 100).round()}% completado',
      child: _BadgesBody(),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gamification = context.watch<GamificationState>();
    return _PageScaffold(
      title: '👤 Perfil',
      subtitle: gamification.displayName,
      progress: gamification.levelProgress,
      progressLabel: 'Streak ${gamification.streakDays} dias',
      child: _ProfileBody(),
    );
  }
}

class _PageScaffold extends StatelessWidget {
  const _PageScaffold({
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.progressLabel,
    required this.child,
  });

  final String title;
  final String subtitle;
  final double progress;
  final String progressLabel;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1F7A75), Color(0xFF135C58)],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x221F7A75),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 18,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation(
                        Color(0xFFFFC857),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    progressLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            child,
          ],
        ),
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody();

  @override
  Widget build(BuildContext context) {
    final gamification = context.watch<GamificationState>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('📊 Seu impacto'),
        const SizedBox(height: 12),
        _StatsGrid(
          daily: '${gamification.dailySavedKwh.toStringAsFixed(1)} kWh',
          total: '${gamification.totalSavedKwh.toStringAsFixed(0)} kWh',
          third: '${gamification.co2AvoidedKg.toStringAsFixed(1)} kg',
          streak: '${gamification.streakDays} 🔥',
        ),
        const SizedBox(height: 24),
        const _SectionTitle('🎯 Próximas missões'),
        const SizedBox(height: 12),
        const ProximasMissoesWidget(maxMissoes: 3),
      ],
    );
  }
}

class _MissionsBody extends StatelessWidget {
  const _MissionsBody({required this.ref});
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle('📊 Resumo de Missões'),
        const SizedBox(height: 12),
        ResumoMissoesWidget(),
        const SizedBox(height: 24),
        _SectionTitle('⏰ Próximas Missões'),
        const SizedBox(height: 12),
        ProximasMissoesWidget(maxMissoes: 5),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MissoesImprovedPage(
                    gamificationState: context.read<GamificationState>(),
                  ),
                ),
              );
            },
            icon: const Icon(Icons.check_circle_outlined),
            label: const Text('Ver Todas as Missões'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: const Color(0xFF1F7A75),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RankingBody extends StatelessWidget {
  const _RankingBody();

  @override
  Widget build(BuildContext context) {
    final gamification = context.watch<GamificationState>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle('🌍 Ranking global'),
        SizedBox(height: 12),
        _LeaderboardCard(
          items: [
            const _LeaderboardItem(
              rank: '🥇',
              name: 'Maria Silva',
              level: 'Level 6: Herói Ambiental',
              xp: '8.500 XP',
              streak: '45 🔥',
              highlight: false,
            ),
            const _LeaderboardItem(
              rank: '🥈',
              name: 'João Santos',
              level: 'Level 5: Mestre da Economia',
              xp: '6.200 XP',
              streak: '32 🔥',
              highlight: false,
            ),
            _LeaderboardItem(
              rank: '🥉',
              name: 'Você (${gamification.firstName})',
              level: gamification.levelLabel,
              xp: '${gamification.xpLabel}',
              streak: '${gamification.streakDays} 🔥',
              highlight: true,
            ),
          ],
        ),
        SizedBox(height: 24),
        _SectionTitle('🏫 Ranking de salas'),
        SizedBox(height: 12),
        _LeaderboardCard(
          items: [
            const _LeaderboardItem(
              rank: '🥇',
              name: 'Sala 304',
              level: '8/10 alunos participando',
              xp: '-35%',
              streak: 'Economia',
              highlight: false,
            ),
            _LeaderboardItem(
              rank: '🥈',
              name: 'Sala 101 (${gamification.schoolRoom})',
              level:
                  '${gamification.completedMissionCount + 6}/10 alunos participando',
              xp: '-${28 - gamification.completedMissionCount}%',
              streak: 'Economia',
              highlight: true,
            ),
          ],
        ),
      ],
    );
  }
}

class _BadgesBody extends StatelessWidget {
  const _BadgesBody();

  @override
  Widget build(BuildContext context) {
    final gamification = context.watch<GamificationState>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle('🌱 Sustentabilidade'),
        SizedBox(height: 12),
        _BadgeGrid(
          items: gamification.badgeViewModels
              .map(
                (badge) => _BadgeItem(
                  icon: badge.icon,
                  name: badge.name,
                  unlocked: badge.unlocked,
                  progress: badge.progress,
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody();

  @override
  Widget build(BuildContext context) {
    final gamification = context.watch<GamificationState>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ProfileHeader(
          name: gamification.displayName,
          title: gamification.levelLabel,
          avatar: '🌟',
        ),
        SizedBox(height: 18),
        _SectionTitle('📊 Estatísticas'),
        SizedBox(height: 12),
        _StatsGrid(
          daily: '${gamification.dailySavedKwh.toStringAsFixed(1)} kWh',
          total: '${gamification.co2AvoidedKg.toStringAsFixed(1)} kg',
          third: '${gamification.coins} moedas',
          streak: '${gamification.streakDays} 🔥',
        ),
        SizedBox(height: 18),
        _SectionTitle('🎖️ Badges recentes'),
        SizedBox(height: 12),
        _RecentBadgesRow(),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
  );
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({
    this.daily = '2.5 kWh',
    this.total = '125 kWh',
    this.third = '62.5 kg',
    this.streak = '23 🔥',
  });

  final String daily;
  final String total;
  final String third;
  final String streak;

  @override
  Widget build(BuildContext context) {
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.45,
      ),
      children: [
        _StatCard(
          value: daily,
          label: 'Economizado hoje',
          color: Color(0xFF27AE60),
        ),
        _StatCard(
          value: total,
          label: 'Total do semestre',
          color: Color(0xFFE67E22),
        ),
        _StatCard(value: third, label: 'CO₂ evitado', color: Color(0xFF32B8C6)),
        _StatCard(
          value: streak,
          label: 'Dias de streak',
          color: Color(0xFFF39C12),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: color, width: 4)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF7F8C8D),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MissionCard extends StatelessWidget {
  const _MissionCard({
    required this.title,
    required this.icon,
    required this.description,
    required this.progress,
    required this.xp,
    required this.coins,
    required this.buttonLabel,
    required this.completed,
    required this.onPressed,
  });

  final String title;
  final String icon;
  final String description;
  final double progress;
  final String xp;
  final String? coins;
  final String buttonLabel;
  final bool completed;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: completed ? const Color(0xFF27AE60) : const Color(0xFFECF0F1),
        ),
      ),
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
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: const TextStyle(
                        color: Color(0xFF7F8C8D),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Text(icon, style: const TextStyle(fontSize: 24)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: const Color(0xFFECF0F1),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF1F7A75)),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _Pill(
                text: xp,
                background: const Color(0xFFE8F5E9),
                foreground: const Color(0xFF27AE60),
              ),
              if (coins != null)
                _Pill(
                  text: coins!,
                  background: const Color(0xFFFFF8E1),
                  foreground: const Color(0xFFE67E22),
                ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: completed
                    ? Colors.white
                    : const Color(0xFF1F7A75),
                foregroundColor: completed
                    ? const Color(0xFF27AE60)
                    : Colors.white,
                side: BorderSide(
                  color: completed
                      ? const Color(0xFF27AE60)
                      : Colors.transparent,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                completed ? 'Concluída' : buttonLabel,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  const _ChallengeCard({
    required this.title,
    required this.description,
    required this.progress,
    required this.progressText,
    required this.timeLeft,
    required this.rewards,
  });

  final String title;
  final String description;
  final double progress;
  final String progressText;
  final String timeLeft;
  final List<String> rewards;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFECF0F1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(fontSize: 13, color: Color(0xFF7F8C8D)),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: const Color(0xFFECF0F1),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF1F7A75)),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                progressText,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '⏱️ $timeLeft',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFFF39C12),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: rewards
                .map(
                  (reward) => _Pill(
                    text: reward,
                    background: const Color(0xFFF8F9FA),
                    foreground: const Color(0xFF1F7A75),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _LeaderboardCard extends StatelessWidget {
  const _LeaderboardCard({required this.items});

  final List<_LeaderboardItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: items),
    );
  }
}

class _LeaderboardItem extends StatelessWidget {
  const _LeaderboardItem({
    required this.rank,
    required this.name,
    required this.level,
    required this.xp,
    required this.streak,
    required this.highlight,
  });

  final String rank;
  final String name;
  final String level;
  final String xp;
  final String streak;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: highlight ? const Color(0xFFF1FBFC) : Colors.white,
        border: const Border(bottom: BorderSide(color: Color(0xFFECF0F1))),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              rank,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1F7A75),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  level,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF7F8C8D),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                xp,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1F7A75),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                streak,
                style: const TextStyle(fontSize: 12, color: Color(0xFF7F8C8D)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BadgeGrid extends StatelessWidget {
  const _BadgeGrid({required this.items});

  final List<_BadgeItem> items;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemBuilder: (context, index) => _BadgeCard(item: items[index]),
    );
  }
}

class _BadgeItem {
  const _BadgeItem({
    required this.icon,
    required this.name,
    required this.unlocked,
    required this.progress,
  });

  final String icon;
  final String name;
  final bool unlocked;
  final String progress;
}

class _BadgeCard extends StatelessWidget {
  const _BadgeCard({required this.item});

  final _BadgeItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: item.unlocked
              ? const Color(0xFF32B8C6)
              : const Color(0xFFECF0F1),
        ),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(item.icon, style: const TextStyle(fontSize: 30)),
          const SizedBox(height: 8),
          Text(
            item.name,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            item.progress,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, color: Color(0xFF7F8C8D)),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.name,
    required this.title,
    required this.avatar,
  });

  final String name;
  final String title;
  final String avatar;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1F7A75), Color(0xFF135C58)],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: Colors.white24,
            child: Text(avatar, style: const TextStyle(fontSize: 34)),
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _RecentBadgesRow extends StatelessWidget {
  const _RecentBadgesRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: _MiniBadge(icon: '♻️', label: 'Guardião Verde'),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _MiniBadge(icon: '🔥', label: '7 Days Strong'),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _MiniBadge(icon: '💡', label: 'Apagador Ninja'),
        ),
      ],
    );
  }
}

class _MiniBadge extends StatelessWidget {
  const _MiniBadge({required this.icon, required this.label});

  final String icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF32B8C6)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.text,
    required this.background,
    required this.foreground,
  });

  final String text;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: foreground,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}
