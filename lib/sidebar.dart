import 'package:flutter/material.dart';

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
            // Header
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

            // Menu Items
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
                      child: Text(
                        'OVERVIEW',
                        style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w700, fontSize: 12),
                      ),
                    ),
                    _item(context, 0, currentIndex, Icons.home_rounded, 'Beranda', onSelect),
                    _item(context, 1, currentIndex, Icons.people_alt_rounded, 'Komunitas', onSelect),
                    _item(context, 2, currentIndex, Icons.menu_book_rounded, 'Materi', onSelect),
                    _item(context, 3, currentIndex, Icons.assignment_rounded, 'Soal', onSelect),
                    _item(context, 4, currentIndex, Icons.mail_outline_rounded, 'Kontak', onSelect),
                    _item(context, 5, currentIndex, Icons.account_circle_rounded, 'Profil', onSelect),
                  ],
                ),
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
      onTap: () {
        // Close the drawer before switching content
        Navigator.of(c).pop();
        onTap(i);
      },
    );
  }
}
