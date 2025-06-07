import 'package:flutter/material.dart';
import '../models/airport.dart';
import 'temperature_display.dart';

class RouteCard extends StatelessWidget {
  final Airport? selectedDeparture;
  final Airport? selectedDestination;
  final Map<String, double?> temperatures;
  final Animation<Offset> slideAnimation;
  final VoidCallback onBookFlight;

  const RouteCard({
    Key? key,
    required this.selectedDeparture,
    required this.selectedDestination,
    required this.temperatures,
    required this.slideAnimation,
    required this.onBookFlight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: slideAnimation,
      child: Container(
        margin: EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.white],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.2),
              blurRadius: 15,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              _buildDepartureSection(),
              SizedBox(height: 16),
              _buildDivider(),
              SizedBox(height: 16),
              _buildDestinationSection(),
              if (selectedDeparture != null && selectedDestination != null) ...[
                SizedBox(height: 24),
                Align(
                  alignment: Alignment.center,
                  child: _buildBookFlightButton(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDepartureSection() {
    return Row(
      children: [
        Icon(Icons.flight_takeoff, color: Colors.blue.shade600, size: 24),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'From: ${selectedDeparture?.city ?? 'Select departure'}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  TemperatureDisplay(
                    airport: selectedDeparture,
                    temperatures: temperatures,
                  ),
                ],
              ),
              if (selectedDeparture != null)
                Text(
                  '${selectedDeparture!.name} (${selectedDeparture!.code})',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 2,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade200, Colors.blue.shade400],
        ),
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }

  Widget _buildDestinationSection() {
    return Row(
      children: [
        Icon(Icons.flight_land, color: Colors.orange.shade600, size: 24),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'To: ${selectedDestination?.city ?? 'Select destination'}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.orange.shade800,
                    ),
                  ),
                  TemperatureDisplay(
                    airport: selectedDestination,
                    temperatures: temperatures,
                  ),
                ],
              ),
              if (selectedDestination != null)
                Text(
                  '${selectedDestination!.name} (${selectedDestination!.code})',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBookFlightButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.blue.shade600],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(25),
          onTap: onBookFlight,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.book_online, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text(
                  'Book Flight',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}