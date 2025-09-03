import 'package:flutter/material.dart';
import 'materi_page.dart';
import '../sidebar.dart';

class BerandaPage extends StatelessWidget {
  const BerandaPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SideMenu(currentIndex: 0, onSelect: _noop),
      appBar: AppBar(title: const Text('Beranda')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MateriPage())),
          child: const Text('Buka Materi'),
        ),
      ),
    );
  }
}

void _noop(int _) {}
