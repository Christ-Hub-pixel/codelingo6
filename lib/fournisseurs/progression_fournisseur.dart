import 'package:flutter/material.dart';
import '../services/cloud_service.dart';

class ProgressionFournisseur with ChangeNotifier {
  int _vies = 5;
  int _gemmes = 350;
  int _serieJours = 0;
  String _langueMaternelle = 'fr';
  String _langueApprise = 'Python';
  bool _estModeSombre = false;
  String _avatarPath = 'assets/images/joyeuse.png';
  List<String> _succesDebloques = [];
  int _xpTotal = 0;
  String _ligueActuelle = 'Bronze';
  int _victoiresDuels = 0;
  int _leconActuelleIndex = 0;

  int get vies => _vies;
  int get gemmes => _gemmes;
  int get serieJours => _serieJours;
  String get langueMaternelle => _langueMaternelle;
  String get langueApprise => _langueApprise;
  bool get estModeSombre => _estModeSombre;
  String get avatarPath => _avatarPath;
  List<String> get succesDebloques => _succesDebloques;
  int get xpTotal => _xpTotal;
  String get ligueActuelle => _ligueActuelle;
  int get victoiresDuels => _victoiresDuels;
  int get leconActuelleIndex => _leconActuelleIndex;

  ProgressionFournisseur() {
    _chargerProgression();
    _ecouterCloud();
  }

  void _ecouterCloud() {
    CloudService.ecouterChangementsCloud().listen((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data() as Map<String, dynamic>;
        _appliquerDonnees(data);
      }
    });
  }

  Future<void> _chargerProgression() async {
    final data = await CloudService.chargerProgression();
    if (data != null) {
      _appliquerDonnees(data);
    }
  }

  void _appliquerDonnees(Map<String, dynamic> data) {
    if (data['progression'] != null) {
      final prog = data['progression'];
      _vies = prog['vies'] ?? 5;
      _gemmes = prog['gemmes'] ?? 350;
      _serieJours = prog['serie_jours'] ?? 0;
      _langueMaternelle = prog['langue_maternelle'] ?? 'fr';
      _langueApprise = prog['langue_apprise'] ?? 'Python';
      _estModeSombre = prog['est_mode_sombre'] == 1;
      _avatarPath = prog['avatar_path'] ?? 'assets/images/joyeuse.png';
      _xpTotal = prog['xp_total'] ?? 0;
      _ligueActuelle = prog['ligue'] ?? 'Bronze';
      _victoiresDuels = prog['victoires_duels'] ?? 0;
      _leconActuelleIndex = prog['lecon_actuelle_index'] ?? 0;
    }
    
    if (data['succes'] != null) {
      _succesDebloques = List<String>.from(data['succes']);
    }
    notifyListeners();
  }

  Future<void> debloquerSucces(String id) async {
    if (!_succesDebloques.contains(id)) {
      _succesDebloques.add(id);
      await _sauvegarderEtatComplet();
      notifyListeners();
    }
  }

  Future<void> setAvatar(String path) async {
    _avatarPath = path;
    await _sauvegarderEtatComplet();
    notifyListeners();
  }

  Future<void> toggleModeSombre() async {
    _estModeSombre = !_estModeSombre;
    await _sauvegarderEtatComplet();
    notifyListeners();
  }

  Future<void> perdreVie() async {
    if (_vies > 0) {
      _vies--;
      await _sauvegarderEtatComplet();
      notifyListeners();
    }
  }

  Future<void> ajouterGemmes(int montant) async {
    _gemmes += montant;
    await _sauvegarderEtatComplet();
    notifyListeners();
  }

  Future<void> depenserGemmes(int montant) async {
    if (_gemmes >= montant) {
      _gemmes -= montant;
      await _sauvegarderEtatComplet();
      notifyListeners();
    }
  }

  Future<void> ajouterBonusParfait() async {
    _gemmes += 10;
    _xpTotal += 20;
    await _sauvegarderEtatComplet();
    notifyListeners();
  }

  Future<void> ajouterXP(int montant) async {
    _xpTotal += montant;
    _verifierChangementLigue();
    await _sauvegarderEtatComplet();
    notifyListeners();
  }

  Future<void> _sauvegarderEtatComplet() async {
    final progression = {
      'xp_total': _xpTotal,
      'gemmes': _gemmes,
      'vies': _vies,
      'ligue': _ligueActuelle,
      'serie_jours': _serieJours,
      'lecon_actuelle_index': _leconActuelleIndex,
      'avatar_path': _avatarPath,
      'est_mode_sombre': _estModeSombre ? 1 : 0,
      'langue_apprise': _langueApprise,
      'langue_maternelle': _langueMaternelle,
    };
    await CloudService.sauvegarderProgression(progression, _succesDebloques);
  }

  void _verifierChangementLigue() {
    _ligueActuelle = switch (_xpTotal) {
      > 3000 => 'Diamant',
      > 1200 => 'Or',
      > 400 => 'Argent',
      _ => 'Bronze',
    };
  }

  Future<void> incrementerSerie() async {
    _serieJours++;
    await _sauvegarderEtatComplet();
    notifyListeners();
  }

  Future<void> rechargerVies() async {
    _vies = 5;
    await _sauvegarderEtatComplet();
    notifyListeners();
  }

  Future<void> setLangueApprise(String langue) async {
    _langueApprise = langue;
    await _sauvegarderEtatComplet();
    notifyListeners();
  }

  Future<void> ajouterVictoireDuel() async {
    _victoiresDuels++;
    await _sauvegarderEtatComplet();
    notifyListeners();
  }

  Future<void> completerLecon(int index) async {
    if (index >= _leconActuelleIndex) {
      _leconActuelleIndex = index + 1;
      await _sauvegarderEtatComplet();
      notifyListeners();
    }
  }
}
