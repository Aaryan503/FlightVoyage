import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade900,
              Colors.blue.shade600,
              Colors.blue.shade400,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildFlightIcon(),
              SizedBox(height: 30),
              _buildProgressIndicator(),
              SizedBox(height: 20),
              _buildMainTitle(),
              SizedBox(height: 10),
              _buildSubtitle(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFlightIcon() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(
        Icons.flight,
        size: 60,
        color: Colors.white,
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return CircularProgressIndicator(
      strokeWidth: 3,
      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
    );
  }

  Widget _buildMainTitle() {
    return Text(
      'Preparing Your Journey',
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildSubtitle() {
    return Text(
      'Loading airport data and weather information',
      style: TextStyle(
        fontSize: 16,
        color: Colors.white.withOpacity(0.8),
      ),
    );
  }
}