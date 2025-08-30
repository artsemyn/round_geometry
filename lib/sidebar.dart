import 'package:flutter/material.dart';
import 'package:round_geometry/pages/profil_page.dart';

class SideMenu extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onSelect;
  const SideMenu({super.key, required this.currentIndex, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    const dark = Color(0xFF1C1C1C);
    const brandGreen = Color(0xFF57D364);

    return Drawer(
      backgroundColor: dark,
      child: SafeArea(
        child: Column(
          children: [
            // header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
              child: Row(
                children: const [
                  Icon(Icons.star, color: brandGreen, size: 22),
                  SizedBox(width: 8),
                  Text('ROUND GEOMETRY',
                      style: TextStyle(color: brandGreen, fontWeight: FontWeight.w800)),
                ],
              ),
            ),

            // menu
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(18),
                ),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: ListView(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 4, bottom: 8),
                      child: Text('OVERVIEW',
                          style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w700, fontSize: 12)),
                    ),
                    _item(context, 0, currentIndex, Icons.home_rounded, 'Beranda', onSelect),
                    _item(context, 1, currentIndex, Icons.people_alt_rounded, 'Komunitas', onSelect),
                    _item(context, 2, currentIndex, Icons.menu_book_rounded, 'Materi', onSelect),
                    _item(context, 3, currentIndex, Icons.assignment_rounded, 'Soal', onSelect),
                    _item(context, 4, currentIndex, Icons.mail_outline_rounded, 'Kontak', onSelect),
                    const Divider(height: 24),
                    // tombol Profil (langsung push halaman profil)
                    ListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                      leading: const Icon(Icons.account_circle_rounded, color: brandGreen),
                      title: const Text('Profil', style: TextStyle(fontWeight: FontWeight.w600)),
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfilPage()));
                      },
                    ),
                  ],
                ),
              ),
            ),

            // footer kecil
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 10, 20, 16),
              child: Opacity(
                opacity: .6,
                child: Text('v0.1 • MVP', style: TextStyle(color: Colors.white, fontSize: 12)),
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
    const brandGreen = Color(0xFF57D364);
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
      leading: Icon(icon, color: active ? brandGreen : Colors.black87),
      title: Text(
        label,
        style: TextStyle(
          color: active ? brandGreen : Colors.black87,
          fontWeight: active ? FontWeight.w700 : FontWeight.w400,
        ),
      ),
      onTap: () => onTap(i),
    );
  }
}
