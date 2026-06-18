// lib/services/contenu_service.dart

import 'dart:convert';
import 'package:flutter/services.dart';
import '../modeles/index.dart';

class ContenuService {
  static List<Unite>? _unites;

  static Future<List<Unite>> chargerContenu() async {
    if (_unites != null) return _unites!;

    try {
      final String response = await rootBundle.loadString('assets/data/lecons.json');
      final data = await json.decode(response);
      
      _unites = (data['unites'] as List)
          .map((u) => Unite.fromJson(u as Map<String, dynamic>))
          .toList();
          
      return _unites!;
    } catch (e) {
      return [];
    }
  }

  static Future<Lecon?> getLeconById(String id) async {
    final unites = await chargerContenu();
    for (var unite in unites) {
      for (var lecon in unite.lecons) {
        if (lecon.id == id) return lecon;
      }
    }
    return null;
  }
}
