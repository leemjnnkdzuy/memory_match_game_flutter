import 'battle_royale_player_model.dart';

class BattleRoyaleGameState {
  final String roomId;
  final String seed;
  final List<int> cardIds;
  final List<bool> revealedCards;
  final int myPairsFound;
  final int myFlipCount;
  final int myCompletionTime;
  final DateTime startTime;
  final List<BattleRoyalePlayer> leaderboard;
  final bool isFinished;
  final int? selectedCardIndex;
  final int? firstFlippedIndex;

  BattleRoyaleGameState({
    required this.roomId,
    required this.seed,
    required this.cardIds,
    required this.revealedCards,
    this.myPairsFound = 0,
    this.myFlipCount = 0,
    this.myCompletionTime = 0,
    required this.startTime,
    this.leaderboard = const [],
    this.isFinished = false,
    this.selectedCardIndex,
    this.firstFlippedIndex,
  });

  factory BattleRoyaleGameState.initial({
    required String roomId,
    required String seed,
    required List<int> cardIds,
  }) {
    return BattleRoyaleGameState(
      roomId: roomId,
      seed: seed,
      cardIds: cardIds,
      revealedCards: List.filled(cardIds.length, false),
      startTime: DateTime.now(),
    );
  }

  double get myScore {
    if (myCompletionTime == 0) return 0;
    return (10000 / myCompletionTime) +
        (myPairsFound * 150) -
        (myFlipCount * 5);
  }

  int get elapsedSeconds {
    return DateTime.now().difference(startTime).inSeconds;
  }

  bool get allPairsFound => myPairsFound >= 8;

  BattleRoyaleGameState copyWith({
    String? roomId,
    String? seed,
    List<int>? cardIds,
    List<bool>? revealedCards,
    int? myPairsFound,
    int? myFlipCount,
    int? myCompletionTime,
    DateTime? startTime,
    List<BattleRoyalePlayer>? leaderboard,
    bool? isFinished,
    int? selectedCardIndex,
    int? firstFlippedIndex,
  }) {
    return BattleRoyaleGameState(
      roomId: roomId ?? this.roomId,
      seed: seed ?? this.seed,
      cardIds: cardIds ?? this.cardIds,
      revealedCards: revealedCards ?? this.revealedCards,
      myPairsFound: myPairsFound ?? this.myPairsFound,
      myFlipCount: myFlipCount ?? this.myFlipCount,
      myCompletionTime: myCompletionTime ?? this.myCompletionTime,
      startTime: startTime ?? this.startTime,
      leaderboard: leaderboard ?? this.leaderboard,
      isFinished: isFinished ?? this.isFinished,
      selectedCardIndex: selectedCardIndex,
      firstFlippedIndex: firstFlippedIndex,
    );
  }
}
