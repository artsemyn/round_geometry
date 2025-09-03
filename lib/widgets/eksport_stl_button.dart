import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../services/convert_service.dart';

class EksporStlButton extends StatefulWidget {
  const EksporStlButton({super.key});

  @override
  State<EksporStlButton> createState() => _EksporStlButtonState();
}

class _EksporStlButtonState extends State<EksporStlButton> {
  // NOTE: Android emulator pakai 10.0.2.2
  late final ConvertService _svc = ConvertService(
    Platform.isAndroid ? "http://10.0.2.2:8000/convert" : "http://127.0.0.1:8000/convert",
  );

  bool _loading = false;
  String _msg = "";

  Future<void> _pickAndConvert() async {
    try {
      setState(() {
        _loading = true;
        _msg = "";
      });

      final picked = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ["glb", "gltf"],
      );
      if (picked == null || picked.files.single.path == null) {
        setState(() => _msg = "Batal memilih file");
        return;
      }

      final glb = File(picked.files.single.path!);
      final stlBytes = await _svc.convertGlbToStl(glb);

      final baseName = glb.uri.pathSegments.last.split('.').first;
      final dir = await getApplicationDocumentsDirectory();
      final out = File("${dir.path}/$baseName.stl");
      await out.writeAsBytes(stlBytes);

      setState(() => _msg = "Berhasil simpan: ${out.path}");
    } catch (e) {
      setState(() => _msg = "Gagal: $e");
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      ElevatedButton.icon(
        onPressed: _loading ? null : _pickAndConvert,
        icon: _loading
            ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
            : const Icon(Icons.save_alt),
        label: const Text("Ekspor STL dari File…"),
      ),
      if (_msg.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(_msg, style: const TextStyle(fontSize: 12)),
        ),
    ]);
  }
}
