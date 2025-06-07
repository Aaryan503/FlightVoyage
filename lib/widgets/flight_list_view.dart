import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../providers/booking_provider.dart';
import 'flight_card.dart';
import 'date_header.dart';

class FlightListView extends StatelessWidget {
  final List<FlightInfo> outboundFlights;
  final List<FlightInfo> returnFlights;
  final BookingState booking;
  final Function(FlightInfo, bool) onFlightSelected;

  const FlightListView({
    Key? key,
    required this.outboundFlights,
    required this.returnFlights,
    required this.booking,
    required this.onFlightSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 20),
          
          // Outbound flights
          DateHeader(
            title: 'Departure',
            date: booking.departureDate!,
            isReturn: false,
          ),
          
          ...outboundFlights.map((flight) => FlightCard(
            flight: flight,
            isReturn: false,
            isSelected: booking.selectedOutboundFlight?.flightNumber == flight.flightNumber,
            onTap: () => onFlightSelected(flight, false),
          )),
          
          if (booking.isRoundTrip && returnFlights.isNotEmpty) ...[
            SizedBox(height: 40),
            DateHeader(
              title: 'Return',
              date: booking.returnDate!,
              isReturn: true,
            ),
            ...returnFlights.map((flight) => FlightCard(
              flight: flight,
              isReturn: true,
              isSelected: booking.selectedReturnFlight?.flightNumber == flight.flightNumber,
              onTap: () => onFlightSelected(flight, true),
            )),
          ],
          
          SizedBox(height: 100),
        ],
      ),
    );
  }
}