import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/game_provider.dart';
import '../models/game_state.dart';
import '../models/player.dart';

import '../utils/time_utils.dart';
import '../widgets/google_word_image_widget.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  bool _showWord = false;
  bool _gameStarted = false;
  bool _showingResults = false;
  int _currentResultIndex = 0;
  late AnimationController _resultAnimationController;

  @override
  void initState() {
    super.initState();
    _resultAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _resultAnimationController.dispose();
    super.dispose();
  }

  void _showExitConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFE74C3C),
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'ยืนยันการออก',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
          content: Text(
            'คุณต้องการออกจากเกมหรือไม่?\nข้อมูลเกมปัจจุบันจะหายไป',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: const Color(0xFF7F8C8D),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'ยกเลิก',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: const Color(0xFF7F8C8D),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE74C3C),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'ออกจากเกม',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF2C3E50),
            size: 28,
          ),
          onPressed: () {
            _showExitConfirmationDialog(context);
          },
        ),
        title: Text(
          'เกมทายคำ',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2C3E50),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Consumer<GameProvider>(
          builder: (context, gameProvider, child) {
            final gameState = gameProvider.gameState;

            if (gameState.status == GameStatus.finished) {
              return _buildGameOverScreen(gameProvider);
            }

            return _buildGamePlayScreen(gameProvider);
          },
        ),
      ),
    );
  }

  Widget _buildGamePlayScreen(GameProvider gameProvider) {
    final gameState = gameProvider.gameState;
    final currentPlayer = gameState.currentPlayer;
    final currentAsker = gameState.currentAsker;

    if (currentPlayer == null || currentAsker == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // Reset state when player changes
    if (currentPlayer.isCurrentTurn && _gameStarted) {
      // Player is already playing, don't reset
    } else if (!currentPlayer.isCurrentTurn && _gameStarted) {
      // Player changed, reset state
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _showWord = false;
          _gameStarted = false;
        });
      });
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Header with game info
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE9ECEF)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'รอบที่ ${gameState.currentRound}/${gameState.totalRounds}',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2C3E50),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2C3E50),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'ผู้เล่น ${gameState.players.length} คน',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'คนถาม: ${currentAsker.name}',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: const Color(0xFFE67E22),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'ผู้เล่นปัจจุบัน: ${currentPlayer.name}',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: const Color(0xFF2C3E50),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Game flow based on current state
            if (!_gameStarted)
              _buildGameSetup(gameProvider, currentPlayer)
            else if (currentPlayer.isCurrentTurn && !currentPlayer.isAsker)
              _buildCurrentPlayerTurn(gameProvider, currentPlayer)
            else if (currentPlayer.isAsker)
              _buildAskerTurn(currentPlayer)
            else
              _buildWaitingTurn(currentPlayer),

            const SizedBox(height: 30),

            // Players list
            Container(
              constraints: const BoxConstraints(minHeight: 200, maxHeight: 400),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE9ECEF)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📊 สถานะผู้เล่น',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: gameState.players.length,
                      itemBuilder: (context, index) {
                        final player = gameState.players[index];
                        return _buildPlayerCard(player, index);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameSetup(GameProvider gameProvider, Player currentPlayer) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2C3E50), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.play_circle_outline,
            size: 64,
            color: const Color(0xFF2C3E50),
          ),
          const SizedBox(height: 20),
          Text(
            'เตรียมเริ่มเกม',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'ตอนนี้เป็นตาของ: ${currentPlayer.name}',
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: const Color(0xFF7F8C8D),
            ),
          ),
          const SizedBox(height: 30),

          if (!_showWord)
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _showWord = true;
                });
              },
              icon: const Icon(Icons.visibility),
              label: Text(
                '👁️ ดูคำที่ได้',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3498DB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            )
          else
            Column(
              children: [
                if (currentPlayer.targetWordItem != null)
                  GoogleWordImageWidget(
                    wordItem: currentPlayer.targetWordItem!,
                    height: 300,
                    showDescription: true,
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF3498DB),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'คำที่คุณได้คือ:',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: const Color(0xFF7F8C8D),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          currentPlayer.targetWord ?? 'ไม่พบคำ',
                          style: GoogleFonts.poppins(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2C3E50),
                          ),
                        ).animate().fadeIn().scale(),
                      ],
                    ),
                  ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _gameStarted = true;
                    });
                    // เริ่มจับเวลาทันทีเมื่อกดปุ่ม
                    gameProvider.startCurrentPlayerTurn();
                  },
                  icon: const Icon(Icons.timer),
                  label: Text(
                    '⏰ เริ่มจับเวลา',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE74C3C),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildCurrentPlayerTurn(GameProvider gameProvider, Player player) {
    final currentTime = player.getCurrentTime();

    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2C3E50), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.timer, size: 64, color: const Color(0xFFE74C3C)),
          const SizedBox(height: 20),
          Text(
            'กำลังจับเวลา',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFE74C3C),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'คำที่คุณได้: ${player.targetWord}',
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: const Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE74C3C), width: 2),
            ),
            child: Text(
              TimeUtils.formatDuration(currentTime),
              style: GoogleFonts.poppins(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFE74C3C),
              ),
            ),
          ).animate().fadeIn().scale(),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () {
              gameProvider.endCurrentPlayerTurn();
              setState(() {
                _showWord = false;
                _gameStarted = false;
              });
            },
            icon: const Icon(Icons.stop),
            label: Text(
              'หยุดจับเวลา',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE74C3C),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAskerTurn(Player player) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE67E22), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.question_answer, size: 64, color: const Color(0xFFE67E22)),
          const SizedBox(height: 20),
          Text(
            'ตาคนถาม',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFE67E22),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'คุณเป็นคนถามในรอบนี้',
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: const Color(0xFF7F8C8D),
            ),
          ),
          const SizedBox(height: 20),
          if (player.targetWordItem != null)
            GoogleWordImageWidget(
              wordItem: player.targetWordItem!,
              height: 300,
              showDescription: true,
            )
          else
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE67E22), width: 2),
              ),
              child: Column(
                children: [
                  Text(
                    'คำที่คุณได้:',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: const Color(0xFF7F8C8D),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    player.targetWord ?? 'ไม่พบคำ',
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2C3E50),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWaitingTurn(Player player) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF7F8C8D), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.hourglass_empty, size: 64, color: const Color(0xFF7F8C8D)),
          const SizedBox(height: 20),
          Text(
            'รอตาของคุณ',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF7F8C8D),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'กรุณารอให้ถึงตาของคุณ',
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: const Color(0xFF7F8C8D),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerCard(Player player, int index) {
    final isCurrentTurn = player.isCurrentTurn;
    final hasFinished = player.hasFinished;
    final timeUsed = player.timeUsed;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCurrentTurn
            ? Colors.white.withOpacity(0.2)
            : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: isCurrentTurn
            ? Border.all(color: Colors.white, width: 2)
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCurrentTurn
                  ? Colors.white
                  : Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isCurrentTurn ? const Color(0xFF667eea) : Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      player.name,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    if (player.isAsker) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'คนถาม',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                    if (isCurrentTurn) ...[
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 20,
                      ),
                    ],
                  ],
                ),
                if (hasFinished && timeUsed != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        TimeUtils.formatDurationShort(timeUsed),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        TimeUtils.getTimeEmoji(timeUsed),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (isCurrentTurn && !player.isAsker)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'กำลังเล่น',
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGameOverScreen(GameProvider gameProvider) {
    final gameState = gameProvider.gameState;
    final sortedPlayers = gameState.sortedPlayersByTime;

    if (!_showingResults) {
      return _buildGameShowResults(gameProvider, sortedPlayers);
    }

    return _buildFinalResults(gameProvider, sortedPlayers);
  }

  Widget _buildGameShowResults(
    GameProvider gameProvider,
    List<Player> sortedPlayers,
  ) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    Text(
                      '🎬 รายการเกมโชว์',
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ).animate().fadeIn().scale(),
                    const SizedBox(height: 20),
                    Text(
                      'ผลการแข่งขัน',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Current Result Display
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_currentResultIndex < sortedPlayers.length) ...[
                        Text(
                          'อันดับที่ ${_currentResultIndex + 1}',
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(30),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                sortedPlayers[_currentResultIndex].name,
                                style: GoogleFonts.poppins(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 16),
                              if (sortedPlayers[_currentResultIndex].timeUsed !=
                                  null) ...[
                                Text(
                                  'ใช้เวลา:',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  TimeUtils.formatDuration(
                                    sortedPlayers[_currentResultIndex]
                                        .timeUsed!,
                                  ),
                                  style: GoogleFonts.poppins(
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  TimeUtils.getTimeEmoji(
                                    sortedPlayers[_currentResultIndex]
                                        .timeUsed!,
                                  ),
                                  style: const TextStyle(fontSize: 32),
                                ),
                              ],
                            ],
                          ),
                        ).animate().fadeIn().scale(),
                      ] else ...[
                        Text(
                          '🎉 ครบทุกคนแล้ว!',
                          style: GoogleFonts.poppins(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'กดปุ่มด้านล่างเพื่อดูผลรวม',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Navigation Buttons
              Row(
                children: [
                  if (_currentResultIndex > 0)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _currentResultIndex--;
                          });
                          _resultAnimationController.reset();
                          _resultAnimationController.forward();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.2),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          '⬅️ คนก่อนหน้า',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  if (_currentResultIndex > 0) const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentResultIndex < sortedPlayers.length) {
                          setState(() {
                            _currentResultIndex++;
                          });
                          _resultAnimationController.reset();
                          _resultAnimationController.forward();
                        } else {
                          setState(() {
                            _showingResults = true;
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF667eea),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        _currentResultIndex < sortedPlayers.length
                            ? 'คนถัดไป ➡️'
                            : 'ดูผลรวม 📊',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFinalResults(
    GameProvider gameProvider,
    List<Player> sortedPlayers,
  ) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Final Results Header
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    Text(
                      '🏆 ผลการแข่งขันสุดท้าย',
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ).animate().fadeIn().scale(),
                    const SizedBox(height: 20),
                    Text(
                      'เรียงจากเร็วที่สุดไปช้าที่สุด',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Final Results List
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: ListView.builder(
                    itemCount: sortedPlayers.length,
                    itemBuilder: (context, index) {
                      final player = sortedPlayers[index];
                      final timeUsed = player.timeUsed;

                      return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: index == 0
                                  ? Colors.green.withOpacity(0.3)
                                  : Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: index == 0
                                  ? Border.all(color: Colors.green, width: 2)
                                  : Border.all(
                                      color: Colors.white.withOpacity(0.2),
                                    ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: index == 0
                                        ? Colors.green
                                        : Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${index + 1}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: index == 0
                                            ? Colors.white
                                            : Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        player.name,
                                        style: GoogleFonts.poppins(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                      if (timeUsed != null) ...[
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Text(
                                              TimeUtils.formatDurationShort(
                                                timeUsed,
                                              ),
                                              style: GoogleFonts.poppins(
                                                fontSize: 16,
                                                color: Colors.white70,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              TimeUtils.getTimeEmoji(timeUsed),
                                              style: const TextStyle(
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                if (index == 0)
                                  const Icon(
                                    Icons.emoji_events,
                                    color: Colors.green,
                                    size: 32,
                                  ),
                              ],
                            ),
                          )
                          .animate()
                          .fadeIn(delay: Duration(milliseconds: index * 200))
                          .slideX();
                    },
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Action Buttons
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _showingResults = false;
                              _currentResultIndex = 0;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.2),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            '🔄 ดูใหม่',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/stats');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.2),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            '📊 สถิติ',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        gameProvider.resetGame();
                        Navigator.pushReplacementNamed(context, '/setup');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF667eea),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        '🎮 เล่นใหม่',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
