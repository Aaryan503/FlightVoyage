import 'dart:math' as math;
import '../models/seat.dart';

class SeatGenerator {
  static const List<String> seatLetters = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J'];
  static const int totalRows = 30;
  //this generates a seat map for an airplane with 30 rows and 10 columns (A-K)
  static List<List<Seat>> generateSeatMap() {
    final random = math.Random();
    List<List<Seat>> seatMap = [];
    
    for (int row = 1; row <= totalRows; row++) {
      List<Seat> rowSeats = [];
      
      for (int seatIndex = 0; seatIndex < seatLetters.length; seatIndex++) {
        final letter = seatLetters[seatIndex];
        final seatId = '$row$letter';
        SeatType seatType = SeatType.standard;
        double basePrice = 30000.0;
        bool isDisabled = false;
        if (row <= 3) {
          isDisabled = true;
          seatType = SeatType.disabled;
          basePrice = 25000.0;
        }
        final isOccupied = random.nextDouble() < 0.2;
        
        rowSeats.add(Seat(
          id: seatId,
          row: row,
          letter: letter,
          isOccupied: isOccupied,
          price: basePrice,
          isDisabled: isDisabled,
          type: seatType,
        ));
      }
      
      seatMap.add(rowSeats);
    }
    
    return seatMap;
  }
}