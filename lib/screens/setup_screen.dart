import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import '../providers/game_provider.dart';
import '../models/game_state.dart';
import '../services/stats_service.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen>
    with TickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  GameMode _selectedMode = GameMode.classic;
  final StatsService _statsService = StatsService();
  List<String> _savedPlayerNames = [];
  late AnimationController _pulseController;
  late AnimationController _glowController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _loadSavedPlayers();

    // Initialize animations
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _glowController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // โหลดผู้เล่นที่บันทึกไว้ใน GameProvider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GameProvider>().loadSavedPlayers();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pulseController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedPlayers() async {
    try {
      final savedNames = await _statsService.getSortedPlayerNames();
      setState(() {
        _savedPlayerNames = savedNames;
      });
    } catch (e) {
      // Handle error silently
    }
  }

  void _addPlayer() {
    if (_nameController.text.trim().isNotEmpty) {
      context.read<GameProvider>().addPlayer(_nameController.text.trim());
      _nameController.clear();
      // รีเฟรชรายชื่อที่บันทึกไว้
      _loadSavedPlayers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6F0),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFDF6F0), Color(0xFFF8F0E8), Color(0xFFFDF6F0)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Game Title with gaming effects
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFFE8B4B8,
                                    ).withOpacity(0.3),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: const Color(
                                                  0xFFE8B4B8,
                                                ).withOpacity(0.3),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: Colors.white
                                                      .withOpacity(0.3),
                                                ),
                                              ),
                                              child: const Icon(
                                                Icons.sports_esports,
                                                color: Color(0xFF8B7D7B),
                                                size: 24,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              '🎮 เกมถามตอบ',
                                              style: GoogleFonts.inter(
                                                fontSize: 32,
                                                fontWeight: FontWeight.w300,
                                                color: const Color(0xFF8B7D7B),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          _buildGameButton(
                                            icon: Icons.refresh,
                                            onPressed: () {
                                              context
                                                  .read<GameProvider>()
                                                  .loadSavedPlayers();
                                              _loadSavedPlayers();
                                            },
                                            tooltip: 'รีเฟรช',
                                          ),
                                          const SizedBox(width: 8),
                                          _buildGameButton(
                                            icon: Icons.leaderboard,
                                            onPressed: () {
                                              Navigator.pushNamed(
                                                context,
                                                '/stats',
                                              );
                                            },
                                            tooltip: 'ดูสถิติ',
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'ใครใช้เวลามากสุดแพ้!',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w300,
                                      color: const Color(
                                        0xFF8B7D7B,
                                      ).withOpacity(0.8),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'แต่ละคนจะได้คำที่แตกต่างกัน ไม่ซ้ำกัน',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w300,
                                      color: const Color(
                                        0xFF8B7D7B,
                                      ).withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),

                  // Game Settings with gaming UI
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.4),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFFE8B4B8,
                                    ).withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.3),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.settings,
                                    color: Color(0xFF8B7D7B),
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  '⚙️ การตั้งค่าเกม',
                                  style: GoogleFonts.inter(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFF8B7D7B),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Game Mode Selection
                            _buildGameSettingItem(
                              label: '🎯 โหมดเกม:',
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: 5,
                                    sigmaY: 5,
                                  ),
                                  child: DropdownButtonFormField<GameMode>(
                                    value: _selectedMode,
                                    dropdownColor: Colors.white.withOpacity(
                                      0.9,
                                    ),
                                    style: GoogleFonts.inter(
                                      color: const Color(0xFF8B7D7B),
                                      fontWeight: FontWeight.w300,
                                    ),
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.white.withOpacity(0.4),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 16,
                                          ),
                                    ),
                                    items: const [
                                      DropdownMenuItem(
                                        value: GameMode.classic,
                                        child: Text(
                                          '🎯 คลาสสิค',
                                          style: TextStyle(
                                            color: Color(0xFF8B7D7B),
                                          ),
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: GameMode.timeAttack,
                                        child: Text(
                                          '⏰ แข่งเวลา',
                                          style: TextStyle(
                                            color: Color(0xFF8B7D7B),
                                          ),
                                        ),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      if (value != null) {
                                        setState(() {
                                          _selectedMode = value;
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Word Category Selection
                            Consumer<GameProvider>(
                              builder: (context, gameProvider, child) {
                                return _buildGameSettingItem(
                                  label: '📚 หมวดหมู่คำ:',
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(
                                        sigmaX: 5,
                                        sigmaY: 5,
                                      ),
                                      child: DropdownButtonFormField<String>(
                                        value: gameProvider.selectedCategory,
                                        dropdownColor: Colors.white.withOpacity(
                                          0.9,
                                        ),
                                        style: GoogleFonts.inter(
                                          color: const Color(0xFF8B7D7B),
                                          fontWeight: FontWeight.w300,
                                        ),
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: Colors.white.withOpacity(
                                            0.4,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            borderSide: BorderSide.none,
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 20,
                                                vertical: 16,
                                              ),
                                        ),
                                        items: gameProvider.availableCategories
                                            .map(
                                              (category) => DropdownMenuItem(
                                                value: category,
                                                child: Text(
                                                  category,
                                                  style: const TextStyle(
                                                    color: Color(0xFF8B7D7B),
                                                  ),
                                                ),
                                              ),
                                            )
                                            .toList(),
                                        onChanged: (value) {
                                          if (value != null) {
                                            gameProvider.setSelectedCategory(
                                              value,
                                            );
                                            gameProvider
                                                .assignWordsByCategory();
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Add Player Section with gaming UI
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.4),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFFE8B4B8,
                                    ).withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.3),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.person_add,
                                    color: Color(0xFF8B7D7B),
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  '👥 เพิ่มผู้เล่น',
                                  style: GoogleFonts.inter(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFF8B7D7B),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            Row(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(
                                        sigmaX: 5,
                                        sigmaY: 5,
                                      ),
                                      child: TextField(
                                        controller: _nameController,
                                        style: GoogleFonts.inter(
                                          color: const Color(0xFF8B7D7B),
                                          fontWeight: FontWeight.w300,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: 'ชื่อผู้เล่น',
                                          hintStyle: GoogleFonts.inter(
                                            color: const Color(0xFFB8A9A7),
                                            fontWeight: FontWeight.w300,
                                          ),
                                          filled: true,
                                          fillColor: Colors.white.withOpacity(
                                            0.4,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            borderSide: BorderSide.none,
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 20,
                                                vertical: 16,
                                              ),
                                        ),
                                        onSubmitted: (value) {
                                          if (value.trim().isNotEmpty) {
                                            _addPlayer();
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                _buildGameActionButton(
                                  onPressed: _addPlayer,
                                  child: const Text('เพิ่ม'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Players List with gaming UI
                  Consumer<GameProvider>(
                    builder: (context, gameProvider, child) {
                      final players = gameProvider.gameState.players;

                      if (players.isEmpty) {
                        return _buildEmptyState();
                      }

                      return ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.4),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFFE8B4B8,
                                        ).withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.3),
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.people,
                                        color: Color(0xFF8B7D7B),
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      '📋 รายชื่อผู้เล่น (${players.length} คน)',
                                      style: GoogleFonts.inter(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w400,
                                        color: const Color(0xFF8B7D7B),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                ...players.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final player = entry.value;
                                  return _buildPlayerCard(
                                    index,
                                    player,
                                    gameProvider,
                                  );
                                }).toList(),
                                const SizedBox(height: 20),
                                if (players.length >= 2)
                                  _buildGameActionButtons(gameProvider),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: IconButton(
            onPressed: onPressed,
            icon: Icon(icon, color: const Color(0xFF8B7D7B), size: 24),
            tooltip: tooltip,
          ),
        ),
      ),
    );
  }

  Widget _buildGameSettingItem({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF8B7D7B),
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildGameActionButton({
    required VoidCallback onPressed,
    required Widget child,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFE8B4B8).withOpacity(0.4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.4), width: 1),
          ),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: const Icon(
                      Icons.people_outline,
                      size: 48,
                      color: Color(0xFFB8A9A7),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'ยังไม่มีผู้เล่น',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF8B7D7B),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'เพิ่มผู้เล่นอย่างน้อย 2 คนเพื่อเริ่มเกม\nหรือคลิกปุ่มรีเฟรชเพื่อโหลดผู้เล่นที่เคยบันทึกไว้',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                  color: const Color(0xFFB8A9A7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerCard(
    int index,
    dynamic player,
    GameProvider gameProvider,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: player.isAsker
                ? const Color(0xFFD4A5A5).withOpacity(0.4)
                : Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.4), width: 1),
          ),
          child: Row(
            children: [
              // Player Avatar
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8B4B8).withOpacity(0.4),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF8B7D7B),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  player.name,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF8B7D7B),
                  ),
                ),
              ),
              // Asker Badge
              if (player.isAsker)
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4A5A5).withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        'คนถาม',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF8B7D7B),
                        ),
                      ),
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              // Set Asker Button
              if (!player.isAsker)
                _buildSmallGameButton(
                  onPressed: () {
                    gameProvider.setAsker(player.id);
                  },
                  child: const Text('ตั้งเป็นคนถาม'),
                ),
              const SizedBox(width: 8),
              // Remove Button
              _buildSmallGameButton(
                onPressed: () {
                  context.read<GameProvider>().removePlayer(player.id);
                },
                child: const Icon(Icons.delete, size: 16),
                isDestructive: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSmallGameButton({
    required VoidCallback onPressed,
    required Widget child,
    bool isDestructive = false,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
        child: Container(
          decoration: BoxDecoration(
            color: isDestructive
                ? const Color(0xFFE74C3C).withOpacity(0.2)
                : const Color(0xFFE8B4B8).withOpacity(0.4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: child is Icon
                ? Icon(
                    (child as Icon).icon,
                    color: const Color(0xFF8B7D7B),
                    size: 16,
                  )
                : child,
          ),
        ),
      ),
    );
  }

  Widget _buildGameActionButtons(GameProvider gameProvider) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFE8B4B8).withOpacity(0.4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: ElevatedButton.icon(
                onPressed: () {
                  gameProvider.assignWordsToPlayers();
                },
                icon: const Icon(Icons.refresh, color: Color(0xFF8B7D7B)),
                label: Text(
                  '🔄 สุ่มคำใหม่',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF8B7D7B),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        AnimatedBuilder(
          animation: _glowAnimation,
          builder: (context, child) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8B4B8).withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(
                          0xFFE8B4B8,
                        ).withOpacity(_glowAnimation.value),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      gameProvider.setGameMode(_selectedMode);
                      gameProvider.startGame();
                      Navigator.pushReplacementNamed(context, '/game');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      '🚀 เริ่มเกม',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF8B7D7B),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
