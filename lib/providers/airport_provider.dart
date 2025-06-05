import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/airport.dart';
import '../models/flight_route.dart';

// Static airport data
final airportsData = [
  const Airport(
    code: 'IAD',
    name: 'Dulles International',
    city: 'Washington DC',
    latitude: 38.9445,
    longitude: -77.4558,
  ),
  const Airport(
    code: 'LHR',
    name: 'Heathrow',
    city: 'London',
    latitude: 51.4700,
    longitude: -0.4543,
  ),
  const Airport(
    code: 'DEL',
    name: 'Indira Gandhi International',
    city: 'New Delhi',
    latitude: 28.5562,
    longitude: 77.1000,
  ),
  const Airport(
    code: 'SYD',
    name: 'Kingsford Smith',
    city: 'Sydney',
    latitude: -33.9399,
    longitude: 151.1753,
  ),
];

// State class to hold both airports and loading state
class AirportState {
  final List<Airport> airports;
  final bool isLoading;
  final Map<String, double?> temperatures;
  final bool temperaturesLoaded; // New field to track if all temperatures are loaded

  const AirportState({
    required this.airports,
    required this.isLoading,
    required this.temperatures,
    required this.temperaturesLoaded,
  });

  AirportState copyWith({
    List<Airport>? airports,
    bool? isLoading,
    Map<String, double?>? temperatures,
    bool? temperaturesLoaded,
  }) {
    return AirportState(
      airports: airports ?? this.airports,
      isLoading: isLoading ?? this.isLoading,
      temperatures: temperatures ?? this.temperatures,
      temperaturesLoaded: temperaturesLoaded ?? this.temperaturesLoaded,
    );
  }
}

class AirportNotifier extends StateNotifier<AirportState> {
  AirportNotifier() : super(AirportState(
    airports: airportsData,
    isLoading: false,
    temperatures: {},
    temperaturesLoaded: false,
  ));

  Future<void> loadTemperatures() async {
    if (state.isLoading || state.temperaturesLoaded) return;
    
    print('🔄 Starting temperature loading...');
    state = state.copyWith(isLoading: true);
    
    try {
      final Map<String, double?> newTemperatures = {};
      
      // Load all temperatures in parallel
      final List<Future<void>> temperatureFutures = airportsData.map((airport) async {
        try {
          print('📍 Fetching temperature for ${airport.code}');
          final temperature = await _fetchTemperature(airport.latitude, airport.longitude);
          print('🌡️ Got temperature for ${airport.code}: $temperature°C');
          newTemperatures[airport.code] = temperature;
        } catch (e) {
          print('❌ Error for ${airport.code}: $e');
          newTemperatures[airport.code] = null;
        }
      }).toList();

      // Wait for all temperatures to load
      await Future.wait(temperatureFutures);
      
      // Update state with all temperatures at once
      state = state.copyWith(
        temperatures: newTemperatures,
        temperaturesLoaded: true,
      );

      print('✅ All temperatures loaded: $newTemperatures');
      
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<double> _fetchTemperature(double lat, double lon) async {
    const apiKey = '68aab4c5a4e8af4f22dbf6f46289e543';
    const String baseUrl = 'https://api.openweathermap.org/data/2.5/weather';
  
    try {
      final url = Uri.parse('$baseUrl?lat=$lat&lon=$lon&appid=$apiKey&units=metric');
      
      print('🌐 Making API call to: $url');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final temp = data['main']['temp'].toDouble();
        print('🌐 API Success - Temperature: $temp°C');
        return temp;
      } else {
        print('⚠️ API Error: ${response.statusCode}');
        return _getFallbackTemperature(lat);
      }
    } catch (e) {
      print('❌ Network Error: $e');
      return _getFallbackTemperature(lat);
    }
  }

  double _getFallbackTemperature(double lat) {
    final temp = switch (lat.round()) {
      39 => 18.5, // Washington DC
      51 => 12.3, // London
      29 => 28.7, // New Delhi
      -34 => 22.1, // Sydney
      _ => 20.0,
    };
    print('🔄 Using fallback temperature: $temp°C for lat: $lat');
    return temp;
  }

  Future<void> refreshTemperatures() async {
    // Reset state and reload
    state = state.copyWith(
      temperatures: {},
      temperaturesLoaded: false,
    );
    await loadTemperatures();
  }
}

class RouteNotifier extends StateNotifier<FlightRoute?> {
  RouteNotifier() : super(null);

  void setRoute(Airport departure, Airport destination) {
    state = FlightRoute(departure: departure, destination: destination);
  }

  void clearRoute() {
    state = null;
  }
}

final airportProvider = StateNotifierProvider<AirportNotifier, AirportState>((ref) {
  return AirportNotifier();
});

final routeProvider = StateNotifierProvider<RouteNotifier, FlightRoute?>((ref) {
  return RouteNotifier();
});

// Computed providers for easier access
final airportsListProvider = Provider<List<Airport>>((ref) {
  return ref.watch(airportProvider).airports;
});

final airportLoadingProvider = Provider<bool>((ref) {
  return ref.watch(airportProvider).isLoading;
});

final temperaturesProvider = Provider<Map<String, double?>>((ref) {
  return ref.watch(airportProvider).temperatures;
});

final temperaturesLoadedProvider = Provider<bool>((ref) {
  return ref.watch(airportProvider).temperaturesLoaded;
});