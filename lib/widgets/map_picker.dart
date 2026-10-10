import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapPicker extends StatefulWidget {
  final LatLng? initialPosition;
  final Function(LatLng) onLocationPicked;

  const MapPicker({
    super.key,
    this.initialPosition,
    required this.onLocationPicked,
  });

  @override
  State<MapPicker> createState() => _MapPickerState();
}

class _MapPickerState extends State<MapPicker> {
  late MapController _mapController;
  LatLng _selectedPosition = const LatLng(
    -6.2088,
    106.8456,
  ); // Default: Jakarta

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    if (widget.initialPosition != null) {
      _selectedPosition = widget.initialPosition!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Lokasi Instalasi'),
        actions: [
          TextButton.icon(
            onPressed: () {
              widget.onLocationPicked(_selectedPosition);
              Navigator.pop(context, _selectedPosition);
            },
            icon: const Icon(Icons.check, color: Colors.white),
            label: const Text(
              'Konfirmasi',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selectedPosition,
              initialZoom: 15.0,
              onTap: (tapPosition, point) {
                setState(() {
                  _selectedPosition = point;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.audira_app',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _selectedPosition,
                    width: 40,
                    height: 40,
                    child: const Icon(
                      Icons.location_pin,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Koordinat yang Dipilih:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Lat: ${_selectedPosition.latitude.toStringAsFixed(6)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    Text(
                      'Lng: ${_selectedPosition.longitude.toStringAsFixed(6)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tap pada peta untuk memilih lokasi',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Center ke Jakarta
          _mapController.move(const LatLng(-6.2088, 106.8456), 13.0);
        },
        child: const Icon(Icons.my_location),
      ),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}
