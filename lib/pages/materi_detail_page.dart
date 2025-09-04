import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_cube/flutter_cube.dart';
import 'package:vector_math/vector_math_64.dart' as vmath;

/// MateriDetailPage (versi baru):
/// - 3D parametrik tabung (r, h)
/// - Garis radius (merah) & garis tinggi (biru) langsung di scene 3D
/// - Animasi rotasi halus
/// - Slider untuk ubah r & h, volume auto-update
///
/// NOTE:
/// - Tidak membutuhkan GLB dari Supabase
/// - Signature tetap menyediakan title/description/glbUrl agar kompatibel
class MateriDetailPage extends StatefulWidget {
  final String title;
  final String? description;
  final String? glbUrl; // tidak dipakai lagi, dibiarkan agar kompatibel

  const MateriDetailPage({
    super.key,
    required this.title,
    this.description,
    this.glbUrl,
  });

  @override
  State<MateriDetailPage> createState() => _MateriDetailPageState();
}

class _MateriDetailPageState extends State<MateriDetailPage>
    with SingleTickerProviderStateMixin {
  late Scene _scene;
  late Ticker _ticker;

  // Root object (biar gampang rebuild)
  final Object _root = Object(name: 'root');

  // Referensi objek agar bisa diupdate
  Object? _cylinderObj;   // tabung
  Object? _heightLineObj; // garis tinggi (silinder tipis)
  Object? _radiusLineObj; // garis radius (silinder tipis)

  // Parameter (cm, relatif)
  double _r = 7;   // jari-jari
  double _h = 10;  // tinggi

  // Style
  final Color _cylinderColor = const Color(0xFF57D364); // hijau brand
  final Color _heightColor   = const Color(0xFF1E3A8A); // biru
  final Color _radiusColor   = const Color(0xFFDC2626); // merah

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_animate)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _onSceneCreated(Scene scene) {
    _scene = scene;
    _scene.camera.position.setFrom(vmath.Vector3(0, 8, 28));
    _scene.light.position.setFrom(vmath.Vector3(0, 20, 10));

    _scene.world.add(_root);
    _rebuildAll();
  }

  // Animasi rotasi ringan agar objek “bergerak sendiri”
  void _animate(Duration _) {
    if (_root.children.isEmpty) return;
    for (final o in _root.children) {
      o.rotation.setValues(o.rotation.x, o.rotation.y + 0.01, o.rotation.z);
    }
    _scene.update();
  }

  // Rebuild semua komponen saat r/h berubah
  void _rebuildAll() {
    _root.children.toList().forEach(_root.remove);

    // Tabung
    _cylinderObj = _buildCylinder(_r, _h,
        segments: 48, color: _cylinderColor, opacity: 0.92);
    _root.add(_cylinderObj!);

    // Garis Tinggi: silinder tipis sepanjang h, letakkan di x = r (tepi)
    _heightLineObj = _buildThinCylinder(
      length: _h,
      thickness: math.max(_r * 0.03, 0.12),
      color: _heightColor,
    )..position.setValues(_r, 0, 0);
    _root.add(_heightLineObj!);

    // Garis Radius: silinder tipis sejajar sumbu X, di alas bawah (y = -h/2)
    _radiusLineObj = _buildThinCylinder(
      length: _r,
      thickness: math.max(_r * 0.03, 0.12),
      color: _radiusColor,
    )
      ..rotation.setValues(0, 0, math.pi / 2) // putar agar sejajar X
      ..position.setValues(_r / 2, -_h / 2, 0);
    _root.add(_radiusLineObj!);

    _scene.update();
  }

  // ====== Helper: buat tabung mesh ======
  Object _buildCylinder(double r, double h,
      {int segments = 48, required Color color, double opacity = 1.0}) {
    final vertices = <vmath.Vector3>[];
    final faces = <Face>[];

    final double halfH = h / 2.0;
    const topCenterIndex = 0;
    const bottomCenterIndex = 1;

    // pusat atas & bawah
    vertices.add(vmath.Vector3(0,  halfH, 0)); // 0
    vertices.add(vmath.Vector3(0, -halfH, 0)); // 1

    // cincin atas & bawah
    for (int i = 0; i < segments; i++) {
      final t = (i / segments) * 2 * math.pi;
      final x = r * math.cos(t);
      final z = r * math.sin(t);
      vertices.add(vmath.Vector3(x,  halfH, z)); // 2..(2+segments-1)
      vertices.add(vmath.Vector3(x, -halfH, z)); // selang-seling
    }

    // sisi (dua segitiga per segmen)
    for (int i = 0; i < segments; i++) {
      final iTopA = 2 + (i * 2);
      final iBotA = iTopA + 1;
      final iTopB = 2 + (((i + 1) % segments) * 2);
      final iBotB = iTopB + 1;

      faces.add(Face(iTopA, iBotA, iTopB, color: color.withOpacity(opacity)));
      faces.add(Face(iBotA, iBotB, iTopB, color: color.withOpacity(opacity)));
    }

    // tutup atas (fan)
    for (int i = 0; i < segments; i++) {
      final iTopA = 2 + (i * 2);
      final iTopB = 2 + (((i + 1) % segments) * 2);
      faces.add(Face(topCenterIndex, iTopA, iTopB, color: color.withOpacity(opacity)));
    }

    // tutup bawah (fan) — urutan dibalik agar normal keluar
    for (int i = 0; i < segments; i++) {
      final iBotA = 2 + (i * 2) + 1;
      final iBotB = 2 + (((i + 1) % segments) * 2) + 1;
      faces.add(Face(bottomCenterIndex, iBotB, iBotA, color: color.withOpacity(opacity)));
    }

    final mesh = Mesh(vertices: vertices, faces: faces)..backfaceCulling = false;
    return Object(name: 'cylinder')..mesh = mesh;
  }

  // ====== Helper: silinder tipis sebagai "garis" ======
  Object _buildThinCylinder({required double length, required double thickness, required Color color}) {
    final r = math.max(thickness / 2, 0.02);
    return _buildCylinder(r, length, segments: 24, color: color, opacity: 1.0)
      ..name = 'thin_cylinder';
  }

  @override
  Widget build(BuildContext context) {
    final descText = (widget.description?.trim().isNotEmpty ?? false)
        ? widget.description!.trim()
        : 'Materi interaktif tabung: jari-jari (r), tinggi (h), '
          'garis radius & tinggi di dalam 3D, dan animasi rotasi.';

    return Scaffold(
      appBar: AppBar(title: Text(widget.title.isEmpty ? 'Materi 3D' : widget.title)),
      body: Column(
        children: [
          // Viewport 3D
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Cube(
              onSceneCreated: _onSceneCreated,
              interactive: true, // drag untuk rotasi, pinch untuk zoom
            ),
          ),

          // Deskripsi & kontrol
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(descText),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text('Perkiraan Volume: ', style: TextStyle(color: Colors.grey[700])),
                    Text(
                      '${(math.pi * _r * _r * _h).toStringAsFixed(1)} cm³',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _sliderRow(
                  label: 'r (cm)',
                  value: _r,
                  min: 2,
                  max: 14,
                  onChanged: (v) {
                    setState(() => _r = v);
                    _rebuildAll();
                  },
                ),
                _sliderRow(
                  label: 'h (cm)',
                  value: _h,
                  min: 4,
                  max: 20,
                  onChanged: (v) {
                    setState(() => _h = v);
                    _rebuildAll();
                  },
                ),
                const SizedBox(height: 6),
                Row(
                  children: const [
                    Icon(Icons.circle, size: 10, color: Color(0xFF57D364)),
                    SizedBox(width: 6), Text('Tabung'),
                    SizedBox(width: 16),
                    Icon(Icons.circle, size: 10, color: Color(0xFF1E3A8A)),
                    SizedBox(width: 6), Text('Tinggi (h)'),
                    SizedBox(width: 16),
                    Icon(Icons.circle, size: 10, color: Color(0xFFDC2626)),
                    SizedBox(width: 6), Text('Radius (r)'),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sliderRow({
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Row(
      children: [
        SizedBox(width: 64, child: Text(label)),
        Expanded(
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: (max - min).round(),
            label: value.toStringAsFixed(1),
            onChanged: onChanged,
          ),
        ),
        SizedBox(width: 52, child: Text(value.toStringAsFixed(1))),
      ],
    );
  }
}
