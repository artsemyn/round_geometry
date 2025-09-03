import 'package:flutter/material.dart';
import '../services/materi_repo_service.dart';
import 'materi3d_page.dart';

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
      _future = repo.fetchMateri();
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Materi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _reload,
          ),
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
              return Center(child: Text('Error: ${snap.error}'));
            }

            final items = snap.data ?? [];
            if (items.isEmpty) {
              return const Center(child: Text('Belum ada materi'));
            }

            return ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (_, i) {
                final m = items[i];
                final url = m['glb_url'] as String?;
                final title = m['title'] ?? '';
                final desc = m['description'] ?? '';
                final canOpen = url != null && url.isNotEmpty;

                return ListTile(
                  leading: const Icon(Icons.view_in_ar),
                  title: Text(title),
                  subtitle: Text(desc.isEmpty ? 'Tanpa deskripsi' : desc),
                  trailing: Icon(
                    canOpen ? Icons.chevron_right : Icons.block,
                    color: canOpen ? null : Colors.red,
                  ),
                  onTap: !canOpen
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => Materi3DPage(
                                title: title,
                                glbUrl: url!,
                              ),
                            ),
                          );
                        },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
