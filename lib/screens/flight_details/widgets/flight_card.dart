import 'package:flutter/material.dart';
import '../../../../models/booking.dart';
import '../../../../utils/date_formatter.dart';

class FlightCard extends StatelessWidget {
  final FlightInfo flight;
  final bool isReturn;
  final bool isSelected;
  final VoidCallback onTap;

  const FlightCard({
    Key? key,
    required this.flight,
    required this.isReturn,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSelected 
                ? [Colors.green.shade50, Colors.green.shade100]
                : [Colors.white, Colors.blue.shade50],
          ),
          borderRadius: BorderRadius.circular(20),
          border: isSelected 
              ? Border.all(color: Colors.green.shade400, width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: isSelected 
                  ? Colors.green.withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: 0.1),
              blurRadius: isSelected ? 20 : 15,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              _buildFlightHeader(),
              if (isSelected) _buildSelectedAirlineRow(),
              SizedBox(height: 24),
              _buildFlightTimesRow(),
              if (!isSelected) _buildTapToSelectButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFlightHeader() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isReturn 
                  ? [Colors.orange.shade400, Colors.orange.shade600]
                  : [Colors.blue.shade400, Colors.blue.shade600],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            flight.flightNumber,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        Spacer(),
        if (isSelected)
          Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.green.shade400,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check,
              color: Colors.white,
              size: 16,
            ),
          )
        else
          Text(
            flight.airline,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
              fontSize: 14,
            ),
          ),
      ],
    );
  }

  Widget _buildSelectedAirlineRow() {
    return Padding(
      padding: EdgeInsets.only(top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            flight.airline,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.green.shade700,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlightTimesRow() {
    return Row(
      children: [
        _buildTimeColumn(
          time: DateFormatter.formatTime(flight.departureTime),
          city: flight.departureAirport.city,
          code: flight.departureAirport.code,
          color: isSelected ? Colors.green.shade800 : Colors.blue.shade800,
        ),
        _buildFlightPath(),
        _buildTimeColumn(
          time: DateFormatter.formatTime(flight.arrivalTime),
          city: flight.arrivalAirport.city,
          code: flight.arrivalAirport.code,
          color: isSelected ? Colors.green.shade800 : Colors.orange.shade800,
        ),
      ],
    );
  }

  Widget _buildTimeColumn({
    required String time,
    required String city,
    required String code,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Text(
            time,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 8),
          Text(
            city,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            code,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlightPath() {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected 
                  ? Colors.green.shade100
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Text(
                  DateFormatter.formatDuration(flight.duration),
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected 
                        ? Colors.green.shade700
                        : Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '${flight.miles.toStringAsFixed(0)} miles',
                  style: TextStyle(
                    fontSize: 11,
                    color: isSelected 
                        ? Colors.green.shade700
                        : Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isSelected 
                        ? [Colors.green.shade300, Colors.green.shade400]
                        : [Colors.blue.shade300, Colors.blue.shade400],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? Colors.green.shade400
                      : Colors.blue.shade400,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.flight,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTapToSelectButton() {
    return Padding(
      padding: EdgeInsets.only(top: 16),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.blue.shade200,
            width: 1,
          ),
        ),
        child: Text(
          'Tap to select',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.blue.shade600,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}