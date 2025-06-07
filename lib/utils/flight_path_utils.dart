import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_maps/maps.dart';
import 'dart:math' as math;
import '../../models/airport.dart';

class FlightPathUtils {
  /// Generates a curved flight path between two airports
  static List<MapLatLng> generateCurvedPath(Airport departure, Airport destination) {
    return _generateCurvedPathSync([
      departure.latitude,
      departure.longitude,
      destination.latitude,
      destination.longitude,
    ]);
  }

  /// Internal method to generate curved path points
  static List<MapLatLng> _generateCurvedPathSync(List<double> args) {
    double startLat = args[0], startLon = args[1], endLat = args[2], endLon = args[3];
    List<MapLatLng> points = [];
    
    // Calculate midpoint
    double midLat = (startLat + endLat) / 2;
    double midLon = (startLon + endLon) / 2;
    
    // Calculate distance and offset for curve
    double distance = math.sqrt(math.pow(endLat - startLat, 2) + math.pow(endLon - startLon, 2));
    double offsetDistance = distance * 0.3;
    
    // Calculate perpendicular direction for curve
    double perpLat = -(endLon - startLon) / distance;
    double perpLon = (endLat - startLat) / distance;
    
    // Calculate control point for curve
    double controlLat = midLat + perpLat * offsetDistance;
    double controlLon = midLon + perpLon * offsetDistance;
    
    // Generate curve points using quadratic Bézier curve
    int numPoints = 100;
    for (int i = 0; i <= numPoints; i++) {
      double t = i / numPoints;
      double invT = 1 - t;
      
      // Quadratic Bézier formula
      double lat = invT * invT * startLat + 2 * invT * t * controlLat + t * t * endLat;
      double lon = invT * invT * startLon + 2 * invT * t * controlLon + t * t * endLon;
      
      points.add(MapLatLng(lat, lon));
    }
    
    return points;
  }

  /// Creates a set of MapPolyline for the flight path
  static Set<MapPolyline> buildFlightPath({
    required Airport? departure,
    required Airport? destination,
    Color? pathColor,
    double? pathWidth,
  }) {
    if (departure == null || destination == null) {
      return <MapPolyline>{};
    }
    
    final curvedPoints = generateCurvedPath(departure, destination);
    
    return <MapPolyline>{
      MapPolyline(
        points: curvedPoints,
        color: pathColor ?? Colors.red.shade400,
        width: pathWidth ?? 4,
      ),
    };
  }

  /// Calculate the center point between two airports for map focusing
  static MapLatLng calculateRouteCenter(Airport departure, Airport destination) {
    double centerLat = (departure.latitude + destination.latitude) / 2;
    double centerLng = (departure.longitude + destination.longitude) / 2;
    return MapLatLng(centerLat, centerLng);
  }

  /// Calculate appropriate zoom level for route display
  static double calculateRouteZoom(Airport departure, Airport destination) {
    // Calculate distance between airports
    double latDiff = (departure.latitude - destination.latitude).abs();
    double lngDiff = (departure.longitude - destination.longitude).abs();
    double maxDiff = math.max(latDiff, lngDiff);
    
    // Determine zoom level based on distance
    if (maxDiff > 50) return 2.0;
    if (maxDiff > 20) return 2.5;
    if (maxDiff > 10) return 3.0;
    if (maxDiff > 5) return 4.0;
    return 5.0;
  }
}