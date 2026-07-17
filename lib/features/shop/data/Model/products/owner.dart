class Owner {
  String? type;
  String? id;
  String? name;

  Owner({this.type, this.id, this.name});

  factory Owner.fromJson(Map<String, dynamic> json) => Owner(
    type: json['type'] as String?,
    id: json['id'] as String?,
    name: json['name'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'name': name,
  };
}
