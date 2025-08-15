import 'package:word_guessing_game/models/game_state.dart';

class GameRecord {
  final String id;
  final DateTime playedAt;
  final GameMode gameMode;
  final int totalRounds;
  final List<PlayerResult> playerResults;
  final Duration gameDuration;
  final String? winnerId;

  GameRecord({
    required this.id,
    required this.playedAt,
    required this.gameMode,
    required this.totalRounds,
    required this.playerResults,
    required this.gameDuration,
    this.winnerId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'playedAt': playedAt.toIso8601String(),
      'gameMode': gameMode.toString(),
      'totalRounds': totalRounds,
      'playerResults': playerResults.map((result) => result.toJson()).toList(),
      'gameDuration': gameDuration.inMilliseconds,
      'winnerId': winnerId,
    };
  }

  factory GameRecord.fromJson(Map<String, dynamic> json) {
    return GameRecord(
      id: json['id'],
      playedAt: DateTime.parse(json['playedAt']),
      gameMode: GameMode.values.firstWhere(
        (mode) => mode.toString() == json['gameMode'],
      ),
      totalRounds: json['totalRounds'],
      playerResults: (json['playerResults'] as List)
          .map((result) => PlayerResult.fromJson(result))
          .toList(),
      gameDuration: Duration(milliseconds: json['gameDuration']),
      winnerId: json['winnerId'],
    );
  }
}

class PlayerResult {
  final String playerId;
  final String playerName;
  final Duration timeUsed;
  final bool isWinner;
  final int roundNumber;

  PlayerResult({
    required this.playerId,
    required this.playerName,
    required this.timeUsed,
    required this.isWinner,
    required this.roundNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'playerId': playerId,
      'playerName': playerName,
      'timeUsed': timeUsed.inMilliseconds,
      'isWinner': isWinner,
      'roundNumber': roundNumber,
    };
  }

  factory PlayerResult.fromJson(Map<String, dynamic> json) {
    return PlayerResult(
      playerId: json['playerId'],
      playerName: json['playerName'],
      timeUsed: Duration(milliseconds: json['timeUsed']),
      isWinner: json['isWinner'],
      roundNumber: json['roundNumber'],
    );
  }
}
