// lib/modeles/notification_modele.dart

class NotificationModele {
  final String id;
  final String titre;
  final String message;
  final DateTime date;
  bool estLu;
  final String type; // 'info', 'succes', 'rappel'

  NotificationModele({
    required this.id,
    required this.titre,
    required this.message,
    required this.date,
    this.estLu = false,
    required this.type,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'titre': titre,
    'message': message,
    'date': date.toIso8601String(),
    'estLu': estLu,
    'type': type,
  };

  factory NotificationModele.fromJson(Map<String, dynamic> json) => NotificationModele(
    id: json['id'],
    titre: json['titre'],
    message: json['message'],
    date: DateTime.parse(json['date']),
    estLu: json['estLu'],
    type: json['type'],
  );
}
