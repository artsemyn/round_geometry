import 'package:supabase_flutter/supabase_flutter.dart';

class LessonService {
  final _sb = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchModules() async {
    final rows = await _sb
        .from('modules')
        .select('id,title,description,type,content')
        .order('id');
    return rows.cast<Map<String, dynamic>>();
  }
}
