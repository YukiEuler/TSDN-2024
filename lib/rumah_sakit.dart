import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math';

class HospitalListPage extends StatefulWidget {
  final GoogleMapsPlaces places;

  const HospitalListPage({
    Key? key,
    required this.places,
  }) : super(key: key);

  @override
  _HospitalListPageState createState() => _HospitalListPageState();
}

class _HospitalListPageState extends State<HospitalListPage> {
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
    print('API Key: ${widget.places.apiKey}');
  }

  Future<void> _initializeLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showLocationError('Location services are disabled.');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showLocationError('Location permissions are denied');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showLocationError('Location permissions are permanently denied');
      return;
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = position;
    });
  }

  void _showLocationError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<List<Map<String, dynamic>>> getNearbyHospitals() async {
    if (_currentPosition == null) return [];

    final location = Location(
      lat: _currentPosition!.latitude,
      lng: _currentPosition!.longitude,
    );

    final response = await widget.places.searchNearbyWithRadius(
      location,
      20000, // 20km radius
      type: 'hospital', // Use 'hospital' instead of 'rumah sakit'
      language: 'id',
    );

    print('API Key: ${widget.places.apiKey}');
    print('Response status: ${response.status}');
    print('Response error message: ${response.errorMessage}');
    print('Response results: ${response.results}');

    if (response.status == 'OK') {
      return response.results.map((place) => {
        'name': place.name,
        'address': place.vicinity,
        'latitude': place.geometry?.location.lat,
        'longitude': place.geometry?.location.lng,
        'rating': place.rating,
        'placeId': place.placeId,
        'photoReference': place.photos.isNotEmpty ? place.photos.first.photoReference : null,
      }).toList();
    } else {
      print('Error fetching hospitals: ${response.errorMessage}');
      return [];
    }
  }

  double calculateDistance(double startLatitude, double startLongitude, double endLatitude, double endLongitude) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    double dLat = _degreesToRadians(endLatitude - startLatitude);
    double dLon = _degreesToRadians(endLongitude - startLongitude);

    double a = 
      sin(dLat / 2) * sin(dLat / 2) +
      cos(_degreesToRadians(startLatitude)) * cos(_degreesToRadians(endLatitude)) *
      sin(dLon / 2) * sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rumah Sakit Terdekat'),
      ),
      body: _currentPosition == null
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<List<Map<String, dynamic>>>(
              future: getNearbyHospitals(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No hospitals found.'));
                }

                final hospitals = snapshot.data!;

                return ListView.builder(
                  itemCount: hospitals.length,
                  itemBuilder: (context, index) {
                    final hospital = hospitals[index];
                    final distance = calculateDistance(
                      _currentPosition!.latitude,
                      _currentPosition!.longitude,
                      hospital['latitude'] as double,
                      hospital['longitude'] as double,
                    );

                    final url = 'https://www.google.com/maps/search/?api=1&query=${hospital['latitude']},${hospital['longitude']}';
                    final photoUrl = hospital['photoReference'] != null
                        ? 'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=${hospital['photoReference']}&key=${widget.places.apiKey}'
                        : null;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      child: ListTile(
                        leading: photoUrl != null
                            ? Image.network(photoUrl, width: 50, height: 50, fit: BoxFit.cover)
                            : Icon(Icons.local_hospital, color: Colors.red),
                        title: Text(
                          hospital['name'],
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(hospital['address']),
                            Text('Rating: ${hospital['rating'] ?? 'N/A'}'),
                          ],
                        ),
                        trailing: Text('${distance.toStringAsFixed(1)} km'),
                        onTap: () {
                          launchUrl(Uri.parse(url));
                        },
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}