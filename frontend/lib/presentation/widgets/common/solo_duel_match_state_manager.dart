import '../../../services/sound_service.dart';

class SoloDuelMatchStateManager {
  final Set<int> _matchedCardPositions = {};
  bool _hasInitialMatchedSnapshot = false;

  void reset() {
    _matchedCardPositions.clear();
    _hasInitialMatchedSnapshot = false;
  }

  void updateMatchedCardSnapshot(List<dynamic> cards) {
    final currentMatchedPositions = <int>{};
    for (var i = 0; i < cards.length; i++) {
      if (cards[i].isMatched) {
        currentMatchedPositions.add(i);
      }
    }

    if (!_hasInitialMatchedSnapshot) {
      _matchedCardPositions
        ..clear()
        ..addAll(currentMatchedPositions);
      _hasInitialMatchedSnapshot = true;
      return;
    }

    final newMatches = currentMatchedPositions.difference(
      _matchedCardPositions,
    );
    if (newMatches.isNotEmpty) {
      SoundService().playMatchSound();
    }

    _matchedCardPositions
      ..clear()
      ..addAll(currentMatchedPositions);
  }

  Set<int> get matchedPositions => Set.unmodifiable(_matchedCardPositions);
  bool get hasSnapshot => _hasInitialMatchedSnapshot;
}
