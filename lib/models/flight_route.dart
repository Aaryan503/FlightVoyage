import 'airport.dart';

class FlightRoute {
  final Airport departure;
  final Airport destination;

  const FlightRoute({
    required this.departure,
    required this.destination,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FlightRoute &&
        other.departure == departure &&
        other.destination == destination;
  }

  @override
  int get hashCode => departure.hashCode ^ destination.hashCode;

  @override
  String toString() {
    return 'FlightRoute(departure: ${departure.code}, destination: ${destination.code})';
  }
}