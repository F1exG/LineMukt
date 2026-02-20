import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapsScreen extends StatefulWidget {
  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  MapController? mapController;

  // Civil Service Hospital - PINNED LOCATION (FIXED)
  final LatLng cshHospital = LatLng(27.6892, 85.3419);

  // Hospital locations in Kathmandu, Nepal (ALL FIXED)
  final List<Marker> hospitals = [
    // 🟢 CIVIL SERVICE HOSPITAL
    Marker(
      point: LatLng(27.6892, 85.3419),
      width: 100,
      height: 120,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Civil Service Hospital',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Icon(Icons.location_on, color: Colors.green, size: 50),
        ],
      ),
    ),
    // 🟢 KATHMANDU MEDICAL HOSPITAL
    Marker(
      point: LatLng(27.6917, 85.3450),
      width: 100,
      height: 100,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'Kathmandu Medical Hospital',
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          Icon(Icons.location_on, color: Colors.green, size: 35),
        ],
      ),
    ),
    // 🟢 BIR HOSPITAL
    Marker(
      point: LatLng(27.7063, 85.3166),
      width: 80,
      height: 80,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'Bir Hospital',
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          Icon(Icons.location_on, color: Colors.green, size: 35),
        ],
      ),
    ),
    // 🟢 T.U. TEACHING HOSPITAL
    Marker(
      point: LatLng(27.7358, 85.3300),
      width: 80,
      height: 80,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'T.U. Teaching Hospital',
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          Icon(Icons.location_on, color: Colors.green, size: 35),
        ],
      ),
    ),
    // 🟢 CHHATRAPATI FREE CLINIC HOSPITAL
    Marker(
      point: LatLng(27.7070, 85.3095),
      width: 80,
      height: 80,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'Chhatrapati Free Clinic',
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          Icon(Icons.location_on, color: Colors.green, size: 35),
        ],
      ),
    ),
    // 🟢 SUKRARAJ TROPICAL & INFECTIOUS DISEASE HOSPITAL
    Marker(
      point: LatLng(27.6946, 85.3006),
      width: 80,
      height: 80,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'Sukraraj Hospital',
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          Icon(Icons.location_on, color: Colors.green, size: 35),
        ],
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hospitals in Kathmandu'),
        backgroundColor: Color(0xFF00C9A7),
        elevation: 0,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: cshHospital,
              initialZoom: 13.0, // Zoomed out a bit to see all hospitals
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.linemukta.app',
              ),
              MarkerLayer(markers: hospitals),
            ],
          ),
          // Hospital Info Card at bottom
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.local_hospital, color: Colors.green, size: 28),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hospitals in Kathmandu',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Kathmandu, Nepal',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.queue),
                    label: Text('Join Queue'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF00C9A7),
                      minimumSize: Size(double.infinity, 40),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}