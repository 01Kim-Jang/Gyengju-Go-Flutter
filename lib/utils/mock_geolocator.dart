class Position {
  final double latitude;
  final double longitude;
  final DateTime? timestamp;
  final double accuracy;
  final double altitude;
  final double heading;
  final double speed;
  final double speedAccuracy;

  Position({
    required this.latitude,
    required this.longitude,
    this.timestamp,
    this.accuracy = 0.0,
    this.altitude = 0.0,
    this.heading = 0.0,
    this.speed = 0.0,
    this.speedAccuracy = 0.0,
  });
}

enum LocationAccuracy {
  lowest,
  low,
  medium,
  high,
  best,
  bestForNavigation
}

class LocationPermission {
  static const always = LocationPermission();
  static const whileInUse = LocationPermission();
  static const denied = LocationPermission();
  static const deniedForever = LocationPermission();

  const LocationPermission();
}

class Geolocator {
  static Future<LocationPermission> checkPermission() async {
    return LocationPermission.always;
  }

  static Future<LocationPermission> requestPermission() async {
    return LocationPermission.always;
  }

  static Future<Position> getCurrentPosition({dynamic desiredAccuracy}) async {
    // Return a dummy location in Gyeongju (Cheomseongdae area)
    return Position(
      latitude: 35.834710,
      longitude: 129.219062,
    );
  }
}
