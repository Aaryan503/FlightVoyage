import 'airport.dart';

class Booking {
  final Airport departure;
  final Airport destination;
  final bool isRoundTrip;
  final DateTime departureDate;
  final DateTime? returnDate;
  final int passengers;

  const Booking({
    required this.departure,
    required this.destination,
    required this.isRoundTrip,
    required this.departureDate,
    this.returnDate,
    this.passengers = 1,
  });
}

class FlightInfo {
  final String flightNumber;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final Airport departureAirport;
  final Airport arrivalAirport;
  final String airline;
  final Duration duration;

  const FlightInfo({
    required this.flightNumber,
    required this.departureTime,
    required this.arrivalTime,
    required this.departureAirport,
    required this.arrivalAirport,
    required this.airline,
    required this.duration,
  });
}