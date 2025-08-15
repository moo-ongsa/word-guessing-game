import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/game_provider.dart';
import '../models/game_state.dart';
import '../services/stats_service.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final TextEditingController _nameController = TextEditingController();
  int _selectedRounds = 3;
  GameMode _selectedMode = GameMode.classic;
  final StatsService _statsService = StatsService();
  List<String> _savedPlayerNames = [];

  @override
  void initState() {
    super.initState();
    _loadSavedPlayers();
    // โหลดผู้เล่นที่บันทึกไว้ใน GameProvider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GameProvider>().loadSavedPlayers();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '🎮 เกมถามตอบ',
                        style: GoogleFonts.poppins(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2C3E50),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            context.read<GameProvider>().loadSavedPlayers();
                            _loadSavedPlayers();
                          },
                          icon: const Icon(
                            Icons.refresh,
                            color: Color(0xFF2C3E50),
                            size: 28,
                          ),
                          tooltip: 'รีเฟรช',
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/stats');
                          },
                          icon: const Icon(
                            Icons.bar_chart,
                            color: Color(0xFF2C3E50),
                            size: 28,
                          ),
                          tooltip: 'ดูสถิติ',
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'ใครใช้เวลามากสุดแพ้!',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: const Color(0xFF7F8C8D),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'แต่ละคนจะได้คำที่แตกต่างกัน ไม่ซ้ำกัน',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: const Color(0xFF7F8C8D),
                  ),
                ),
                const SizedBox(height: 40),

                // Game Settings
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '⚙️ การตั้งค่าเกม',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Game Mode
                      Text(
                        'โหมดเกม:',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: const Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<GameMode>(
                        value: _selectedMode,
                        dropdownColor: Colors.white,
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF2C3E50),
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: const Color(0xFFE9ECEF),
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: GameMode.classic,
                            child: Text(
                              '🎯 คลาสสิค',
                              style: TextStyle(color: Color(0xFF2C3E50)),
                            ),
                          ),
                          DropdownMenuItem(
                            value: GameMode.timeAttack,
                            child: Text(
                              '⏰ แข่งเวลา',
                              style: TextStyle(color: Color(0xFF2C3E50)),
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
                      const SizedBox(height: 20),

                      // Number of Rounds
                      Text(
                        'จำนวนรอบ:',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: const Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<int>(
                        value: _selectedRounds,
                        dropdownColor: Colors.white,
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF2C3E50),
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: const Color(0xFFE9ECEF),
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        items: List.generate(10, (index) => index + 1)
                            .map(
                              (rounds) => DropdownMenuItem(
                                value: rounds,
                                child: Text(
                                  '$rounds รอบ',
                                  style: const TextStyle(
                                    color: Color(0xFF2C3E50),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedRounds = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 20),

                      // Word Category
                      Text(
                        'หมวดหมู่คำ:',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: const Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Consumer<GameProvider>(
                        builder: (context, gameProvider, child) {
                          return DropdownButtonFormField<String>(
                            value: gameProvider.selectedCategory,
                            dropdownColor: Colors.white,
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF2C3E50),
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: const Color(0xFFE9ECEF),
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            items: gameProvider.availableCategories
                                .map(
                                  (category) => DropdownMenuItem(
                                    value: category,
                                    child: Text(
                                      category,
                                      style: const TextStyle(
                                        color: Color(0xFF2C3E50),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                gameProvider.setSelectedCategory(value);
                                gameProvider.assignWordsByCategory();
                              }
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Add Player Section
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '👥 เพิ่มผู้เล่น',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // รายชื่อที่เคยบันทึกไว้ (สำหรับเพิ่มใหม่)
                      if (_savedPlayerNames.isNotEmpty) ...[
                        Text(
                          '📋 ผู้เล่นที่เคยบันทึกไว้ (คลิกเพื่อเพิ่ม):',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF2C3E50),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _savedPlayerNames.map((name) {
                            final isAlreadyAdded = context
                                .read<GameProvider>()
                                .gameState
                                .players
                                .any((player) => player.name == name);
                            return ActionChip(
                              label: Text(
                                name,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: isAlreadyAdded
                                      ? const Color(0xFF7F8C8D)
                                      : const Color(0xFF2C3E50),
                                ),
                              ),
                              onPressed: isAlreadyAdded
                                  ? null
                                  : () {
                                      context.read<GameProvider>().addPlayer(
                                        name,
                                      );
                                    },
                              backgroundColor: isAlreadyAdded
                                  ? const Color(0xFFF8F9FA)
                                  : Colors.white,
                              side: BorderSide(
                                color: isAlreadyAdded
                                    ? const Color(0xFFE9ECEF)
                                    : const Color(0xFF2C3E50),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                      ],

                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _nameController,
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF2C3E50),
                              ),
                              decoration: InputDecoration(
                                hintText: 'ชื่อผู้เล่น',
                                hintStyle: GoogleFonts.poppins(
                                  color: const Color(0xFF7F8C8D),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: const Color(0xFFE9ECEF),
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              onSubmitted: (value) {
                                if (value.trim().isNotEmpty) {
                                  _addPlayer();
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: _addPlayer,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2C3E50),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'เพิ่ม',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Players List
                Consumer<GameProvider>(
                  builder: (context, gameProvider, child) {
                    final players = gameProvider.gameState.players;

                    if (players.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(40),
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
                            Icon(
                              Icons.people_outline,
                              size: 48,
                              color: const Color(0xFF7F8C8D),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'ยังไม่มีผู้เล่น',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                color: const Color(0xFF2C3E50),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'เพิ่มผู้เล่นอย่างน้อย 2 คนเพื่อเริ่มเกม\nหรือคลิกปุ่มรีเฟรชเพื่อโหลดผู้เล่นที่เคยบันทึกไว้',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: const Color(0xFF7F8C8D),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return Container(
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
                            '📋 รายชื่อผู้เล่น (${players.length} คน)',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF2C3E50),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ...players.asMap().entries.map((entry) {
                            final index = entry.key;
                            final player = entry.value;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFE9ECEF),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2C3E50),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${index + 1}',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      player.name,
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        color: const Color(0xFF2C3E50),
                                      ),
                                    ),
                                  ),
                                  if (player.isAsker)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.withOpacity(0.8),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'คนถาม',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  const SizedBox(width: 8),
                                  if (!player.isAsker)
                                    ElevatedButton(
                                      onPressed: () {
                                        gameProvider.setAsker(player.id);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF3498DB,
                                        ),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        'ตั้งเป็นคนถาม',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    onPressed: () {
                                      context.read<GameProvider>().removePlayer(
                                        player.id,
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.delete,
                                      color: const Color(0xFF7F8C8D),
                                    ),
                                    iconSize: 20,
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          const SizedBox(height: 16),
                          if (players.length >= 2)
                            Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          // สุ่มคำใหม่
                                          gameProvider.assignWordsToPlayers();
                                        },
                                        icon: const Icon(Icons.refresh),
                                        label: Text(
                                          '🔄 สุ่มคำใหม่',
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFF3498DB,
                                          ),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          gameProvider.setTotalRounds(
                                            _selectedRounds,
                                          );
                                          gameProvider.setGameMode(
                                            _selectedMode,
                                          );
                                          gameProvider.startGame();
                                          Navigator.pushReplacementNamed(
                                            context,
                                            '/game',
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFF2C3E50,
                                          ),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 16,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          '🚀 เริ่มเกม',
                                          style: GoogleFonts.poppins(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                        ],
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
    );
  }
}
