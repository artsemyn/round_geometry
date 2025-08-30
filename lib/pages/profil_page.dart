import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../features/gamification/stats_service.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});
  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  int xp = 0;
  int selesai = 0;
  int total = 0;
  List<String> badgeNames = [];
  bool loading = true;
  final _stats = StatsService();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = Supabase.instance.client.auth.currentUser!;
    final userId = user.id;

    final xpF = _stats.totalXp(userId);
    final progF = _stats.moduleProgress(userId);
    final badgesF = _stats.badges(userId);

    final results = await Future.wait([xpF, progF, badgesF]);
    setState(() {
      xp = results[0] as int;
      final p = results[1] as ({int selesai, int total});
      selesai = p.selesai; total = p.total == 0 ? 1 : p.total; // hindari /0
      badgeNames = results[2] as List<String>;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Statistika Belajar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(children: [
            _statCard('XP', '$xp'),
            const SizedBox(width: 12),
            _statCard('Modul', '$selesai/$total'),
            const SizedBox(width: 12),
            _statCard('Badge', '${badgeNames.length}'),
          ]),
          const SizedBox(height: 20),
          const Text('Badge Terakhir', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: badgeNames.isEmpty
                ? [const Text('Belum ada badge')]
                : badgeNames.take(10).map((b) => Chip(label: Text(b))).toList(),
          ),
        ]),
      ),
    );
  }

  Widget _statCard(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE6E8EC)),
          color: Colors.white,
        ),
        child: Column(children: [
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Color(0xFF667085))),
        ]),
      ),
    );
  }
}
