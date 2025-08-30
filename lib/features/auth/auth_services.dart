import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final _sb = Supabase.instance.client;

  Future<void> signUpAndCreateProfile({
    required String email,
    required String password,
    required String fullName,
  }) async {
    // 1) Sign up
    final res = await _sb.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName, 'role': 'siswa'},
    );

    // Kalau confirm email OFF, session biasanya sudah ada.
    // Untuk aman, login eksplisit:
    await _sb.auth.signInWithPassword(email: email, password: password);

    // 2) Ambil user yang sudah AUTHENTICATED
    final user = _sb.auth.currentUser;
    if (user == null) {
      throw 'User belum ter-authenticated. Pastikan Confirm Email dimatikan saat dev, atau login ulang.';
    }

    // 3) Upsert profile dengan id = auth.uid()
    await _sb.from('profiles').upsert({
      'id': user.id,          // <-- WAJIB sama dengan auth.uid()
      'full_name': fullName,
      'role': 'siswa',
    });
  }

  Future<void> login(String email, String password) async {
    await _sb.auth.signInWithPassword(email: email, password: password);
  }
}
