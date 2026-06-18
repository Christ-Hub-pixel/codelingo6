// lib/composants/carte_stats.dart

import 'package:flutter/material.dart';

class CarteStats extends StatelessWidget {
  final String label;
  final String valeur;
  final IconData icone;

  const CarteStats({
    super.key,
    required this.label,
    required this.valeur,
    required this.icone,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icone, size: 30, color: Colors.deepPurple),
        const SizedBox(height: 8),
        Text(valeur, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
