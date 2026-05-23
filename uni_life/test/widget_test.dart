import 'package:flutter_test/flutter_test.dart';
import 'package:uni_life/core/utils/validators.dart';

void main() {
  group('Validators', () {
    test('notEmpty rifiuta stringhe vuote', () {
      expect(Validators.notEmpty(''), isNotNull);
      expect(Validators.notEmpty('   '), isNotNull);
      expect(Validators.notEmpty('valido'), isNull);
    });

    test('cfuRange accetta 1..30', () {
      expect(Validators.cfuRange('0'), isNotNull);
      expect(Validators.cfuRange('9'), isNull);
      expect(Validators.cfuRange('31'), isNotNull);
    });

    test('gradeRange accetta 18..31 e stringa vuota', () {
      expect(Validators.gradeRange(''), isNull);
      expect(Validators.gradeRange('17'), isNotNull);
      expect(Validators.gradeRange('18'), isNull);
      expect(Validators.gradeRange('31'), isNull);
      expect(Validators.gradeRange('32'), isNotNull);
    });
  });
}
