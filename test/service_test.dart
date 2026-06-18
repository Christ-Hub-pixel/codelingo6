import 'package:flutter_test/flutter_test.dart';
import 'package:codelingo/services/traduction_service.dart';

void main() {
  group('TraductionService Tests', () {
    test('Default language should be French', () {
      expect(TraductionService.langueActive, 'fr');
    });

    test('Translation should return correct value for key', () {
      expect(TraductionService.t('app_name'), 'Codelingo');
      expect(TraductionService.t('bravo'), 'Bravo !');
    });

    test('Changing language should update translations', () {
      TraductionService.changerLangue('en');
      expect(TraductionService.langueActive, 'en');
      expect(TraductionService.t('bravo'), 'Great job!');
      
      TraductionService.changerLangue('es');
      expect(TraductionService.t('bravo'), '¡Buen trabajo!');
      
      // Reset to fr for other tests
      TraductionService.changerLangue('fr');
    });

    test('Missing key should return the key itself', () {
      expect(TraductionService.t('non_existent_key'), 'non_existent_key');
    });
  });
}
