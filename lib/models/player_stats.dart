class PlayerStats {
  final String playerId;
  final String playerName;
  final int totalGames;
  final int gamesWon;
  final int gamesLost;
  final Duration totalPlayTime;
  final Duration fastestTime;
  final Duration slowestTime;
  final DateTime lastPlayed;
  final DateTime firstPlayed;

  PlayerStats({
    required this.playerId,
    required this.playerName,
    this.totalGames = 0,
    this.gamesWon = 0,
    this.gamesLost = 0,
    this.totalPlayTime = Duration.zero,
    this.fastestTime = Duration.zero,
    this.slowestTime = Duration.zero,
    required this.lastPlayed,
    required this.firstPlayed,
  });

  PlayerStats copyWith({
    String? playerId,
    String? playerName,
    int? totalGames,
    int? gamesWon,
    int? gamesLost,
    Duration? totalPlayTime,
    Duration? fastestTime,
    Duration? slowestTime,
    DateTime? lastPlayed,
    DateTime? firstPlayed,
  }) {
    return PlayerStats(
      playerId: playerId ?? this.playerId,
      playerName: playerName ?? this.playerName,
      totalGames: totalGames ?? this.totalGames,
      gamesWon: gamesWon ?? this.gamesWon,
      gamesLost: gamesLost ?? this.gamesLost,
      totalPlayTime: totalPlayTime ?? this.totalPlayTime,
      fastestTime: fastestTime ?? this.fastestTime,
      slowestTime: slowestTime ?? this.slowestTime,
      lastPlayed: lastPlayed ?? this.lastPlayed,
      firstPlayed: firstPlayed ?? this.firstPlayed,
    );
  }

  double get winRate {
    if (totalGames == 0) return 0.0;
    return gamesWon / totalGames;
  }

  Duration get averageTime {
    if (totalGames == 0) return Duration.zero;
    return Duration(milliseconds: totalPlayTime.inMilliseconds ~/ totalGames);
  }

  Map<String, dynamic> toJson() {
    return {
      'playerId': playerId,
      'playerName': playerName,
      'totalGames': totalGames,
      'gamesWon': gamesWon,
      'gamesLost': gamesLost,
      'totalPlayTime': totalPlayTime.inMilliseconds,
      'fastestTime': fastestTime.inMilliseconds,
      'slowestTime': slowestTime.inMilliseconds,
      'lastPlayed': lastPlayed.toIso8601String(),
      'firstPlayed': firstPlayed.toIso8601String(),
    };
  }

  factory PlayerStats.fromJson(Map<String, dynamic> json) {
    return PlayerStats(
      playerId: json['playerId'],
      playerName: json['playerName'],
      totalGames: json['totalGames'] ?? 0,
      gamesWon: json['gamesWon'] ?? 0,
      gamesLost: json['gamesLost'] ?? 0,
      totalPlayTime: Duration(milliseconds: json['totalPlayTime'] ?? 0),
      fastestTime: Duration(milliseconds: json['fastestTime'] ?? 0),
      slowestTime: Duration(milliseconds: json['slowestTime'] ?? 0),
      lastPlayed: DateTime.parse(json['lastPlayed']),
      firstPlayed: DateTime.parse(json['firstPlayed']),
    );
  }
}
