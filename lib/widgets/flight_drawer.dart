import "package:flutter/material.dart";

class FlightDrawer extends StatelessWidget {
  final VoidCallback navigateToFlightHistory;

  const FlightDrawer({
    Key? key,
    required this.navigateToFlightHistory}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade600, Colors.blue.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Container(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons.flight_takeoff,
                    size: 48,
                    color: Colors.white,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Flight Booking',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Your travel companion',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.map,
              color: Colors.blue.shade600,
            ),
            title: Text(
              'Airport Selection',
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
            selected: true,
            selectedTileColor: Colors.blue.shade50,
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            leading: Icon(
              Icons.history,
              color: Colors.blue.shade600,
            ),
            title: Text(
              'Flight History',
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: navigateToFlightHistory,
          ),
          Divider(),
          ListTile(
            leading: Icon(
              Icons.settings,
              color: Colors.grey.shade600,
            ),
            title: Text(
              'Profile & Settings',
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Settings screen coming soon!'),
                  backgroundColor: Colors.blue.shade600,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
