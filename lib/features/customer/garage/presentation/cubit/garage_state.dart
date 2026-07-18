import 'package:equatable/equatable.dart';
import 'package:osta/features/customer/garage/data/model/garage_response/garage_response.dart';

abstract class GarageState extends Equatable {
  const GarageState();

  @override
  List<Object?> get props => [];
}

class GarageInitial extends GarageState {
  const GarageInitial();
}

class GarageLoading extends GarageState {
  const GarageLoading();
}

class GarageSuccess extends GarageState {
  const GarageSuccess(this.response);

  final GarageResponse response;

  @override
  List<Object?> get props => [response];
}

class GarageError extends GarageState {
  const GarageError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class GarageAddLoading extends GarageState {
  const GarageAddLoading();
}

class GarageAddSuccess extends GarageState {
  const GarageAddSuccess();
}

class GarageAddError extends GarageState {
  const GarageAddError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

// ── Update-vehicle sub-states ────────────────────────────────────────────────

class GarageUpdateLoading extends GarageState {
  const GarageUpdateLoading();
}

class GarageUpdateSuccess extends GarageState {
  const GarageUpdateSuccess();
}

class GarageUpdateError extends GarageState {
  const GarageUpdateError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

// ── Set-primary sub-states ───────────────────────────────────────────────────

class GarageSetPrimaryLoading extends GarageState {
  const GarageSetPrimaryLoading();
}

class GarageSetPrimarySuccess extends GarageState {
  const GarageSetPrimarySuccess();
}

class GarageSetPrimaryError extends GarageState {
  const GarageSetPrimaryError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}


class GarageDeleteLoading extends GarageState {
  const GarageDeleteLoading();
}

class GarageDeleteSuccess extends GarageState {
  const GarageDeleteSuccess();
}

class GarageDeleteError extends GarageState {
  const GarageDeleteError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
