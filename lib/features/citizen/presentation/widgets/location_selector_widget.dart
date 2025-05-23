import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../domain/entities/enhanced_report_entity.dart';
import 'manual_address_widget.dart';

class LocationSelectorWidget extends StatefulWidget {
  final LocationData? initialLocation;
  final Function(LocationData) onLocationSelected;

  const LocationSelectorWidget({
    super.key,
    this.initialLocation,
    required this.onLocationSelected,
  });

  @override
  State<LocationSelectorWidget> createState() => _LocationSelectorWidgetState();
}

class _LocationSelectorWidgetState extends State<LocationSelectorWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  LocationData? _selectedLocation;
  GoogleMapController? _mapController;

  bool _isLoadingGPS = false;
  String? _errorMessage;

  final Set<Marker> _markers = {};
  late CameraPosition _initialCameraPosition;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _selectedLocation = widget.initialLocation;

    _initialCameraPosition = const CameraPosition(
      target: LatLng(-37.1716, -72.9333),
      zoom: 14,
    );

    if (_selectedLocation != null) {
      _updateMapMarker(_selectedLocation!);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withAlpha((0.1 * 255).toInt()),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Seleccionar Ubicación',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (_selectedLocation != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color:
                          AppTheme.successColor.withAlpha((0.2 * 255).toInt()),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Seleccionada',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.successColor,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (_selectedLocation != null) _buildCurrentSelection(),
          if (_errorMessage != null) _buildErrorMessage(),
          TabBar(
            controller: _tabController,
            labelColor: AppTheme.primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppTheme.primaryColor,
            tabs: const [
              Tab(icon: Icon(Icons.gps_fixed), text: 'GPS'),
              Tab(icon: Icon(Icons.map), text: 'Mapa'),
              Tab(icon: Icon(Icons.edit_location), text: 'Manual'),
            ],
          ),
          SizedBox(
            height: 300,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildGPSTab(),
                _buildMapTab(),
                _buildManualTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentSelection() {
    final location = _selectedLocation!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.successColor.withAlpha((0.05 * 255).toInt()),
        border: Border.all(
            color: AppTheme.successColor.withAlpha((0.3 * 255).toInt())),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.check_circle, color: AppTheme.successColor, size: 16),
              SizedBox(width: 8),
              Text(
                'Ubicación seleccionada:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.successColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _getLocationDisplayText(location),
            style: const TextStyle(fontSize: 14),
          ),
          if (location.latitude != 0 && location.longitude != 0)
            Text(
              'Coordenadas: ${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.errorColor.withAlpha((0.05 * 255).toInt()),
        border: Border.all(
            color: AppTheme.errorColor.withAlpha((0.3 * 255).toInt())),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppTheme.errorColor, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: AppTheme.errorColor, fontSize: 14),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 16),
            onPressed: () => setState(() => _errorMessage = null),
          ),
        ],
      ),
    );
  }

  Widget _buildGPSTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.gps_fixed,
            size: 64,
            color: _selectedLocation?.source == LocationSource.gps
                ? AppTheme.successColor
                : Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            _selectedLocation?.source == LocationSource.gps
                ? 'Ubicación GPS obtenida'
                : 'Obtener ubicación actual',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Usa el GPS de tu dispositivo para obtener tu ubicación exacta',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              text: 'Obtener Ubicación GPS',
              icon: Icons.gps_fixed,
              isLoading: _isLoadingGPS,
              onPressed: () {
                if (!_isLoadingGPS) {
                  _getCurrentLocation();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapTab() {
    return Column(
      children: [
        Expanded(
          child: GoogleMap(
            initialCameraPosition: _initialCameraPosition,
            onMapCreated: (controller) {
              _mapController = controller;
              if (_selectedLocation != null &&
                  _selectedLocation!.latitude != 0 &&
                  _selectedLocation!.longitude != 0) {
                _mapController!.animateCamera(
                  CameraUpdate.newLatLng(
                    LatLng(_selectedLocation!.latitude,
                        _selectedLocation!.longitude),
                  ),
                );
              }
            },
            onTap: _onMapTapped,
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            mapType: MapType.normal,
            zoomControlsEnabled: true,
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade600, size: 16),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Toca en el mapa para seleccionar la ubicación exacta',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildManualTab() {
    return ManualAddressWidget(
      initialAddress: _selectedLocation?.manualAddress,
      onAddressEntered: (address) {
        final location = LocationData(
          latitude: 0,
          longitude: 0,
          manualAddress: address,
          source: LocationSource.manual,
        );
        _updateSelectedLocation(location);
      },
    );
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingGPS = true;
      _errorMessage = null;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Los servicios de ubicación están desactivados');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Permiso de ubicación denegado');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception(
            'Permiso de ubicación denegado permanentemente. Ve a configuración para habilitarlo.');
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      String? address;
      try {
        final placemarks = await placemarkFromCoordinates(
            position.latitude, position.longitude);
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          address =
              '${place.street ?? ''}, ${place.locality ?? ''}, ${place.country ?? ''}';
        }
      } catch (_) {}

      final location = LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        address: address,
        source: LocationSource.gps,
      );

      _updateSelectedLocation(location);
      _updateMapMarker(location);
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoadingGPS = false);
    }
  }

  Future<void> _onMapTapped(LatLng position) async {
    String? address;
    try {
      final placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        address =
            '${place.street ?? ''}, ${place.locality ?? ''}, ${place.country ?? ''}';
      }
    } catch (_) {}

    final location = LocationData(
      latitude: position.latitude,
      longitude: position.longitude,
      address: address ?? 'Ubicación seleccionada en mapa',
      source: LocationSource.map,
    );

    _updateSelectedLocation(location);
    _updateMapMarker(location);
  }

  void _updateSelectedLocation(LocationData location) {
    setState(() {
      _selectedLocation = location;
    });
    widget.onLocationSelected(location);
  }

  void _updateMapMarker(LocationData location) {
    if (location.latitude != 0 && location.longitude != 0) {
      setState(() {
        _markers.clear();
        _markers.add(
          Marker(
            markerId: const MarkerId('selected_location'),
            position: LatLng(location.latitude, location.longitude),
            infoWindow: InfoWindow(
              title: 'Ubicación seleccionada',
              snippet: location.address ?? 'Sin dirección',
            ),
          ),
        );
      });

      _mapController?.animateCamera(
        CameraUpdate.newLatLng(LatLng(location.latitude, location.longitude)),
      );
    }
  }

  String _getLocationDisplayText(LocationData location) {
    switch (location.source) {
      case LocationSource.gps:
        return location.address ?? 'Ubicación GPS obtenida';
      case LocationSource.map:
        return location.address ?? 'Ubicación seleccionada en mapa';
      case LocationSource.manual:
        return location.manualAddress ?? 'Dirección manual';
    }
  }
}
