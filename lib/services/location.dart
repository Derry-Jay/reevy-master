import 'package:geolocation/geolocation.dart';
import 'package:location_permissions/location_permissions.dart';

Future<LocationResult> getLocation() async {
  final GeolocationResult result = await Geolocation.isLocationOperational();
  if (result.isSuccessful) {
    return await Geolocation.lastKnownLocation();
  }
  else
    return null;
      // location permission is not granted
      // user might have denied, but it's also possible that location service is not enabled, restricted, and user never saw the permission request dialog. Check the result.error.type for details.
}