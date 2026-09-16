import 'package:flutter/foundation.dart';

import 'main_quest.dart';
import 'quests.dart';
import 'social.dart';

enum ClaimResult { claimed, alreadyOwned, levelLocked, tooExpensive }

class GameState extends ChangeNotifier {
  GameState._();

  static final GameState instance = GameState._();

  static const Player _seed = Player.you;

  String _name = _seed.name;
  MainQuest? _mainQuest;
  Difficulty _difficulty = Difficulty.warrior;
  int _earned = 0;
  int _spent = 0;
  final Set<String> _claimedRewards = <String>{};
  final Set<String> _claimedQuests = <String>{};
  final Set<String> _read = <String>{};

  String get name => _name;

  void signIn({String? heroName}) {
    final chosen = heroName?.trim();
    if (chosen != null && chosen.isNotEmpty) _name = chosen.toUpperCase();
    notifyListeners();
  }

  MainQuest? get mainQuest => _mainQuest;
  Difficulty get difficulty => _difficulty;

  void chooseMainQuest(MainQuest quest, Difficulty difficulty) {
    _mainQuest = quest;
    _difficulty = difficulty;
    notifyListeners();
  }

  int get _lifetime => (_seed.level - 1) * _seed.xpToNext + _seed.xp + _earned;

  int get level => _lifetime ~/ _seed.xpToNext + 1;

  int get xp => _lifetime % _seed.xpToNext;
  int get xpToNext => _seed.xpToNext;
  double get xpFraction => xp / xpToNext;

  int get balance => _seed.balance + _earned - _spent;

  bool owns(Reward r) => r.owned || _claimedRewards.contains(r.name);
  int get badgesOwned => Reward.all.where(owns).length;
  List<Reward> get ownedRewards => Reward.all.where(owns).toList();

  ClaimResult claimReward(Reward r) {
    if (owns(r)) return ClaimResult.alreadyOwned;
    final gate = r.unlocksAtLevel;
    if (gate != null && level < gate) return ClaimResult.levelLocked;
    if (r.cost > balance) return ClaimResult.tooExpensive;
    _claimedRewards.add(r.name);
    _spent += r.cost;
    notifyListeners();
    return ClaimResult.claimed;
  }

  bool questClaimed(Quest q) => _claimedQuests.contains(q.id);

  int payout(Quest q) => q.xp * _seed.multiplier;

  int? claimQuest(Quest q) {
    if (!q.done || questClaimed(q)) return null;
    final before = level;
    _claimedQuests.add(q.id);
    _earned += payout(q);
    notifyListeners();
    return level - before;
  }

  bool isRead(GameNotification n) => !n.unread || _read.contains(n.id);
  int get unreadCount =>
      GameNotification.all.where((GameNotification n) => !isRead(n)).length;

  void markRead(GameNotification n) {
    if (isRead(n)) return;
    _read.add(n.id);
    notifyListeners();
  }

  void markAllRead() {
    _read.addAll(GameNotification.all.map((GameNotification n) => n.id));
    notifyListeners();
  }

  @visibleForTesting
  void reset() {
    _name = _seed.name;
    _mainQuest = null;
    _difficulty = Difficulty.warrior;
    _earned = 0;
    _spent = 0;
    _claimedRewards.clear();
    _claimedQuests.clear();
    _read.clear();
    notifyListeners();
  }
}
