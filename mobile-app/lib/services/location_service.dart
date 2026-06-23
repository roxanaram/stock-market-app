import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  // Countries available in the app catalog (for manual selection fallback)
  static const List<String> supportedCountries = [
    'United States',
    'Germany',
    'United Kingdom',
    'France',
    'Japan',
    'Canada',
    'Switzerland',
    'Australia',
  ];

  List<String> get supportedCountriesList => supportedCountries;

  Future<String> getCountry() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return 'Germany';

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return 'Germany';
      }
      if (permission == LocationPermission.deniedForever) return 'Germany';

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      ).timeout(const Duration(seconds: 8));

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      final detected = placemarks.first.country ?? 'Germany';

      // Map detected country to a supported one, else default to Germany
      if (supportedCountries.contains(detected)) {
        return detected;
      }
      return 'Germany';
    } catch (e) {
      return 'Germany';
    }
  }
}

