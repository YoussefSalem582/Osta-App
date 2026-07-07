import 'package:flutter/material.dart';

class DummyVehicle {
  const DummyVehicle({
    required this.id,
    required this.brand,
    required this.model,
    required this.plateNumber,
    required this.mileageKm,
    required this.isPrimary,
    this.year,
    this.icon = Icons.directions_car_rounded,
  });

  final String id;
  final String brand;
  final String model;
  final String plateNumber;
  final int mileageKm;
  final bool isPrimary;
  final int? year;
  final IconData icon;
}

final List<DummyVehicle> vehicles = [
    const DummyVehicle(
      id: '1',
      brand: 'كيا',
      model: 'سيراتو',
      plateNumber: '1234 ي',
      year: 2021,
      mileageKm: 65000,
      isPrimary: true,
    ),
    const DummyVehicle(
      id: '2',
      brand: 'هيونداي',
      model: 'إلنترا',
      plateNumber: '9999 ص',
      year: 2019,
      mileageKm: 82000,
      isPrimary: false,
      icon: Icons.directions_car_filled,
    ),
  ];
