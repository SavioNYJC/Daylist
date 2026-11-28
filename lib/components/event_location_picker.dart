import 'dart:async';
import 'dart:convert';

import 'package:daylist/utils/themes.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:liquid_glass_easy/liquid_glass_easy.dart';
import 'package:material_ui/material_ui.dart';

Future<String?> showEventLocationPicker(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: Colors.white,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => const EventLocationPickerSheet(),
  );
}

class EventLocationPickerSheet extends StatefulWidget {
  const EventLocationPickerSheet({super.key});

  @override
  State<EventLocationPickerSheet> createState() =>
      _EventLocationPickerSheetState();
}

class _EventLocationPickerSheetState extends State<EventLocationPickerSheet> {
  static DateTime? _lastNominatimRequest;

  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  LatLng? _selectedLocation;
  LatLng? _pendingMapCenter;
  String? _message;
  bool _isLocating = true;
  bool _hasSearchQuery = false;
  bool _isSearching = false;
  bool _isResolvingAddress = false;
  bool _mapIsReady = false;
  bool _userSelectedLocation = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();
  }

  Future<void> _loadCurrentLocation() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        _message =
            'Location services are off. Pan the map and tap to choose a place.';
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.unableToDetermine) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _message = 'Location access is unavailable. Pan the map and tap to choose a place.';
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );
      final point = LatLng(position.latitude, position.longitude);

      if (!mounted || _userSelectedLocation) return;
      setState(() {
        _selectedLocation = point;
        _message = null;
      });

      if (_mapIsReady) {
        _mapController.move(point, 16);
      } else {
        _pendingMapCenter = point;
      }
    } catch (error) {
      debugPrint('Getting current location for event picker failed: $error');
      if (mounted) {
        setState(() {
          _message = 'Could not find your current location. Pan the map and tap to choose a place.';
        });
      }
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  void _onMapReady() {
    _mapIsReady = true;
    final pendingCenter = _pendingMapCenter;
    if (pendingCenter != null) {
      _mapController.move(pendingCenter, 16);
      _pendingMapCenter = null;
    }
  }

  void _onMapTap(TapPosition tapPosition, LatLng point) {
    _pendingMapCenter = null;
    setState(() {
      _selectedLocation = point;
      _message = null;
      _userSelectedLocation = true;
    });
  }

  Future<void> _waitForNominatimRateLimit() async {
    final lastRequest = _lastNominatimRequest;
    if (lastRequest != null) {
      final remaining =
          const Duration(seconds: 1) - DateTime.now().difference(lastRequest);
      if (remaining > Duration.zero) await Future.delayed(remaining);
    }
    _lastNominatimRequest = DateTime.now();
  }

  Future<void> _searchLocation() async {
    final query = _searchController.text.trim();
    if (query.isEmpty || _isSearching || _isResolvingAddress) return;

    FocusScope.of(context).unfocus();
    setState(() {
      _isSearching = true;
      _message = null;
    });

    try {
      await _waitForNominatimRateLimit();

      final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
        'q': query,
        'format': 'jsonv2',
        'limit': '1',
      });
      final response = await http
          .get(
            uri,
            headers: const {
              'User-Agent':
                  'Daylist/1.0 (https://github.com/SavioNYJC/Daylist)',
              'Accept-Language': 'en',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw StateError(
          'Location search failed with status ${response.statusCode}.',
        );
      }

      final results = jsonDecode(response.body);
      if (results is! List || results.isEmpty) {
        throw const FormatException(
          'No matching location found. Try another address or postal code.',
        );
      }

      final result = results.first;
      if (result is! Map<String, dynamic>) {
        throw const FormatException('Location search returned invalid data.');
      }

      final latitudeValue = result['lat'];
      final longitudeValue = result['lon'];
      final latitude = latitudeValue is String
          ? double.tryParse(latitudeValue)
          : latitudeValue is num
          ? latitudeValue.toDouble()
          : null;
      final longitude = longitudeValue is String
          ? double.tryParse(longitudeValue)
          : longitudeValue is num
          ? longitudeValue.toDouble()
          : null;

      if (latitude == null ||
          longitude == null ||
          latitude < -90 ||
          latitude > 90 ||
          longitude < -180 ||
          longitude > 180) {
        throw const FormatException(
          'Location search returned invalid coordinates.',
        );
      }

      final point = LatLng(latitude, longitude);
      if (!mounted) return;
      setState(() {
        _selectedLocation = point;
        _userSelectedLocation = true;
        _message = null;
      });

      if (_mapIsReady) {
        _mapController.move(point, 16);
      } else {
        _pendingMapCenter = point;
      }
    } catch (error) {
      debugPrint('Searching for event location failed: $error');
      if (mounted) {
        setState(() {
          _message = 'Could not find that location: $error';
        });
      }
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  Future<String> _reverseGeocode(LatLng point) async {
    await _waitForNominatimRateLimit();

    final uri = Uri.https('nominatim.openstreetmap.org', '/reverse', {
      'format': 'jsonv2',
      'lat': point.latitude.toStringAsFixed(6),
      'lon': point.longitude.toStringAsFixed(6),
      'zoom': '18',
    });
    final response = await http
        .get(
          uri,
          headers: const {
            'User-Agent': 'Daylist/1.0 (https://github.com/SavioNYJC/Daylist)',
            'Accept-Language': 'en',
          },
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw StateError(
        'Address lookup failed with status ${response.statusCode}.',
      );
    }

    final result = jsonDecode(response.body);
    if (result is! Map<String, dynamic>) {
      throw const FormatException('Address lookup returned invalid data.');
    }

    final displayName = result['display_name'];
    if (displayName is! String || displayName.trim().isEmpty) {
      throw const FormatException('No address was found for this map point.');
    }

    final addressDetails = result['address'];
    if (addressDetails is Map<String, dynamic>) {
      final houseNumber = addressDetails['house_number'];
      String? streetName;
      for (final key in const ['road', 'street', 'pedestrian', 'residential']) {
        final value = addressDetails[key];
        if (value is String && value.trim().isNotEmpty) {
          streetName = value.trim();
          break;
        }
      }
      final postcode = addressDetails['postcode'];

      final streetAddress = [
        if (houseNumber is String && houseNumber.trim().isNotEmpty)
          houseNumber.trim(),
        ?streetName,
      ].join(' ');
      final compactAddress = [
        if (streetAddress.isNotEmpty) streetAddress,
        if (postcode is String && postcode.trim().isNotEmpty) postcode.trim(),
      ].join(', ');

      if (streetAddress.isNotEmpty) return compactAddress;
    }

    return displayName.trim();
  }

  Future<void> _confirmLocation() async {
    final point = _selectedLocation;
    if (point == null || _isResolvingAddress) return;

    setState(() {
      _isResolvingAddress = true;
      _message = null;
    });

    try {
      final address = await _reverseGeocode(point);
      if (!mounted) return;
      Navigator.of(context).pop(address);
    } catch (error) {
      debugPrint('Reverse geocoding event location failed: $error');
      if (mounted) {
        setState(() {
          _message = 'Could not find an address for this point: $error';
        });
      }
    } finally {
      if (mounted) setState(() => _isResolvingAddress = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final availableHeight =
        mediaQuery.size.height - mediaQuery.viewInsets.bottom;
    final sheetHeight = availableHeight * 0.78;
    final selectedLocation = _selectedLocation;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: sheetHeight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Choose location',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close location picker',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              if (_isLocating)
                const LinearProgressIndicator(minHeight: 2)
              else if (_message != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    _message!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Tap the map to place the pin.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: const LatLng(0, 0),
                      initialZoom: 2,
                      onMapReady: _onMapReady,
                      onTap: _onMapTap,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.daylist',
                      ),
                      if (selectedLocation != null)
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: selectedLocation,
                              width: 48,
                              height: 48,
                              child: const Icon(
                                Icons.location_on,
                                color: Colors.red,
                                size: 42,
                              ),
                            ),
                          ],
                        ),
                      const RichAttributionWidget(
                        attributions: [
                          TextSourceAttribution('OpenStreetMap contributors'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      enabled: !_isSearching && !_isResolvingAddress,
                      textInputAction: TextInputAction.search,
                      onChanged: (value) {
                        setState(
                          () => _hasSearchQuery = value.trim().isNotEmpty,
                        );
                      },
                      onSubmitted: (_) => _searchLocation(),
                      decoration: InputDecoration(
                        hintText: 'Postal code or address',
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(
                            color: Colors.black.withAlpha(60),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  LiquidGlassButton(
                    height: 56,
                    width: 56,
                    style: glassButtonStyle,
                    onPressed:
                        !_hasSearchQuery || _isSearching || _isResolvingAddress
                        ? null
                        : _searchLocation,
                    child: _isSearching
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.search),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LiquidGlassButton(
                height: 64,
                width: MediaQuery.sizeOf(context).width - 32,
                style: glassButtonStyle,
                onPressed:
                    selectedLocation == null ||
                        _isResolvingAddress ||
                        _isSearching
                    ? null
                    : _confirmLocation,
                child: _isResolvingAddress
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        'Use this location',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
