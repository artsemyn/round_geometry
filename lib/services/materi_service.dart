import 'package:supabase_flutter/supabase_flutter.dart';

class MateriService {
  final _client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchMateri() async {
    final res = await _client.from('materi').select();
    return List<Map<String, dynamic>>.from(res);
  }
}
