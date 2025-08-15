import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:word_guessing_game/models/player_stats.dart';
import 'package:word_guessing_game/models/game_record.dart';
import 'package:word_guessing_game/models/game_state.dart';
import 'package:word_guessing_game/models/player.dart';

class StatsService {
  static const String _playerStatsKey = 'player_stats';
  static const String _gameRecordsKey = 'game_records';
  static const String _totalGamesKey = 'total_games';
  static const String _savedPlayersKey = 'saved_players';

  // บันทึกสถิติผู้เล่น
  Future<void> savePlayerStats(PlayerStats stats) async {
    final prefs = await SharedPreferences.getInstance();
    final statsMap = await _getPlayerStatsMap();
    statsMap[stats.playerId] = stats;

    await prefs.setString(_playerStatsKey, jsonEncode(statsMap));
  }

  // ดึงสถิติผู้เล่นทั้งหมด
  Future<Map<String, PlayerStats>> getAllPlayerStats() async {
    return await _getPlayerStatsMap();
  }

  // ดึงสถิติผู้เล่นคนเดียว
  Future<PlayerStats?> getPlayerStats(String playerId) async {
    final statsMap = await _getPlayerStatsMap();
    return statsMap[playerId];
  }

  // บันทึกประวัติเกม
  Future<void> saveGameRecord(GameRecord record) async {
    final prefs = await SharedPreferences.getInstance();
    final records = await _getGameRecords();
    records.add(record);

    // เก็บแค่ 100 เกมล่าสุด
    if (records.length > 100) {
      records.removeRange(0, records.length - 100);
    }

    await prefs.setString(
      _gameRecordsKey,
      jsonEncode(records.map((r) => r.toJson()).toList()),
    );

    // อัปเดตจำนวนเกมทั้งหมด
    final totalGames = await getTotalGames();
    await prefs.setInt(_totalGamesKey, totalGames + 1);
  }

  // ดึงประวัติเกมทั้งหมด
  Future<List<GameRecord>> getGameRecords() async {
    return await _getGameRecords();
  }

  // ดึงจำนวนเกมทั้งหมด
  Future<int> getTotalGames() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_totalGamesKey) ?? 0;
  }

  // อัปเดตสถิติหลังจากเกมจบ
  Future<void> updateStatsAfterGame(
    GameState gameState,
    DateTime gameStartTime,
  ) async {
    final gameEndTime = DateTime.now();
    final gameDuration = gameEndTime.difference(gameStartTime);
    final winner = gameState.winner;

    // สร้าง GameRecord
    final gameRecord = GameRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      playedAt: gameEndTime,
      gameMode: gameState.mode,
      totalRounds: gameState.totalRounds,
      playerResults: gameState.players.map((player) {
        return PlayerResult(
          playerId: player.id,
          playerName: player.name,
          timeUsed: player.timeUsed ?? Duration.zero,
          isWinner: player.id == winner?.id,
          roundNumber: gameState.currentRound,
        );
      }).toList(),
      gameDuration: gameDuration,
      winnerId: winner?.id,
    );

    // บันทึกประวัติเกม
    await saveGameRecord(gameRecord);

    // อัปเดตสถิติผู้เล่นแต่ละคน
    for (final player in gameState.players) {
      if (player.timeUsed != null) {
        await _updatePlayerStats(player, gameRecord);
      }
    }
  }

  // ลบสถิติทั้งหมด
  Future<void> clearAllStats() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_playerStatsKey);
    await prefs.remove(_gameRecordsKey);
    await prefs.remove(_totalGamesKey);
  }

  // บันทึกรายชื่อผู้เล่นที่เคยเล่น
  Future<void> savePlayerName(String playerId, String playerName) async {
    final prefs = await SharedPreferences.getInstance();
    final savedPlayers = await getSavedPlayerNames();
    savedPlayers[playerId] = playerName;

    await prefs.setString(_savedPlayersKey, jsonEncode(savedPlayers));
  }

  // ดึงรายชื่อผู้เล่นที่เคยเล่น
  Future<Map<String, String>> getSavedPlayerNames() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPlayersJson = prefs.getString(_savedPlayersKey);

    if (savedPlayersJson == null) return {};

    try {
      final Map<String, dynamic> playersMap = jsonDecode(savedPlayersJson);
      return playersMap.map((key, value) => MapEntry(key, value.toString()));
    } catch (e) {
      return {};
    }
  }

  // ดึงรายชื่อผู้เล่นที่เคยเล่น (เรียงตามชื่อ)
  Future<List<String>> getSortedPlayerNames() async {
    final savedPlayers = await getSavedPlayerNames();
    final names = savedPlayers.values.toList();
    names.sort();
    return names;
  }

  // ลบรายชื่อผู้เล่น
  Future<void> removePlayerName(String playerId) async {
    final prefs = await SharedPreferences.getInstance();
    final savedPlayers = await getSavedPlayerNames();
    savedPlayers.remove(playerId);

    await prefs.setString(_savedPlayersKey, jsonEncode(savedPlayers));
  }

  // บันทึกรายชื่อผู้เล่นทั้งหมดในเกมปัจจุบัน
  Future<void> saveAllCurrentPlayers(List<Player> players) async {
    final prefs = await SharedPreferences.getInstance();
    final savedPlayers = <String, String>{};

    for (final player in players) {
      savedPlayers[player.id] = player.name;
    }

    await prefs.setString(_savedPlayersKey, jsonEncode(savedPlayers));
  }

  // Helper methods
  Future<Map<String, PlayerStats>> _getPlayerStatsMap() async {
    final prefs = await SharedPreferences.getInstance();
    final statsJson = prefs.getString(_playerStatsKey);

    if (statsJson == null) return {};

    try {
      final Map<String, dynamic> statsMap = jsonDecode(statsJson);
      return statsMap.map(
        (key, value) => MapEntry(key, PlayerStats.fromJson(value)),
      );
    } catch (e) {
      return {};
    }
  }

  Future<List<GameRecord>> _getGameRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final recordsJson = prefs.getString(_gameRecordsKey);

    if (recordsJson == null) return [];

    try {
      final List<dynamic> recordsList = jsonDecode(recordsJson);
      return recordsList.map((record) => GameRecord.fromJson(record)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> _updatePlayerStats(Player player, GameRecord gameRecord) async {
    final existingStats = await getPlayerStats(player.id);
    final now = DateTime.now();

    PlayerStats newStats;
    if (existingStats == null) {
      // สร้างสถิติใหม่
      newStats = PlayerStats(
        playerId: player.id,
        playerName: player.name,
        totalGames: 1,
        gamesWon: player.id == gameRecord.winnerId ? 1 : 0,
        gamesLost: player.id == gameRecord.winnerId ? 0 : 1,
        totalPlayTime: player.timeUsed ?? Duration.zero,
        fastestTime: player.timeUsed ?? Duration.zero,
        slowestTime: player.timeUsed ?? Duration.zero,
        lastPlayed: now,
        firstPlayed: now,
      );
    } else {
      // อัปเดตสถิติที่มีอยู่
      final isWinner = player.id == gameRecord.winnerId;
      final newTotalGames = existingStats.totalGames + 1;
      final newGamesWon = existingStats.gamesWon + (isWinner ? 1 : 0);
      final newGamesLost = existingStats.gamesLost + (isWinner ? 0 : 1);
      final newTotalPlayTime =
          existingStats.totalPlayTime + (player.timeUsed ?? Duration.zero);

      Duration newFastestTime = existingStats.fastestTime;
      Duration newSlowestTime = existingStats.slowestTime;

      if (player.timeUsed != null) {
        if (existingStats.fastestTime == Duration.zero ||
            player.timeUsed! < existingStats.fastestTime) {
          newFastestTime = player.timeUsed!;
        }
        if (player.timeUsed! > existingStats.slowestTime) {
          newSlowestTime = player.timeUsed!;
        }
      }

      newStats = existingStats.copyWith(
        totalGames: newTotalGames,
        gamesWon: newGamesWon,
        gamesLost: newGamesLost,
        totalPlayTime: newTotalPlayTime,
        fastestTime: newFastestTime,
        slowestTime: newSlowestTime,
        lastPlayed: now,
      );
    }

    await savePlayerStats(newStats);
  }
}
