import 'player.dart';

enum GameStatus { setup, playing, finished }

enum GameMode { classic, timeAttack, team }

class GameState {
  final List<Player> players;
  final GameStatus status;
  final GameMode mode;
  final int currentPlayerIndex;
  final int currentRound;
  final int totalRounds;
  final DateTime? gameStartTime;
  final List<String> wordList;

  GameState({
    required this.players,
    this.status = GameStatus.setup,
    this.mode = GameMode.classic,
    this.currentPlayerIndex = 0,
    this.currentRound = 1,
    this.totalRounds = 1,
    this.gameStartTime,
    this.wordList = const [],
  });

  GameState copyWith({
    List<Player>? players,
    GameStatus? status,
    GameMode? mode,
    int? currentPlayerIndex,
    int? currentRound,
    int? totalRounds,
    DateTime? gameStartTime,
    List<String>? wordList,
  }) {
    return GameState(
      players: players ?? this.players,
      status: status ?? this.status,
      mode: mode ?? this.mode,
      currentPlayerIndex: currentPlayerIndex ?? this.currentPlayerIndex,
      currentRound: currentRound ?? this.currentRound,
      totalRounds: totalRounds ?? this.totalRounds,
      gameStartTime: gameStartTime ?? this.gameStartTime,
      wordList: wordList ?? this.wordList,
    );
  }

  Player? get currentPlayer {
    if (players.isEmpty || currentPlayerIndex >= players.length) return null;
    return players[currentPlayerIndex];
  }

  Player? get currentAsker {
    try {
      return players.firstWhere((player) => player.isAsker);
    } catch (e) {
      return players.isNotEmpty ? players.first : null;
    }
  }

  List<Player> get answerers {
    return players.where((player) => !player.isAsker).toList();
  }

  bool get isGameFinished {
    return currentRound > totalRounds ||
        players.every((player) => player.hasFinished);
  }

  Player? get winner {
    if (!isGameFinished) return null;

    Player? slowestPlayer;
    Duration? maxTime;

    for (final player in players) {
      if (player.timeUsed != null) {
        if (maxTime == null || player.timeUsed! > maxTime!) {
          maxTime = player.timeUsed;
          slowestPlayer = player;
        }
      }
    }

    return slowestPlayer;
  }

  List<Player> get sortedPlayersByTime {
    final sortedPlayers = List<Player>.from(players);
    sortedPlayers.sort((a, b) {
      final timeA = a.timeUsed ?? Duration.zero;
      final timeB = b.timeUsed ?? Duration.zero;
      return timeA.compareTo(timeB);
    });
    return sortedPlayers;
  }
}
