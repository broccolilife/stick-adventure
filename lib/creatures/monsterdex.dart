import 'package:flutter/material.dart';
import 'types.dart';
import 'generator.dart';
import '../data/storage.dart';

class MonsterDexScreen extends StatefulWidget {
  const MonsterDexScreen({super.key});

  @override
  State<MonsterDexScreen> createState() => _MonsterDexScreenState();
}

class _MonsterDexScreenState extends State<MonsterDexScreen> {
  late int _year;
  late int _month;
  Creature? _selectedCreature;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _year = now.year;
    _month = now.month;
  }

  void _prevMonth() {
    setState(() {
      _month--;
      if (_month < 1) { _month = 12; _year--; }
      _selectedCreature = null;
    });
  }

  void _nextMonth() {
    setState(() {
      _month++;
      if (_month > 12) { _month = 1; _year++; }
      _selectedCreature = null;
    });
  }

  void _selectDay(int day) {
    final dateStr = '$_year-${_month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
    final today = getTodayDateStr();
    if (dateStr.compareTo(today) > 0) return;
    setState(() {
      _selectedCreature = GameStorage.getCreature(dateStr) ?? getCreatureForDate(dateStr);
    });
  }

  @override
  Widget build(BuildContext context) {
    final meta = GameStorage.getMeta();
    final caught = GameStorage.getCaughtForMonth(_year, _month);
    final daysInMonth = DateTime(_year, _month + 1, 0).day;
    final firstDow = DateTime(_year, _month, 1).weekday % 7; // 0=Sun
    final today = getTodayDateStr();

    const months = ['January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'];
    const dayNames = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    return Scaffold(
      backgroundColor: const Color(0xFF0a0a1a),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('📖 MonsterDex', style: TextStyle(fontFamily: 'monospace')),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '🔥${meta.currentStreak} streak • ${meta.totalCaught} caught',
                style: const TextStyle(color: Colors.deepOrange, fontSize: 12, fontFamily: 'monospace'),
              ),
            ),
          ),
        ],
      ),
      body: _selectedCreature != null
          ? _buildDetail(_selectedCreature!)
          : _buildCalendar(months, dayNames, daysInMonth, firstDow, caught, today),
    );
  }

  Widget _buildCalendar(List<String> months, List<String> dayNames,
      int daysInMonth, int firstDow, Map<int, Creature> caught, String today) {
    return Column(
      children: [
        // Month nav
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(onPressed: _prevMonth, icon: const Icon(Icons.chevron_left, color: Colors.white)),
            Text(
              '${months[_month - 1]} $_year',
              style: const TextStyle(color: Colors.white, fontSize: 18, fontFamily: 'monospace'),
            ),
            IconButton(onPressed: _nextMonth, icon: const Icon(Icons.chevron_right, color: Colors.white)),
          ],
        ),
        // Day headers
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: dayNames.map((d) => SizedBox(
            width: 44,
            child: Center(child: Text(d, style: const TextStyle(color: Colors.grey, fontSize: 11, fontFamily: 'monospace'))),
          )).toList(),
        ),
        const SizedBox(height: 4),
        // Calendar grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7, mainAxisSpacing: 2, crossAxisSpacing: 2,
            ),
            itemCount: firstDow + daysInMonth,
            itemBuilder: (ctx, idx) {
              if (idx < firstDow) return const SizedBox();
              final day = idx - firstDow + 1;
              final dateStr = '$_year-${_month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
              final isCaught = caught.containsKey(day);
              final isToday = dateStr == today;
              final isFuture = dateStr.compareTo(today) > 0;

              return GestureDetector(
                onTap: () => _selectDay(day),
                child: Container(
                  decoration: BoxDecoration(
                    color: isToday ? Colors.white10 : Colors.white.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(4),
                    border: isToday ? Border.all(color: Colors.green, width: 2) : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$day',
                        style: TextStyle(
                          color: isFuture ? Colors.grey.shade800 : Colors.grey,
                          fontSize: 10,
                          fontFamily: 'monospace',
                        ),
                      ),
                      if (isCaught)
                        Container(
                          width: 16, height: 16,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: caught[day]!.sprite.bodyColor,
                          ),
                        )
                      else if (!isFuture)
                        const Text('?', style: TextStyle(color: Colors.grey, fontSize: 16, fontFamily: 'monospace')),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDetail(Creature c) {
    final rColor = rarityColors[c.rarity]!;
    return GestureDetector(
      onTap: () => setState(() => _selectedCreature = null),
      child: Center(
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1a1a2e),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: c.caught ? rColor : Colors.grey, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(c.date, style: const TextStyle(color: Colors.grey, fontSize: 11, fontFamily: 'monospace')),
              const SizedBox(height: 8),
              if (c.caught) ...[
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: c.sprite.bodyColor),
                ),
                const SizedBox(height: 8),
                Text(c.name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(c.element.label, style: TextStyle(color: elementColors[c.element], fontSize: 12, fontFamily: 'monospace')),
                    const SizedBox(width: 16),
                    Text(c.rarity.label, style: TextStyle(color: rColor, fontSize: 12, fontFamily: 'monospace')),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _stat('ATK', c.stats.atk),
                    _stat('DEF', c.stats.def),
                    _stat('SPD', c.stats.spd),
                    _stat('HP', c.stats.hp),
                  ],
                ),
                const SizedBox(height: 12),
                ...c.skills.map((s) => Text(
                  '• ${s.name} (${s.power})',
                  style: TextStyle(color: elementColors[s.element], fontSize: 11, fontFamily: 'monospace'),
                )),
                const SizedBox(height: 8),
                Text('Drop: ${c.item.name}', style: const TextStyle(color: Color(0xFFffd700), fontSize: 11, fontFamily: 'monospace')),
                const SizedBox(height: 8),
                Text(c.lore, style: const TextStyle(color: Colors.grey, fontSize: 10, fontFamily: 'monospace'), textAlign: TextAlign.center),
              ] else ...[
                const Text('?', style: TextStyle(color: Colors.grey, fontSize: 40, fontFamily: 'monospace')),
                const Text('MISSED', style: TextStyle(color: Colors.grey, fontSize: 12, fontFamily: 'monospace')),
              ],
              const SizedBox(height: 12),
              const Text('Tap to close', style: TextStyle(color: Colors.grey, fontSize: 10, fontFamily: 'monospace')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stat(String label, int value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10, fontFamily: 'monospace')),
        Text('$value', style: const TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'monospace')),
      ],
    );
  }
}
