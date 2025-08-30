import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class ModuleService {
  Future<List<dynamic>> fetchModules() async {
    final data = await supabase.from('modules').select();
    return data;
  }
}
