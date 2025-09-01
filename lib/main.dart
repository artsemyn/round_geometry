import 'package:flutter/material.dart';
import 'sidebar.dart';  // Import Sidebar
import 'pages/materi_page.dart';  // Import MateriPage
import 'pages/soal_page.dart'; // Import SoalPage

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Round Geometry',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int currentIndex = 0;

  void _onSelect(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SideMenu(currentIndex: currentIndex, onSelect: _onSelect),
      appBar: AppBar(title: const Text('Round Geometry')),
      body: Builder(
        builder: (context) {
          switch (currentIndex) {
            case 0:
              return const Center(child: Text('Beranda'));
            case 1:
              return const Center(child: Text('Komunitas'));
            case 2:
              return const MateriPage();
            case 3:
              return const SoalPage();
            case 4:
              return const Center(child: Text('Kontak'));
            case 5:
              return const Center(child: Text('Profil'));
            default:
              return const MateriPage();
          }
        },
      ),
    );
  }
}
