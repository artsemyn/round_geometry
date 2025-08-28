// lib/sidebar.dart
import 'package:flutter/material.dart';
import 'package:round_geometry/ui/pages/materi3d_page.dart';

class SideMenu extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onSelect;
  const SideMenu({super.key, required this.currentIndex, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    const dark = Color(0xFF1C1C1C);

    return Drawer(
      backgroundColor: dark,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 8),
              child: Text('MENU',
                  style: TextStyle(color: Colors.white70, letterSpacing: 1.5)),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header title
                  Row(
                    children: const [
                      Icon(Icons.star, color: Colors.green),
                      SizedBox(width: 8),
                      Text(
                        'ROUND GEOMETRY',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'OVERVIEW',
                    style: TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Items utama
                  _item(context, 0, currentIndex, Icons.home, 'Beranda', onSelect),
                  _item(context, 1, currentIndex, Icons.people, 'Komunitas', onSelect),

                  // Item Materi (mengganti body utama)
                  _item(context, 2, currentIndex, Icons.book, 'Materi', onSelect),

                  // Submenu: buka Materi3DPage langsung dengan model tertentu
                  Padding(
                    padding: const EdgeInsets.only(left: 44), // indent agar kelihatan submenu
                    child: Column(
                      children: [
                        ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: const Text('– Tabung',
                              style: TextStyle(color: Colors.black87)),
                          onTap: () {
                            Navigator.of(context).pop(); // tutup drawer
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const Materi3DPage(
                                  initialSrc: 'assets/models/cylinder.glb',
                                ),
                              ),
                            );
                          },
                        ),
                        ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: const Text('– Kerucut',
                              style: TextStyle(color: Colors.black87)),
                          onTap: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const Materi3DPage(
                                  initialSrc: 'assets/models/cone.glb',
                                ),
                              ),
                            );
                          },
                        ),
                        ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: const Text('– Bola',
                              style: TextStyle(color: Colors.black87)),
                          onTap: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const Materi3DPage(
                                  initialSrc: 'assets/models/sphere.glb',
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  _item(context, 3, currentIndex, Icons.assignment, 'Soal', onSelect),
                  _item(context, 4, currentIndex, Icons.contact_mail, 'Kontak', onSelect),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _item(
    BuildContext c,
    int i,
    int current,
    IconData icon,
    String label,
    ValueChanged<int> onTap,
  ) {
    final active = i == current;
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
      leading: Icon(icon, color: active ? Colors.green : Colors.black87),
      title: Text(
        label,
        style: TextStyle(
          color: active ? Colors.green : Colors.black87,
          fontWeight: active ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      onTap: () => onTap(i), // ganti konten body utama via Shell
    );
  }
}
