import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  Position? _lastKnownPosition;
  DateTime? _lastLocationUpdate;
  static const Duration _locationUpdateInterval = Duration(seconds: 30);

  Future<Position> getCurrentLocation() async {
    // Check if we have a recent location update
    if (_lastKnownPosition != null && _lastLocationUpdate != null) {
      final timeSinceLastUpdate =
          DateTime.now().difference(_lastLocationUpdate!);
      if (timeSinceLastUpdate < _locationUpdateInterval) {
        return _lastKnownPosition!;
      }
    }

    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    // Check for location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    try {
      // Get the location with a timeout
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      // Cache the position
      _lastKnownPosition = position;
      _lastLocationUpdate = DateTime.now();

      return position;
    } catch (e) {
      // If getting current position fails, try to get last known position
      try {
        final lastPosition = await Geolocator.getLastKnownPosition();
        if (lastPosition != null) {
          _lastKnownPosition = lastPosition;
          _lastLocationUpdate = DateTime.now();
          return lastPosition;
        }
      } catch (_) {
        // Ignore errors from last known position
      }
      throw Exception('Failed to get location: $e');
    }
  }

  Future<LatLng> getCurrentLatLng() async {
    final position = await getCurrentLocation();
    return LatLng(position.latitude, position.longitude);
  }

  Future<bool> hasLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    permission = await Geolocator.checkPermission();
    return permission != LocationPermission.denied &&
        permission != LocationPermission.deniedForever;
  }

  Future<void> requestLocationPermission() async {
    await Geolocator.requestPermission();
  }

  void dispose() {
    _lastKnownPosition = null;
    _lastLocationUpdate = null;
  }
}
