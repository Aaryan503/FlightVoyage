import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/booking.dart';
import '../providers/auth_provider.dart';

class BookingService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Save booking to Firestore
  static Future<String?> saveBookingToFirestore({
    required WidgetRef ref,
    required Booking booking,
    required FlightInfo outboundFlight,
    FlightInfo? returnFlight,
    required Set<String> outboundSeats,
    required Set<String> returnSeats,
    required Function(Set<String>) calculateSeatPrice,
  }) async {
    try {
      final user = ref.read(currentUserProvider);
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Create booking document reference
      final bookingRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('bookings')
          .doc(); // Auto-generate document ID

      final bookingId = bookingRef.id;
      final bookingTimestamp = FieldValue.serverTimestamp();

      // Save outbound flight
      await _saveFlightBooking(
        bookingRef: bookingRef,
        bookingId: bookingId,
        userId: user.uid,
        flight: outboundFlight,
        flightType: 'outbound',
        passengers: booking.passengers,
        seatNumbers: outboundSeats,
        calculateSeatPrice: calculateSeatPrice,
        isRoundTrip: booking.isRoundTrip,
        bookingTimestamp: bookingTimestamp,
      );

      // If round trip, save return flight as well
      if (booking.isRoundTrip && returnFlight != null) {
        await _saveFlightBooking(
          bookingRef: bookingRef,
          bookingId: bookingId,
          userId: user.uid,
          flight: returnFlight,
          flightType: 'return',
          passengers: booking.passengers,
          seatNumbers: returnSeats,
          calculateSeatPrice: calculateSeatPrice,
          isRoundTrip: booking.isRoundTrip,
          bookingTimestamp: bookingTimestamp,
        );
      }

      // Create a summary document at the booking level
      await _saveBookingSummary(
        bookingRef: bookingRef,
        bookingId: bookingId,
        userId: user.uid,
        booking: booking,
        outboundSeats: outboundSeats,
        returnSeats: returnSeats,
        calculateSeatPrice: calculateSeatPrice,
        bookingTimestamp: bookingTimestamp,
      );

      return bookingId;
    } catch (e) {
      print('Error saving booking: $e');
      rethrow;
    }
  }

  /// Save individual flight booking
  static Future<void> _saveFlightBooking({
    required DocumentReference bookingRef,
    required String bookingId,
    required String userId,
    required FlightInfo flight,
    required String flightType,
    required int passengers,
    required Set<String> seatNumbers,
    required Function(Set<String>) calculateSeatPrice,
    required bool isRoundTrip,
    required FieldValue bookingTimestamp,
  }) async {
    Map<String, dynamic> flightBookingData = {
      'bookingId': bookingId,
      'userId': userId,
      'flightType': flightType,
      'bookingTimestamp': bookingTimestamp,
      
      // Flight Information
      'flightNumber': flight.flightNumber,
      'airline': flight.airline,
      
      // Departure Information
      'departureAirportCode': flight.departureAirport.code,
      'departureAirportName': flight.departureAirport.name,
      'departureCity': flight.departureAirport.city,
      'departureDate': Timestamp.fromDate(flight.departureTime),
      'departureTime': _formatTime(flight.departureTime),
      
      // Arrival Information
      'arrivalAirportCode': flight.arrivalAirport.code,
      'arrivalAirportName': flight.arrivalAirport.name,
      'arrivalCity': flight.arrivalAirport.city,
      'arrivalDate': Timestamp.fromDate(flight.arrivalTime),
      'arrivalTime': _formatTime(flight.arrivalTime),
      
      // Booking Information
      'numberOfPassengers': passengers,
      'seatNumbers': seatNumbers.toList()..sort(),
      'totalSeatPrice': calculateSeatPrice(seatNumbers),
      'bookingStatus': 'confirmed',
      'paymentStatus': 'pending',
      
      // Trip Information
      'isRoundTrip': isRoundTrip,
      'duration': flight.duration.inMinutes,
    };

    await bookingRef.collection('flights').doc(flightType).set(flightBookingData);
  }

  /// Save booking summary
  static Future<void> _saveBookingSummary({
    required DocumentReference bookingRef,
    required String bookingId,
    required String userId,
    required Booking booking,
    required Set<String> outboundSeats,
    required Set<String> returnSeats,
    required Function(Set<String>) calculateSeatPrice,
    required FieldValue bookingTimestamp,
  }) async {
    Map<String, dynamic> bookingSummary = {
      'bookingId': bookingId,
      'userId': userId,
      'bookingTimestamp': bookingTimestamp,
      'isRoundTrip': booking.isRoundTrip,
      'numberOfPassengers': booking.passengers,
      'totalFlights': booking.isRoundTrip ? 2 : 1,
      'bookingStatus': 'confirmed',
      'paymentStatus': 'pending',
      'outboundSeatNumbers': outboundSeats.toList()..sort(),
      'returnSeatNumbers': booking.isRoundTrip ? (returnSeats.toList()..sort()) : [],
      'totalBookingValue': booking.isRoundTrip 
          ? calculateSeatPrice(outboundSeats) + calculateSeatPrice(returnSeats)
          : calculateSeatPrice(outboundSeats),
    };

    await bookingRef.set(bookingSummary);
  }

  static String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}