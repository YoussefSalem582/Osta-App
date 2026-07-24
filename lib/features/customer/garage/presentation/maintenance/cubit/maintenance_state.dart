import 'package:equatable/equatable.dart';
import 'package:osta/core/network/api_client.dart';
import 'package:osta/features/customer/garage/data/models/maintenance_record.dart';

abstract class MaintenanceState extends Equatable {
  const MaintenanceState();

  @override
  List<Object?> get props => [];
}

class MaintenanceInitial extends MaintenanceState {
  const MaintenanceInitial();
}

class MaintenanceLoading extends MaintenanceState {
  const MaintenanceLoading();
}

class MaintenanceSuccess extends MaintenanceState {
  const MaintenanceSuccess(this.records, this.meta);

  final List<MaintenanceRecord> records;
  final PaginationMeta? meta;

  @override
  List<Object?> get props => [records, meta];
}

class MaintenanceError extends MaintenanceState {
  const MaintenanceError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

// ── Add-record sub-states ────────────────────────────────────────────────────

class MaintenanceAddLoading extends MaintenanceState {
  const MaintenanceAddLoading();
}

class MaintenanceAddSuccess extends MaintenanceState {
  const MaintenanceAddSuccess();
}

class MaintenanceAddError extends MaintenanceState {
  const MaintenanceAddError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
