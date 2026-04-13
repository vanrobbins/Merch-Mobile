import 'dart:math';

const _chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // no I,O,0,1 — avoids confusion

String generateInviteCode() {
  final rng = Random.secure();
  return String.fromCharCodes(
    List.generate(6, (_) => _chars.codeUnitAt(rng.nextInt(_chars.length))),
  );
}
