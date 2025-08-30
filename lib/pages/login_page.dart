import 'package:flutter/material.dart';
import '../features/auth/auth_services.dart';
import 'beranda_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController();
  final pass = TextEditingController();
  bool loading = false;
  bool showRegister = false;
  final name = TextEditingController(); // untuk register

  Future<void> _login() async {
    setState(() => loading = true);
    try {
      await AuthService().login(email.text.trim(), pass.text.trim());
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const BerandaPage()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _register() async {
    setState(() => loading = true);
    try {
      await AuthService().signUpAndCreateProfile(
        email: email.text.trim(),
        password: pass.text.trim(),
        fullName: name.text.trim(),
      );
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const BerandaPage()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            if (showRegister)
              TextField(controller: name, decoration: const InputDecoration(labelText: 'Nama lengkap')),
            TextField(controller: email, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: pass, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: loading ? null : (showRegister ? _register : _login),
              child: Text(loading ? 'Loading...' : (showRegister ? 'Register' : 'Login')),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => setState(() => showRegister = !showRegister),
              child: Text(showRegister ? 'Sudah punya akun? Login' : 'Belum punya akun? Register'),
            ),

            // (Opsional) tombol dev bypass untuk cepat lihat UI tanpa auth
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const BerandaPage()));
              },
              child: const Text('Skip (dev demo)'),
            ),
          ]),
        ),
      ),
    );
  }
}
