import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shopping_app/domain/products/product.dart';
import 'package:shopping_app/infrastructure/location/location_repository.dart';

part 'location_event.dart';
part 'location_state.dart';
part 'location_bloc.freezed.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  StreamSubscription? _locationSubscription;
  LocationBloc() : super(const _Initial()) {
    on<LocationEvent>((event, emit) {
      event.map(
        started: (value) {
          final LocationRepository locationRepository =
              LocationRepository(value.orderId);

          if (!isClosed) {
            _locationSubscription = locationRepository.locationStream.listen(
              (data) {
                if (!isClosed) {
                  add(const LocationEvent.loading());
                  add(LocationEvent.locationChanged(location: data));
                }
              },
            );
          }
        },
        loading: (value) => emit(const LocationState.initial()),
        locationChanged: (value) {
          if (!isClosed) {
            emit(
              LocationState.updatedLocation(location: value.location),
            );
          }
        },
        emitLocationUpdate: (_EmitLocationUpdate value) {
          final LocationRepository locationRepository =
              LocationRepository(value.orderId);
          if (!isClosed) {
            locationRepository.emitLocationUpdate(
              latitude: value.location.coordinates[0],
              longitude: value.location.coordinates[1],
              orderId: value.orderId,
            );
          }
        },
      );
    });
  }
  @override
  Future<void> close() {
    // Cancel the subscription when the bloc is closed
    _locationSubscription?.cancel();
    return super.close();
  }
}
