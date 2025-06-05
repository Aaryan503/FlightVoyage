import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_maps/maps.dart';
import 'dart:math' as math;
import '../providers/airport_provider.dart';
import '../models/airport.dart';

class AirportSelectionScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<AirportSelectionScreen> createState() => _AirportSelectionScreenState();
}

class _AirportSelectionScreenState extends ConsumerState<AirportSelectionScreen> {
  late MapZoomPanBehavior _zoomPanBehavior;
  Airport? selectedDeparture;
  Airport? selectedDestination;
  bool _initialized = false;
  
  @override
  void initState() {
    super.initState();
    _zoomPanBehavior = MapZoomPanBehavior(
      enablePanning: true,
      enablePinching: true,
      showToolbar: true,
      enableDoubleTapZooming: true,
      toolbarSettings: MapToolbarSettings(
        position: MapToolbarPosition.topRight,
        iconColor: Colors.white,
        itemBackgroundColor: Colors.blue.withOpacity(0.8),
        itemHoverColor: Colors.blue.withOpacity(0.6),
        direction: Axis.vertical,
      ),
      minZoomLevel: 2,
      maxZoomLevel: 10,
      zoomLevel: 3,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Load temperatures only once when the widget is ready
    if (!_initialized) {
      _initialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        print('🚀 Loading temperatures from didChangeDependencies');
        ref.read(airportProvider.notifier).loadTemperatures();
      });
    }
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      appBar: AppBar(
        title: Text('Loading Airports...'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            SizedBox(height: 20),
            Text(
              'Loading airports...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Please wait a moment',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAirportMarker(Airport airport, Map<String, double?> temperatures) {
    bool isSelected = selectedDeparture == airport || selectedDestination == airport;
    final temperature = temperatures[airport.code];
    
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.blue, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Text(
              temperature != null ? '${temperature.round()}°C' : '--°C',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: temperature != null ? Colors.black87 : Colors.grey,
              ),
            ),
          ),
          SizedBox(height: 6),
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isSelected ? Colors.red : Colors.blue,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
          ),
          SizedBox(height: 6),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              airport.code,
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<MapLatLng> _generateCurvedPath(double startLat, double startLon, double endLat, double endLon) {
    List<MapLatLng> points = [];
    
    // Calculate the midpoint
    double midLat = (startLat + endLat) / 2;
    double midLon = (startLon + endLon) / 2;
    
    // Calculate the distance between start and end points
    double distance = math.sqrt(math.pow(endLat - startLat, 2) + math.pow(endLon - startLon, 2));
    
    // Calculate the curve control point (perpendicular offset from midpoint)
    double offsetDistance = distance * 0.3; // Adjust this for curve intensity
    
    // Calculate perpendicular direction
    double perpLat = -(endLon - startLon) / distance;
    double perpLon = (endLat - startLat) / distance;
    
    // Control point for the curve
    double controlLat = midLat + perpLat * offsetDistance;
    double controlLon = midLon + perpLon * offsetDistance;
    
    // Generate points along the quadratic bezier curve
    int numPoints = 100;
    for (int i = 0; i <= numPoints; i++) {
      double t = i / numPoints;
      double invT = 1 - t;
      
      // Quadratic Bezier formula: B(t) = (1-t)²P₀ + 2(1-t)tP₁ + t²P₂
      double lat = invT * invT * startLat + 2 * invT * t * controlLat + t * t * endLat;
      double lon = invT * invT * startLon + 2 * invT * t * controlLon + t * t * endLon;
      
      points.add(MapLatLng(lat, lon));
    }
    
    return points;
  }

  Set<MapPolyline> _buildFlightPath() {
    if (selectedDeparture == null || selectedDestination == null) {
      return <MapPolyline>{};
    }

    List<MapLatLng> curvedPoints = _generateCurvedPath(
      selectedDeparture!.latitude,
      selectedDeparture!.longitude,
      selectedDestination!.latitude,
      selectedDestination!.longitude,
    );

    return <MapPolyline>{
      MapPolyline(
        points: curvedPoints,
        color: Colors.red,
        width: 4,
      ),
    };
  }

  void _onMarkerTapped(Airport airport) {
    setState(() {
      if (selectedDeparture == null) {
        selectedDeparture = airport;
      } else if (selectedDeparture == airport) {
        // Deselect if tapping the same airport
        selectedDeparture = null;
        selectedDestination = null;
        // Clear route in provider
        ref.read(routeProvider.notifier).clearRoute();
      } else {
        selectedDestination = airport;
        // Update route in provider
        ref.read(routeProvider.notifier).setRoute(selectedDeparture!, airport);
      }
    });
  }

  void _zoomIn() {
    final currentZoom = _zoomPanBehavior.zoomLevel;
    if (currentZoom < _zoomPanBehavior.maxZoomLevel) {
      _zoomPanBehavior.zoomLevel = currentZoom + 1;
    }
  }

  void _zoomOut() {
    final currentZoom = _zoomPanBehavior.zoomLevel;
    if (currentZoom > _zoomPanBehavior.minZoomLevel) {
      _zoomPanBehavior.zoomLevel = currentZoom - 1;
    }
  }

  void _centerOnRoute() {
    if (selectedDeparture == null || selectedDestination == null) return;
    
    double centerLat = (selectedDeparture!.latitude + selectedDestination!.latitude) / 2;
    double centerLng = (selectedDeparture!.longitude + selectedDestination!.longitude) / 2;

    // Ensure zoom level is within allowed range
    double targetZoom = 2.5;
    if (targetZoom < _zoomPanBehavior.minZoomLevel) {
      targetZoom = _zoomPanBehavior.minZoomLevel;
    } else if (targetZoom > _zoomPanBehavior.maxZoomLevel) {
      targetZoom = _zoomPanBehavior.maxZoomLevel;
    }
    
    _zoomPanBehavior.focalLatLng = MapLatLng(centerLat, centerLng);
    _zoomPanBehavior.zoomLevel = targetZoom;
  }

  void _resetSelection() {
    setState(() {
      selectedDeparture = null;
      selectedDestination = null;
      ref.read(routeProvider.notifier).clearRoute();
    });
  }

  Widget _buildMapControls() {
    return Positioned(
      top: 20,
      right: 20,
      child: Column(
        children: [
          FloatingActionButton(
            heroTag: "zoom_in",
            mini: true,
            onPressed: _zoomIn,
            child: Icon(Icons.add),
            tooltip: 'Zoom In',
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            heroTag: "zoom_out",
            mini: true,
            onPressed: _zoomOut,
            child: Icon(Icons.remove),
            tooltip: 'Zoom Out',
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            heroTag: "center_route",
            mini: true,
            onPressed: _centerOnRoute,
            child: Icon(Icons.center_focus_strong),
            tooltip: 'Center on Route',
          ),
        ],
      ),
    );
  }

  Widget _buildTemperatureDisplay(Airport? airport, Map<String, double?> temperatures) {
    if (airport == null) return SizedBox.shrink();
    final temperature = temperatures[airport.code];
    if (temperature != null) {
      return Container(
        margin: EdgeInsets.only(left: 8),
        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.blue.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '${temperature.round()}°C',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade800,
          ),
        ),
      );
    }
    return Container(
      margin: EdgeInsets.only(left: 8),
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '--°C',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final airports = ref.watch(airportsListProvider);
    final isLoading = ref.watch(airportLoadingProvider);
    final temperatures = ref.watch(temperaturesProvider);
    final temperaturesLoaded = ref.watch(temperaturesLoadedProvider);

    // Show loading screen until temperatures are loaded
    if (isLoading || !temperaturesLoaded) {
      return _buildLoadingScreen();
    }

    // Debug: Print current state
    print('🔍 Build - Airports count: ${airports.length}');
    print('🔍 Build - Temperatures: $temperatures');
    print('🔍 Build - Temperatures Loaded: $temperaturesLoaded');

    return Scaffold(
      appBar: AppBar(
        title: Text('Select Airports'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          if (selectedDeparture != null || selectedDestination != null)
            IconButton(
              icon: Icon(Icons.clear),
              onPressed: _resetSelection,
            ),
        ],
      ),
      body: Column(
        children: [
          if (selectedDeparture != null || selectedDestination != null)
            Container(
              padding: EdgeInsets.all(16),
              color: Colors.blue.shade50,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'From: ${selectedDeparture?.city ?? 'Select departure'}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            _buildTemperatureDisplay(selectedDeparture, temperatures),
                          ],
                        ),
                        if (selectedDeparture != null)
                          Text(
                            '${selectedDeparture!.name} (${selectedDeparture!.code})',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              'To: ${selectedDestination?.city ?? 'Select destination'}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            _buildTemperatureDisplay(selectedDestination, temperatures),
                          ],
                        ),
                        if (selectedDestination != null)
                          Text(
                            '${selectedDestination!.name} (${selectedDestination!.code})',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                      ],
                    ),
                  ),
                  if (selectedDeparture != null && selectedDestination != null)
                    ElevatedButton(
                      onPressed: () {
                        // Handle flight booking
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Flight from ${selectedDeparture?.code ?? ''} to ${selectedDestination?.code ?? ''} selected!',
                            ),
                          ),
                        );
                      },
                      child: Text('Book Flight'),
                    ),
                ],
              ),
            ),
          Expanded(
            child: Stack(
              children: [
                SfMaps(
                  layers: [
                    MapTileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      zoomPanBehavior: _zoomPanBehavior,
                      markerBuilder: (BuildContext context, int index) {
                        final airport = airports[index];
                        return MapMarker(
                          latitude: airport.latitude,
                          longitude: airport.longitude,
                          child: Material(
                            color: Colors.transparent,
                            child: GestureDetector(
                              onTap: () => _onMarkerTapped(airport),
                              child: _buildAirportMarker(airport, temperatures),
                            ),
                          ),
                        );
                      },
                      initialMarkersCount: airports.length,
                      sublayers: [
                        MapPolylineLayer(
                          polylines: _buildFlightPath(),
                        ),
                      ],
                    ),
                  ],
                ),
                _buildMapControls(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: 
        FloatingActionButton(
          heroTag: "reset_view",
          onPressed: () {
            // Reset map to world view
            if (mounted) {
              _zoomPanBehavior.reset();
            }
          },
          child: Icon(Icons.my_location),
          tooltip: 'Reset to World View',
        ),
    );
  }
}