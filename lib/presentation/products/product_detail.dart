import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shopping_app/application/delivery/deliveries_cubit/deliveries_cubit.dart';
import 'package:shopping_app/application/location/location_bloc/location_bloc.dart';
import 'package:shopping_app/domain/product_order/product_order.dart';
import 'package:shopping_app/domain/products/product.dart';
import 'package:shopping_app/injection.dart';
import 'package:shopping_app/presentation/core/utils/current_location.dart';
import 'package:shopping_app/presentation/core/utils/get_image_from_bytes.dart';
import 'package:shopping_app/presentation/core/utils/get_polylines.dart';
import 'package:shopping_app/presentation/core/widgets/app_scaffold.dart';

@RoutePage()
class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({super.key, required this.order});
  final ProductOrder order;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => getIt<DeliveriesCubit>()),
        BlocProvider(create: (context) => LocationBloc()),
      ],
      child: OrderDetailsWidget(
        order: order,
      ),
    );
  }
}

class OrderDetailsWidget extends StatefulWidget {
  const OrderDetailsWidget({super.key, required this.order});
  final ProductOrder order;

  @override
  State<OrderDetailsWidget> createState() => OrderDetailsWidgetState();
}

class OrderDetailsWidgetState extends State<OrderDetailsWidget> {
  GoogleMapController? _mapController;

  LatLng? _currentPosition;

  Set<Marker> markers = {};

  Set<Polyline> polylines = {};

  late LatLng sellerLocation;
  late LatLng buyerLocation;

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
  BitmapDescriptor? deliveryPartnerCustomMarkerIcon;

  Future<void> _setCustomMarkerIcon() async {
    final Uint8List buyerMarkerIcon =
        await getBytesFromAsset('assets/images/house.png', 40);
    buyerCustomMarkerIcon = BitmapDescriptor.bytes(buyerMarkerIcon);
    final Uint8List sellerMarkerIcon =
        await getBytesFromAsset('assets/images/warehouse.png', 40);
    sellerCustomMarkerIcon = BitmapDescriptor.bytes(sellerMarkerIcon);
    final Uint8List deliveryPartnerMarkerIcon =
        await getBytesFromAsset('assets/images/deliveryguy.png', 40);
    deliveryPartnerCustomMarkerIcon =
        BitmapDescriptor.bytes(deliveryPartnerMarkerIcon);
    setState(() {});
  }

  @override
  void initState() {
    BlocProvider.of<LocationBloc>(context).add(LocationEvent.started(
      orderId: widget.order.id,
    ));
    BlocProvider.of<LocationBloc>(context).add(LocationEvent.emitLocationUpdate(
      location: Location(
        type: 'Point',
        coordinates: [
          widget.order.sellerAddress.coordinates.latitude!,
          widget.order.sellerAddress.coordinates.longitude!,
        ],
      ),
      orderId: widget.order.id,
    ));
    _setCustomMarkerIcon();
    _getCurrentLocation();
    super.initState();
  }

  StreamSubscription? positionStream;

  @override
  void dispose() {
    positionStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBarTitle: 'Order',
      body: BlocConsumer<LocationBloc, LocationState>(
        listener: (context, locationState) {
          locationState.maybeMap(
            orElse: () {},
            updatedLocation: (value) {
              final deliveryPartnerLocation = LatLng(
                value.location.coordinates[0],
                value.location.coordinates[1],
              );
              buyerLocation = LatLng(
                widget.order.buyerAddress.coordinates.latitude!,
                widget.order.buyerAddress.coordinates.longitude!,
              );

              updatePolyline(
                buyerLocation,
                deliveryPartnerLocation,
              );
            },
          );
        },
        builder: (context, state) {
          return state.maybeMap(
            orElse: () => const Center(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
            updatedLocation: (value) {
              sellerLocation = LatLng(
                widget.order.sellerAddress.coordinates.latitude!,
                widget.order.sellerAddress.coordinates.longitude!,
              );
              buyerLocation = LatLng(
                widget.order.buyerAddress.coordinates.latitude!,
                widget.order.buyerAddress.coordinates.longitude!,
              );
              markers.add(
                Marker(
                  markerId: const MarkerId('DeliveryPartner'),
                  position: LatLng(
                    value.location.coordinates[0],
                    value.location.coordinates[1],
                  ),
                  infoWindow: const InfoWindow(
                    title: 'Delivery Partner',
                    snippet: 'This is the Delivery partner location',
                  ),
                  icon: deliveryPartnerCustomMarkerIcon ??
                      BitmapDescriptor.defaultMarker,
                ),
              );
              markers.add(
                Marker(
                  markerId: const MarkerId('BuyerLocation'),
                  position: LatLng(
                    buyerLocation.latitude,
                    buyerLocation.longitude,
                  ),
                  infoWindow: const InfoWindow(
                    title: 'Delivery Address',
                    snippet: 'This is the Delivery address location',
                  ),
                  icon: buyerCustomMarkerIcon ?? BitmapDescriptor.defaultMarker,
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
                  icon:
                      sellerCustomMarkerIcon ?? BitmapDescriptor.defaultMarker,
                ),
              );
              return Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your address: ${widget.order.buyerAddress.address}',
                    ),
                    Text(
                      'Pickup address: ${widget.order.sellerAddress.address}',
                    ),
                    // Text(
                    //   'Total distance to cover: $distance',
                    // ),
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
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Timer? _debounceTimer;
  void updatePolyline(LatLng newStart, LatLng newEnd) async {
    // Cancel the previous timer if it exists
    _debounceTimer?.cancel();

    // Start a new timer
    _debounceTimer = Timer(Duration(seconds: 5), () async {
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
