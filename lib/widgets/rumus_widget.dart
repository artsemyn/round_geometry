import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class RumusTabung extends StatelessWidget {
  final double r;
  final double t;
  const RumusTabung({super.key, required this.r, required this.t});

  @override
  Widget build(BuildContext context) {
    // tampilkan V = π r^2 t dengan nilai terkini
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Math.tex(r'V = \pi \cdot r^{2} \cdot t', textStyle: const TextStyle(fontSize: 20)),
        const SizedBox(height: 8),
        Text('r = ${r.toStringAsFixed(2)}, t = ${t.toStringAsFixed(2)}'),
        Text('V ≈ ${(3.1415926535 * r * r * t).toStringAsFixed(2)} satuan³'),
      ],
    );
  }
}
