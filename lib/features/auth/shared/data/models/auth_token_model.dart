import 'package:equatable/equatable.dart';

/// Sanctum dual-token pair returned by the auth endpoints.
///
/// Plain immutable model with hand-written JSON mapping — no codegen. Real auth
/// wiring lands in a later epic.
class AuthTokenModel extends Equatable {
  const AuthTokenModel({
    required this.accessToken,
    required this.refreshToken,
  });

  factory AuthTokenModel.fromJson(Map<String, dynamic> json) => AuthTokenModel(
    accessToken: json['accessToken'] as String,
    refreshToken: json['refreshToken'] as String,
  );

  final String accessToken;
  final String refreshToken;

  Map<String, dynamic> toJson() => {
    'accessToken': accessToken,
    'refreshToken': refreshToken,
  };

  @override
  List<Object?> get props => [accessToken, refreshToken];
}
