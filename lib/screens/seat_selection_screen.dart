import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../providers/booking_provider.dart';
import '../models/seat.dart';

class SeatSelectionScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends ConsumerState<SeatSelectionScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  
  List<List<Seat>> seatMap = [];
  bool showingOutbound = true;
  Set<String> selectedSeatIds = {};
  double totalSeatPrice = 0.0;
  
  // Seat configuration: 3-4-3 layout
  final List<String> seatLetters = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'J', 'K'];
  final int totalRows = 30;

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
    
    _generateSeatMap();
    _slideController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _generateSeatMap() {
    final random = math.Random();
    seatMap = [];
    
    for (int row = 1; row <= totalRows; row++) {
      List<Seat> rowSeats = [];
      
      for (int seatIndex = 0; seatIndex < seatLetters.length; seatIndex++) {
        final letter = seatLetters[seatIndex];
        final seatId = '$row$letter';
        
        // Determine seat type and price
        SeatType seatType = SeatType.standard;
        double basePrice = 30000.0;
        bool isDisabled = false;
        
        // First 3 rows: Reserved for disabled passengers
        if (row <= 3) {
          isDisabled = true;
          seatType = SeatType.disabled;
          basePrice = 25000.0;
        }
        
        // Add some randomness to pricing
        final priceVariation = random.nextDouble() * 1000 - random.nextInt(300);
        final finalPrice = math.max(0, basePrice + priceVariation);
        
        // Randomly occupy some seats (about 10% occupancy for more availability)
        final isOccupied = random.nextDouble() < 0.2;
        
        rowSeats.add(Seat(
          id: seatId,
          row: row,
          letter: letter,
          isOccupied: isOccupied,
          price: finalPrice.toDouble(),
          isDisabled: isDisabled,
          type: seatType,
        ));
      }
      
      seatMap.add(rowSeats);
    }
  }

  void _selectSeat(String seatId) {
    final booking = ref.read(bookingProvider);
    final maxPassengers = booking.passengers;
    
    setState(() {
      if (selectedSeatIds.contains(seatId)) {
        // Deselect the seat
        selectedSeatIds.remove(seatId);
        _updateSeatSelection(seatId, false);
      } else if (selectedSeatIds.length < maxPassengers) {
        // Select the seat if we haven't reached the passenger limit
        selectedSeatIds.add(seatId);
        _updateSeatSelection(seatId, true);
      } else {
        // Show message that passenger limit reached
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'You can only select $maxPassengers seat(s) for $maxPassengers passenger(s)',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            backgroundColor: Colors.orange.shade400,
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: EdgeInsets.all(16),
          ),
        );
      }
      
      // Calculate total price
      _calculateTotalPrice();
    });
  }

  void _updateSeatSelection(String seatId, bool isSelected) {
    for (int i = 0; i < seatMap.length; i++) {
      for (int j = 0; j < seatMap[i].length; j++) {
        if (seatMap[i][j].id == seatId) {
          seatMap[i][j] = seatMap[i][j].copyWith(isSelected: isSelected);
          break;
        }
      }
    }
  }

  

  void _calculateTotalPrice() {
    totalSeatPrice = 0.0;
    for (String seatId in selectedSeatIds) {
      for (int i = 0; i < seatMap.length; i++) {
        for (int j = 0; j < seatMap[i].length; j++) {
          if (seatMap[i][j].id == seatId) {
            totalSeatPrice += seatMap[i][j].price;
            break;
          }
        }
      }
    }
  }

  Color _getSeatColor(Seat seat) {
    if (seat.isSelected) {
      return Colors.green.shade400;
    } else if (seat.isOccupied) {
      return Colors.red.shade400;
    } else if (seat.isDisabled) {
      return Colors.purple.shade300;
    } else {
      return Colors.blue.shade300;
    }
  }

  IconData _getSeatIcon(Seat seat) {
    if (seat.isSelected) {
      return Icons.check;
    } else if (seat.isOccupied) {
      return Icons.person;
    } else if (seat.isDisabled) {
      return Icons.accessible;
    } else {
      return Icons.airline_seat_recline_normal;
    }
  }

  Widget _buildSeat(Seat seat) {
    return GestureDetector(
      onTap: seat.isOccupied ? null : () => _selectSeat(seat.id),
      child: Container(
        width: 24,
        height: 24,
        margin: EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: _getSeatColor(seat),
          borderRadius: BorderRadius.circular(6),
          border: seat.isSelected 
              ? Border.all(color: Colors.green.shade700, width: 1.5)
              : null,
          boxShadow: seat.isSelected 
              ? [BoxShadow(
                  color: Colors.green.withOpacity(0.3),
                  blurRadius: 6,
                  offset: Offset(0, 3),
                )]
              : null,
        ),
        child: Icon(
          _getSeatIcon(seat),
          size: 12,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildSeatRow(List<Seat> rowSeats, int rowNumber) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Row number
            Container(
              width: 24,
              child: Text(
                '$rowNumber',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            SizedBox(width: 4),
            
            // Left section (3 seats: ABC)
            ...rowSeats.sublist(0, 3).map((seat) => _buildSeat(seat)),
            
            SizedBox(width: 8), // Aisle
            
            // Middle section (4 seats: DEFG)
            ...rowSeats.sublist(3, 7).map((seat) => _buildSeat(seat)),
            
            SizedBox(width: 8), // Aisle
            
            // Right section (3 seats: HJK)
            ...rowSeats.sublist(7, 10).map((seat) => _buildSeat(seat)),
            
            SizedBox(width: 4),
            
            // Row number (right side)
            Container(
              width: 24,
              child: Text(
                '$rowNumber',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeatLegend() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Seat Legend',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    _buildLegendItem(Colors.blue.shade300, 'Available', ''),
                    SizedBox(height: 8),
                    _buildLegendItem(Colors.red.shade400, 'Occupied', ''),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    _buildLegendItem(Colors.purple.shade300, 'Disabled', ' '),
                    SizedBox(height: 8),
                    _buildLegendItem(Colors.green.shade400, 'Selected', ''),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label, String price) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(
            Icons.airline_seat_recline_normal,
            size: 12,
            color: Colors.white,
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
              if (price.isNotEmpty)
                Text(
                  price,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade500,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFlightInfo() {
    final booking = ref.watch(bookingProvider);
    final flight = showingOutbound 
        ? booking.selectedOutboundFlight!
        : booking.selectedReturnFlight!;
    
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: showingOutbound 
              ? [Colors.blue.shade400, Colors.blue.shade600]
              : [Colors.orange.shade400, Colors.orange.shade600],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (showingOutbound ? Colors.blue : Colors.orange).withOpacity(0.3),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  showingOutbound ? Icons.flight_takeoff : Icons.flight_land,
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
                      flight.flightNumber,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      flight.airline,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '${flight.departureTime.hour.toString().padLeft(2, '0')}:${flight.departureTime.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      flight.departureAirport.code,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 2,
                width: 40,
                color: Colors.white.withOpacity(0.5),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '${flight.arrivalTime.hour.toString().padLeft(2, '0')}:${flight.arrivalTime.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      flight.arrivalAirport.code,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPassengerInfo() {
    final booking = ref.watch(bookingProvider);
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.indigo.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.indigo.shade200, width: 1),
      ),
      child: Row(
        children: [
          Icon(
            Icons.people,
            color: Colors.indigo.shade600,
            size: 24,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Passengers: ${booking.passengers}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo.shade800,
                  ),
                ),
                Text(
                  'Selected: ${selectedSeatIds.length}/${booking.passengers} seats',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.indigo.shade600,
                  ),
                ),
              ],
            ),
          ),
          if (selectedSeatIds.length == booking.passengers)
            Icon(
              Icons.check_circle,
              color: Colors.green.shade600,
              size: 24,
            ),
        ],
      ),
    );
  }

  Widget _buildSeatSelection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          
          // Seat letters header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Left section letters
                  ...['A', 'B', 'C'].map((letter) => Container(
                    width: 26,
                    child: Text(
                      letter,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  )),
                  SizedBox(width: 8), // Aisle
                  // Middle section letters
                  ...['D', 'E', 'F', 'G'].map((letter) => Container(
                    width: 26,
                    child: Text(
                      letter,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  )),
                  SizedBox(width: 8), // Aisle
                  // Right section letters
                  ...['H', 'J', 'K'].map((letter) => Container(
                    width: 26,
                    child: Text(
                      letter,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  )),
                ],
              ),
            ),
          ),
          
          SizedBox(height: 8),
          
          // Seat map
          Container(
            height: 400,
            child: SingleChildScrollView(
              child: Column(
                children: seatMap.asMap().entries.map((entry) {
                  final index = entry.key;
                  final rowSeats = entry.value;
                  return _buildSeatRow(rowSeats, index + 1);
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final booking = ref.watch(bookingProvider);
    final hasReturnFlight = booking.isRoundTrip && booking.selectedReturnFlight != null;
    final allSeatsSelected = selectedSeatIds.length == booking.passengers;
    final selectedSeatsList = selectedSeatIds.toList()..sort();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'Select Seats',
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
        actions: hasReturnFlight ? [
          TextButton(
            onPressed: () {
              setState(() {
                showingOutbound = !showingOutbound;
                selectedSeatIds.clear();
                totalSeatPrice = 0.0;
                _generateSeatMap(); // Generate new seat map for the other flight
              });
            },
            child: Text(
              showingOutbound ? 'Return >' : '< Outbound',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ] : null,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 20),
                
                // Flight info
                _buildFlightInfo(),
                
                SizedBox(height: 16),
                
                // Passenger info
                _buildPassengerInfo(),
                
                SizedBox(height: 16),
                
                // Seat selection
                _buildSeatSelection(),
                
                SizedBox(height: 16),
                
                // Legend
                _buildSeatLegend(),
                
                // Selected seats info
                if (selectedSeatIds.isNotEmpty)
                  Container(
                    margin: EdgeInsets.all(16),
                    padding: EdgeInsets.all(16),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.airline_seat_recline_normal, color: Colors.white),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Selected Seats (${selectedSeatIds.length}/${booking.passengers})',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Seats: ${selectedSeatsList.join(', ')}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Total Price: ₹${totalSeatPrice.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                
                SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: allSeatsSelected 
          ? Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: hasReturnFlight && showingOutbound
                      ? [Colors.orange.shade400, Colors.orange.shade600]
                      : [Colors.green.shade400, Colors.green.shade600],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: (hasReturnFlight && showingOutbound ? Colors.orange : Colors.green).withOpacity(0.3),
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: FloatingActionButton.extended(
                backgroundColor: Colors.transparent,
                elevation: 0,
                onPressed: () {
                  if (hasReturnFlight && showingOutbound) {
                    // Move to return flight seat selection
                    setState(() {
                      showingOutbound = false;
                      selectedSeatIds.clear();
                      totalSeatPrice = 0.0;
                      _generateSeatMap();
                    });
                  } else {
                    // Proceed to payment
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'All seats selected! Proceeding to payment...',
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
                },
                label: Text(
                  hasReturnFlight && showingOutbound ? 'Next Flight' : 'Proceed to Payment',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                icon: Icon(
                  hasReturnFlight && showingOutbound ? Icons.arrow_forward : Icons.payment,
                  color: Colors.white,
                ),
              ),
            )
          : null,
    );
  }
}