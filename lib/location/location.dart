import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Location {
  Location(this.longitude, this.latitude, this.name);

  final double longitude;
  final double latitude;
  final String name;

  static Location? fromJson(Map<String, Object?>? json) {
    if (json == null) return null;
    return Location(
      json['longitude'] as double,
      json['latitude'] as double,
      json['name'] as String,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'name': name,
    };
  }

  static Future<bool> locationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('locations') ?? false;
  }

  static Future<Location?> now() async {
    if (! await locationEnabled()) return null;
    try {
      bool result = await checkPermissions();
      if (!result) return null;
    } catch(e) {
      return null;
    }
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
    String name = position.latitude.toStringAsPrecision(3) + position.longitude.toStringAsPrecision(3);
    if (placemarks.isNotEmpty) {
      Placemark first = placemarks.first;
      String street = first.thoroughfare ?? '';
      String city = first.locality ?? '';
      String country = first.country ?? '';
      if (street.isNotEmpty || city.isNotEmpty) {
        name = street + (street.isEmpty ? "" : " in ")
            + city + (city.isEmpty ? "" : ", ")
            + country;
      }
    }
    return Location(position.longitude, position.latitude, name);
  }

  static Future<bool> checkPermissions() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('permission_denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
      throw Exception('permission_denied');
    }
    return true;
  }
}
