import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:codelingo/fournisseurs/progression_fournisseur.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ProgressionFournisseur Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({
        'vies': 5,
        'gemmes': 350,
      });
    });

    test('Initial values should be correct', () async {
      final provider = ProgressionFournisseur();
      // Wait for the async _chargerProgression to finish if needed
      // but SharedPreferences mock is usually synchronous in tests
      expect(provider.vies, 5);
      expect(provider.gemmes, 350);
    });

    test('perdreVie should decrease lives', () async {
      final provider = ProgressionFournisseur();
      await provider.perdreVie();
      expect(provider.vies, 4);
    });

    test('ajouterGemmes should increase gems', () async {
      final provider = ProgressionFournisseur();
      await provider.ajouterGemmes(50);
      expect(provider.gemmes, 400);
    });

    test('rechargerVies should reset lives to 5', () async {
      final provider = ProgressionFournisseur();
      await provider.perdreVie();
      await provider.perdreVie();
      expect(provider.vies, 3);
      
      await provider.rechargerVies();
      expect(provider.vies, 5);
    });

    test('toggleModeSombre should change theme mode', () async {
      final provider = ProgressionFournisseur();
      bool initialMode = provider.estModeSombre;
      await provider.toggleModeSombre();
      expect(provider.estModeSombre, !initialMode);
    });
  });
}
