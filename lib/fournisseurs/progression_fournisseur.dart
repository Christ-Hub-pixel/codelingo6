import 'package:flutter/material.dart';
import '../services/cloud_service.dart';

class ProgressionFournisseur with ChangeNotifier {
  int _vies = 5;
  int _gemmes = 350;
  int _serieJours = 0;
  String _langueMaternelle = 'fr';
  String _langueApprise = 'Python';
  bool _estModeSombre = false;
  bool _notificationsActives = true;
  String _avatarPath = 'assets/images/joyeuse.png';
  List<String> _succesDebloques = [];
  int _xpTotal = 0;
  String _ligueActuelle = 'Bronze';
  int _victoiresDuels = 0;
  int _leconActuelleIndex = 0;
  bool _gelDeSerieActif = false;
  List<String> _tenuesPossedees = [];
  String _tenueActuelle = 'Defaut';
  String _derniereLeconDate = '';
  String? _avatarBase64;

  int get vies => _vies;
  int get gemmes => _gemmes;
  int get serieJours => _serieJours;
  String get langueMaternelle => _langueMaternelle;
  String get langueApprise => _langueApprise;
  bool get estModeSombre => _estModeSombre;
  bool get notificationsActives => _notificationsActives;
  
  String get avatarPath {
    if (_tenueActuelle == 'magicien') return 'assets/images/magicien.png';
    if (_tenueActuelle == 'robot') return 'assets/images/robot.png';
    return _avatarPath;
  }
  
  List<String> get succesDebloques => _succesDebloques;
  int get xpTotal => _xpTotal;
  String get ligueActuelle => _ligueActuelle;
  int get victoiresDuels => _victoiresDuels;
  int get leconActuelleIndex => _leconActuelleIndex;
  bool get gelDeSerieActif => _gelDeSerieActif;
  List<String> get tenuesPossedees => _tenuesPossedees;
  String get tenueActuelle => _tenueActuelle;
  String? get avatarBase64 => _avatarBase64;

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
      _mettreAJourDepuisMap(data['progression']);
    }
    
    if (data['succes'] != null) {
      _succesDebloques = List<String>.from(data['succes']);
    }
    if (data['tenues'] != null) {
      _tenuesPossedees = List<String>.from(data['tenues']);
    }
    notifyListeners();
  }

  void _mettreAJourDepuisMap(Map<String, dynamic> prog) {
    _vies = prog['vies'] ?? 5;
    _gemmes = prog['gemmes'] ?? 0;
    _serieJours = prog['serie_jours'] ?? 0;
    _langueMaternelle = prog['langue_maternelle'] ?? 'fr';
    _langueApprise = prog['langue_apprise'] ?? 'Python';
    _estModeSombre = (prog['est_mode_sombre'] ?? 0) == 1;
    _notificationsActives = (prog['notifications_actives'] ?? 1) == 1;
    _avatarPath = prog['avatar_path'] ?? 'assets/images/joyeuse.png';
    _avatarBase64 = prog['avatar_base64'];
    _xpTotal = prog['xp_total'] ?? 0;
    _ligueActuelle = prog['ligue'] ?? 'Bronze';
    _victoiresDuels = prog['victoires_duels'] ?? 0;
    _leconActuelleIndex = prog['lecon_actuelle_index'] ?? 0;
    _gelDeSerieActif = prog['gel_serie_actif'] ?? false;
    _tenuesPossedees = List<String>.from(prog['tenues_possedees'] ?? []);
    _tenueActuelle = prog['tenue_actuelle'] ?? 'Defaut';
    _derniereLeconDate = prog['derniere_lecon_date'] ?? '';
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
    _avatarBase64 = null;
    _tenueActuelle = 'Defaut'; 
    await _sauvegarderEtatComplet();
    notifyListeners();
  }

  Future<void> toggleModeSombre() async {
    _estModeSombre = !_estModeSombre;
    await _sauvegarderEtatComplet();
    notifyListeners();
  }

  Future<void> toggleNotifications() async {
    _notificationsActives = !_notificationsActives;
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
      'avatar_base64': _avatarBase64,
      'est_mode_sombre': _estModeSombre ? 1 : 0,
      'notifications_actives': _notificationsActives ? 1 : 0,
      'langue_apprise': _langueApprise,
      'langue_maternelle': _langueMaternelle,
      'gel_serie_actif': _gelDeSerieActif ? 1 : 0,
      'tenues_possedees': _tenuesPossedees,
      'tenue_actuelle': _tenueActuelle,
      'derniere_lecon_date': _derniereLeconDate,
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
    // Cette méthode manuelle peut toujours être utilisée si besoin
    _serieJours++;
    _gelDeSerieActif = false;
    _derniereLeconDate = DateTime.now().toIso8601String().split('T')[0];
    await _sauvegarderEtatComplet();
    notifyListeners();
  }

  Future<void> rechargerVies() async {
    _vies = 5;
    await _sauvegarderEtatComplet();
    notifyListeners();
  }

  Future<void> activerGelDeSerie() async {
    _gelDeSerieActif = true;
    await _sauvegarderEtatComplet();
    notifyListeners();
  }

  Future<void> acheterTenue(String tenueId) async {
    if (!_tenuesPossedees.contains(tenueId)) {
      _tenuesPossedees.add(tenueId);
      await _sauvegarderEtatComplet();
      notifyListeners();
    }
  }

  Future<void> equiperTenue(String tenueId) async {
    if (_tenuesPossedees.contains(tenueId) || tenueId == 'Defaut') {
      _tenueActuelle = tenueId;
      await _sauvegarderEtatComplet();
      notifyListeners();
    }
  }

  Future<void> mettreAJourAvatarPersonnalise(String base64) async {
    _avatarBase64 = base64;
    _tenueActuelle = 'Defaut'; // Revert to default outfit so custom photo shows
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

  void _verifierEtMettreAJourSerie() {
    final aujourdHui = DateTime.now().toIso8601String().split('T')[0];
    if (_derniereLeconDate.isEmpty) return;
    
    final derniere = DateTime.tryParse(_derniereLeconDate);
    if (derniere == null) return;

    final aujourdHuiDate = DateTime.parse(aujourdHui);
    final difference = aujourdHuiDate.difference(derniere).inDays;
    
    if (difference > 1) {
      if (_gelDeSerieActif) {
        // Le gel a sauvé la série !
        _gelDeSerieActif = false;
        _derniereLeconDate = aujourdHuiDate.subtract(const Duration(days: 1)).toIso8601String().split('T')[0];
      } else {
        // Série cassée :(
        _serieJours = 0;
      }
    }
  }

  Future<void> completerLecon(int index) async {
    final aujourdHui = DateTime.now().toIso8601String().split('T')[0];
    
    if (_derniereLeconDate != aujourdHui) {
      _verifierEtMettreAJourSerie();
      
      if (_derniereLeconDate.isEmpty || _serieJours == 0) {
        _serieJours = 1;
      } else {
        _serieJours++;
      }
      
      _derniereLeconDate = aujourdHui;
      _gelDeSerieActif = false;
    }

    if (index >= _leconActuelleIndex) {
      _leconActuelleIndex = index;
    }
    
    await _sauvegarderEtatComplet();
    notifyListeners();
  }
}
