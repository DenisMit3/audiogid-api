import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class SharedLocationScreen extends StatelessWidget {
  final double lat;
  final double lon;
  final String? time;

  const SharedLocationScreen({super.key, required this.lat, required this.lon, this.time});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(time != null ? 'Shared: $time' : 'Shared Location')),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(lat, lon),
          initialZoom: 15,
        ),
        children: [
            TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.audiogid.app',
            ),
            MarkerLayer(
                markers: [
                    Marker(
                        point: LatLng(lat, lon),
                        width: 40,
                        height: 40,
                        child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
                    )
                ]
            )
        ],
      )
    );
  }
}
