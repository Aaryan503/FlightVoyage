import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/booking.dart';
import '../providers/booking_provider.dart';
import '../widgets/flight_list_view.dart';
import '../widgets/proceed_button.dart';
import '../services/flight_service.dart';
import 'seat_selection.dart';

class FlightDetailsScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<FlightDetailsScreen> createState() => _FlightDetailsScreenState();
}

class _FlightDetailsScreenState extends ConsumerState<FlightDetailsScreen> 
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  
  List<FlightInfo> outboundFlights = [];
  List<FlightInfo> returnFlights = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _generateFlights();
    _startAnimations();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
  }

  void _startAnimations() {
    _slideController.forward();
    _fadeController.forward();
  }

  void _generateFlights() {
    final booking = ref.read(bookingProvider);
    final flightService = FlightService();
    
    outboundFlights = flightService.generateFlights(
      from: booking.departure!,
      to: booking.destination!,
      date: booking.departureDate!,
      count: 6,
    );

    if (booking.isRoundTrip && booking.returnDate != null) {
      returnFlights = flightService.generateFlights(
        from: booking.destination!,
        to: booking.departure!,
        date: booking.returnDate!,
        count: 6,
      );
    }
  }

  void _onFlightSelected(FlightInfo flight, bool isReturn) {
    if (isReturn) {
      ref.read(bookingProvider.notifier).selectReturnFlight(flight);
    } else {
      ref.read(bookingProvider.notifier).selectOutboundFlight(flight);
    }
  }

  void _onProceedToSeatSelection() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => SeatSelectionScreen(),
    ));
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Flights selected!',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green.shade400,
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final booking = ref.watch(bookingProvider);
    final canProceed = ref.watch(canProceedToPaymentProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'Select Flights',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade600, Colors.blue.shade400],
            ),
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: FlightListView(
            outboundFlights: outboundFlights,
            returnFlights: returnFlights,
            booking: booking,
            onFlightSelected: _onFlightSelected,
          ),
        ),
      ),
      floatingActionButton: canProceed 
          ? ProceedButton(
              onPressed: _onProceedToSeatSelection,
              label: 'Select Seats',
              icon: Icons.payment,
            )
          : null,
    );
  }
}