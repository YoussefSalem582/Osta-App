import 'package:flutter_test/flutter_test.dart';
import 'package:osta/features/auth/shared/data/models/auth_token_model.dart';

void main() {
  test('AuthTokenModel round-trips through JSON', () {
    const model = AuthTokenModel(accessToken: 'a', refreshToken: 'r');

    expect(AuthTokenModel.fromJson(model.toJson()), model);
  });
}
