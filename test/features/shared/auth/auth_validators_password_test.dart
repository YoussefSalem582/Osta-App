import 'package:flutter_test/flutter_test.dart';
import 'package:osta/features/shared/auth/presentation/validators/auth_validators.dart';

/// The server rule is `Password::min(8)->mixedCase()->numbers()`. The client
/// used to require only a letter and a digit, so it blessed passwords the
/// server then rejected. [AuthValidators.strength] shares the same gate, so a
/// password can never be scored "medium" and rejected on submit.
void main() {
  group('password policy mirrors the server', () {
    test('rejects what the server would reject', () {
      for (final weak in [
        'password1', // no uppercase — the case that shipped
        'PASSWORD1', // no lowercase
        'Password', // no digit
        'Pass1', // under 8
      ]) {
        expect(
          AuthValidators.strength(weak),
          PasswordStrength.weak,
          reason: '$weak does not satisfy min(8)+mixedCase()+numbers()',
        );
      }
    });

    test('accepts what the server accepts', () {
      expect(
        AuthValidators.strength('Password1'),
        isNot(PasswordStrength.weak),
      );
    });

    test('scores extra length and symbols as strong', () {
      expect(
        AuthValidators.strength('Password123456!'),
        PasswordStrength.strong,
      );
    });
  });
}
