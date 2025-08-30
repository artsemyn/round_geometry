import 'package:supabase_flutter/supabase_flutter.dart';

class StatsService {
  final _sb = Supabase.instance.client;

  Future<int> totalXp(String userId) async {
    final rows = await _sb
        .from('achievements')
        .select('xp')
        .eq('user_id', userId);
    return rows.fold<int>(0, (sum, r) => sum + (r['xp'] as int? ?? 0));
  }

  Future<({int selesai, int total})> moduleProgress(String userId) async {
    final rows = await _sb
        .from('progress')
        .select('status')
        .eq('user_id', userId);
    final total = rows.length;
    final selesai = rows.where((r) => r['status'] == 'done').length;
    return (selesai: selesai, total: total);
  }

  Future<List<String>> badges(String userId) async {
    final rows = await _sb
        .from('achievements')
        .select('badge_name')
        .eq('user_id', userId)
        .order('awarded_at', ascending: false);
    return rows.map<String>((r) => r['badge_name'] as String).toList();
  }
}
