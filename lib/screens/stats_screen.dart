import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:word_guessing_game/models/player_stats.dart';
import 'package:word_guessing_game/models/game_record.dart';
import 'package:word_guessing_game/models/game_state.dart';
import 'package:word_guessing_game/services/stats_service.dart';
import 'package:word_guessing_game/utils/time_utils.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final StatsService _statsService = StatsService();

  List<PlayerStats> _playerStats = [];
  List<GameRecord> _gameRecords = [];
  int _totalGames = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadStats();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadStats() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final statsMap = await _statsService.getAllPlayerStats();
      final records = await _statsService.getGameRecords();
      final totalGames = await _statsService.getTotalGames();

      setState(() {
        _playerStats = statsMap.values.toList();
        _gameRecords = records;
        _totalGames = totalGames;
        _isLoading = false;
      });

      // เรียงลำดับสถิติ
      _playerStats.sort((a, b) => b.totalGames.compareTo(a.totalGames));
      _gameRecords.sort((a, b) => b.playedAt.compareTo(a.playedAt));
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C3E50),
        foregroundColor: Colors.white,
        title: Text(
          '📊 สถิติการเล่น',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(onPressed: _loadStats, icon: const Icon(Icons.refresh)),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'clear') {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('ยืนยันการลบ'),
                    content: const Text(
                      'คุณต้องการลบสถิติทั้งหมดหรือไม่? การดำเนินการนี้ไม่สามารถยกเลิกได้',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('ยกเลิก'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('ลบ'),
                      ),
                    ],
                  ),
                );

                if (confirmed == true) {
                  await _statsService.clearAllStats();
                  _loadStats();
                }
              } else if (value == 'clear_players') {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('ยืนยันการลบ'),
                    content: const Text(
                      'คุณต้องการลบรายชื่อผู้เล่นที่บันทึกไว้ทั้งหมดหรือไม่?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('ยกเลิก'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('ลบ'),
                      ),
                    ],
                  ),
                );

                if (confirmed == true) {
                  // ลบรายชื่อผู้เล่นที่บันทึกไว้
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('saved_players');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'ลบรายชื่อผู้เล่นแล้ว',
                        style: GoogleFonts.poppins(),
                      ),
                      backgroundColor: const Color(0xFF27AE60),
                    ),
                  );
                }
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear_players',
                child: Row(
                  children: [
                    Icon(Icons.people_outline, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('ลบรายชื่อผู้เล่น'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.delete_forever, color: Colors.red),
                    SizedBox(width: 8),
                    Text('ลบสถิติทั้งหมด'),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'ภาพรวม'),
            Tab(text: 'ผู้เล่น'),
            Tab(text: 'ประวัติ'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildPlayersTab(),
                _buildHistoryTab(),
              ],
            ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // สถิติรวม
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2C3E50), Color(0xFF3498DB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  '📈 สถิติรวม',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('เกมทั้งหมด', '$_totalGames', Icons.games),
                    _buildStatItem(
                      'ผู้เล่น',
                      '${_playerStats.length}',
                      Icons.people,
                    ),
                    _buildStatItem(
                      'เกมล่าสุด',
                      _gameRecords.isNotEmpty
                          ? TimeUtils.formatDate(_gameRecords.first.playedAt)
                          : 'ไม่มี',
                      Icons.schedule,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ผู้เล่นยอดเยี่ยม
          if (_playerStats.isNotEmpty) ...[
            Text(
              '🏆 ผู้เล่นยอดเยี่ยม',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 12),
            ..._playerStats.take(3).map((stats) => _buildTopPlayerCard(stats)),
          ],

          const SizedBox(height: 24),

          // สถิติเร็วที่สุด
          if (_playerStats.isNotEmpty) ...[
            Text(
              '⚡ เวลาดีที่สุด',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 12),
            ...(_playerStats
                    .where((stats) => stats.fastestTime != Duration.zero)
                    .toList()
                  ..sort((a, b) => a.fastestTime.compareTo(b.fastestTime)))
                .take(3)
                .map((stats) => _buildFastestTimeCard(stats)),
          ],
        ],
      ),
    );
  }

  Widget _buildPlayersTab() {
    if (_playerStats.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: const Color(0xFF7F8C8D),
            ),
            const SizedBox(height: 16),
            Text(
              'ยังไม่มีสถิติผู้เล่น',
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: const Color(0xFF2C3E50),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _playerStats.length,
      itemBuilder: (context, index) {
        final stats = _playerStats[index];
        return _buildPlayerStatsCard(stats);
      },
    );
  }

  Widget _buildHistoryTab() {
    if (_gameRecords.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: const Color(0xFF7F8C8D)),
            const SizedBox(height: 16),
            Text(
              'ยังไม่มีประวัติเกม',
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: const Color(0xFF2C3E50),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _gameRecords.length,
      itemBuilder: (context, index) {
        final record = _gameRecords[index];
        return _buildGameRecordCard(record);
      },
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildTopPlayerCard(PlayerStats stats) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE9ECEF)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF2C3E50),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Center(
              child: Text(
                '${stats.gamesWon}',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stats.playerName,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2C3E50),
                  ),
                ),
                Text(
                  'ชนะ ${stats.gamesWon} เกม จาก ${stats.totalGames} เกม',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: const Color(0xFF7F8C8D),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${(stats.winRate * 100).toStringAsFixed(1)}%',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF27AE60),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFastestTimeCard(PlayerStats stats) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE9ECEF)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF27AE60),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Center(
              child: Icon(Icons.timer, color: Colors.white, size: 24),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stats.playerName,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2C3E50),
                  ),
                ),
                Text(
                  'เวลาดีที่สุด: ${TimeUtils.formatDuration(stats.fastestTime)}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: const Color(0xFF7F8C8D),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerStatsCard(PlayerStats stats) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE9ECEF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFF2C3E50),
                child: Text(
                  stats.playerName[0].toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stats.playerName,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2C3E50),
                      ),
                    ),
                    Text(
                      'เล่นครั้งล่าสุด: ${TimeUtils.formatDate(stats.lastPlayed)}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFF7F8C8D),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatColumn(
                  'เกมทั้งหมด',
                  '${stats.totalGames}',
                  Icons.games,
                ),
              ),
              Expanded(
                child: _buildStatColumn(
                  'ชนะ',
                  '${stats.gamesWon}',
                  Icons.emoji_events,
                ),
              ),
              Expanded(
                child: _buildStatColumn(
                  'แพ้',
                  '${stats.gamesLost}',
                  Icons.sentiment_dissatisfied,
                ),
              ),
              Expanded(
                child: _buildStatColumn(
                  'อัตราชนะ',
                  '${(stats.winRate * 100).toStringAsFixed(1)}%',
                  Icons.trending_up,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatColumn(
                  'เวลารวม',
                  TimeUtils.formatDuration(stats.totalPlayTime),
                  Icons.timer,
                ),
              ),
              Expanded(
                child: _buildStatColumn(
                  'เวลาดีที่สุด',
                  TimeUtils.formatDuration(stats.fastestTime),
                  Icons.flash_on,
                ),
              ),
              Expanded(
                child: _buildStatColumn(
                  'เวลาเฉลี่ย',
                  TimeUtils.formatDuration(stats.averageTime),
                  Icons.analytics,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGameRecordCard(GameRecord record) {
    final winner = record.playerResults.firstWhere(
      (result) => result.playerId == record.winnerId,
      orElse: () => record.playerResults.first,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE9ECEF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                record.gameMode == GameMode.classic ? Icons.games : Icons.timer,
                color: const Color(0xFF2C3E50),
              ),
              const SizedBox(width: 8),
              Text(
                '${record.gameMode == GameMode.classic ? 'คลาสสิค' : 'แข่งเวลา'} - ${record.totalRounds} รอบ',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2C3E50),
                ),
              ),
              const Spacer(),
              Text(
                TimeUtils.formatDate(record.playedAt),
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: const Color(0xFF7F8C8D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '🏆 ผู้ชนะ: ${winner.playerName}',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF27AE60),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '⏱️ เวลาเกม: ${TimeUtils.formatDuration(record.gameDuration)}',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xFF7F8C8D),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '👥 ผู้เล่น: ${record.playerResults.length} คน',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xFF7F8C8D),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF2C3E50), size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2C3E50),
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: const Color(0xFF7F8C8D),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
