import 'package:flutter/material.dart';

class SelectedSeatsInfoWidget extends StatelessWidget {
  final Set<String> selectedSeatIds;
  final Set<String> outboundSeats;
  final Set<String> returnSeats;
  final double totalSeatPrice;
  final bool showingOutbound;
  final bool hasReturnFlight;
  final int totalPassengers;
  final Function(Set<String>) calculateSeatPrice;

  const SelectedSeatsInfoWidget({
    Key? key,
    required this.selectedSeatIds,
    required this.outboundSeats,
    required this.returnSeats,
    required this.totalSeatPrice,
    required this.showingOutbound,
    required this.hasReturnFlight,
    required this.totalPassengers,
    required this.calculateSeatPrice,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (selectedSeatIds.isEmpty) {
      return SizedBox.shrink();
    }

    final selectedSeatsList = selectedSeatIds.toList()..sort();

    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade400, Colors.green.shade600],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.airline_seat_recline_normal, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                // Displaying the number of selected seats and total passengers
                child: Text(
                  'Selected Seats for ${showingOutbound ? 'Outbound' : 'Return'} Flight (${selectedSeatIds.length}/$totalPassengers)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Seats: ${selectedSeatsList.join(', ')}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Price: ₹${totalSeatPrice.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          if (hasReturnFlight) ...[
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Trip Summary:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Outbound: ${outboundSeats.isEmpty ? 'Not selected' : (outboundSeats.toList()..sort()).join(', ')}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Return: ${returnSeats.isEmpty ? 'Not selected' : (returnSeats.toList()..sort()).join(', ')}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Total Trip Price: ₹${(calculateSeatPrice(outboundSeats) + calculateSeatPrice(returnSeats)).toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}