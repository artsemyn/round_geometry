import 'package:flutter/material.dart';
import 'pages/beranda_page.dart';
import 'pages/komunitas_page.dart';
import 'pages/materi_page.dart';
import 'pages/soal_page.dart';
import 'pages/kontak_page.dart';
import 'pages/profil_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/config.dart';

void main() async {
  await Supabase.initialize(
    url: AppConfig.current().supabaseUrl,
    anonKey: AppConfig.current().supabaseAnonKey,
  );
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Round Geometry',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: const Color(0xFF57D364)),
      initialRoute: '/', // beranda default
      routes: {
        '/': (context) => const BerandaPage(),
        '/komunitas': (context) => const KomunitasPage(),
        '/materi': (context) => const MateriPage(),   // <<< Materi route
        '/soal': (context) => const SoalPage(),
        '/kontak': (context) => const KontakPage(),
        '/profil': (context) => const ProfilPage(),
      },
    );
  }
}
