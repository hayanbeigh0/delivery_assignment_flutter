import 'dart:developer';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
import 'package:shopping_app/application/products/product_cart_cubit/product_cart_cubit.dart';
import 'package:shopping_app/injection.dart';
import 'package:shopping_app/presentation/core/utils/current_location.dart';
import 'package:shopping_app/presentation/core/widgets/spinner_overlay.dart';

class PickupPointSheet extends StatelessWidget {
  final LatLng currentLocation;
  const PickupPointSheet({
    super.key,
    required this.currentLocation,
    required this.onPlacePicked,
  });
  final void Function(PickResult) onPlacePicked;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 30.0),
      child: PlacePicker(
        apiKey: Platform.isAndroid
            ? "AIzaSyBGiL6tvDFee_XBHcrFExHxr5fUrhKH6WM"
            : "AIzaSyA12JOjXBzE23QkBuni8Ku1uP7SYV9HIFw",
        onPlacePicked: onPlacePicked,
        initialPosition: currentLocation,
        useCurrentLocation: true,
        enableMyLocationButton: true,
        selectText: 'Select',
        onTapBack: () => context.router.popForced(),
      ),
    );
  }
}

//

Future<void> showPickupLocationSheet({
  required BuildContext context,
  required void Function(PickResult) onPlacePicked,
}) async {
  try {
    SpinnerOverlay().show(context);
    await determinePosition()
        .then((position) => LatLng(
              position.latitude,
              position.longitude,
            ))
        .then((latLng) async {
      SpinnerOverlay().hide();
      return await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return BlocProvider(
            create: (context) => getIt<ProductCartCubit>(),
            child: Center(
              child: PickupPointSheet(
                currentLocation: latLng,
                onPlacePicked: onPlacePicked,
              ),
            ),
          );
        },
      );
    });
  } catch (e) {
    log(e.toString());
  }
}
