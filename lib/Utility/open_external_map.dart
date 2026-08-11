import 'dart:io' show Platform;
import 'package:url_launcher/url_launcher.dart';

Future<void> openExternalMap({
  required double? lat,
  required double? lng,
  String? label,
}) async {

  if (lat == null || lng == null) return;


  final name = Uri.encodeComponent(label ?? 'Selected Location');

  // Schemes / URLs
  final googleMapsScheme = Uri.parse('comgooglemaps://?q=$name&center=$lat,$lng&zoom=16');
  final appleMapsHttp   = Uri.parse('http://maps.apple.com/?ll=$lat,$lng&q=$name');
  final geoScheme       = Uri.parse('geo:$lat,$lng?q=$lat,$lng($name)'); // Android
  final webFallback     = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');

  // iOS: Google Maps app -> Apple Maps -> Web
  if (Platform.isIOS) {
    if (await canLaunchUrl(googleMapsScheme)) {
      await launchUrl(googleMapsScheme, mode: LaunchMode.externalApplication);
      return;
    }
    if (await canLaunchUrl(appleMapsHttp)) {
      await launchUrl(appleMapsHttp, mode: LaunchMode.externalApplication);
      return;
    }
    await launchUrl(webFallback, mode: LaunchMode.externalApplication);
    return;
  }

  // Android: geo: -> Google Maps scheme -> Web
  if (await canLaunchUrl(geoScheme)) {
    await launchUrl(geoScheme, mode: LaunchMode.externalApplication);
    return;
  }
  if (await canLaunchUrl(googleMapsScheme)) {
    await launchUrl(googleMapsScheme, mode: LaunchMode.externalApplication);
    return;
  }
  await launchUrl(webFallback, mode: LaunchMode.externalApplication);
}
