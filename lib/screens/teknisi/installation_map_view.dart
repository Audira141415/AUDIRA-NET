import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class InstallationMapView extends StatefulWidget {
  final List<Map<String, dynamic>> installations;

  const InstallationMapView({super.key, required this.installations});

  @override
  State<InstallationMapView> createState() => _InstallationMapViewState();
}

class _InstallationMapViewState extends State<InstallationMapView> {
  late MapController _mapController;
  Map<String, dynamic>? _selectedInstallation;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  Color _getMarkerColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'in_progress':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  void _openGoogleMaps(double lat, double lng) async {
    final url = 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter installations yang punya koordinat
    final installationsWithCoords = widget.installations
        .where((i) => i['latitude'] != null && i['longitude'] != null)
        .toList();

    if (installationsWithCoords.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Peta Instalasi'),
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.map_outlined, size: 80, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Belum ada instalasi dengan lokasi',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    // Calculate center point
    double avgLat =
        installationsWithCoords
            .map((i) => i['latitude'] as double)
            .reduce((a, b) => a + b) /
        installationsWithCoords.length;
    double avgLng =
        installationsWithCoords
            .map((i) => i['longitude'] as double)
            .reduce((a, b) => a + b) /
        installationsWithCoords.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Peta Instalasi'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              _mapController.move(LatLng(avgLat, avgLng), 13.0);
            },
            tooltip: 'Lihat Semua',
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(avgLat, avgLng),
              initialZoom: 13.0,
              onTap: (_, position) =>
                  setState(() => _selectedInstallation = null),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.audira_app',
              ),
              MarkerLayer(
                markers: installationsWithCoords.map((installation) {
                  final lat = installation['latitude'] as double;
                  final lng = installation['longitude'] as double;
                  final status = installation['status'] as String;

                  return Marker(
                    point: LatLng(lat, lng),
                    width: 40,
                    height: 40,
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _selectedInstallation = installation);
                        _mapController.move(LatLng(lat, lng), 15.0);
                      },
                      child: Icon(
                        Icons.location_pin,
                        color: _getMarkerColor(status),
                        size: 40,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          // Bottom info card
          if (_selectedInstallation != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Card(
                margin: EdgeInsets.zero,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              _selectedInstallation!['customerName'],
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () =>
                                setState(() => _selectedInstallation = null),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.wifi,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${_selectedInstallation!['packageName']} - ${_selectedInstallation!['speed']} Mbps',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _selectedInstallation!['address'],
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.phone,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _selectedInstallation!['phone'],
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${_selectedInstallation!['scheduledDate']} ${_selectedInstallation!['scheduledTime']}',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () {
                                final lat =
                                    _selectedInstallation!['latitude']
                                        as double;
                                final lng =
                                    _selectedInstallation!['longitude']
                                        as double;
                                _openGoogleMaps(lat, lng);
                              },
                              icon: const Icon(Icons.directions),
                              label: const Text('Navigasi'),
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.orange,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                final phone = _selectedInstallation!['phone'];
                                final url = Uri.parse('tel:$phone');
                                if (await canLaunchUrl(url)) {
                                  await launchUrl(url);
                                }
                              },
                              icon: const Icon(Icons.phone),
                              label: const Text('Hubungi'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.orange,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          // Legend
          Positioned(
            top: 16,
            right: 16,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Legenda',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    _legendItem(Colors.blue, 'Terjadwal'),
                    _legendItem(Colors.orange, 'Sedang Proses'),
                    _legendItem(Colors.green, 'Selesai'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(Icons.circle, color: color, size: 12),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}
