import 'package:flutter/material.dart';

class SeatSelectionFAB extends StatelessWidget {
  final bool hasReturnFlight;
  final bool showingOutbound;
  final bool allSeatsSelected;
  final bool outboundSeatsSelected;
  final bool isSavingBooking;
  final VoidCallback onPressed;

  const SeatSelectionFAB({
    Key? key,
    required this.hasReturnFlight,
    required this.showingOutbound,
    required this.allSeatsSelected,
    required this.outboundSeatsSelected,
    required this.isSavingBooking,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool canProceed = false;
    String buttonText = '';
    IconData buttonIcon = Icons.arrow_forward;

    if (!hasReturnFlight) {
      canProceed = allSeatsSelected;
      buttonText = 'Confirm Booking';
      buttonIcon = Icons.bookmark_outline;
    } else {
      if (showingOutbound) {
        canProceed = allSeatsSelected;
        buttonText = 'Select Return Seats';
        buttonIcon = Icons.arrow_forward;
      } else {
        canProceed = allSeatsSelected && outboundSeatsSelected;
        buttonText = 'Proceed';
        buttonIcon = Icons.bookmark_outline;
      }
    }

    if (!canProceed) {
      return SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: (hasReturnFlight && showingOutbound)
              ? [Colors.orange.shade400, Colors.orange.shade600]
              : [Colors.green.shade400, Colors.green.shade600],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: ((hasReturnFlight && showingOutbound) ? Colors.orange : Colors.green).withOpacity(0.3),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        backgroundColor: Colors.transparent,
        elevation: 0,
        onPressed: isSavingBooking ? null : onPressed,
        label: isSavingBooking
            ? Text(
                'Saving...',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              )
            : Text(
                buttonText,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
        icon: isSavingBooking
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Icon(
                buttonIcon,
                color: Colors.white,
              ),
      ),
    );
  }
}