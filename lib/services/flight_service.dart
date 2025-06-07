import 'dart:math' as math;
import '../models/airport.dart';
import '../models/booking.dart';

class FlightService {
  static const List<String> _airlines = [
    'Emirates', 
    'Qatar Airways', 
    'Singapore Airlines', 
    'British Airways', 
    'Lufthansa', 
    'Air France'
  ];

  List<FlightInfo> generateFlights({
    required Airport from,
    required Airport to,
    required DateTime date,
    required int count,
  }) {
    final random = math.Random();
    
    return List.generate(count, (index) {
      final airline = _airlines[random.nextInt(_airlines.length)];
      final flightNumber = '${airline.substring(0, 2).toUpperCase()}${random.nextInt(900) + 100}';

      final departureTime = _generateDepartureTime(date, index, random);
      final duration = _calculateFlightDuration(from, to);
      final arrivalTime = departureTime.add(duration);

      return FlightInfo(
        flightNumber: flightNumber,
        departureTime: departureTime,
        arrivalTime: arrivalTime,
        departureAirport: from,
        arrivalAirport: to,
        airline: airline,
        duration: duration,
      );
    });
  }

  DateTime _generateDepartureTime(DateTime date, int index, math.Random random) {
    // Generate departure times at 30-minute intervals between 6:00 and 22:00
    const startHour = 6;
    const slotsPerHour = 2; // 0 or 30 minutes
    const totalSlots = (22 - startHour + 1) * slotsPerHour;
    
    final slot = (index < totalSlots) ? index : random.nextInt(totalSlots);
    final departureHour = startHour + (slot ~/ slotsPerHour);
    final departureMinute = (slot % slotsPerHour) * 30;

    return DateTime(
      date.year,
      date.month,
      date.day,
      departureHour,
      departureMinute,
    );
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
}