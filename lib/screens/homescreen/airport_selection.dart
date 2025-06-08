import 'package:flightbooking/screens/homescreen/widgets/flight_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_maps/maps.dart';
import '../../../providers/airport_provider.dart';
import '../../../models/airport.dart';
import 'widgets/booking_dialog.dart';
import 'widgets/airport_marker.dart';
import 'widgets/map_controls.dart';
import 'widgets/loading_screen.dart';
import 'widgets/route_card.dart';
import '../../../utils/flight_path.dart';
import '../flight_history/flight_history_screen.dart';

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
    _initializeAnimations();
    _initializeMapBehavior();
  }

  void _initializeAnimations() {
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
  }

  void _initializeMapBehavior() {
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
    
    final center = FlightPathUtils.calculateRouteCenter(selectedDeparture!, selectedDestination!);
    double targetZoom = FlightPathUtils.calculateRouteZoom(selectedDeparture!, selectedDestination!);
    
    if (targetZoom < _zoomPanBehavior.minZoomLevel) {
      targetZoom = _zoomPanBehavior.minZoomLevel;
    } else if (targetZoom > _zoomPanBehavior.maxZoomLevel) {
      targetZoom = _zoomPanBehavior.maxZoomLevel;
    }
    
    _zoomPanBehavior.focalLatLng = center;
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

  void _navigateToFlightHistory() {
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FlightHistoryScreen(),
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
      return LoadingScreen();
    }
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      drawer: FlightDrawer(navigateToFlightHistory: _navigateToFlightHistory),
      body: Stack(
        children: [
          _buildMap(airports),
          _buildRouteCardSection(temperatures),
          _buildMapControls(),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'Select Your Journey',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      backgroundColor: Colors.blue.shade600.withValues(alpha: 0.9),
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
    );
  }

  Widget _buildMap(List<Airport> airports) {
    return SfMaps(
      layers: [
        MapTileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          zoomPanBehavior: _zoomPanBehavior,
          markerBuilder: (BuildContext context, int index) {
            final airport = airports[index];
            final isSelected = selectedDeparture == airport || selectedDestination == airport;
            
            return MapMarker(
              latitude: airport.latitude,
              longitude: airport.longitude,
              child: AirportMarker(
                airport: airport,
                temperatures: ref.watch(temperaturesProvider),
                isSelected: isSelected,
                pulseAnimation: _pulseAnimation,
                onTap: () => _onMarkerTapped(airport),
              ),
            );
          },
          initialMarkersCount: airports.length,
          sublayers: [
            MapPolylineLayer(
              polylines: FlightPathUtils.buildFlightPath(
                departure: selectedDeparture,
                destination: selectedDestination,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRouteCardSection(Map<String, double?> temperatures) {
    if (selectedDeparture == null && selectedDestination == null) {
      return SizedBox.shrink();
    }
    final appBarHeight = kToolbarHeight;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final totalTopOffset = appBarHeight + statusBarHeight + 8;

    return Positioned(
      top: totalTopOffset,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: RouteCard(
          selectedDeparture: selectedDeparture,
          selectedDestination: selectedDestination,
          temperatures: temperatures,
          slideAnimation: _slideAnimation,
          onBookFlight: _showBookingDialog,
        ),
      ),
    );
  }

  Widget _buildMapControls() {
    return MapControls(
      onZoomIn: _zoomIn,
      onZoomOut: _zoomOut,
      onCenterRoute: _centerOnRoute,
      showCenterRoute: selectedDeparture != null && selectedDestination != null,
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingResetButton(
      onPressed: () {
        if (mounted) {
          _zoomPanBehavior.reset();
        }
      },
    );
  }
}