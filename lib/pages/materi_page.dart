import 'package:flutter/material.dart';
import '../services/materi_repo_service.dart'; // ganti sesuai path repo kamu
import 'materi3d_page.dart';
import 'materi_detail_page.dart';

class MateriPage extends StatefulWidget {
  const MateriPage({super.key});

  @override
  State<MateriPage> createState() => _MateriPageState();
}

class _MateriPageState extends State<MateriPage> {
  final repo = MateriRepo();
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = repo.fetchMateri();
  }

  Future<void> _reload() async {
    setState(() {
      _future = repo.fetchMateri(); // regenerate signed URL setiap refresh
    });
    await _future;
  }

  void _openLesson(String title, String url, String desc) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MateriDetailPage(
          title: title,
          description: desc,
          glbUrl: url,
    ),
  ),
);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Materi'),
        actions: [
          IconButton(onPressed: _reload, icon: const Icon(Icons.refresh_rounded)),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _reload,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return ListView(
                children: [
                  const SizedBox(height: 80),
                  Center(child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('Error: ${snap.error}'),
                  )),
                ],
              );
            }

            final items = snap.data ?? [];
            if (items.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 80),
                  Center(child: Text('Belum ada materi')),
                ],
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final m = items[i];
                final title = (m['title'] ?? '') as String;
                final desc  = (m['description'] ?? '') as String;
                final url   = m['glb_url'] as String?;
                final note  = m['note'] as String?;
                final canOpen = url != null && url.isNotEmpty;

                return Card(
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Icon(Icons.view_in_ar_rounded, size: 28),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                              const SizedBox(height: 2),
                              Text(
                                note?.isNotEmpty == true
                                    ? '❗ $note'
                                    : (desc.isEmpty ? 'Tanpa deskripsi' : desc),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: Colors.grey.shade700),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  FilledButton.icon(
                                    onPressed: canOpen ? () => _openPreview3D(title, url!) : null,
                                    icon: const Icon(Icons.play_circle_fill_rounded),
                                    label: const Text('Preview 3D'),
                                  ),
                                  OutlinedButton.icon(
                                    onPressed: canOpen ? () => _openLesson(title, url!) : null,
                                    icon: const Icon(Icons.menu_book_rounded),
                                    label: const Text('Materi Interaktif'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
