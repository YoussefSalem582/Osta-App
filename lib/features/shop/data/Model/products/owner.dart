import 'package:equatable/equatable.dart';

class Owner extends Equatable {
  const Owner({this.type, this.id, this.name});

  factory Owner.fromJson(Map<String, dynamic> json) => Owner(
    type: json['type'] as String?,
    id: json['id'] as String?,
    name: json['name'] as String?,
  );

  final String? type;
  final String? id;
  final String? name;

  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'name': name,
  };

  @override
  List<Object?> get props => [type, id, name];
}
