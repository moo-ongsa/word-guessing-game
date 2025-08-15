import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/player.dart';
import '../models/game_state.dart';
import '../models/word_item.dart';
import '../services/stats_service.dart';
import '../services/word_service.dart';

class GameProvider with ChangeNotifier {
  GameState _gameState = GameState(players: []);
  Timer? _timer;
  final StatsService _statsService = StatsService();
  String _selectedCategory = 'ทั้งหมด';
  List<String> get availableCategories => [
    'ทั้งหมด',
    ...WordService.getAllCategories(),
  ];
  String get selectedCategory => _selectedCategory;

  GameProvider() {
    _loadSavedPlayers();
  }

  GameState get gameState => _gameState;

  // โหลดผู้เล่นที่บันทึกไว้
  Future<void> _loadSavedPlayers() async {
    try {
      final savedPlayers = await _statsService.getSavedPlayerNames();
      final players = <Player>[];

      for (final entry in savedPlayers.entries) {
        players.add(Player(id: entry.key, name: entry.value));
      }

      if (players.isNotEmpty) {
        _gameState = _gameState.copyWith(players: players);
        assignWordsToPlayers();
        notifyListeners();
      }
    } catch (e) {
      // Handle error silently
    }
  }

  // โหลดผู้เล่นที่บันทึกไว้ (public method)
  Future<void> loadSavedPlayers() async {
    await _loadSavedPlayers();
  }

  // สุ่มคำที่ไม่ซ้ำกันให้ผู้เล่นแต่ละคน
  Future<List<WordItem>> _getRandomUniqueWords(int count) async {
    final allWords = <WordItem>[];

    // รวบรวมคำจากทุกหมวดหมู่
    for (final category in WordService.getAllCategories()) {
      final words = await WordService.getWordsByCategory(category);
      allWords.addAll(words);
    }

    if (count > allWords.length) {
      // ถ้าผู้เล่นมากกว่าคำที่มี ให้ใช้คำที่มีซ้ำ
      final random = Random();
      return List.generate(count, (index) {
        return allWords[random.nextInt(allWords.length)];
      });
    }

    final availableWords = List<WordItem>.from(allWords);
    final selectedWords = <WordItem>[];
    final random = Random();

    for (int i = 0; i < count; i++) {
      final randomIndex = random.nextInt(availableWords.length);
      selectedWords.add(availableWords[randomIndex]);
      availableWords.removeAt(randomIndex);
    }

    return selectedWords;
  }

  Future<void> addPlayer(String name) async {
    final newPlayer = Player(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
    );

    final updatedPlayers = List<Player>.from(_gameState.players)
      ..add(newPlayer);
    _gameState = _gameState.copyWith(players: updatedPlayers);

    // บันทึกรายชื่อผู้เล่น
    _statsService.savePlayerName(newPlayer.id, newPlayer.name);

    // มอบหมายคำให้ผู้เล่นใหม่
    await assignWordsToPlayers();
    notifyListeners();
  }

  Future<void> removePlayer(String playerId) async {
    final updatedPlayers = _gameState.players
        .where((player) => player.id != playerId)
        .toList();
    _gameState = _gameState.copyWith(players: updatedPlayers);

    // ลบรายชื่อผู้เล่นจากที่บันทึกไว้
    _statsService.removePlayerName(playerId);

    // มอบหมายคำใหม่หลังจากลบผู้เล่น
    await assignWordsToPlayers();
    notifyListeners();
  }

  // มอบหมายคำที่ไม่ซ้ำกันให้ผู้เล่นแต่ละคน
  Future<void> assignWordsToPlayers() async {
    if (_gameState.players.isEmpty) return;

    final uniqueWords = await _getRandomUniqueWords(_gameState.players.length);
    final updatedPlayers = <Player>[];

    for (int i = 0; i < _gameState.players.length; i++) {
      updatedPlayers.add(
        _gameState.players[i].copyWith(
          targetWord: uniqueWords[i].word,
          targetWordItem: uniqueWords[i],
        ),
      );
    }

    _gameState = _gameState.copyWith(players: updatedPlayers);
  }

  void setAsker(String playerId) {
    final updatedPlayers = _gameState.players.map((player) {
      return player.copyWith(isAsker: player.id == playerId);
    }).toList();

    _gameState = _gameState.copyWith(players: updatedPlayers);
    notifyListeners();
  }

  Future<void> startGame() async {
    if (_gameState.players.length < 2) return;

    // บันทึกรายชื่อผู้เล่นทั้งหมดในเกมปัจจุบัน
    _statsService.saveAllCurrentPlayers(_gameState.players);

    // มอบหมายคำใหม่เมื่อเริ่มเกม
    await assignWordsToPlayers();

    _gameState = _gameState.copyWith(
      status: GameStatus.playing,
      gameStartTime: DateTime.now(),
      currentPlayerIndex: 0,
      currentRound: 1,
      // ใช้ totalRounds ที่ตั้งค่าไว้
    );

    notifyListeners();
  }

  void startCurrentPlayerTurn() {
    if (_gameState.currentPlayer == null) return;

    final currentPlayer = _gameState.currentPlayer!;
    if (currentPlayer.isAsker) return; // Skip asker's turn

    final updatedPlayers = _gameState.players.map((player) {
      if (player.id == currentPlayer.id) {
        player.startTurn();
        return player;
      }
      return player;
    }).toList();

    _gameState = _gameState.copyWith(players: updatedPlayers);

    // Start timer
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      notifyListeners();
    });
  }

  Future<void> endCurrentPlayerTurn() async {
    if (_gameState.currentPlayer == null) return;

    final currentPlayer = _gameState.currentPlayer!;
    final updatedPlayers = _gameState.players.map((player) {
      if (player.id == currentPlayer.id) {
        player.endTurn();
        return player;
      }
      return player;
    }).toList();

    _gameState = _gameState.copyWith(players: updatedPlayers);

    _timer?.cancel();
    await _moveToNextPlayer();
  }

  Future<void> _moveToNextPlayer() async {
    int nextIndex = _gameState.currentPlayerIndex + 1;

    // Skip asker
    while (nextIndex < _gameState.players.length &&
        _gameState.players[nextIndex].isAsker) {
      nextIndex++;
    }

    if (nextIndex >= _gameState.players.length) {
      // All players have played, move to next round
      await _moveToNextRound();
    } else {
      _gameState = _gameState.copyWith(currentPlayerIndex: nextIndex);
      // Don't auto-start turn, let the UI handle it
    }

    notifyListeners();
  }

  Future<void> _moveToNextRound() async {
    final nextRound = _gameState.currentRound + 1;

    if (nextRound > _gameState.totalRounds) {
      // Game finished
      _gameState = _gameState.copyWith(
        status: GameStatus.finished,
        currentRound: nextRound,
      );
      _timer?.cancel();

      // บันทึกสถิติเมื่อเกมจบ
      if (_gameState.gameStartTime != null) {
        _statsService.updateStatsAfterGame(
          _gameState,
          _gameState.gameStartTime!,
        );
      }
    } else {
      // Reset players for next round with new unique words
      final updatedPlayers = _gameState.players.map((player) {
        return player.copyWith(
          isCurrentTurn: false,
          timeUsed: null,
          startTime: null,
          hasFinished: false,
        );
      }).toList();

      _gameState = _gameState.copyWith(
        players: updatedPlayers,
        currentRound: nextRound,
        currentPlayerIndex: 0,
      );

      // มอบหมายคำใหม่ที่ไม่ซ้ำกันสำหรับรอบใหม่
      await assignWordsToPlayers();
      // Don't auto-start turn, let the UI handle it
    }

    notifyListeners();
  }

  void resetGame() {
    _timer?.cancel();
    _gameState = GameState(players: _gameState.players);
    notifyListeners();
  }

  void setGameMode(GameMode mode) {
    _gameState = _gameState.copyWith(mode: mode);
    notifyListeners();
  }

  void setTotalRounds(int rounds) {
    _gameState = _gameState.copyWith(totalRounds: rounds);
    notifyListeners();
  }

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  // มอบหมายคำตามหมวดหมู่ที่เลือก
  Future<void> assignWordsByCategory() async {
    if (_gameState.players.isEmpty) return;

    final updatedPlayers = <Player>[];

    for (int i = 0; i < _gameState.players.length; i++) {
      WordItem wordItem;
      if (_selectedCategory == 'ทั้งหมด') {
        wordItem = await WordService.getRandomWord();
      } else {
        wordItem = await WordService.getRandomWordByCategory(_selectedCategory);
      }

      updatedPlayers.add(
        _gameState.players[i].copyWith(
          targetWord: wordItem.word,
          targetWordItem: wordItem,
        ),
      );
    }

    _gameState = _gameState.copyWith(players: updatedPlayers);
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
