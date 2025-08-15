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
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF6B9D),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          '📊 สถิติการเล่น',
          style: GoogleFonts.nunito(fontWeight: FontWeight.bold),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: _loadStats,
              icon: const Icon(Icons.refresh, color: Colors.white),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onSelected: (value) async {
                if (value == 'clear') {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      title: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF6B9D).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.delete_forever,
                              color: Color(0xFFFF6B9D),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'ยืนยันการลบ',
                            style: GoogleFonts.nunito(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF8B5A96),
                            ),
                          ),
                        ],
                      ),
                      content: Text(
                        'คุณต้องการลบสถิติทั้งหมดหรือไม่? การดำเนินการนี้ไม่สามารถยกเลิกได้',
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          color: const Color(0xFF8B5A96),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(
                            'ยกเลิก',
                            style: GoogleFonts.nunito(
                              fontSize: 16,
                              color: const Color(0xFFB8A9C9),
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF6B9D), Color(0xFFFFB3D9)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'ลบ',
                              style: GoogleFonts.nunito(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
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
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      title: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFD93D).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.people_outline,
                              color: Color(0xFFFFD93D),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'ยืนยันการลบ',
                            style: GoogleFonts.nunito(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF8B5A96),
                            ),
                          ),
                        ],
                      ),
                      content: Text(
                        'คุณต้องการลบรายชื่อผู้เล่นที่บันทึกไว้ทั้งหมดหรือไม่?',
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          color: const Color(0xFF8B5A96),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(
                            'ยกเลิก',
                            style: GoogleFonts.nunito(
                              fontSize: 16,
                              color: const Color(0xFFB8A9C9),
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFD93D), Color(0xFFFFE5A3)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'ลบ',
                              style: GoogleFonts.nunito(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
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
                          style: GoogleFonts.nunito(),
                        ),
                        backgroundColor: const Color(0xFF6C5CE7),
                      ),
                    );
                  }
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'clear_players',
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD93D).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.people_outline,
                          color: Color(0xFFFFD93D),
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'ลบรายชื่อผู้เล่น',
                        style: GoogleFonts.nunito(
                          color: const Color(0xFF8B5A96),
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'clear',
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6B9D).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.delete_forever,
                          color: Color(0xFFFF6B9D),
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'ลบสถิติทั้งหมด',
                        style: GoogleFonts.nunito(
                          color: const Color(0xFF8B5A96),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelStyle: GoogleFonts.nunito(fontWeight: FontWeight.bold),
          unselectedLabelStyle: GoogleFonts.nunito(fontWeight: FontWeight.w500),
          tabs: const [
            Tab(text: 'ภาพรวม'),
            Tab(text: 'ผู้เล่น'),
            Tab(text: 'ประวัติ'),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF8F0), Color(0xFFFFF0F5), Color(0xFFFFF8F0)],
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(),
                  _buildPlayersTab(),
                  _buildHistoryTab(),
                ],
              ),
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
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6B9D), Color(0xFFFFB3D9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF6B9D).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.analytics,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'สถิติรวม',
                      style: GoogleFonts.nunito(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
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
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD93D),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.emoji_events,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'ผู้เล่นยอดเยี่ยม',
                  style: GoogleFonts.nunito(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF8B5A96),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._playerStats.take(3).map((stats) => _buildTopPlayerCard(stats)),
          ],

          const SizedBox(height: 24),

          // สถิติเร็วที่สุด
          if (_playerStats.isNotEmpty) ...[
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C5CE7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.flash_on,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'เวลาดีที่สุด',
                  style: GoogleFonts.nunito(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF8B5A96),
                  ),
                ),
              ],
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
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8F0),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.people_outline,
                size: 64,
                color: Color(0xFFB8A9C9),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'ยังไม่มีสถิติผู้เล่น',
              style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF8B5A96),
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
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8F0),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.history,
                size: 64,
                color: Color(0xFFB8A9C9),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'ยังไม่มีประวัติเกม',
              style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF8B5A96),
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
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: Colors.white, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.nunito(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 12,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildTopPlayerCard(PlayerStats stats) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5A96).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6B9D), Color(0xFFFFB3D9)],
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF6B9D).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '${stats.gamesWon}',
                style: GoogleFonts.nunito(
                  fontSize: 20,
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
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF8B5A96),
                  ),
                ),
                Text(
                  'ชนะ ${stats.gamesWon} เกม จาก ${stats.totalGames} เกม',
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    color: const Color(0xFFB8A9C9),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '${(stats.winRate * 100).toStringAsFixed(1)}%',
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFastestTimeCard(PlayerStats stats) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5A96).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6C5CE7).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Icon(Icons.timer, color: Colors.white, size: 28),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stats.playerName,
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF8B5A96),
                  ),
                ),
                Text(
                  'เวลาดีที่สุด: ${TimeUtils.formatDuration(stats.fastestTime)}',
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    color: const Color(0xFFB8A9C9),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5A96).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B9D), Color(0xFFFFB3D9)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Center(
                  child: Text(
                    stats.playerName[0].toUpperCase(),
                    style: GoogleFonts.nunito(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 18,
                    ),
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
                      style: GoogleFonts.nunito(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF8B5A96),
                      ),
                    ),
                    Text(
                      'เล่นครั้งล่าสุด: ${TimeUtils.formatDate(stats.lastPlayed)}',
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        color: const Color(0xFFB8A9C9),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5A96).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: record.gameMode == GameMode.classic
                      ? const Color(0xFFFF6B9D).withOpacity(0.1)
                      : const Color(0xFF6C5CE7).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  record.gameMode == GameMode.classic
                      ? Icons.games
                      : Icons.timer,
                  color: record.gameMode == GameMode.classic
                      ? const Color(0xFFFF6B9D)
                      : const Color(0xFF6C5CE7),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${record.gameMode == GameMode.classic ? 'คลาสสิค' : 'แข่งเวลา'} - ${record.totalRounds} รอบ',
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF8B5A96),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8F0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  TimeUtils.formatDate(record.playedAt),
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    color: const Color(0xFFB8A9C9),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD93D), Color(0xFFFFE5A3)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '🏆 ผู้ชนะ: ${winner.playerName}',
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '⏱️ เวลาเกม: ${TimeUtils.formatDuration(record.gameDuration)}',
            style: GoogleFonts.nunito(
              fontSize: 14,
              color: const Color(0xFFB8A9C9),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '👥 ผู้เล่น: ${record.playerResults.length} คน',
            style: GoogleFonts.nunito(
              fontSize: 14,
              color: const Color(0xFFB8A9C9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8F0),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF8B5A96), size: 20),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.nunito(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF8B5A96),
          ),
        ),
        Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 10,
            color: const Color(0xFFB8A9C9),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
