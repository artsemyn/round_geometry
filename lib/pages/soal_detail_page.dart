import 'package:flutter/material.dart';

class SoalDetailPage extends StatelessWidget {
  final int soalId;
  const SoalDetailPage({super.key, required this.soalId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Soal ${soalId}')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Pertanyaan:'),
            const SizedBox(height: 10),
            const Text('Pilih jawaban yang benar'),
            const SizedBox(height: 20),
            ...List.generate(4, (index) {
              return RadioListTile<int>(
                value: index,
                groupValue: 0,  // Misalnya 0 adalah jawaban yang dipilih
                onChanged: (value) {},
                title: Text('Pilihan ${index + 1}'),
              );
            }),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Logika kirim jawaban
                Navigator.pop(context);
              },
              child: const Text('Kirim Jawaban'),
            ),
          ],
        ),
      ),
    );
  }
}
