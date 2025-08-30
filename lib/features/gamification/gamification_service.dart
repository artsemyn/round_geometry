import 'package:supabase_flutter/supabase_flutter.dart';

class GamificationService {
  final _sb = Supabase.instance.client;

  Future<void> markDone({required String userId, required int moduleId}) async {
    // Upsert progress (done + XP 100)
    await _sb.from('progress').upsert({
      'user_id': userId,
      'module_id': moduleId,
      'status': 'done',
      'xp': 100,
      'updated_at': DateTime.now().toIso8601String(),
    });

    // Tambahkan badge (bisa kamu variasi per modul)
    await _sb.from('achievements').insert({
      'user_id': userId,
      'badge_name': 'Arsitek Tabung',
      'xp': 100,
    });
  }
}
