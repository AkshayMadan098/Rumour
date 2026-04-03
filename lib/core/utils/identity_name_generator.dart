import '../constants/identity_words.dart';

/// Builds a stable "Adjective Animal" handle from API-provided entropy.
String displayNameFromSeed(String seed) {
  var h = 0;
  for (final u in seed.codeUnits) {
    h = (h * 31 + u) & 0x7fffffff;
  }
  final adj = kAdjectives[h % kAdjectives.length];
  final animal = kAnimals[(h >> 8) % kAnimals.length];
  return '$adj $animal';
}
