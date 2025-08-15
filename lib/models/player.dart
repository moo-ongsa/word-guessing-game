import 'word_item.dart';

class Player {
  final String id;
  final String name;
  bool isAsker;
  bool isCurrentTurn;
  Duration? timeUsed;
  DateTime? startTime;
  String? targetWord;
  WordItem? targetWordItem;
  bool hasFinished;

  Player({
    required this.id,
    required this.name,
    this.isAsker = false,
    this.isCurrentTurn = false,
    this.timeUsed,
    this.startTime,
    this.targetWord,
    this.targetWordItem,
    this.hasFinished = false,
  });

  Player copyWith({
    String? id,
    String? name,
    bool? isAsker,
    bool? isCurrentTurn,
    Duration? timeUsed,
    DateTime? startTime,
    String? targetWord,
    WordItem? targetWordItem,
    bool? hasFinished,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      isAsker: isAsker ?? this.isAsker,
      isCurrentTurn: isCurrentTurn ?? this.isCurrentTurn,
      timeUsed: timeUsed ?? this.timeUsed,
      startTime: startTime ?? this.startTime,
      targetWord: targetWord ?? this.targetWord,
      targetWordItem: targetWordItem ?? this.targetWordItem,
      hasFinished: hasFinished ?? this.hasFinished,
    );
  }

  void startTurn() {
    isCurrentTurn = true;
    startTime = DateTime.now();
    hasFinished = false;
  }

  void endTurn() {
    isCurrentTurn = false;
    if (startTime != null) {
      timeUsed = DateTime.now().difference(startTime!);
    }
    hasFinished = true;
  }

  Duration getCurrentTime() {
    if (startTime == null) return Duration.zero;
    return DateTime.now().difference(startTime!);
  }
}
