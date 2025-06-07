import '../models/seat.dart';

class SeatSelectionLogic {
  /// Update seat selection status in the seat map
  static void updateSeatSelection(
    List<List<Seat>> seatMap,
    String seatId,
    bool isSelected,
  ) {
    for (int i = 0; i < seatMap.length; i++) {
      for (int j = 0; j < seatMap[i].length; j++) {
        if (seatMap[i][j].id == seatId) {
          seatMap[i][j] = seatMap[i][j].copyWith(isSelected: isSelected);
          return; // Exit early once found
        }
      }
    }
  }

  /// Calculate total price for a set of selected seats
  static double calculateSeatPrice(
    List<List<Seat>> seatMap,
    Set<String> selectedSeatIds,
  ) {
    double price = 0.0;
    
    for (String seatId in selectedSeatIds) {
      for (int i = 0; i < seatMap.length; i++) {
        for (int j = 0; j < seatMap[i].length; j++) {
          if (seatMap[i][j].id == seatId) {
            price += seatMap[i][j].price;
            break; // Move to next seat ID
          }
        }
      }
    }
    
    return price;
  }

  /// Validate if seat can be selected based on passenger limit
  static bool canSelectSeat(
    Set<String> selectedSeatIds,
    String seatId,
    int maxPassengers,
  ) {
    // If seat is already selected, allow deselection
    if (selectedSeatIds.contains(seatId)) {
      return true;
    }
    
    // Check if we haven't reached the passenger limit
    return selectedSeatIds.length < maxPassengers;
  }

  /// Get formatted seat numbers list
  static List<String> getFormattedSeatNumbers(Set<String> seatIds) {
    return seatIds.toList()..sort();
  }
}