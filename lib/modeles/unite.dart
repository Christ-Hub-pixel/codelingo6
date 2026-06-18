// lib/modeles/unite.dart

import 'lecon.dart';

class Unite {
  final String id;
  final String titre;
  final String description;
  final List<Lecon> lecons;

  const Unite({
    required this.id,
    required this.titre,
    required this.description,
    required this.lecons,
  });

  factory Unite.fromJson(Map<String, dynamic> json) {
    return Unite(
      id: json['id'] as String,
      titre: json['titre'] as String,
      description: json['description'] as String,
      lecons: (json['lecons'] as List)
          .map((e) => Lecon.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
