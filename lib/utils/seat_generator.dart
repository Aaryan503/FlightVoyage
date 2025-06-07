import 'dart:math' as math;
import '../models/seat.dart';

class SeatGenerator {
  static const List<String> seatLetters = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'J', 'K'];
  static const int totalRows = 30;

  static List<List<Seat>> generateSeatMap() {
    final random = math.Random();
    List<List<Seat>> seatMap = [];
    
    for (int row = 1; row <= totalRows; row++) {
      List<Seat> rowSeats = [];
      
      for (int seatIndex = 0; seatIndex < seatLetters.length; seatIndex++) {
        final letter = seatLetters[seatIndex];
        final seatId = '$row$letter';
        
        // Determine seat type and price
        SeatType seatType = SeatType.standard;
        double basePrice = 30000.0;
        bool isDisabled = false;
        
        // First 3 rows: Reserved for disabled passengers
        if (row <= 3) {
          isDisabled = true;
          seatType = SeatType.disabled;
          basePrice = 25000.0;
        }
        
        // Add some randomness to pricing
        final priceVariation = random.nextDouble() * 1000 - random.nextInt(300);
        final finalPrice = math.max(0, basePrice + priceVariation);
        
        // Randomly occupy some seats (about 20% occupancy)
        final isOccupied = random.nextDouble() < 0.2;
        
        rowSeats.add(Seat(
          id: seatId,
          row: row,
          letter: letter,
          isOccupied: isOccupied,
          price: finalPrice.toDouble(),
          isDisabled: isDisabled,
          type: seatType,
        ));
      }
      
      seatMap.add(rowSeats);
    }
    
    return seatMap;
  }
}