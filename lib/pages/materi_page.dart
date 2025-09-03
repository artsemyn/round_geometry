import 'package:flutter/material.dart';
import '../services/materi_service.dart';
import 'materi3d_page.dart';

class MateriPage extends StatefulWidget {
  const MateriPage({super.key});
  @override
  State<MateriPage> createState() => _MateriPageState();
}

class _MateriPageState extends State<MateriPage> {
  final MateriService _service = MateriService();
  List<Map<String, dynamic>> _materi = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await _service.fetchMateri();
    setState(() {
      _materi = data;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Materi")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _materi.length,
              itemBuilder: (c, i) {
                final m = _materi[i];
                return ListTile(
                  title: Text(m['judul']),
                  subtitle: Text(m['deskripsi'] ?? ""),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => Materi3DPage(
                          title: m['judul'],
                          glbUrl: m['glb_url'],
                        ),
                      ),
                    );
                  },
                );
              }),
    );
  }
}
