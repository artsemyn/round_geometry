import 'package:flutter/material.dart';
import '../../services/ai_grader_service.dart';
import '../sidebar.dart';

class SoalPage extends StatefulWidget {
  const SoalPage({super.key});

  @override
  State<SoalPage> createState() => _SoalPageState();
}

class _SoalPageState extends State<SoalPage> {
  final TextEditingController _answerCtrl = TextEditingController();

  // NOTE:
  // - Web/Desktop: http://127.0.0.1:54321/...
  // - Android emulator: ganti ke http://10.0.2.2:54321/...
  final AiGraderService _grader =
      AiGraderService("http://127.0.0.1:54321/functions/v1/grade-essay");

  bool _loading = false;
  String _result = "";
  List<int> _scores = const [];        // <— simpan skor di state

  Future<void> _nilaiAI() async {
    if (_answerCtrl.text.trim().isEmpty) {
      setState(() => _result = "Tulis jawaban dulu ya 🙂");
      return;
    }
    setState(() {
      _loading = true;
      _result = "";
      _scores = const [];
    });

    try {
      final data = await _grader.grade(
        problemText: "Hitung volume tabung jari-jari 7 cm dan tinggi 10 cm.",
        studentAnswer: _answerCtrl.text,
      );

      // dukung dua format (JSON-only & FEEDBACK/SKOR)
      if (data.containsKey("explanation")) {
        _scores = List<int>.from(data["scores"] as List);
        _result =
            "Skor total: ${data['total']}\nPenjelasan: ${data['explanation']}";
      } else {
        _scores = List<int>.from(data["scores"] as List);
        _result =
            "Skor: ${data['scores']}\nFeedback: ${data['feedback'] ?? ''}";
      }
    } catch (e) {
      _result = "Error: $e";
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _answerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SideMenu(currentIndex: 3, onSelect: _noop),
      appBar: AppBar(title: const Text("Soal")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Soal:\nHitung volume tabung jari-jari 7 cm dan tinggi 10 cm.",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _answerCtrl,
              minLines: 3,
              maxLines: 6,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Tulis jawabanmu di sini (langkah-langkah)...",
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loading ? null : _nilaiAI,
              child: _loading
                  ? const SizedBox(
                      height: 16, width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text("Nilai AI"),
            ),
            const SizedBox(height: 12),

            // tampilkan chip skor kalau ada
            if (_scores.isNotEmpty) _scoreChips(_scores),
            const SizedBox(height: 8),

            // dan ringkasan teksnya
            if (_result.isNotEmpty)
              Text(_result, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

void _noop(int _) {}

// helper chip (punya kamu – aku biarkan di file yang sama untuk simpel)
Widget _scoreChips(List<int> scores) {
  final labels = const ["Rumus", "Substitusi", "Hitung"];
  return Wrap(
    spacing: 8,
    runSpacing: 8,
    children: List.generate(scores.length, (i) {
      final ok = scores[i] == 1;
      return Chip(
        label: Text("${labels[i]}: ${ok ? "OK" : "X"}"),
        backgroundColor: ok ? const Color(0xFFEFFBF1) : const Color(0xFFFFF2F0),
        labelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          color: ok ? const Color(0xFF166534) : const Color(0xFFB42318),
        ),
        side: BorderSide(
          color: ok ? const Color(0xFF86EFAC) : const Color(0xFFFECACA),
        ),
      );
    }),
  );
}
