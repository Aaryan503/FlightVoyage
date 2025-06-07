import 'package:flutter/material.dart';
import '../models/airport.dart';

class TemperatureDisplay extends StatelessWidget {
  final Airport? airport;
  final Map<String, double?> temperatures;

  const TemperatureDisplay({
    Key? key,
    required this.airport,
    required this.temperatures,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (airport == null) return SizedBox.shrink();
    
    final temperature = temperatures[airport!.code];
    
    return Container(
      margin: EdgeInsets.only(left: 8),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: temperature != null 
              ? [Colors.orange.shade200, Colors.red.shade300]
              : [Colors.grey.shade200, Colors.grey.shade300],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        temperature != null ? '${temperature.round()}°C' : '--°C',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [
            Shadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 2,
            ),
          ],
        ),
      ),
    );
  }
}