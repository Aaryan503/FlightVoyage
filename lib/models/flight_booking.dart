import 'package:cloud_firestore/cloud_firestore.dart';

class FlightBooking {
  final String bookingId;
  final DateTime bookingTimestamp;
  final bool isRoundTrip;
  final int numberOfPassengers;
  final double totalBookingValue;
  final FlightDetails outboundFlight;
  final FlightDetails? returnFlight;

  FlightBooking({
    required this.bookingId,
    required this.bookingTimestamp,
    required this.isRoundTrip,
    required this.numberOfPassengers,
    required this.totalBookingValue,
    required this.outboundFlight,
    this.returnFlight,
  });

  factory FlightBooking.fromFirestore({
    required String bookingId,
    required Map<String, dynamic> bookingData,
    required Map<String, dynamic> outboundFlight,
    Map<String, dynamic>? returnFlight,
  }) {
    return FlightBooking(
      bookingId: bookingId,
      bookingTimestamp: (bookingData['bookingTimestamp'] as Timestamp).toDate(),
      isRoundTrip: bookingData['isRoundTrip'] ?? false,
      numberOfPassengers: bookingData['numberOfPassengers'] ?? 1,
      totalBookingValue: (bookingData['totalBookingValue'] ?? 0.0).toDouble(),
      outboundFlight: FlightDetails.fromFirestore(outboundFlight),
      returnFlight: returnFlight != null 
          ? FlightDetails.fromFirestore(returnFlight) 
          : null,
    );
  }

  String get tripTypeDisplay => isRoundTrip ? 'Round Trip' : 'One Way';
  
}

class FlightDetails {
  final String flightNumber;
  final String airline;
  final String flightType;
  final String departureAirportCode;
  final String departureAirportName;
  final String departureCity;
  final DateTime departureDate;
  final String departureTime;
  final String arrivalAirportCode;
  final String arrivalAirportName;
  final String arrivalCity;
  final DateTime arrivalDate;
  final String arrivalTime;
  final List<String> seatNumbers;
  final double totalSeatPrice;
  final int duration;

  FlightDetails({
    required this.flightNumber,
    required this.airline,
    required this.flightType,
    required this.departureAirportCode,
    required this.departureAirportName,
    required this.departureCity,
    required this.departureDate,
    required this.departureTime,
    required this.arrivalAirportCode,
    required this.arrivalAirportName,
    required this.arrivalCity,
    required this.arrivalDate,
    required this.arrivalTime,
    required this.seatNumbers,
    required this.totalSeatPrice,
    required this.duration,
  });

  factory FlightDetails.fromFirestore(Map<String, dynamic> data) {
    return FlightDetails(
      flightNumber: data['flightNumber'] ?? '',
      airline: data['airline'] ?? '',
      flightType: data['flightType'] ?? '',
      departureAirportCode: data['departureAirportCode'] ?? '',
      departureAirportName: data['departureAirportName'] ?? '',
      departureCity: data['departureCity'] ?? '',
      departureDate: (data['departureDate'] as Timestamp).toDate(),
      departureTime: data['departureTime'] ?? '',
      arrivalAirportCode: data['arrivalAirportCode'] ?? '',
      arrivalAirportName: data['arrivalAirportName'] ?? '',
      arrivalCity: data['arrivalCity'] ?? '',
      arrivalDate: (data['arrivalDate'] as Timestamp).toDate(),
      arrivalTime: data['arrivalTime'] ?? '',
      seatNumbers: List<String>.from(data['seatNumbers'] ?? []),
      totalSeatPrice: (data['totalSeatPrice'] ?? 0.0).toDouble(),
      duration: data['duration'] ?? 0,
    );
  }

  String get route => '$departureAirportCode → $arrivalAirportCode';
  String get cityRoute => '$departureCity → $arrivalCity';
  String get fullRoute => '$departureAirportName ($departureAirportCode) → $arrivalAirportName ($arrivalAirportCode)';
  
  String get durationDisplay {
    final hours = duration ~/ 60;
    final minutes = duration % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  String get dateDisplay {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${departureDate.day} ${months[departureDate.month - 1]}, ${departureDate.year}';
  }

  String get seatsDisplay {
    if (seatNumbers.isEmpty) return 'No seats';
    if (seatNumbers.length == 1) return seatNumbers.first;
    return '${seatNumbers.first} (+${seatNumbers.length - 1} more)';
  }
}