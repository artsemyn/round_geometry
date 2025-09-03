import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class Materi3DPage extends StatelessWidget {
  final String title;
  final String glbUrl; // bisa URL https ATAU path asset

  const Materi3DPage({super.key, required this.title, required this.glbUrl});

  @override
  Widget build(BuildContext context) {
    // Log biar kelihatan nilainya di console
    debugPrint('GLB src = $glbUrl');

    // Tentukan apakah ini URL (http/https) atau asset lokal
    final isHttp = Uri.tryParse(glbUrl)?.hasScheme == true;

    // Jika asset lokal, pastikan di pubspec.yaml sudah didaftarkan (lihat langkah 3)
    final src = isHttp ? glbUrl : 'assets/$glbUrl';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Column(
        children: [
          Expanded(
            child: ModelViewer(
              src: src,
              alt: "3D model",
              ar: false,
              autoRotate: true,
              cameraControls: true,
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(12.0),
            child: Text("Gunakan jari untuk memutar dan zoom model 3D."),
          ),
        ],
      ),
    );
  }
}
