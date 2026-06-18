import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class CloudService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- Authentification ---

  static Future<UserCredential?> sinscrire(String email, String password) async {
    final userCred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    if (userCred.user != null) {
      await initialiserDonneesParDefaut(userCred.user!.uid);
    }
    return userCred;
  }

  static Future<UserCredential?> seConnecter(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  static Future<UserCredential?> seConnecterAnonymement() async {
    final userCred = await _auth.signInAnonymously();
    if (userCred.user != null) {
      final doc = await _firestore.collection('utilisateurs').doc(userCred.user!.uid).get();
      if (!doc.exists) {
        await initialiserDonneesParDefaut(userCred.user!.uid);
      }
    }
    return userCred;
  }

  static Future<void> seDeconnecter() async {
    await _auth.signOut();
  }

  // --- Base de Données (Progression) ---

  static Future<void> initialiserDonneesParDefaut(String uid) async {
    final Map<String, dynamic> donneesDefaut = {
      'progression': {
        'vies': 5,
        'gemmes': 350,
        'serie_jours': 0,
        'langue_maternelle': 'fr',
        'langue_apprise': 'Python',
        'est_mode_sombre': 0,
        'avatar_path': 'assets/images/joyeuse.png',
        'xp_total': 0,
        'ligue': 'Bronze',
        'victoires_duels': 0,
        'lecon_actuelle_index': 0
      },
      'succes': [],
      'amis': [],
      'derniere_sync': FieldValue.serverTimestamp(),
    };
    await _firestore.collection('utilisateurs').doc(uid).set(donneesDefaut);
  }

  static Future<Map<String, dynamic>?> chargerProgression() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final doc = await _firestore.collection('utilisateurs').doc(user.uid).get();
      if (doc.exists && doc.data() != null) {
        return doc.data();
      }
    } catch (e) {
      debugPrint("Erreur de chargement depuis cloud: $e");
    }
    return null;
  }

  static Future<void> sauvegarderProgression(Map<String, dynamic> progression, List<String> succes) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('utilisateurs').doc(user.uid).set({
        'progression': progression,
        'succes': succes,
        'derniere_sync': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("Erreur de sauvegarde vers cloud: $e");
    }
  }

  static Stream<DocumentSnapshot> ecouterChangementsCloud() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();
    return _firestore.collection('utilisateurs').doc(user.uid).snapshots();
  }

  // --- Social ---

  static Future<List<Map<String, dynamic>>> chercherUtilisateurs(String query) async {
    final snapshot = await _firestore
        .collection('utilisateurs')
        .where('email', isGreaterThanOrEqualTo: query)
        .where('email', isLessThanOrEqualTo: '$query\uf8ff')
        .limit(10)
        .get();

    return snapshot.docs.map((doc) => {
      'uid': doc.id,
      ...doc.data()
    }).toList();
  }

  static Future<void> ajouterAmi(String friendUid) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('utilisateurs').doc(user.uid).update({
      'amis': FieldValue.arrayUnion([friendUid])
    });
  }

  static Future<List<Map<String, dynamic>>> chargerAmis() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    final doc = await _firestore.collection('utilisateurs').doc(user.uid).get();
    if (doc.exists && doc.data()!['amis'] != null) {
      final List<dynamic> amisIds = doc.data()!['amis'];
      if (amisIds.isEmpty) return [];

      final snapshot = await _firestore
          .collection('utilisateurs')
          .where(FieldPath.documentId, whereIn: amisIds)
          .get();

      return snapshot.docs.map((doc) => {
        'uid': doc.id,
        ...doc.data()
      }).toList();
    }
    return [];
  }

  // --- Défis (Duels) ---

  static Future<void> envoyerDefi(String destinataireUid, String titreLecon) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('defis').add({
      'expediteur_id': user.uid,
      'expediteur_nom': user.email?.split('@').first ?? 'Un codeur',
      'destinataire_id': destinataireUid,
      'lecon_titre': titreLecon,
      'statut': 'en_attente',
      'date_envoi': FieldValue.serverTimestamp(),
    });
  }

  static Stream<QuerySnapshot> ecouterDefisRecus() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _firestore
        .collection('defis')
        .where('destinataire_id', isEqualTo: user.uid)
        .where('statut', isEqualTo: 'en_attente')
        .snapshots();
  }
}
