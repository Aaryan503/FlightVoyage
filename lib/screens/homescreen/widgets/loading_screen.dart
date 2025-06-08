import 'package:flutter/material.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with TickerProviderStateMixin {
  late AnimationController _flightController;
  late AnimationController _trailController;
  late Animation<double> _flightAnimation;
  late Animation<double> _trailOpacity;

  @override
  void initState() {
    super.initState();
    
    // Animation for movement
    _flightController = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    );
    
    // Animation for trail glow
    _trailController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    
    _flightAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _flightController,
      curve: Curves.easeInOut,
    ));
    
    _trailOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _trailController,
      curve: Curves.easeOut,
    ));
    
    _flightController.repeat();
    _trailController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _flightController.dispose();
    _trailController.dispose();
    super.dispose();
  }

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
        child: Column(
          children: [
            _buildWelcomeText(),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildAnimatedFlight(),
                    SizedBox(height: 50),
                    _buildProgressIndicator(),
                    SizedBox(height: 20),
                    _buildSubtitle(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeText() {
    return Padding(
      padding: EdgeInsets.only(top: 80),
      child: Text(
        'Welcome to FlightVoyage',
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildAnimatedFlight() {
    return Container(
      height: 200,
      width: double.infinity,
      child: AnimatedBuilder(
        animation: Listenable.merge([_flightAnimation, _trailOpacity]),
        builder: (context, child) {
          return CustomPaint(
            painter: FlightTrailPainter(
              progress: _flightAnimation.value,
              trailOpacity: _trailOpacity.value,
            ),
            child: Container(),
          );
        },
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return CircularProgressIndicator(
      strokeWidth: 3,
      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
    );
  }

  Widget _buildSubtitle() {
    return Text(
      'Loading airport data',
      style: TextStyle(
        fontSize: 16,
        color: Colors.white.withValues(alpha: .8),
      ),
    );
  }
}

class FlightTrailPainter extends CustomPainter {
  final double progress;
  final double trailOpacity;

  FlightTrailPainter({
    required this.progress,
    required this.trailOpacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double centerY = size.height / 2;
    final double flightX = size.width * progress;
    
    // Draw exhaust trail
    _drawExhaustTrail(canvas, size, flightX, centerY);
    
    // Draw flight icon
    _drawFlight(canvas, flightX, centerY);
  }

  void _drawExhaustTrail(Canvas canvas, Size size, double flightX, double centerY) {
    if (flightX < 80) return; // No trail if flight hasn't moved enough
    
    final Paint trailPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8 * trailOpacity)
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;
    
    final Paint fadePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5 * trailOpacity)
      ..strokeWidth = 30
      ..strokeCap = StrokeCap.round;
    
    final Paint lightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.25 * trailOpacity)
      ..strokeWidth = 40
      ..strokeCap = StrokeCap.round;
    
    double trailLength = (flightX * 0.8).clamp(0.0, size.width * 0.6);
    double startX = (flightX - trailLength).clamp(0.0, size.width);
    
    // Trail Lines
    canvas.drawLine(
      Offset(startX, centerY),
      Offset(flightX - 30, centerY),
      lightPaint,
    );
    
    canvas.drawLine(
      Offset(startX + 10, centerY),
      Offset(flightX - 30, centerY),
      fadePaint,
    );
    
    canvas.drawLine(
      Offset(startX + 20, centerY),
      Offset(flightX - 30, centerY),
      trailPaint,
    );
  }

  void _drawFlight(Canvas canvas, double flightX, double centerY) {
    final Paint flightPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    Path flightPath = Path();
    
    // Main body
    flightPath.moveTo(flightX - 40, centerY);
    flightPath.lineTo(flightX + 40, centerY - 5);
    flightPath.lineTo(flightX + 40, centerY + 5);
    flightPath.close();
    
    // Wings
    flightPath.moveTo(flightX - 15, centerY - 20);
    flightPath.lineTo(flightX + 15, centerY - 8);
    flightPath.lineTo(flightX - 5, centerY);
    flightPath.close();
    
    flightPath.moveTo(flightX - 15, centerY + 20);
    flightPath.lineTo(flightX + 15, centerY + 8);
    flightPath.lineTo(flightX - 5, centerY);
    flightPath.close();
    
    // Tail
    flightPath.moveTo(flightX - 40, centerY - 12);
    flightPath.lineTo(flightX - 20, centerY - 3);
    flightPath.lineTo(flightX - 30, centerY);
    flightPath.close();
    
    flightPath.moveTo(flightX - 40, centerY + 12);
    flightPath.lineTo(flightX - 20, centerY + 3);
    flightPath.lineTo(flightX - 30, centerY);
    flightPath.close();
    
    canvas.drawPath(flightPath, flightPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}