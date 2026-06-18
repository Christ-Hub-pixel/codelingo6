import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioService {

  static Future<void> jouerSonSucces() async {
    await _jouer('audio/succes.mp3');
  }

  static Future<void> jouerSonErreur() async {
    await _jouer('audio/erreur.mp3');
  }

  static Future<void> jouerSonBouton() async {
    await _jouer('audio/clic.mp3');
  }

  static Future<void> jouerSonGemmes() async {
    await _jouer('audio/gemmes.mp3');
  }

  static Future<void> jouerSonVictoire() async {
    await _jouer('audio/victoire.mp3');
  }

  static Future<void> jouerSonLigue() async {
    await _jouer('audio/ligue.mp3');
  }

  static Future<void> _jouer(String path) async {
    try {
      // On utilise un nouveau player à chaque fois pour permettre la superposition des sons
      final player = AudioPlayer();
      await player.play(AssetSource(path));
    } catch (e) {
      debugPrint("Erreur audio ($path): $e");
    }
  }
}
