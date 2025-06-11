import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/flight_booking.dart';

class FlightHistoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetches flight history for a specific user from their subcollection of bookings
  Future<List<FlightBooking>> getFlightHistory(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('bookings')
          .orderBy('bookingTimestamp', descending: true)
          .get();

      List<FlightBooking> bookings = [];

      for (var doc in querySnapshot.docs) {
        final bookingData = doc.data();
        final flightsSnapshot = await doc.reference
            .collection('flights')
            .get();

        Map<String, dynamic> outboundFlight = {};
        Map<String, dynamic>? returnFlight;
      //get flight data of return flight if exists
        for (var flightDoc in flightsSnapshot.docs) {
          final flightData = flightDoc.data();
          if (flightData['flightType'] == 'outbound') {
            outboundFlight = flightData;
          } else if (flightData['flightType'] == 'return') {
            returnFlight = flightData;
          }
        }

        if (outboundFlight.isNotEmpty) {
          bookings.add(FlightBooking.fromFirestore(
            bookingId: doc.id,
            bookingData: bookingData,
            outboundFlight: outboundFlight,
            returnFlight: returnFlight,
          ));
        }
      }

      return bookings;
    } catch (e) {
      throw FlightHistoryException('Failed to load flight history: $e');
    }
  }

  /// Stream for real-time flight history updates
  Stream<List<FlightBooking>> getFlightHistoryStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('bookings')
        .orderBy('bookingTimestamp', descending: true)
        .snapshots()
        .asyncMap((querySnapshot) async {
      List<FlightBooking> bookings = [];

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
          bookings.add(FlightBooking.fromFirestore(
            bookingId: doc.id,
            bookingData: bookingData,
            outboundFlight: outboundFlight,
            returnFlight: returnFlight,
          ));
        }
      }

      return bookings;
    });
  }
}

/// Custom exception for flight history operations
class FlightHistoryException implements Exception {
  final String message;
  FlightHistoryException(this.message);

  @override
  String toString() => 'FlightHistoryException: $message';
}