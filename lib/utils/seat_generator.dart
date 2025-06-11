import 'dart:math' as math;
import '../models/seat.dart';

class SeatGenerator {
  static const List<String> seatLetters = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J'];
  static const int totalRows = 30;
  static const double standardSeatBasePrice = 30000.0;
  static const double disabledSeatBasePrice = 25000.0;
  static const double windowSeatPremium = 2000.0;
  static const double aisleSeatPremium = 1500.0;
  static const double emergencyExitPremium = 3000.0;
  
  static List<List<Seat>> generateSeatMap() {
    final random = math.Random();
    List<List<Seat>> seatMap = [];
    
    for (int row = 1; row <= totalRows; row++) {
      List<Seat> rowSeats = [];
      
      for (int seatIndex = 0; seatIndex < seatLetters.length; seatIndex++) {
        final letter = seatLetters[seatIndex];
        final seatId = '$row$letter';
        SeatType seatType = SeatType.standard;
        double basePrice = standardSeatBasePrice;
        bool isDisabled = false;
        if (row <= 3) {
          isDisabled = true;
          seatType = SeatType.disabled;
          basePrice = disabledSeatBasePrice;
        }
        if (letter == 'A' || letter == 'J') {
          basePrice += windowSeatPremium;
        }
        if (letter == 'C' || letter == 'D' || letter == 'G' || letter == 'H') {
          basePrice += aisleSeatPremium;
        }
        if (row == 14 || row == 15) {
          basePrice += emergencyExitPremium;
        }
        final variation = (random.nextDouble() * 0.1 - 0.05) * basePrice;
        final finalPrice = math.max(0, basePrice + variation).toDouble();
        
        final isOccupied = random.nextDouble() < 0.2;
        
        rowSeats.add(Seat(
          id: seatId,
          row: row,
          letter: letter,
          isOccupied: isOccupied,
          price: finalPrice,
          isDisabled: isDisabled,
          type: seatType,
        ));
      }
      
      seatMap.add(rowSeats);
    }
    
    return seatMap;
  }
}
