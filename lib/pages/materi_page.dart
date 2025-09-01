import 'package:flutter/material.dart';
import 'soal_page.dart';  // Bisa diubah ke halaman lain sesuai navigasi

class MateriPage extends StatelessWidget {
  const MateriPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Materi')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,  // Atur jumlah kolom
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
          ),
          itemCount: 6, // Misalnya ada 6 materi
          itemBuilder: (context, index) {
            return _CardMateri(
              title: 'Materi ${index + 1}',
              onOpen: () {
                // Navigasi ke SoalPage atau materi lainnya
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SoalPage()),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _CardMateri extends StatelessWidget {
  final String title;
  final VoidCallback onOpen;  // Tidak perlu const karena onOpen adalah fungsi

  const _CardMateri({
    required this.title,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE6E8EC)),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(blurRadius: 18, color: Color(0x14000000), offset: Offset(0, 8))],
      ),
      child: Column(
        children: [
          Container(
            height: 120,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: const Icon(Icons.view_in_ar_rounded, size: 42, color: Color(0xFF475467)),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: onOpen,
                child: const Text('Buka'),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

