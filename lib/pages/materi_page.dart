import 'package:flutter/material.dart';
import 'package:round_geometry/pages/materi3d_page.dart';
import '../features/lessons/lesson_service.dart';

class MateriPage extends StatefulWidget {
  const MateriPage({super.key});
  @override
  State<MateriPage> createState() => _MateriPageState();
}

class _MateriPageState extends State<MateriPage> {
  bool loading = true;
  List<Map<String, dynamic>> modules = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final rows = await LessonService().fetchModules();
    setState(() {
      modules = rows;
      loading = false;
    });
  }

  String _srcFrom(Map<String, dynamic> m) {
    final content = (m['content'] ?? {}) as Map<String, dynamic>;
    if (content['glb'] is String) return content['glb'] as String;

    switch ((m['type'] ?? '').toString()) {
      case 'kerucut':
        return 'assets/models/cone.glb';
      case 'bola':
        return 'assets/models/sphere.glb';
      default:
        return 'assets/models/cylinder.glb';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(title: const Text('Materi')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, c) {
            final w = c.maxWidth;
            int col = 3;
            if (w < 980) col = 2;
            if (w < 640) col = 1;

            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: col,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.28,
              ),
              itemCount: modules.length,
              itemBuilder: (context, i) {
                final m = modules[i];
                return _CardMateri(
                  title: (m['title'] as String?) ?? 'Materi',
                  subtitle: (m['description'] as String?) ?? '3D • Interaktif',
                  onOpen: () {
                    final src = _srcFrom(m);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => Materi3DPage(
                          moduleId: m['id'] as int?,
                          moduleTitle: m['title'] as String?,
                          initialSrc: src,
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

class _CardMateri extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onOpen;

  const _CardMateri({
    required this.title,
    required this.subtitle,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE6E8EC)),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(blurRadius: 18, color: Color(0x14000000), offset: Offset(0, 8))],
      ),
      child: Column(
        children: [
          Container(
            height: 120,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: const Icon(Icons.view_in_ar_rounded, size: 42, color: Color(0xFF475467)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFEAFE),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text('GEOMETRY', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF6B43D9))),
              ),
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(color: Color(0xFF475467))),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: onOpen,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF57D364),
                      foregroundColor: const Color(0xFF0F172A),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                    child: const Text('Buka', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                  OutlinedButton(
                    onPressed: () {}, // TODO: implement download jika sudah siap
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF111827),
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                    child: const Text('Download'),
                  ),
                ],
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
