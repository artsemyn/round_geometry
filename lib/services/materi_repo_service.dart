// lib/services/materi_repo.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class MateriRepo {
  final _sb = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchMateri() async {
    final rows = await _sb
        .from('materials')
        .select('id,title,description,bucket,glb_path,is_public')
        .order('created_at', ascending: false) as List;

    final items = <Map<String, dynamic>>[];

    for (final r in rows.cast<Map<String, dynamic>>()) {
      final bucket = (r['bucket'] as String?) ?? '';
      final path = (r['glb_path'] as String?) ?? '';
      final isPublic = (r['is_public'] as bool?) ?? false;

      String? url;
      if (bucket.isNotEmpty && path.isNotEmpty) {
        try {
          url = isPublic
              ? _sb.storage.from(bucket).getPublicUrl(path)
              : await _sb.storage.from(bucket).createSignedUrl(path, 3600);
        } catch (e) {
          url = null;
        }
      }

      // debug log untuk cek
      print("📦 $bucket | 📂 $path => 🔗 $url");

      items.add({
        ...r,
        'glb_url': url,
      });
    }

    return items;
  }
}
