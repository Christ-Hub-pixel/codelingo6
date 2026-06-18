// lib/modeles/lecon.dart

import 'exercice.dart';

class Lecon {
  final String id;
  final String titre;
  final String theorie;
  final List<String> exemples;
  final List<Exercice> exercices;
  final int ordre;

  const Lecon({
    required this.id,
    required this.titre,
    required this.theorie,
    required this.exemples,
    required this.exercices,
    required this.ordre,
  });

  factory Lecon.fromJson(Map<String, dynamic> json) {
    return Lecon(
      id: json['id'] as String,
      titre: json['titre'] as String,
      theorie: json['theorie'] as String,
      exemples: List<String>.from(json['exemples'] as List? ?? []),
      exercices: (json['exercices'] as List)
          .map((e) => Exercice.fromJson(e as Map<String, dynamic>))
          .toList(),
      ordre: json['ordre'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titre': titre,
      'theorie': theorie,
      'exemples': exemples,
      'exercices': exercices.map((e) => e.toJson()).toList(),
      'ordre': ordre,
    };
  }
}
