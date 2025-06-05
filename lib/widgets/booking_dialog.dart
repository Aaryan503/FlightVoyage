import 'package:flutter/material.dart';
import '../models/airport.dart';

class BookingDialog extends StatefulWidget {
  final Airport departure;
  final Airport destination;

  const BookingDialog({
    Key? key,
    required this.departure,
    required this.destination,
  }) : super(key: key);

  @override
  _BookingDialogState createState() => _BookingDialogState();
}

class _BookingDialogState extends State<BookingDialog> {
  bool isRoundTrip = false;
  DateTime? departureDate;
  DateTime? returnDate;

  Future<void> _selectDepartureDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
      helpText: 'Select Departure Date',
    );
    if (picked != null) {
      setState(() {
        departureDate = picked;
        // If return date is before departure date, clear it
        if (returnDate != null && returnDate!.isBefore(picked)) {
          returnDate = null;
        }
      });
    }
  }

  Future<void> _selectReturnDate() async {
    final DateTime firstDate = departureDate ?? DateTime.now().add(Duration(days: 1));
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: firstDate.add(Duration(days: 1)),
      firstDate: firstDate,
      lastDate: DateTime.now().add(Duration(days: 365)),
      helpText: 'Select Return Date',
    );
    if (picked != null) {
      setState(() {
        returnDate = picked;
      });
    }
  }

  void _bookFlight() {
    if (departureDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a departure date'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (isRoundTrip && returnDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a return date'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Close dialog and show confirmation
    Navigator.of(context).pop();
    
    String message = isRoundTrip 
        ? 'Round trip booked from ${widget.departure.city} to ${widget.destination.city}!\nDeparture: ${_formatDate(departureDate!)}\nReturn: ${_formatDate(returnDate!)}'
        : 'One-way flight booked from ${widget.departure.city} to ${widget.destination.city}!\nDeparture: ${_formatDate(departureDate!)}';
        
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 4),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.flight_takeoff, color: Colors.blue),
          SizedBox(width: 8),
          Text('Book Flight'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Route Info
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.flight_takeoff, size: 16, color: Colors.blue),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${widget.departure.city} (${widget.departure.code})',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    widget.departure.name,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.flight_land, size: 16, color: Colors.blue),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${widget.destination.city} (${widget.destination.code})',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    widget.destination.name,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 20),
            
            // Trip Type Selection
            Text(
              'Trip Type',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<bool>(
                    title: Text('One Way'),
                    value: false,
                    groupValue: isRoundTrip,
                    onChanged: (value) {
                      setState(() {
                        isRoundTrip = false;
                        returnDate = null;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                ),
                Expanded(
                  child: RadioListTile<bool>(
                    title: Text('Round Trip'),
                    value: true,
                    groupValue: isRoundTrip,
                    onChanged: (value) {
                      setState(() {
                        isRoundTrip = true;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 20),
            
            // Date Selection
            Text(
              'Select Dates',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            
            // Departure Date
            ListTile(
              leading: Icon(Icons.calendar_today, color: Colors.blue),
              title: Text('Departure Date'),
              subtitle: Text(
                departureDate != null 
                    ? _formatDate(departureDate!)
                    : 'Select departure date',
                style: TextStyle(
                  color: departureDate != null ? Colors.black87 : Colors.grey,
                ),
              ),
              onTap: _selectDepartureDate,
              contentPadding: EdgeInsets.zero,
            ),
            
            // Return Date (only for round trip)
            if (isRoundTrip)
              ListTile(
                leading: Icon(Icons.calendar_today, color: Colors.orange),
                title: Text('Return Date'),
                subtitle: Text(
                  returnDate != null 
                      ? _formatDate(returnDate!)
                      : 'Select return date',
                  style: TextStyle(
                    color: returnDate != null ? Colors.black87 : Colors.grey,
                  ),
                ),
                onTap: departureDate != null ? _selectReturnDate : null,
                contentPadding: EdgeInsets.zero,
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _bookFlight,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          child: Text('Book Flight'),
        ),
      ],
    );
  }
}