import 'package:flightbooking/screens/seat_selection_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../models/booking.dart';
import '../models/airport.dart';
import '../providers/booking_provider.dart';

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
    
    _generateFlights();
    _slideController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _generateFlights() {
    final booking = ref.read(bookingProvider);
    final random = math.Random();
    
    // Airlines list
    final airlines = ['Emirates', 'Qatar Airways', 'Singapore Airlines', 'British Airways', 'Lufthansa', 'Air France'];
    
    // Generate outbound flights
    outboundFlights = List.generate(6, (index) {
      final airline = airlines[random.nextInt(airlines.length)];
      final flightNumber = '${airline.substring(0, 2).toUpperCase()}${random.nextInt(900) + 100}';

      // Generate departure times at 30-minute intervals between 6:00 and 22:00
      final startHour = 6;
      final slotsPerHour = 2; // 0 or 30 minutes
      final totalSlots = (22 - startHour + 1) * slotsPerHour; // 33 slots (6:00 to 22:30)
      final slot = (index < totalSlots) ? index : random.nextInt(totalSlots);
      final departureHour = startHour + (slot ~/ slotsPerHour);
      final departureMinute = (slot % slotsPerHour) * 30;

      final departureTime = DateTime(
      booking.departureDate!.year,
      booking.departureDate!.month,
      booking.departureDate!.day,
      departureHour,
      departureMinute,
      );

      // Calculate flight duration based on distance (simplified)
      final duration = _calculateFlightDuration(booking.departure!, booking.destination!);
      final arrivalTime = departureTime.add(duration);

      return FlightInfo(
      flightNumber: flightNumber,
      departureTime: departureTime,
      arrivalTime: arrivalTime,
      departureAirport: booking.departure!,
      arrivalAirport: booking.destination!,
      airline: airline,
      duration: duration,
      );
    });

    // Generate return flights if round trip
    if (booking.isRoundTrip && booking.returnDate != null) {
      // Generate return flights similar to outbound flights
      final startHour = 6;
      final slotsPerHour = 1; // 0 or 30 minutes
      final totalSlots = (22 - startHour + 1) * slotsPerHour; // 33 slots (6:00 to 22:30)
      returnFlights = List.generate(6, (index) {
      final airline = airlines[random.nextInt(airlines.length)];
      final flightNumber = '${airline.substring(0, 2).toUpperCase()}${random.nextInt(900) + 100}';

      final slot = (index < totalSlots) ? index : random.nextInt(totalSlots);
      final departureHour = startHour + (slot ~/ slotsPerHour);
      final departureMinute = (slot % slotsPerHour) * 30;

      final departureTime = DateTime(
        booking.returnDate!.year,
        booking.returnDate!.month,
        booking.returnDate!.day,
        departureHour,
        departureMinute,
      );

      final duration = _calculateFlightDuration(booking.destination!, booking.departure!);
      final arrivalTime = departureTime.add(duration);

      return FlightInfo(
        flightNumber: flightNumber,
        departureTime: departureTime,
        arrivalTime: arrivalTime,
        departureAirport: booking.destination!,
        arrivalAirport: booking.departure!,
        airline: airline,
        duration: duration,
      );
      });
    }
  }

  Duration _calculateFlightDuration(Airport from, Airport to) {
    // Simple distance calculation and flight duration estimation
    final lat1 = from.latitude * math.pi / 180;
    final lon1 = from.longitude * math.pi / 180;
    final lat2 = to.latitude * math.pi / 180;
    final lon2 = to.longitude * math.pi / 180;
    
    final dLat = lat2 - lat1;
    final dLon = lon2 - lon1;
    
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) * math.cos(lat2) * math.sin(dLon / 2) * math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    final distance = 6371 * c; // Distance in km
    
    // Approximate flight time (800 km/h average speed + 30 min for takeoff/landing)
    final hours = (distance / 800) + 0.5;
    final roundedHours = (hours * 2).round() / 2;
    return Duration(minutes: (roundedHours * 60).round());
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return '${hours}h ${minutes}m';
  }

  bool _isFlightSelected(FlightInfo flight, bool isReturn) {
    final booking = ref.watch(bookingProvider);
    if (isReturn) {
      return booking.selectedReturnFlight?.flightNumber == flight.flightNumber;
    } else {
      return booking.selectedOutboundFlight?.flightNumber == flight.flightNumber;
    }
  }

  void _selectFlight(FlightInfo flight, bool isReturn) {
    if (isReturn) {
      ref.read(bookingProvider.notifier).selectReturnFlight(flight);
    } else {
      ref.read(bookingProvider.notifier).selectOutboundFlight(flight);
    }
  }

  Widget _buildFlightCard(FlightInfo flight, bool isReturn) {
    final isSelected = _isFlightSelected(flight, isReturn);
    
    return GestureDetector(
      onTap: () => _selectFlight(flight, isReturn),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSelected 
                ? [Colors.green.shade50, Colors.green.shade100]
                : [Colors.white, Colors.blue.shade50],
          ),
          borderRadius: BorderRadius.circular(20),
          border: isSelected 
              ? Border.all(color: Colors.green.shade400, width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: isSelected 
                  ? Colors.green.withOpacity(0.2)
                  : Colors.black.withOpacity(0.1),
              blurRadius: isSelected ? 20 : 15,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              // Flight header
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isReturn 
                            ? [Colors.orange.shade400, Colors.orange.shade600]
                            : [Colors.blue.shade400, Colors.blue.shade600],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      flight.flightNumber,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Spacer(),
                  if (isSelected)
                    Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.green.shade400,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      ),
                    )
                  else
                    Text(
                      flight.airline,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                        fontSize: 14,
                      ),
                    ),
                ],
              ),
              
              if (isSelected)
                Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        flight.airline,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.green.shade700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              
              SizedBox(height: 24),
              
              // Flight times and cities
              Row(
                children: [
                  // Departure
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          _formatTime(flight.departureTime),
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: isSelected 
                                ? Colors.green.shade800
                                : Colors.blue.shade800,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          flight.departureAirport.city,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          flight.departureAirport.code,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Flight path
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? Colors.green.shade100
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _formatDuration(flight.duration),
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected 
                                  ? Colors.green.shade700
                                  : Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              height: 2,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: isSelected 
                                      ? [Colors.green.shade300, Colors.green.shade400]
                                      : [Colors.blue.shade300, Colors.blue.shade400],
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: isSelected 
                                    ? Colors.green.shade400
                                    : Colors.blue.shade400,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.flight,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Arrival
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          _formatTime(flight.arrivalTime),
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: isSelected 
                                ? Colors.green.shade800
                                : Colors.orange.shade800,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          flight.arrivalAirport.city,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          flight.arrivalAirport.code,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              if (!isSelected)
                Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.blue.shade200,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'Tap to select',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.blue.shade600,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateHeader(String title, DateTime date, bool isReturn) {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isReturn 
              ? [Colors.orange.shade400, Colors.orange.shade600]
              : [Colors.blue.shade400, Colors.blue.shade600],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isReturn ? Colors.orange : Colors.blue).withOpacity(0.3),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              isReturn ? Icons.flight_land : Icons.flight_takeoff,
              color: Colors.white,
              size: 24,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  _formatDate(date),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
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
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 20),
                
                // Outbound flights
                _buildDateHeader('Departure', booking.departureDate!, false),
                
                ...outboundFlights.map((flight) => _buildFlightCard(flight, false)),
                
                if (booking.isRoundTrip && returnFlights.isNotEmpty) ...[
                  SizedBox(height: 40),
                  _buildDateHeader('Return', booking.returnDate!, true),
                  ...returnFlights.map((flight) => _buildFlightCard(flight, true)),
                ],
                
                SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: canProceed 
          ? Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade400, Colors.green.shade600],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: FloatingActionButton.extended(
                backgroundColor: Colors.transparent,
                elevation: 0,
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => SeatSelectionScreen(),
                  ));
                  // Handle booking confirmation
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
                },
                label: Text(
                  'Select Seats',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                icon: Icon(
                  Icons.payment,
                  color: Colors.white,
                ),
              ),
            )
          : null,
    );
  }
}