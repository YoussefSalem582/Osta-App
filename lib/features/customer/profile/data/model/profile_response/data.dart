class Data {
  String? id;
  String? firstName;
  String? lastName;
  String? fullName;
  String? username;
  String? supportId;
  String? email;
  String? phone;
  String? type;
  String? languagePreference;
  dynamic avatarUrl;
  bool? isActive;
  bool? emailVerified;
  dynamic oauthProvider;
  List<String>? roles;
  String? createdAt;

  Data({
    this.id,
    this.firstName,
    this.lastName,
    this.fullName,
    this.username,
    this.supportId,
    this.email,
    this.phone,
    this.type,
    this.languagePreference,
    this.avatarUrl,
    this.isActive,
    this.emailVerified,
    this.oauthProvider,
    this.roles,
    this.createdAt,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json['id'] as String?,
    firstName: json['first_name'] as String?,
    lastName: json['last_name'] as String?,
    fullName: json['full_name'] as String?,
    username: json['username'] as String?,
    supportId: json['support_id'] as String?,
    email: json['email'] as String?,
    phone: json['phone'] as String?,
    type: json['type'] as String?,
    languagePreference: json['language_preference'] as String?,
    avatarUrl: json['avatar_url'] as dynamic,
    isActive: json['is_active'] as bool?,
    emailVerified: json['email_verified'] as bool?,
    oauthProvider: json['oauth_provider'] as dynamic,
    roles: json['roles'] == null
        ? null
        : List<String>.from(json['roles'] as List),
    createdAt: json['created_at'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'first_name': firstName,
    'last_name': lastName,
    'full_name': fullName,
    'username': username,
    'support_id': supportId,
    'email': email,
    'phone': phone,
    'type': type,
    'language_preference': languagePreference,
    'avatar_url': avatarUrl,
    'is_active': isActive,
    'email_verified': emailVerified,
    'oauth_provider': oauthProvider,
    'roles': roles,
    'created_at': createdAt,
  };
}
