import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioService {

  static Future<void> jouerSonSucces() async {
    await _jouer('audio/notification-de-reussite.wav');
  }

  static Future<void> jouerSonErreur() async {
    await _jouer('audio/notification-de-echoue.wav');
  }

  static Future<void> jouerSonBouton() async {
    await _jouer('audio/notification-de-message.wav');
  }

  static Future<void> jouerSonMessage() async {
    await _jouer('audio/notification-de-message.wav');
  }

  static Future<void> jouerSonExecutionCode() async {
    await _jouer('audio/notification-editeurcode-run.wav');
  }

  static Future<void> jouerSonGemmes() async {
    await _jouer('audio/notification-de-reussite.wav');
  }

  static Future<void> jouerSonVictoire() async {
    await _jouer('audio/notification-de-reussite.wav');
  }

  static Future<void> jouerSonLigue() async {
    await _jouer('audio/notification-de-reussite.wav');
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
