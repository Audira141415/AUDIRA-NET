import 'package:url_launcher/url_launcher.dart';

/// Utility untuk membuka maps dan navigasi
class MapUtils {
  /// Buka Google Maps dengan koordinat
  static Future<bool> openMapWithCoordinates(
    double latitude,
    double longitude, {
    String? label,
  }) async {
    final labelParam = label != null ? Uri.encodeComponent(label) : '';
    final url =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude&query_place_id=$labelParam';

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }

  /// Buka Google Maps dengan alamat
  static Future<bool> openMapWithAddress(String address) async {
    final encodedAddress = Uri.encodeComponent(address);
    final url =
        'https://www.google.com/maps/search/?api=1&query=$encodedAddress';

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }

  /// Buka navigasi turn-by-turn ke alamat
  static Future<bool> navigateToAddress(String address) async {
    final encodedAddress = Uri.encodeComponent(address);

    // Try Google Maps first
    final googleMapsUrl = 'google.navigation:q=$encodedAddress';
    final googleUri = Uri.parse(googleMapsUrl);

    if (await canLaunchUrl(googleUri)) {
      return await launchUrl(googleUri, mode: LaunchMode.externalApplication);
    }

    // Fallback to web maps
    return await openMapWithAddress(address);
  }

  /// Buka navigasi ke koordinat
  static Future<bool> navigateToCoordinates(
    double latitude,
    double longitude,
  ) async {
    // Try Google Maps navigation
    final googleMapsUrl = 'google.navigation:q=$latitude,$longitude';
    final googleUri = Uri.parse(googleMapsUrl);

    if (await canLaunchUrl(googleUri)) {
      return await launchUrl(googleUri, mode: LaunchMode.externalApplication);
    }

    // Fallback to web maps
    return await openMapWithCoordinates(latitude, longitude);
  }

  /// Dapatkan link share location
  static String getShareLocationLink(double latitude, double longitude) {
    return 'https://maps.google.com/?q=$latitude,$longitude';
  }
}
