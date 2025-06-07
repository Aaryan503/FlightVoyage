import 'package:flutter/material.dart';
import '../models/seat.dart';

class SeatWidgets {
  static Color getSeatColor(Seat seat) {
    if (seat.isSelected) {
      return Colors.green.shade400;
    } else if (seat.isOccupied) {
      return Colors.red.shade400;
    } else if (seat.isDisabled) {
      return Colors.purple.shade300;
    } else {
      return Colors.blue.shade300;
    }
  }

  static IconData getSeatIcon(Seat seat) {
    if (seat.isSelected) {
      return Icons.check;
    } else if (seat.isOccupied) {
      return Icons.person;
    } else if (seat.isDisabled) {
      return Icons.accessible;
    } else {
      return Icons.airline_seat_recline_normal;
    }
  }

  static Widget buildSeat(Seat seat, Function(String) onSeatTap) {
    return GestureDetector(
      onTap: seat.isOccupied ? null : () => onSeatTap(seat.id),
      child: Container(
        width: 24,
        height: 24,
        margin: EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: getSeatColor(seat),
          borderRadius: BorderRadius.circular(6),
          border: seat.isSelected 
              ? Border.all(color: Colors.green.shade700, width: 1.5)
              : null,
          boxShadow: seat.isSelected 
              ? [BoxShadow(
                  color: Colors.green.withOpacity(0.3),
                  blurRadius: 6,
                  offset: Offset(0, 3),
                )]
              : null,
        ),
        child: Icon(
          getSeatIcon(seat),
          size: 12,
          color: Colors.white,
        ),
      ),
    );
  }

  static Widget buildSeatRow(List<Seat> rowSeats, int rowNumber, Function(String) onSeatTap) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 24,
              child: Text(
                '$rowNumber',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            SizedBox(width: 4),
            ...rowSeats.sublist(0, 3).map((seat) => buildSeat(seat, onSeatTap)),
            SizedBox(width: 8), 
            ...rowSeats.sublist(3, 7).map((seat) => buildSeat(seat, onSeatTap)),
            SizedBox(width: 8),
            ...rowSeats.sublist(7, 10).map((seat) => buildSeat(seat, onSeatTap)),
            SizedBox(width: 4),
            Container(
              width: 24,
              child: Text(
                '$rowNumber',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget buildSeatSelection(List<List<Seat>> seatMap, Function(String) onSeatTap) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ...['A', 'B', 'C'].map((letter) => Container(
                    width: 26,
                    child: Text(
                      letter,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  )),
                  SizedBox(width: 8),
                  ...['D', 'E', 'F', 'G'].map((letter) => Container(
                    width: 26,
                    child: Text(
                      letter,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  )),
                  SizedBox(width: 8),
                  ...['H', 'J', 'K'].map((letter) => Container(
                    width: 26,
                    child: Text(
                      letter,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  )),
                ],
              ),
            ),
          ),
          SizedBox(height: 8),
          Container(
            height: 400,
            child: SingleChildScrollView(
              child: Column(
                children: seatMap.asMap().entries.map((entry) {
                  final index = entry.key;
                  final rowSeats = entry.value;
                  return buildSeatRow(rowSeats, index + 1, onSeatTap);
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}