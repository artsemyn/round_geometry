import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class Materi3DPage extends StatefulWidget {
  final String title;
  final String glbUrl; // signed/public URL dari halaman list

  const Materi3DPage({
    super.key,
    required this.title,
    required this.glbUrl,
  });

  @override
  State<Materi3DPage> createState() => _Materi3DPageState();
}

class _Materi3DPageState extends State<Materi3DPage> {
  late String _src;          // url aktif yang dipakai model_viewer
  bool _loading = true;      // indikator render pertama
  String? _error;            // catat error untuk ditampilkan

  @override
  void initState() {
    super.initState();
    _src = widget.glbUrl;
    debugPrint('Materi3DPage src = $_src');
  }

  // trik simple untuk “refresh” src (misal token signed URL sudah expired)
  void _hardRefresh() {
    setState(() {
      // tambahkan cache-buster agar <model-viewer> reload
      _src = '${widget.glbUrl}${widget.glbUrl.contains('?') ? '&' : '?'}t=${DateTime.now().millisecondsSinceEpoch}';
      _loading = true;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isHttp = Uri.tryParse(_src)?.hasScheme == true;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            tooltip: 'Refresh model',
            onPressed: _hardRefresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: !isHttp
          ? _errorView("URL tidak valid:\n$_src")
          : Stack(
              children: [
                // Viewer 3D
                Positioned.fill(
                  child: ModelViewer(
                    key: ValueKey(_src), // pastikan rebuild saat _src berubah
                    src: _src,
                    alt: "3D model",
                    ar: false,
                    autoRotate: true,
                    cameraControls: true,
                    // callback hanya ada di 2.x; di 1.x kita pakai onModelError di bawah
                    // onModelLoaded: (_) => setState(() => _loading = false),
                    // onModelError: (e) => setState(() => _error = e.message),
                  ),
                ),

                // Overlay loading
                if (_loading && _error == null)
                  const Positioned.fill(
                    child: IgnorePointer(
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),

                // Overlay error
                if (_error != null) Positioned.fill(child: _errorView(_error!)),
              ],
            ),
    );
  }

  Widget _errorView(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 32, color: Colors.red),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _hardRefresh,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba muat ulang'),
            )
          ],
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    // render pertama selesai setelah satu frame → matikan spinner
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _loading) setState(() => _loading = false);
    });
    super.didChangeDependencies();
  }
}
