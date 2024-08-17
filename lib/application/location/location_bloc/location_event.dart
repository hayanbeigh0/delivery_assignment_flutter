part of 'location_bloc.dart';

@freezed
class LocationEvent with _$LocationEvent {
  const factory LocationEvent.started({
    required String orderId,
  }) = _Started;
  const factory LocationEvent.locationChanged({
    required Location location,
  }) = _LocationChanged;
  const factory LocationEvent.emitLocationUpdate({
    required Location location,
    required String orderId,
  }) = _EmitLocationUpdate;
  const factory LocationEvent.loading() = _Loading;
}
