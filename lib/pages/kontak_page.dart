import 'package:flutter/material.dart';
import '../sidebar.dart';

class KontakPage extends StatelessWidget {
  const KontakPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SideMenu(currentIndex: 4, onSelect: _noop),
      appBar: AppBar(title: const Text('Kontak')),
      body: Center(child: const Text('Kontak (coming soon)')),
    );
  }
}

void _noop(int _) {}
