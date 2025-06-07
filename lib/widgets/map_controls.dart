import 'package:flutter/material.dart';

class MapControls extends StatelessWidget {
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onCenterRoute;
  final bool showCenterRoute;

  const MapControls({
    Key? key,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onCenterRoute,
    this.showCenterRoute = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 80,
      left: 20,
      child: Column(
        children: [
          _buildControlButton(
            icon: Icons.add,
            onPressed: onZoomIn,
            tooltip: 'Zoom In',
          ),
          SizedBox(height: 12),
          _buildControlButton(
            icon: Icons.remove,
            onPressed: onZoomOut,
            tooltip: 'Zoom Out',
          ),
          if (showCenterRoute) ...[
            SizedBox(height: 12),
            _buildControlButton(
              icon: Icons.center_focus_strong,
              onPressed: onCenterRoute,
              tooltip: 'Center on Route',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey.shade100],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Container(
            width: 48,
            height: 48,
            child: Icon(
              icon,
              color: Colors.blue.shade700,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}

class FloatingResetButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String? tooltip;

  const FloatingResetButton({
    Key? key,
    required this.onPressed,
    this.tooltip = 'Reset to World View',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.blue.shade600],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: FloatingActionButton(
        heroTag: "reset_view",
        backgroundColor: Colors.transparent,
        elevation: 0,
        onPressed: onPressed,
        tooltip: tooltip,
        child: Icon(
          Icons.my_location,
          color: Colors.white,
        ),
      ),
    );
  }
}