import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<List<LatLng>?> fetchAndDrawPolyline(
    LatLng origin, LatLng destination) async {
  final Dio dio = GetIt.instance<Dio>();

  final String url = 'https://maps.googleapis.com/maps/api/directions/json'
      '?origin=${origin.latitude},${origin.longitude}'
      '&destination=${destination.latitude},${destination.longitude}'
      '&key=AIzaSyBGiL6tvDFee_XBHcrFExHxr5fUrhKH6WM';
  final response = await dio.get(
    url,
  );

  final data = response.data;

  if (data['status'] == 'OK') {
    final List<LatLng> polylinePoints =
        _decodePolyline(data['routes'][0]['overview_polyline']['points']);
    return polylinePoints;
  }
  return null;
}

List<LatLng> _decodePolyline(String polyline) {
  List<LatLng> points = [];
  int index = 0, len = polyline.length;
  int lat = 0, lng = 0;

  while (index < len) {
    int shift = 0, result = 0;
    int byte;
    do {
      byte = polyline.codeUnitAt(index++) - 63;
      result |= (byte & 0x1F) << shift;
      shift += 5;
    } while (byte >= 0x20);
    int deltaLat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
    lat += deltaLat;

    shift = 0;
    result = 0;
    do {
      byte = polyline.codeUnitAt(index++) - 63;
      result |= (byte & 0x1F) << shift;
      shift += 5;
    } while (byte >= 0x20);
    int deltaLng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
    lng += deltaLng;

    points.add(LatLng(lat / 1E5, lng / 1E5));
  }

  return points;
}
