import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_maps/maps.dart';
import 'dart:math' as math;
import '../providers/airport_provider.dart';
import '../models/airport.dart';
import '../widgets/booking_dialog.dart';

class AirportSelectionScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<AirportSelectionScreen> createState() => _AirportSelectionScreenState();
}

class _AirportSelectionScreenState extends ConsumerState<AirportSelectionScreen>
    with TickerProviderStateMixin {
  late MapZoomPanBehavior _zoomPanBehavior;
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;
  
  Airport? selectedDeparture;
  Airport? selectedDestination;
  bool _initialized = false;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize animations
    _pulseController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _slideController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.elasticOut));
    
    _zoomPanBehavior = MapZoomPanBehavior(
      enablePanning: true,
      enablePinching: true,
      showToolbar: false,
      toolbarSettings: MapToolbarSettings(position: MapToolbarPosition.bottomLeft),
      enableDoubleTapZooming: true,
      minZoomLevel: 2,
      maxZoomLevel: 10,
      zoomLevel: 3,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    if (!_initialized) {
      _initialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        print('🚀 Loading temperatures from didChangeDependencies');
        ref.read(airportProvider.notifier).loadTemperatures();
      });
    }
  }

  void _showBookingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return BookingDialog(
          departure: selectedDeparture!,
          destination: selectedDestination!,
        );
      },
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade900,
              Colors.blue.shade600,
              Colors.blue.shade400,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.flight,
                  size: 60,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 30),
              CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              SizedBox(height: 20),
              Text(
                'Preparing Your Journey',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Loading airport data and weather information',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAirportMarker(Airport airport, Map<String, double?> temperatures) {
    bool isSelected = selectedDeparture == airport || selectedDestination == airport;
    final temperature = temperatures[airport.code];
    
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: isSelected ? _pulseAnimation.value : 1.0,
          child: Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Temperature badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: temperature != null 
                          ? [Colors.orange.shade300, Colors.red.shade400]
                          : [Colors.grey.shade300, Colors.grey.shade400],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    temperature != null ? '${temperature.round()}°C' : '--°C',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 8),
                
                // Airport marker
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isSelected 
                          ? [Colors.red.shade400, Colors.red.shade600]
                          : [Colors.blue.shade400, Colors.blue.shade600],
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: (isSelected ? Colors.red : Colors.blue).withOpacity(0.4),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.flight,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                
                // Airport code
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: Text(
                    airport.code,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static List<MapLatLng> _generateCurvedPathSync(List<double> args) {
    double startLat = args[0], startLon = args[1], endLat = args[2], endLon = args[3];
    List<MapLatLng> points = [];
    double midLat = (startLat + endLat) / 2;
    double midLon = (startLon + endLon) / 2;
    double distance = math.sqrt(math.pow(endLat - startLat, 2) + math.pow(endLon - startLon, 2));
    double offsetDistance = distance * 0.3;
    double perpLat = -(endLon - startLon) / distance;
    double perpLon = (endLat - startLat) / distance;
    double controlLat = midLat + perpLat * offsetDistance;
    double controlLon = midLon + perpLon * offsetDistance;
    int numPoints = 100;
    for (int i = 0; i <= numPoints; i++) {
      double t = i / numPoints;
      double invT = 1 - t;
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
    
    final curvedPoints = _generateCurvedPathSync([
      selectedDeparture!.latitude,
      selectedDeparture!.longitude,
      selectedDestination!.latitude,
      selectedDestination!.longitude,
    ]);
    
    return <MapPolyline>{
      MapPolyline(
        points: curvedPoints,
        color: Colors.red.shade400,
        width: 4,
      ),
    };
  }

  void _onMarkerTapped(Airport airport) {
    setState(() {
      if (selectedDeparture == null) {
        selectedDeparture = airport;
        _slideController.forward();
      } else if (selectedDeparture == airport) {
        selectedDeparture = null;
        selectedDestination = null;
        _slideController.reverse();
        ref.read(routeProvider.notifier).clearRoute();
      } else {
        selectedDestination = airport;
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
      _slideController.reverse();
      ref.read(routeProvider.notifier).clearRoute();
    });
  }

  Widget _buildMapControls() {
    return Positioned(
      bottom: 80,
      left: 20,
      child: Column(
        children: [
          _buildControlButton(
            icon: Icons.add,
            onPressed: _zoomIn,
            tooltip: 'Zoom In',
          ),
          SizedBox(height: 12),
          _buildControlButton(
            icon: Icons.remove,
            onPressed: _zoomOut,
            tooltip: 'Zoom Out',
          ),
          SizedBox(height: 12),
          _buildControlButton(
            icon: Icons.center_focus_strong,
            onPressed: _centerOnRoute,
            tooltip: 'Center on Route',
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey.shade100],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Container(
            width: 48,
            height: 48,
            child: Icon(
              icon,
              color: Colors.blue.shade700,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTemperatureDisplay(Airport? airport, Map<String, double?> temperatures) {
    if (airport == null) return SizedBox.shrink();
    final temperature = temperatures[airport.code];
    
    return Container(
      margin: EdgeInsets.only(left: 8),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: temperature != null 
              ? [Colors.orange.shade200, Colors.red.shade300]
              : [Colors.grey.shade200, Colors.grey.shade300],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        temperature != null ? '${temperature.round()}°C' : '--°C',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [
            Shadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteCard(Map<String, double?> temperatures) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        margin: EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.white],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.2),
              blurRadius: 15,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.flight_takeoff, color: Colors.blue.shade600, size: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'From: ${selectedDeparture?.city ?? 'Select departure'}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.blue.shade800,
                              ),
                            ),
                            _buildTemperatureDisplay(selectedDeparture, temperatures),
                          ],
                        ),
                        if (selectedDeparture != null)
                          Text(
                            '${selectedDeparture!.name} (${selectedDeparture!.code})',
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
              
              SizedBox(height: 16),
              
              Container(
                height: 2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade200, Colors.blue.shade400],
                  ),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              
              SizedBox(height: 16),
              
              Row(
                children: [
                  Icon(Icons.flight_land, color: Colors.orange.shade600, size: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'To: ${selectedDestination?.city ?? 'Select destination'}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.orange.shade800,
                              ),
                            ),
                            _buildTemperatureDisplay(selectedDestination, temperatures),
                          ],
                        ),
                        if (selectedDestination != null)
                          Text(
                            '${selectedDestination!.name} (${selectedDestination!.code})',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (selectedDeparture != null && selectedDestination != null)
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade400, Colors.blue.shade600],
                        ),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.3),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(25),
                          onTap: _showBookingDialog,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.book_online, color: Colors.white, size: 18),
                                SizedBox(width: 8),
                                Text(
                                  'Book Flight',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
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

    if (isLoading || !temperaturesLoaded) {
      return _buildLoadingScreen();
    }

    print('🔍 Build - Airports count: ${airports.length}');
    print('🔍 Build - Temperatures: $temperatures');
    print('🔍 Build - Temperatures Loaded: $temperaturesLoaded');

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Select Your Journey',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.blue.shade600.withOpacity(0.9),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (selectedDeparture != null || selectedDestination != null)
            IconButton(
              icon: Icon(Icons.clear_all),
              onPressed: _resetSelection,
              tooltip: 'Clear Selection',
            ),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade600, Colors.blue.shade400],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Map
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
          
          // Route selection card
          if (selectedDeparture != null || selectedDestination != null)
            Positioned(
              top: kToolbarHeight + MediaQuery.of(context).padding.top,
              left: 0,
              right: 0,
              child: _buildRouteCard(temperatures),
            ),
          
          // Map controls
          _buildMapControls(),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade400, Colors.blue.shade600],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton(
          heroTag: "reset_view",
          backgroundColor: Colors.transparent,
          elevation: 0,
          onPressed: () {
            if (mounted) {
              _zoomPanBehavior.reset();
            }
          },
          tooltip: 'Reset to World View',
          child: Icon(
            Icons.my_location,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}