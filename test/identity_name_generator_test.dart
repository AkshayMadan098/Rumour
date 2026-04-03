import 'package:flutter_test/flutter_test.dart';
import 'package:rumour/core/utils/identity_name_generator.dart';

void main() {
  test('displayNameFromSeed is stable for same seed', () {
    expect(displayNameFromSeed('abc-uuid'), displayNameFromSeed('abc-uuid'));
  });

  test('displayNameFromSeed differs for different seeds', () {
    expect(
      displayNameFromSeed('aaaa'),
      isNot(equals(displayNameFromSeed('bbbb'))),
    );
  });
}
