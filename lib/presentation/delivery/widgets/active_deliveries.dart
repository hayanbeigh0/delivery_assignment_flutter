import 'dart:async';
import 'dart:developer';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shopping_app/application/delivery/deliveries_cubit/deliveries_cubit.dart';
import 'package:shopping_app/application/delivery/delivery_cubit/delivery_cubit.dart';
import 'package:shopping_app/application/location/location_bloc/location_bloc.dart';
import 'package:shopping_app/domain/products/product.dart';
import 'package:shopping_app/injection.dart';
import 'package:shopping_app/presentation/core/utils/current_location.dart';
import 'package:shopping_app/presentation/core/utils/distance_calculator.dart';
import 'package:shopping_app/presentation/core/utils/get_image_from_bytes.dart';
import 'package:shopping_app/presentation/core/utils/get_polylines.dart';
import 'package:shopping_app/presentation/core/widgets/app_scaffold.dart';
import 'package:shopping_app/presentation/core/widgets/buttons/primary_elevated_button.dart';
import 'package:shopping_app/presentation/core/widgets/spinner_overlay.dart';

@RoutePage()
class ActiveDeliveriesPage extends StatefulWidget {
  const ActiveDeliveriesPage({super.key});

  @override
  State<ActiveDeliveriesPage> createState() => _ActiveDeliveriesPageState();
}

class _ActiveDeliveriesPageState extends State<ActiveDeliveriesPage> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => getIt<DeliveriesCubit>()),
        BlocProvider(create: (context) => getIt<DeliveryCubit>()),
        BlocProvider(create: (context) => LocationBloc()),
      ],
      child: const DeliveryWidget(),
    );
  }
}

class DeliveryWidget extends StatefulWidget {
  const DeliveryWidget({super.key});

  @override
  State<DeliveryWidget> createState() => _DeliveryWidgetState();
}

class _DeliveryWidgetState extends State<DeliveryWidget> {
  GoogleMapController? _mapController;

  LatLng? _currentPosition;

  Set<Marker> markers = {};

  Set<Polyline> polylines = {};

  int updatePolylineDelay = 0;
  // final _updatePloylineDebouncer = Debouncer(seconds: 10);

  void _getCurrentLocation() async {
    _currentPosition = await determinePosition().then(
      (position) => LatLng(
        position.latitude,
        position.longitude,
      ),
    );
    setState(() {
      _currentPosition;
      if (_mapController != null) {
        _zoomToMyLocation();
      }
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _zoomToMyLocation();
  }

  void _zoomToMyLocation() async {
    if (_mapController == null) return;
    _mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: _currentPosition!,
          zoom: 15,
        ),
      ),
    );
  }

  BitmapDescriptor? buyerCustomMarkerIcon;

  BitmapDescriptor? sellerCustomMarkerIcon;

  Future<void> _setCustomMarkerIcon() async {
    final Uint8List buyerMarkerIcon =
        await getBytesFromAsset('assets/images/house.png', 40);
    buyerCustomMarkerIcon = BitmapDescriptor.bytes(buyerMarkerIcon);
    final Uint8List sellerMarkerIcon =
        await getBytesFromAsset('assets/images/warehouse.png', 40);
    sellerCustomMarkerIcon = BitmapDescriptor.bytes(sellerMarkerIcon);
    setState(() {});
  }

  @override
  void initState() {
    _setCustomMarkerIcon();
    _getCurrentLocation();
    super.initState();
  }

  StreamSubscription? positionStream;

  void startLocationUpdates({
    required String orderId,
  }) {
    positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
        // timeLimit: Duration(seconds: 10),
      ),
    ).listen((Position position) {
      setState(() {
        BlocProvider.of<LocationBloc>(context).add(
          LocationEvent.emitLocationUpdate(
            location: Location(
              type: 'Point',
              coordinates: [position.latitude, position.longitude],
            ),
            orderId: orderId,
          ),
        );
      });
    });
  }

  @override
  void dispose() {
    positionStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBarTitle: 'Active Delivery',
      body: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => LocationBloc(),
          ),
          BlocProvider(
            create: (_) => getIt<DeliveriesCubit>()
              ..getDeliveries(
                activeDeliveries: true,
              ),
          ),
          BlocProvider.value(
            value: BlocProvider.of<DeliveryCubit>(context),
          ),
        ],
        child: BlocConsumer<DeliveryCubit, DeliveryState>(
          listener: (context, state) {
            state.maybeMap(
              orElse: () {
                SpinnerOverlay().hide();
              },
              loading: (_) => SpinnerOverlay().show(context),
              success: (value) {
                if (value.delivery == null) {
                  SpinnerOverlay().hide();
                  context.router.replaceNamed('/initiated-deliveries');
                } else {
                  // context.router.popForced();
                  SpinnerOverlay().hide();
                  BlocProvider.of<DeliveriesCubit>(context).getDeliveries(
                    activeDeliveries: true,
                  );
                }
              },
            );
          },
          builder: (context, state) {
            return BlocConsumer<DeliveriesCubit, DeliveriesState>(
              listener: (context, deliveriesState) {
                deliveriesState.when(
                  failed: (failure) {},
                  initial: () {},
                  loading: () {},
                  success: (value) {
                    BlocProvider.of<LocationBloc>(context)
                        .add(LocationEvent.started(
                      orderId: value.first.order.id!,
                    ));
                    startLocationUpdates(orderId: value.first.order.id!);
                  },
                );
              },
              builder: (context, deliveriesStateBuilder) {
                return deliveriesStateBuilder.maybeMap(
                  orElse: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  success: (value) {
                    log('builder is running');
                    final buyerLocation = LatLng(
                      value.deliveries.first.order.buyerAddress!.coordinates
                          .latitude!,
                      value.deliveries.first.order.buyerAddress!.coordinates
                          .longitude!,
                    );
                    final sellerLocation = LatLng(
                      value.deliveries.first.order.sellerAddress!.coordinates
                          .latitude!,
                      value.deliveries.first.order.sellerAddress!.coordinates
                          .longitude!,
                    );
                    // updatePolyline(buyerLocation, sellerLocation);
                    markers.add(
                      Marker(
                        markerId: const MarkerId('Buyer'),
                        position: LatLng(
                          buyerLocation.latitude,
                          buyerLocation.longitude,
                        ),
                        infoWindow: const InfoWindow(
                          title: 'Buyer',
                          snippet: 'This is the Buyer location',
                        ),
                        icon: buyerCustomMarkerIcon ??
                            BitmapDescriptor.defaultMarker,
                      ),
                    );
                    markers.add(
                      Marker(
                        markerId: const MarkerId('Seller'),
                        position: LatLng(
                          sellerLocation.latitude,
                          sellerLocation.longitude,
                        ),
                        infoWindow: const InfoWindow(
                          title: 'Seller',
                          snippet: 'This is the Seller location',
                        ),
                        icon: sellerCustomMarkerIcon ??
                            BitmapDescriptor.defaultMarker,
                      ),
                    );
                    final distance =
                        calculateTotalDistanceInMetersOrKilometers([
                      LatLng(
                        value
                            .deliveries.first.dropAddress.coordinates.latitude!,
                        value.deliveries.first.dropAddress.coordinates
                            .longitude!,
                      ),
                      LatLng(
                        value.deliveries.first.pickupAddress.coordinates
                            .latitude!,
                        value.deliveries.first.pickupAddress.coordinates
                            .longitude!,
                      ),
                      LatLng(
                        value.deliveries.first.order.buyerAddress!.coordinates
                            .latitude!,
                        value.deliveries.first.order.buyerAddress!.coordinates
                            .longitude!,
                      ),
                    ]);
                    return BlocListener<LocationBloc, LocationState>(
                      listener: (context, state) {
                        if (_currentPosition != null) {
                          if (value.deliveries.first.deliveryStatus ==
                              'PARTNER-ASSIGNED') {
                            updatePolyline(_currentPosition!, sellerLocation);
                          } else {
                            updatePolyline(_currentPosition!, buyerLocation);
                          }
                          updatePolylineDelay = 5;
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pickup address: ${value.deliveries.first.pickupAddress.address}',
                            ),
                            Text(
                              'Drop address: ${value.deliveries.first.dropAddress.address}',
                              //
                            ),
                            Text(
                              'Total distance between pickup and drop: $distance',
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            if (_currentPosition == null)
                              const Expanded(
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                            if (_currentPosition != null)
                              Expanded(
                                child: GoogleMap(
                                  initialCameraPosition: const CameraPosition(
                                    target: LatLng(0, 0), // Initial position
                                    zoom: 10,
                                  ),
                                  onMapCreated: _onMapCreated,
                                  compassEnabled: true,
                                  myLocationEnabled: true,
                                  markers: markers,
                                  polylines: polylines,
                                ),
                              ),
                            const SizedBox(
                              height: 12,
                            ),
                            Row(
                              children: [
                                // if (value.deliveries.first.deliveryStatus !=
                                //     'PICKEDUP')
                                //   Expanded(
                                //     child: Row(
                                //       children: [
                                //         AppElevatedButton(
                                //           onPressed: () {
                                // BlocProvider.of<DeliveryCubit>(
                                //         context)
                                //     .updateDeliveryStatus(
                                //   id: value.deliveries.first.id,
                                //   status: 'PICKEDUP',
                                // );
                                //           },
                                //           child: const Text('Complete Pickup'),
                                //         ),
                                //         const SizedBox(
                                //           width: 10,
                                //         ),
                                //       ],
                                //     ),
                                //   ),
                                Expanded(
                                  child: AppElevatedButton(
                                    onPressed: () {
                                      if (value.deliveries.first
                                              .deliveryStatus ==
                                          'PARTNER-ASSIGNED') {
                                        BlocProvider.of<DeliveryCubit>(context)
                                            .updateDeliveryStatus(
                                          id: value.deliveries.first.id,
                                          status: 'PICKEDUP',
                                        );
                                      } else {
                                        BlocProvider.of<DeliveryCubit>(context)
                                            .fulfillDelivery(
                                          deliveryId: value.deliveries.first.id,
                                        );
                                      }
                                    },
                                    child: Text(
                                      value.deliveries.first.deliveryStatus ==
                                              'PARTNER-ASSIGNED'
                                          ? 'Complete Pickup'
                                          : 'Complete Drop',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Timer? _debounceTimer;
  void updatePolyline(LatLng newStart, LatLng newEnd) async {
    // Cancel the previous timer if it exists
    _debounceTimer?.cancel();

    // Start a new timer
    _debounceTimer = Timer(Duration(seconds: updatePolylineDelay), () async {
      debugPrint('Debouncer timer fired');

      // Example function to fetch and draw polyline
      List<LatLng>? newPolylineCoordinates =
          await fetchAndDrawPolyline(newStart, newEnd);

      if (newPolylineCoordinates != null) {
        setState(() {
          polylines.clear();
          polylines.add(
            Polyline(
              polylineId: const PolylineId('real_time_polyline'),
              points: newPolylineCoordinates,
              color: Colors.blue,
              width: 5,
            ),
          );
        });
        debugPrint('New polylines set');
      } else {
        debugPrint('No points found');
      }
    });
  }
}
