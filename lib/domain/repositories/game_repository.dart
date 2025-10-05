import '../entities/offline_game_entity.dart';

abstract class GameRepository {
  Future<OfflineGameEntity> createNewGame(GameDifficulty difficulty);
  Future<OfflineGameEntity> saveGame(OfflineGameEntity game);
  Future<OfflineGameEntity?> loadGame(String gameId);
  Future<List<OfflineGameEntity>> getGameHistory();
  Future<void> deleteGame(String gameId);
}
