import 'package:flightbooking/screens/homescreen/airport_selection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/booking_provider.dart';
import '../../models/seat.dart';
import '../../models/booking.dart';
import '../../utils/seat_generator.dart';
import 'widgets/seat_widgets.dart';
import 'widgets/seat_selection_fab.dart';
import 'widgets/selected_seats_info_widget.dart';
import 'widgets/flight_info_widget.dart';
import 'widgets/seat_legend_widget.dart';
import 'widgets/passenger_info_widget.dart';
import '../../services/booking_service.dart';
import '../../utils/seat_selection_logic.dart';

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
  Set<String> outboundSeats = {};
  Set<String> returnSeats = {};
  double totalSeatPrice = 0.0;
  bool isBookingSaved = false;
  bool isSavingBooking = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeSeatMap();
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
    
    _slideController.forward();
    _fadeController.forward();
  }

  void _initializeSeatMap() {
    seatMap = SeatGenerator.generateSeatMap();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _selectSeat(String seatId) {
    final booking = ref.read(bookingProvider);
    final maxPassengers = booking.passengers;
    
    if (!SeatSelectionLogic.canSelectSeat(selectedSeatIds, seatId, maxPassengers)) {
      _showPassengerLimitMessage(maxPassengers);
      return;
    }

    setState(() {
      if (selectedSeatIds.contains(seatId)) {
        selectedSeatIds.remove(seatId);
        SeatSelectionLogic.updateSeatSelection(seatMap, seatId, false);
      } else {
        selectedSeatIds.add(seatId);
        SeatSelectionLogic.updateSeatSelection(seatMap, seatId, true);
      }
      _calculateTotalPrice();
    });
  }

  void _showPassengerLimitMessage(int maxPassengers) {
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

  void _calculateTotalPrice() {
    totalSeatPrice = SeatSelectionLogic.calculateSeatPrice(seatMap, selectedSeatIds);
  }

  double _calculateSeatPrice(Set<String> seats) {
    return SeatSelectionLogic.calculateSeatPrice(seatMap, seats);
  }
  Future<void> _saveBookingToFirestore() async {
    if (isSavingBooking) return;
    
    setState(() {
      isSavingBooking = true;
    });

    try {
      final bookingState = ref.read(bookingProvider);
      final booking = Booking(
        departure: bookingState.departure!,
        destination: bookingState.destination!,
        isRoundTrip: bookingState.isRoundTrip,
        departureDate: bookingState.departureDate!,
        returnDate: bookingState.returnDate,
        passengers: bookingState.passengers,
      );
      
      final bookingId = await BookingService.saveBookingToFirestore(
        ref: ref,
        booking: booking,
        outboundFlight: bookingState.selectedOutboundFlight!,
        returnFlight: bookingState.selectedReturnFlight,
        outboundSeats: outboundSeats,
        returnSeats: returnSeats,
        calculateSeatPrice: _calculateSeatPrice,
      );

      if (bookingId != null) {
        setState(() {
          isBookingSaved = true;
          isSavingBooking = false;
        });

        _showMessage("Booking saved successfully!", Colors.green.shade400);
      }
    } catch (e) {
      setState(() {
        isSavingBooking = false;
      });
      
      _showMessage('Failed to save booking. Please try again.', Colors.red.shade400);
    }
  }

  void _showMessage(String text, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        backgroundColor: color,
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  void _switchFlightView() {
    setState(() {
      if (showingOutbound) {
        outboundSeats = Set.from(selectedSeatIds);
        selectedSeatIds = Set.from(returnSeats);
      } else {
        returnSeats = Set.from(selectedSeatIds);
        selectedSeatIds = Set.from(outboundSeats);
      }
      showingOutbound = !showingOutbound;
      _calculateTotalPrice();
      seatMap = SeatGenerator.generateSeatMap();
    });
  }

  void _handleFABPressed() async {
    final booking = ref.read(bookingProvider);
    final hasReturnFlight = booking.isRoundTrip && booking.selectedReturnFlight != null;
    
    if (hasReturnFlight && showingOutbound) {
      setState(() {
        outboundSeats = Set.from(selectedSeatIds);
        selectedSeatIds.clear();
        showingOutbound = false;
        totalSeatPrice = 0.0;
        seatMap = SeatGenerator.generateSeatMap();
      });
    } else {
      if (hasReturnFlight) {
        returnSeats = Set.from(selectedSeatIds);
      } else {
        outboundSeats = Set.from(selectedSeatIds);
      }

      await _saveBookingToFirestore();

      if (isBookingSaved) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => AirportSelectionScreen()),
          (route) => false,
        );
      }
    }
  }

  PreferredSizeWidget _buildAppBar(bool hasReturnFlight) {
    return AppBar(
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
          onPressed: _switchFlightView,
          child: Text(
            showingOutbound ? 'Return >' : '< Outbound',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ] : null,
    );
  }

  Widget _buildBody() {
    final booking = ref.watch(bookingProvider);
    final hasReturnFlight = booking.isRoundTrip && booking.selectedReturnFlight != null;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 20),
              FlightInfoWidget(
                flight: showingOutbound 
                    ? booking.selectedOutboundFlight!
                    : booking.selectedReturnFlight!,
                isOutbound: showingOutbound,
              ),
              SizedBox(height: 16),
              PassengerInfoWidget(
                totalPassengers: booking.passengers,
                selectedSeatsCount: selectedSeatIds.length,
              ),
              SizedBox(height: 16),
              SeatWidgets.buildSeatSelection(seatMap, _selectSeat),
              SizedBox(height: 16),
              SeatLegendWidget(),
              SelectedSeatsInfoWidget(
                selectedSeatIds: selectedSeatIds,
                outboundSeats: outboundSeats,
                returnSeats: returnSeats,
                totalSeatPrice: totalSeatPrice,
                showingOutbound: showingOutbound,
                hasReturnFlight: hasReturnFlight,
                totalPassengers: booking.passengers,
                calculateSeatPrice: _calculateSeatPrice,
              ),
              
              SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final booking = ref.watch(bookingProvider);
    final hasReturnFlight = booking.isRoundTrip && booking.selectedReturnFlight != null;
    final allSeatsSelected = selectedSeatIds.length == booking.passengers;
    final outboundSeatsSelected = outboundSeats.length == booking.passengers;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildAppBar(hasReturnFlight),
      body: _buildBody(),
      floatingActionButton: SeatSelectionFAB(
        hasReturnFlight: hasReturnFlight,
        showingOutbound: showingOutbound,
        allSeatsSelected: allSeatsSelected,
        outboundSeatsSelected: outboundSeatsSelected,
        isSavingBooking: isSavingBooking,
        onPressed: _handleFABPressed,
      ),
    );
  }
}