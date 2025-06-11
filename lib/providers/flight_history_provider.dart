import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/flight_history_service.dart';
import '../models/flight_booking.dart';
import 'auth_provider.dart';

final flightHistoryServiceProvider = Provider<FlightHistoryService>((ref) {
  return FlightHistoryService();
});

class FlightHistoryState {
  final List<FlightBooking> bookings;
  final bool isLoading;
  final String? errorMessage;

  const FlightHistoryState({
    this.bookings = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  FlightHistoryState copyWith({
    List<FlightBooking>? bookings,
    bool? isLoading,
    String? errorMessage,
  }) {
    return FlightHistoryState(
      bookings: bookings ?? this.bookings,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Notifier for managing flight history state and methods to use flight history service
class FlightHistoryNotifier extends StateNotifier<FlightHistoryState> {
  final FlightHistoryService _service;
  final String? _userId;

  FlightHistoryNotifier(this._service, this._userId) 
    : super(const FlightHistoryState(isLoading: true)) {
    if (_userId != null) {
      loadFlightHistory();
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'User not authenticated',
      );
    }
  }

  /// Load flight history
  Future<void> loadFlightHistory() async {
    if (_userId == null) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'User not authenticated',
      );
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final bookings = await _service.getFlightHistory(_userId!);
      state = state.copyWith(
        bookings: bookings,
        isLoading: false,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Refresh flight history
  Future<void> refreshHistory() async {
    await loadFlightHistory();
  }
}

final flightHistoryProvider = StateNotifierProvider<FlightHistoryNotifier, FlightHistoryState>((ref) {
  final service = ref.watch(flightHistoryServiceProvider);
  final user = ref.watch(currentUserProvider);
  return FlightHistoryNotifier(service, user?.uid);
});

/// Provider for flight history stream (real-time updates)
final flightHistoryStreamProvider = StreamProvider<List<FlightBooking>>((ref) {
  final service = ref.watch(flightHistoryServiceProvider);
  final user = ref.watch(currentUserProvider);
  
  if (user == null) {
    return Stream.value(<FlightBooking>[]);
  }
  
  return service.getFlightHistoryStream(user.uid);
});