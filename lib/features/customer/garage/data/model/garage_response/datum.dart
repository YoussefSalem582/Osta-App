class Datum {
  String? id;
  String? make;
  String? model;
  int? year;
  dynamic plateNumber;
  dynamic vin;
  String? color;
  dynamic fuelType;
  dynamic transmission;
  dynamic currentMileage;
  bool? isPrimary;
  dynamic deletedAt;
  String? createdAt;
  String? updatedAt;

  Datum({
    this.id,
    this.make,
    this.model,
    this.year,
    this.plateNumber,
    this.vin,
    this.color,
    this.fuelType,
    this.transmission,
    this.currentMileage,
    this.isPrimary,
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json['id'] as String?,
    make: json['make'] as String?,
    model: json['model'] as String?,
    year: json['year'] as int?,
    plateNumber: json['plate_number'] as dynamic,
    vin: json['vin'] as dynamic,
    color: json['color'] as String?,
    fuelType: json['fuel_type'] as dynamic,
    transmission: json['transmission'] as dynamic,
    currentMileage: json['current_mileage'] as dynamic,
    isPrimary: json['is_primary'] as bool?,
    deletedAt: json['deleted_at'] as dynamic,
    createdAt: json['created_at'] as String?,
    updatedAt: json['updated_at'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'make': make,
    'model': model,
    'year': year,
    'plate_number': plateNumber,
    'vin': vin,
    'color': color,
    'fuel_type': fuelType,
    'transmission': transmission,
    'current_mileage': currentMileage,
    'is_primary': isPrimary,
    'deleted_at': deletedAt,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}
