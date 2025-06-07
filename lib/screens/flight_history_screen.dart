import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/auth_provider.dart';
import '../widgets/flight_history_card.dart';
import '../widgets/flight_detail_modal.dart';
import '../models/flight_booking.dart';

class FlightHistoryScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<FlightHistoryScreen> createState() => _FlightHistoryScreenState();
}

class _FlightHistoryScreenState extends ConsumerState<FlightHistoryScreen> {
  List<FlightBooking> bookings = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadFlightHistory();
  }

  Future<void> _loadFlightHistory() async {
    try {
      final user = ref.read(currentUserProvider);
      if (user == null) {
        setState(() {
          errorMessage = 'User not authenticated';
          isLoading = false;
        });
        return;
      }

      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('bookings')
          .orderBy('bookingTimestamp', descending: true)
          .get();

      List<FlightBooking> loadedBookings = [];

      for (var doc in querySnapshot.docs) {
        final bookingData = doc.data();
        final flightsSnapshot = await doc.reference
            .collection('flights')
            .get();

        Map<String, dynamic> outboundFlight = {};
        Map<String, dynamic>? returnFlight;

        for (var flightDoc in flightsSnapshot.docs) {
          final flightData = flightDoc.data();
          if (flightData['flightType'] == 'outbound') {
            outboundFlight = flightData;
          } else if (flightData['flightType'] == 'return') {
            returnFlight = flightData;
          }
        }

        if (outboundFlight.isNotEmpty) {
          loadedBookings.add(FlightBooking.fromFirestore(
            bookingId: doc.id,
            bookingData: bookingData,
            outboundFlight: outboundFlight,
            returnFlight: returnFlight,
          ));
        }
      }

      setState(() {
        bookings = loadedBookings;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load flight history: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _refreshHistory() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    await _loadFlightHistory();
  }

  void _showFlightDetails(FlightBooking booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FlightDetailModal(booking: booking),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'Flight History',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      backgroundColor: Colors.blue.shade600,
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        IconButton(
          icon: Icon(Icons.refresh),
          onPressed: _refreshHistory,
          tooltip: 'Refresh',
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

  Widget _buildBody() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.blue.shade600),
            SizedBox(height: 16),
            Text(
              'Loading your flight history...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade400,
            ),
            SizedBox(height: 16),
            Text(
              'Error Loading History',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade600,
              ),
            ),
            SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _refreshHistory,
              icon: Icon(Icons.refresh),
              label: Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.flight_takeoff,
              size: 64,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: 16),
            Text(
              'No Flight History',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Your booked flights will appear here',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.add),
              label: Text('Book Your First Flight'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshHistory,
      color: Colors.blue.shade600,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          return Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: FlightHistoryCard(
              booking: booking,
              onTap: () => _showFlightDetails(booking),
            ),
          );
        },
      ),
    );
  }
}