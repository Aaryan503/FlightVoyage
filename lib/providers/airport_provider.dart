import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/airport.dart';
import '../models/flight_route.dart';

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

class AirportState {
  final List<Airport> airports;
  final bool isLoading;
  final Map<String, double?> temperatures;
  final bool temperaturesLoaded; 

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

//Fetching and Loading temperatures for the airports with a Fallback mechanism
  Future<void> loadTemperatures() async {
    if (state.isLoading || state.temperaturesLoaded) return;
    state = state.copyWith(isLoading: true);
    
    try {
      final Map<String, double?> newTemperatures = {};
      
      final List<Future<void>> temperatureFutures = airportsData.map((airport) async {
        try {
          final temperature = await _fetchTemperature(airport.latitude, airport.longitude);
          newTemperatures[airport.code] = temperature;
        } catch (e) {
          newTemperatures[airport.code] = null;
        }
      }).toList();

      await Future.wait(temperatureFutures);
      
      state = state.copyWith(
        temperatures: newTemperatures,
        temperaturesLoaded: true,
      );
      
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<double> _fetchTemperature(double lat, double lon) async {
    const apiKey = '68aab4c5a4e8af4f22dbf6f46289e543';
    const String baseUrl = 'https://api.openweathermap.org/data/2.5/weather';
  
    try {
      final url = Uri.parse('$baseUrl?lat=$lat&lon=$lon&appid=$apiKey&units=metric');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final temp = data['main']['temp'].toDouble();
        return temp;
      } else {
        return _getFallbackTemperature(lat);
      }
    } catch (e) {
      return _getFallbackTemperature(lat);
    }
  }

  double _getFallbackTemperature(double lat) {
    final temp = switch (lat.round()) {
      39 => 18.5,
      51 => 12.3,
      29 => 28.7,
      -34 => 22.1,
      _ => 20.0,
    };
    return temp;
  }

  Future<void> refreshTemperatures() async {

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