// lib/fournisseurs/notification_fournisseur.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../modeles/index.dart';

class NotificationFournisseur with ChangeNotifier {
  List<NotificationModele> _notifications = [];

  List<NotificationModele> get notifications => _notifications;
  int get nbNonLus => _notifications.where((n) => !n.estLu).length;

  NotificationFournisseur() {
    _chargerNotifications();
  }

  Future<void> _chargerNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final String? notifsString = prefs.getString('notifications');
    
    if (notifsString != null) {
      final List<dynamic> decoded = json.decode(notifsString);
      _notifications = decoded.map((n) => NotificationModele.fromJson(n)).toList();
    } else {
      // Notifications de bienvenue par défaut
      _notifications = [
        NotificationModele(
          id: 'welcome',
          titre: 'Bienvenue sur Codelingo ! 🚀',
          message: 'Codie est ravi de t\'accueillir. Prêt à devenir un pro de Python ?',
          date: DateTime.now(),
          type: 'info',
        ),
      ];
      _sauvegarderNotifications();
    }
    notifyListeners();
  }

  Future<void> _sauvegarderNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = json.encode(_notifications.map((n) => n.toJson()).toList());
    await prefs.setString('notifications', encoded);
  }

  Future<void> ajouterNotification(String titre, String message, String type) async {
    final nouvelle = NotificationModele(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      titre: titre,
      message: message,
      date: DateTime.now(),
      type: type,
    );
    _notifications.insert(0, nouvelle);
    await _sauvegarderNotifications();
    notifyListeners();
  }

  Future<void> marquerCommeLu(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index].estLu = true;
      await _sauvegarderNotifications();
      notifyListeners();
    }
  }

  Future<void> toutMarquerCommeLu() async {
    for (var n in _notifications) {
      n.estLu = true;
    }
    await _sauvegarderNotifications();
    notifyListeners();
  }

  Future<void> supprimerNotification(String id) async {
    _notifications.removeWhere((n) => n.id == id);
    await _sauvegarderNotifications();
    notifyListeners();
  }
}
