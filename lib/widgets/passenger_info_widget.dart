import 'package:flutter/material.dart';

class PassengerInfoWidget extends StatelessWidget {
  final int totalPassengers;
  final int selectedSeatsCount;

  const PassengerInfoWidget({
    Key? key,
    required this.totalPassengers,
    required this.selectedSeatsCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.indigo.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.indigo.shade200, width: 1),
      ),
      child: Row(
        children: [
          Icon(
            Icons.people,
            color: Colors.indigo.shade600,
            size: 24,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Passengers: $totalPassengers',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo.shade800,
                  ),
                ),
                Text(
                  'Selected: $selectedSeatsCount/$totalPassengers seats',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.indigo.shade600,
                  ),
                ),
              ],
            ),
          ),
          if (selectedSeatsCount == totalPassengers)
            Icon(
              Icons.check_circle,
              color: Colors.green.shade600,
              size: 24,
            ),
        ],
      ),
    );
  }
}