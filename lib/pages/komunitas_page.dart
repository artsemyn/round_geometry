import 'package:flutter/material.dart';
import '../sidebar.dart';

class KomunitasPage extends StatelessWidget {
  const KomunitasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SideMenu(currentIndex: 1, onSelect: _noop),
      appBar: AppBar(title: const Text('Komunitas')),
      body: Center(child: const Text('Komunitas (coming soon)')),
    );
  }
}

void _noop(int _) {}
