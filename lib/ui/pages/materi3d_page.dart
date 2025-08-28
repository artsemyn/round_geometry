import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';

class Materi3DPage extends StatefulWidget {
  const Materi3DPage({super.key, this.initialSrc});

  final String? initialSrc;

  @override
  State<Materi3DPage> createState() => _Materi3DPageState();
}

class _Materi3DPageState extends State<Materi3DPage> {
  // Ganti sesuai file kamu
  final List<String> models = const [
    'assets/models/cylinder.glb',
    'assets/models/cone.glb',
    'assets/models/sphere.glb',
  ];

  late String src;

  @override
  void initState() {
    super.initState();
    src = widget.initialSrc ?? models.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Materi Viewer 3D')),
      body: Column(
        children: [
          const SizedBox(height: 12),
          const Text('Pilih model:'),
          const SizedBox(height: 8),

          // Dropdown ganti model
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: DropdownButton<String>(
              value: src,
              items: models
                  .map((m) => DropdownMenuItem(
                        value: m,
                        child: Text(m.split('/').last),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v == null) return;
                setState(() => src = v); // ubah sumber
              },
            ),
          ),

          const SizedBox(height: 8),

          // Viewer 3D — JANGAN pakai `const`, tambahkan `key` biar reload
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.black,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Flutter3DViewer(
                  key: ValueKey(src),   // <— ini penting
                  src: src,             // model aktif
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
