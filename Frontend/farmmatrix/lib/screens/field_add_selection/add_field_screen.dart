import 'package:flutter/material.dart';
    import 'package:google_maps_flutter/google_maps_flutter.dart';
    import 'package:geolocator/geolocator.dart';
    import 'package:geocoding/geocoding.dart';
    import 'package:supabase_flutter/supabase_flutter.dart';
    import 'package:shared_preferences/shared_preferences.dart';
    import 'package:farmmatrix/config/app_config.dart';

    class AddFieldScreen extends StatefulWidget {
      const AddFieldScreen({super.key});

      @override
      _AddFieldScreenState createState() => _AddFieldScreenState();
    }

    class _AddFieldScreenState extends State<AddFieldScreen> {
      late GoogleMapController _mapController;
      LatLng? _currentLocation;
      final Set<Polygon> _polygons = {};
      final Set<Marker> _markers = {};
      final List<LatLng> _polygonPoints = [];
      final TextEditingController _fieldNameController = TextEditingController();
      final TextEditingController _searchController = TextEditingController();
      final SupabaseClient _supabase = Supabase.instance.client;
      bool _isSaving = false;
      bool _isConfirmEnabled = false;

      @override
      void initState() {
        super.initState();
        _getCurrentLocation();
      }

      Future<void> _getCurrentLocation() async {
        try {
          bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
          if (!serviceEnabled) {
            throw Exception('Location services disabled');
          }

          LocationPermission permission = await Geolocator.checkPermission();
          if (permission == LocationPermission.denied) {
            permission = await Geolocator.requestPermission();
            if (permission == LocationPermission.denied) {
              throw Exception('Location permissions denied');
            }
          }

          Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          );
          setState(() {
            _currentLocation = LatLng(position.latitude, position.longitude);
          });
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }

      Future<void> _searchAndNavigate(String query) async {
        try {
          List<Location> locations = await locationFromAddress(query);
          if (locations.isNotEmpty) {
            final target = LatLng(
              locations.first.latitude,
              locations.first.longitude,
            );
            _mapController.animateCamera(CameraUpdate.newLatLngZoom(target, 16));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Location not found')),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Search error: $e')),
          );
        }
      }

      void _onMapTap(LatLng position) {
        _polygonPoints.add(position);
        _isConfirmEnabled = _polygonPoints.length >= 3;
        _updatePolygon();
      }

      void _updatePolygon() {
        _polygons.clear();
        _markers.clear();

        for (int i = 0; i < _polygonPoints.length; i++) {
          _markers.add(
            Marker(
              markerId: MarkerId('point_$i'),
              position: _polygonPoints[i],
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueAzure,
              ),
            ),
          );
        }

        if (_polygonPoints.length >= 3) {
          _polygons.add(
            Polygon(
              polygonId: const PolygonId('field_polygon'),
              points: _polygonPoints,
              strokeWidth: 2,
              strokeColor: Colors.blue,
              fillColor: Colors.blue.withOpacity(0.3),
            ),
          );
        }

        setState(() {});
      }

      void _clearPolygon() {
        _polygonPoints.clear();
        _polygons.clear();
        _markers.clear();
        _isConfirmEnabled = false;
        setState(() {});
      }

      void _showFieldNameDialog() {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('Enter Field Name'),
            content: TextField(
              controller: _fieldNameController,
              decoration: InputDecoration(
                hintText: 'Enter field name',
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: _isSaving ? null : _saveField,
                child: _isSaving
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text('Save'),
              ),
            ],
          ),
        );
      }

      Future<void> _saveField() async {
        final fieldName = _fieldNameController.text.trim();
        final prefs = await SharedPreferences.getInstance();
        final userId = prefs.getString('userId');

        if (userId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User ID not found')),
          );
          return;
        }

        if (fieldName.isEmpty || _polygonPoints.length < 3) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Invalid field data')),
          );
          return;
        }

        setState(() => _isSaving = true);

        try {
          final coordinates =
              _polygonPoints.map((pt) => [pt.latitude, pt.longitude]).toList();
          final geoJson = {
            "type": "Polygon",
            "coordinates": [coordinates],
          };

          await _supabase.from('user_fields').insert({
            'user_id': userId,
            'field_name': fieldName,
            'coordinates': coordinates,
            'geometry': geoJson,
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Field "$fieldName" saved successfully'),
            ),
          );

          _clearPolygon();
          _fieldNameController.clear();
          if (mounted) {
            Navigator.pop(context); // close dialog
            Navigator.pop(context, true); // return success
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        } finally {
          if (mounted) setState(() => _isSaving = false);
        }
      }

      @override
      Widget build(BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Add New Field'),
            backgroundColor: AppConfig.primaryColor,
          ),
          body: _currentLocation == null
              ? Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: _currentLocation!,
                              zoom: 15,
                            ),
                            onMapCreated: (controller) {
                              _mapController = controller;
                            },
                            myLocationEnabled: true,
                            myLocationButtonEnabled: true,
                            onTap: _onMapTap,
                            polygons: _polygons,
                            markers: _markers,
                            mapType: MapType.hybrid,
                          ),
                          Positioned(
                            top: 10,
                            left: 15,
                            right: 15,
                            child: Material(
                              elevation: 6,
                              borderRadius: BorderRadius.circular(8),
                              child: TextField(
                                controller: _searchController,
                                onSubmitted: _searchAndNavigate,
                                decoration: InputDecoration(
                                  hintText: 'Search location',
                                  prefixIcon: Icon(Icons.search),
                                  suffixIcon: IconButton(
                                    icon: Icon(Icons.clear),
                                    onPressed: () => _searchController.clear(),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 20,
                            left: 20,
                            child: Column(
                              children: [
                                FloatingActionButton(
                                  onPressed: _clearPolygon,
                                  tooltip: 'Clear Field',
                                  child: Icon(Icons.clear),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Clear',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isConfirmEnabled ? _showFieldNameDialog : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppConfig.primaryColor,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Confirm',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        );
      }

      @override
      void dispose() {
        _mapController.dispose();
        _fieldNameController.dispose();
        _searchController.dispose();
        super.dispose();
      }
    }