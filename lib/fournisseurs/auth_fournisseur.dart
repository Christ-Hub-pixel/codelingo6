import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../services/cloud_service.dart';
import '../services/notification_service.dart';

class AuthFournisseur with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  bool _isLoading = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthentifie => _user != null;

  AuthFournisseur() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<String?> seConnecter(String email, String password) async {
    _setLoading(true);
    try {
      final userCred = await CloudService.seConnecter(email, password);
      _setLoading(false);
      if (userCred != null && userCred.user != null) {
        await NotificationService.afficherNotificationInstantanee('👋 Bon retour !', 'Content de te revoir, continuons ta progression !');
        await NotificationService.programmerRappelQuotidien();
        return null;
      } else {
        return "Échec de la connexion. Vérifiez vos identifiants.";
      }
    } catch (e) {
      _setLoading(false);
      return _gererErreurFirebase(e);
    }
  }

  Future<String?> sinscrire(String email, String password, String nom) async {
    _setLoading(true);
    try {
      final userCred = await CloudService.sinscrire(email, password, nom);
      if (userCred != null && userCred.user != null) {
        await userCred.user!.updateDisplayName(nom);
        await userCred.user!.reload();
        _user = _auth.currentUser;
        notifyListeners();
        _setLoading(false);
        await NotificationService.afficherNotificationInstantanee('🎉 Bienvenue sur Codelingo !', 'Ton aventure commence ici !');
        await NotificationService.programmerRappelQuotidien();
        return null;
      } else {
        _setLoading(false);
        return "Échec de l'inscription.";
      }
    } catch (e) {
      _setLoading(false);
      return _gererErreurFirebase(e);
    }
  }

  Future<String?> seConnecterAnonymement() async {
    _setLoading(true);
    try {
      final userCred = await CloudService.seConnecterAnonymement();
      _setLoading(false);
      if (userCred != null && userCred.user != null) {
        await NotificationService.afficherNotificationInstantanee('🕵️ Bienvenue invité !', 'Découvre l\'application librement !');
        await NotificationService.programmerRappelQuotidien();
        return null;
      } else {
        return "Échec de la connexion anonyme.";
      }
    } catch (e) {
      _setLoading(false);
      return _gererErreurFirebase(e);
    }
  }

  Future<void> seDeconnecter() async {
    await CloudService.seDeconnecter();
  }

  String _gererErreurFirebase(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          return "Aucun utilisateur trouvé pour cet email.";
        case 'wrong-password':
          return "Mot de passe incorrect.";
        case 'email-already-in-use':
          return "Cet email est déjà utilisé.";
        case 'invalid-email':
          return "Adresse email invalide.";
        case 'weak-password':
          return "Le mot de passe est trop faible.";
        default:
          return "Une erreur s'est produite : ${e.message}";
      }
    }
    return "Une erreur inattendue s'est produite.";
  }
}
