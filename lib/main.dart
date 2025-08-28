import 'package:flutter/material.dart';
import 'sidebar.dart';
import 'ui/pages/beranda_page.dart';
import 'ui/pages/komunitas_page.dart';
import 'ui/pages/materi3d_page.dart';
import 'ui/pages/soal_page.dart';
import 'ui/pages/kontak_page.dart';

void main() => runApp(const RoundGeometryApp());

class RoundGeometryApp extends StatelessWidget {
  const RoundGeometryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const _Shell(),
    );
  }
}

class _Shell extends StatefulWidget {
  const _Shell({super.key});
  @override
  State<_Shell> createState() => _ShellState();
}

class _ShellState extends State<_Shell> {
  int _index = 0;

  void _select(int i) {
    setState(() => _index = i);
    Navigator.of(context).maybePop(); // tutup drawer
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const BerandaPage(),
      const KomunitasPage(),
      const Materi3DPage(),
      const SoalPage(),
      const KontakPage(),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Round Geometry')),
      drawer: SideMenu(currentIndex: _index, onSelect: _select),
      body: pages[_index],
    );
  }
}
