import 'dart:async';

import 'package:flutter/material.dart';

import '../backend/api_requests/api_manager.dart';
import '/models/missao_model.dart';
import 'backend_session.dart';
import 'backend_gamification_service.dart';
import 'missao_service.dart';
import '../utils/friendly_message.dart';

class GamificationMission {
  GamificationMission({
    required this.key,
    required this.title,
    required this.icon,
    required this.description,
    required this.rewardXp,
    required this.rewardCoins,
    required this.progress,
    required this.buttonLabel,
    required this.completed,
  });

  final String key;
  final String title;
  final String icon;
  final String description;
  final int rewardXp;
  final int rewardCoins;
  double progress;
  String buttonLabel;
  bool completed;

  String get xpLabel => '$rewardXp XP';
  String? get coinsLabel => rewardCoins > 0 ? '+$rewardCoins moedas' : null;
}

class GamificationBadge {
  const GamificationBadge({
    required this.icon,
    required this.name,
    required this.thresholdXp,
  });

  final String icon;
  final String name;
  final int thresholdXp;
}

class GamificationState extends ChangeNotifier {
  GamificationState()
    : _missions = [
        GamificationMission(
          key: 'luz-eficiente',
          title: 'Luz Eficiente',
          icon: '💡',
          description: 'Desligue 3 luzes desnecessárias',
          rewardXp: 25,
          rewardCoins: 10,
          progress: 0.0,
          buttonLabel: 'Completar',
          completed: false,
        ),
        GamificationMission(
          key: 'temperatura-inteligente',
          title: 'Temperatura Inteligente',
          icon: '❄️',
          description: 'Ajuste o AC para 24°C',
          rewardXp: 25,
          rewardCoins: 0,
          progress: 0.0,
          buttonLabel: 'Começar',
          completed: false,
        ),
        GamificationMission(
          key: 'sensor-scout',
          title: 'Sensor Scout',
          icon: '🔍',
          description: 'Verifique 2 salas e reporte anomalias',
          rewardXp: 20,
          rewardCoins: 5,
          progress: 0.0,
          buttonLabel: 'Continuar',
          completed: false,
        ),
        GamificationMission(
          key: 'hora-do-repouso',
          title: 'Hora do Repouso',
          icon: '🔌',
          description: 'Desligar equipamentos em standby',
          rewardXp: 25,
          rewardCoins: 10,
          progress: 0.0,
          buttonLabel: 'Completar',
          completed: false,
        ),
        GamificationMission(
          key: 'educar-e-compartilhar',
          title: 'Educar é Compartilhar',
          icon: '💬',
          description: 'Compartilhar 1 dica de economia',
          rewardXp: 15,
          rewardCoins: 0,
          progress: 0.0,
          buttonLabel: 'Completar',
          completed: false,
        ),
      ] {
    Future.microtask(loadFromBackend);
  }

  static const List<int> _levelThresholds = [
    0,
    1000,
    2000,
    3000,
    5000,
    7000,
    10000,
  ];

  final List<GamificationMission> _missions;

  final List<GamificationBadge> _badgeCatalog = const [
    GamificationBadge(icon: '🌱', name: 'Novato Eco', thresholdXp: 0),
    GamificationBadge(icon: '♻️', name: 'Guardião Verde', thresholdXp: 500),
    GamificationBadge(icon: '🌍', name: 'Herói Ambiental', thresholdXp: 1500),
    GamificationBadge(
      icon: '👑',
      name: 'Lenda Sustentável',
      thresholdXp: 10000,
    ),
  ];

  String displayName = 'João Pedro Santos';
  String schoolRoom = 'Sala 101';
  bool _loading = false;
  String? _errorMessage;

  int _xp = 0;
  int _coins = 0;
  int _streakDays = 0;
  double _dailySavedKwh = 0.0;
  double _totalSavedKwh = 0.0;
  double _co2AvoidedKg = 0.0;

  List<GamificationMission> get missions => List.unmodifiable(_missions);
  int get xp => _xp;
  int get coins => _coins;
  int get streakDays => _streakDays;
  double get dailySavedKwh => _dailySavedKwh;
  double get totalSavedKwh => _totalSavedKwh;
  double get co2AvoidedKg => _co2AvoidedKg;
  bool get isLoading => _loading;
  String? get errorMessage => _errorMessage;

  int get totalMissionCount => _missions.length;
  int get completedMissionCount =>
      _missions.where((mission) => mission.completed).length;

  int get level {
    final computed =
        _levelThresholds.lastIndexWhere((threshold) => _xp >= threshold) + 1;
    return computed.clamp(1, 6).toInt();
  }

  String get levelTitle {
    switch (level) {
      case 1:
        return 'Iniciante Sustentável';
      case 2:
        return 'Explorador de Economia';
      case 3:
        return 'Agente Verde';
      case 4:
        return 'Campeão Sustentável';
      case 5:
        return 'Mestre da Economia';
      case 6:
      default:
        return 'Herói Ambiental';
    }
  }

  int get currentLevelStartXp => _levelThresholds[level - 1];
  int get nextLevelXp => level >= 6 ? 10000 : _levelThresholds[level];

  double get levelProgress {
    final denominator = nextLevelXp - currentLevelStartXp;
    if (denominator <= 0) {
      return 1.0;
    }
    final progress = (_xp - currentLevelStartXp) / denominator;
    return progress.clamp(0.0, 1.0);
  }

  String get levelLabel => 'Level $level: $levelTitle';

  String get xpLabel =>
      '${_formatNumber(_xp)} / ${_formatNumber(nextLevelXp)} XP';
  String get badgeProgressLabel =>
      '${unlockedBadgesCount}/${_badgeCatalog.length} badges desbloqueados';

  int get unlockedBadgesCount =>
      _badgeCatalog.where((badge) => _xp >= badge.thresholdXp).length;

  List<GamificationBadgeViewModel> get badgeViewModels => _badgeCatalog
      .map(
        (badge) => GamificationBadgeViewModel(
          icon: badge.icon,
          name: badge.name,
          unlocked: _xp >= badge.thresholdXp,
          progress: _xp >= badge.thresholdXp
              ? 'Desbloqueado'
              : 'Próximo: ${_formatNumber(badge.thresholdXp)} XP',
        ),
      )
      .toList();

  Future<void> loadFromBackend() async {
    if (ApiManager.accessToken == null || ApiManager.accessToken!.isEmpty) {
      return;
    }

    if (_loading) {
      return;
    }

    _loading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final snapshot = await BackendGamificationService.fetchMe();
      _applySnapshot(snapshot);
    } catch (error) {
      try {
        final fallbackSnapshot = await _buildFallbackSnapshot();
        _applySnapshot(fallbackSnapshot);
        _errorMessage = null;
      } catch (fallbackError) {
        _errorMessage = userFriendlyErrorMessage(
          fallbackError,
          fallbackMessage: 'Não foi possível atualizar seu progresso agora.',
        );
      }
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> completeMission(int index) async {
    if (index < 0 || index >= _missions.length) {
      return;
    }

    final mission = _missions[index];
    if (mission.completed) {
      return;
    }

    _loading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final snapshot = await BackendGamificationService.completeMission(
        mission.key,
      );
      _applySnapshot(snapshot);
    } catch (error) {
      _errorMessage = userFriendlyErrorMessage(
        error,
        fallbackMessage: 'Não foi possível atualizar seu progresso agora.',
      );
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void _applySnapshot(BackendGamificationSnapshot snapshot) {
    displayName = snapshot.displayName.isNotEmpty
        ? snapshot.displayName
        : displayName;
    schoolRoom = snapshot.schoolRoom.isNotEmpty
        ? snapshot.schoolRoom
        : schoolRoom;
    _xp = snapshot.xp;
    _coins = snapshot.coins;
    _streakDays = snapshot.streakDays;
    _dailySavedKwh = snapshot.dailySavedKwh;
    _totalSavedKwh = snapshot.totalSavedKwh;
    _co2AvoidedKg = snapshot.co2AvoidedKg;

    final completedKeys = snapshot.completedMissionKeys.toSet();
    for (final mission in _missions) {
      mission.completed = completedKeys.contains(mission.key);
      mission.progress = mission.completed ? 1.0 : mission.progress;
      mission.buttonLabel = mission.completed
          ? 'Concluída'
          : _defaultButtonLabel(mission.key);
    }

    notifyListeners();
  }

  void applyMissionCompletion(PessoaMissao atividade) {
    final xpGanho = atividade.missaoValue > 0 ? atividade.missaoValue : 0;
    if (xpGanho == 0) {
      return;
    }

    for (final mission in _missions) {
      if (mission.key != atividade.missaoId) {
        continue;
      }

      if (!mission.completed) {
        _xp += xpGanho;
        mission.completed = true;
        mission.progress = 1.0;
        mission.buttonLabel = 'Concluída';
      }
      notifyListeners();
      return;
    }

    _xp += xpGanho;
    notifyListeners();
  }

  Future<BackendGamificationSnapshot> _buildFallbackSnapshot() async {
    final userId = await BackendSession.restoreUserId();
    if (userId == null || userId.isEmpty) {
      throw Exception('Não foi possível identificar o usuário logado.');
    }

    final atividades = await MissaoService().listarAtividadesDaPessoa(userId);
    final atividadesConcluidas = atividades
        .where((atividade) => atividade.isCompleted)
        .toList();

    final xpTotal = atividadesConcluidas.fold<int>(0, (acc, atividade) {
      return acc + (atividade.missaoValue > 0 ? atividade.missaoValue : 0);
    });

    return BackendGamificationSnapshot(
      userId: userId,
      displayName: displayName,
      schoolRoom: schoolRoom,
      xp: xpTotal,
      coins: _coins,
      streakDays: _streakDays,
      dailySavedKwh: _dailySavedKwh,
      totalSavedKwh: _totalSavedKwh,
      co2AvoidedKg: _co2AvoidedKg,
      completedMissionKeys: atividadesConcluidas
          .map((atividade) => atividade.missaoId)
          .toList(),
    );
  }

  static String _defaultButtonLabel(String missionKey) {
    switch (missionKey) {
      case 'luz-eficiente':
        return 'Completar';
      case 'temperatura-inteligente':
        return 'Começar';
      case 'sensor-scout':
        return 'Continuar';
      default:
        return 'Completar';
    }
  }

  void markLogin() {
    notifyListeners();
  }

  String get firstName {
    final parts = displayName.split(' ');
    return parts.isEmpty ? displayName : parts.first;
  }

  static String _formatNumber(num value) {
    final isWholeNumber = value.truncateToDouble() == value;
    final fixed = isWholeNumber
        ? value.toInt().toString()
        : value.toStringAsFixed(1);
    final parts = fixed.split('.');
    final reversed = parts.first.split('').reversed.toList();
    final integerBuffer = StringBuffer();

    for (var i = 0; i < reversed.length; i++) {
      if (i > 0 && i % 3 == 0) {
        integerBuffer.write('.');
      }
      integerBuffer.write(reversed[i]);
    }

    final formattedInteger = integerBuffer.toString().split('').reversed.join();
    if (parts.length > 1) {
      return '$formattedInteger,${parts[1]}';
    }

    return formattedInteger;
  }
}

class GamificationBadgeViewModel {
  const GamificationBadgeViewModel({
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
