import 'package:flutter/material.dart';
import '../../models/airport.dart';

class AirportMarker extends StatelessWidget {
  final Airport airport;
  final Map<String, double?> temperatures;
  final bool isSelected;
  final Animation<double> pulseAnimation;
  final VoidCallback onTap;

  const AirportMarker({
    Key? key,
    required this.airport,
    required this.temperatures,
    required this.isSelected,
    required this.pulseAnimation,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final temperature = temperatures[airport.code];
    
    return AnimatedBuilder(
      animation: pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: isSelected ? pulseAnimation.value : 1.0,
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: temperature != null 
                              ? [Colors.orange.shade300, Colors.red.shade400]
                              : [Colors.grey.shade300, Colors.grey.shade400],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                            offset: Offset(0, 4),
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
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isSelected 
                              ? [Colors.red.shade400, Colors.red.shade600]
                              : [Colors.blue.shade400, Colors.blue.shade600],
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: (isSelected ? Colors.red : Colors.blue).withOpacity(0.4),
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.flight,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: Text(
                        airport.code,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}