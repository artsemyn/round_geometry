import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../features/gamification/gamification_service.dart';

class Materi3DPage extends StatefulWidget {
  final int? moduleId;
  final String? moduleTitle;
  final String initialSrc;

  const Materi3DPage({
    super.key,
    required this.initialSrc,
    this.moduleId,
    this.moduleTitle,
  });

  @override
  State<Materi3DPage> createState() => _Materi3DPageState();
}

class _Materi3DPageState extends State<Materi3DPage> {
  double r = 7;   // jari-jari
  double t = 10;  // tinggi
  bool saving = false;

  @override
  Widget build(BuildContext context) {
    final title = widget.moduleTitle ?? 'Viewer 3D';
    final isWide = MediaQuery.of(context).size.width > 980;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: isWide
          ? Row(
              children: [
                Expanded(child: _viewer()),
                SizedBox(width: 360, child: _panel()),
              ],
            )
          : ListView(
              children: [
                SizedBox(height: 280, child: _viewer()),
                _panel(),
              ],
            ),
    );
  }

  Widget _viewer() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: ModelViewer(
          src: widget.initialSrc,
          ar: false,
          autoRotate: true,
          cameraControls: true,
          disableZoom: false,
          backgroundColor: const Color(0xFFF8FAFC),
        ),
      ),
    );
  }

  Widget _panel() {
    final volume = math.pi * r * r * t; // V tabung

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE6E8EC)),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(blurRadius: 18, color: Color(0x14000000), offset: Offset(0, 8))],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Eksperimen Rumus', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Math.tex(r'V_{\text{tabung}} = \pi \cdot r^{2} \cdot t', textStyle: const TextStyle(fontSize: 20)),
          const SizedBox(height: 8),
          Text('r = ${r.toStringAsFixed(2)},  t = ${t.toStringAsFixed(2)}'),
          Text('V ≈ ${volume.toStringAsFixed(2)} satuan³', style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),

          const Text('Jari-jari (r)'),
          Slider(value: r, min: 1, max: 20, label: r.toStringAsFixed(1), onChanged: (v) => setState(() => r = v)),

          const SizedBox(height: 8),
          const Text('Tinggi (t)'),
          Slider(value: t, min: 1, max: 30, label: t.toStringAsFixed(1), onChanged: (v) => setState(() => t = v)),

          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: saving ? null : _markDone,
                  icon: const Icon(Icons.check_circle_outline),
                  label: Text(saving ? 'Menyimpan…' : 'Tandai Selesai'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF57D364),
                    foregroundColor: const Color(0xFF0F172A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ]),
      ),
    );
  }

  Future<void> _markDone() async {
    setState(() => saving = true);
    try {
      final user = Supabase.instance.client.auth.currentUser!;
      final id = widget.moduleId ?? 1;
      await GamificationService().markDone(userId: user.id, moduleId: id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selesai! XP +100 & badge ditambahkan')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }
}
