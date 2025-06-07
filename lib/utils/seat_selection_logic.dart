import '../models/seat.dart';

class SeatSelectionLogic {
  static void updateSeatSelection(
    List<List<Seat>> seatMap,
    String seatId,
    bool isSelected,
  ) {
    for (int i = 0; i < seatMap.length; i++) {
      for (int j = 0; j < seatMap[i].length; j++) {
        if (seatMap[i][j].id == seatId) {
          seatMap[i][j] = seatMap[i][j].copyWith(isSelected: isSelected);
          return; 
        }
      }
    }
  }

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
            break;
          }
        }
      }
    }
    
    return price;
  }

  static bool canSelectSeat(
    Set<String> selectedSeatIds,
    String seatId,
    int maxPassengers,
  ) {
    if (selectedSeatIds.contains(seatId)) {
      return true;
    }
    return selectedSeatIds.length < maxPassengers;
  }
  static List<String> getFormattedSeatNumbers(Set<String> seatIds) {
    return seatIds.toList()..sort();
  }
}