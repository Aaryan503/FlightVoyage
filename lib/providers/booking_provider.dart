import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/airport.dart';
import '../models/booking.dart';

class BookingState {
  final Airport? departure;
  final Airport? destination;
  final bool isRoundTrip;
  final DateTime? departureDate;
  final DateTime? returnDate;
  final int passengers;
  final bool isConfirmed;
  final FlightInfo? selectedOutboundFlight;
  final FlightInfo? selectedReturnFlight;

  const BookingState({
    this.departure,
    this.destination,
    this.isRoundTrip = false,
    this.departureDate,
    this.returnDate,
    this.passengers = 1,
    this.isConfirmed = false,
    this.selectedOutboundFlight,
    this.selectedReturnFlight,
  });

  BookingState copyWith({
    Airport? departure,
    Airport? destination,
    bool? isRoundTrip,
    DateTime? departureDate,
    DateTime? returnDate,
    int? passengers,
    bool? isConfirmed,
    FlightInfo? selectedOutboundFlight,
    FlightInfo? selectedReturnFlight,
  }) {
    return BookingState(
      departure: departure ?? this.departure,
      destination: destination ?? this.destination,
      isRoundTrip: isRoundTrip ?? this.isRoundTrip,
      departureDate: departureDate ?? this.departureDate,
      returnDate: returnDate ?? this.returnDate,
      passengers: passengers ?? this.passengers,
      isConfirmed: isConfirmed ?? this.isConfirmed,
      selectedOutboundFlight: selectedOutboundFlight ?? this.selectedOutboundFlight,
      selectedReturnFlight: selectedReturnFlight ?? this.selectedReturnFlight,
    );
  }

  bool get isValid {
    return departure != null && 
           destination != null && 
           departureDate != null &&
           passengers >= 1 &&
           passengers <= 4 &&
           (!isRoundTrip || returnDate != null);
  }

  bool get areFlightsSelected {
    final outboundSelected = selectedOutboundFlight != null;
    final returnSelected = !isRoundTrip || selectedReturnFlight != null;
    return outboundSelected && returnSelected;
  }

  bool get canProceedToPayment {
    return isValid && areFlightsSelected;
  }
}

class BookingNotifier extends StateNotifier<BookingState> {
  BookingNotifier() : super(const BookingState());

  void setAirports(Airport departure, Airport destination) {
    state = state.copyWith(
      departure: departure,
      destination: destination,
    );
  }

  void setTripType(bool isRoundTrip) {
    state = state.copyWith(
      isRoundTrip: isRoundTrip,
      returnDate: isRoundTrip ? state.returnDate : null,
      selectedReturnFlight: isRoundTrip ? state.selectedReturnFlight : null,
    );
  }

  void setDepartureDate(DateTime date) {
    state = state.copyWith(departureDate: date);
  }

  void setReturnDate(DateTime? date) {
    state = state.copyWith(returnDate: date);
  }

  void setPassengers(int count) {
    if (count >= 1 && count <= 4) {
      state = state.copyWith(passengers: count);
    }
  }

  void selectOutboundFlight(FlightInfo flight) {
    state = state.copyWith(selectedOutboundFlight: flight);
  }

  void selectReturnFlight(FlightInfo flight) {
    state = state.copyWith(selectedReturnFlight: flight);
  }

  void clearFlightSelections() {
    state = state.copyWith(
      selectedOutboundFlight: null,
      selectedReturnFlight: null,
    );
  }

  void confirmBooking() {
    if (state.canProceedToPayment) {
      state = state.copyWith(isConfirmed: true);
    }
  }

  void resetBooking() {
    state = const BookingState();
  }

  void clearConfirmation() {
    state = state.copyWith(isConfirmed: false);
  }
}

final bookingProvider = StateNotifierProvider<BookingNotifier, BookingState>((ref) {
  return BookingNotifier();
});

final isBookingValidProvider = Provider<bool>((ref) {
  return ref.watch(bookingProvider).isValid;
});

final isBookingConfirmedProvider = Provider<bool>((ref) {
  return ref.watch(bookingProvider).isConfirmed;
});

final areFlightsSelectedProvider = Provider<bool>((ref) {
  return ref.watch(bookingProvider).areFlightsSelected;
});

final canProceedToPaymentProvider = Provider<bool>((ref) {
  return ref.watch(bookingProvider).canProceedToPayment;
});

final passengersProvider = Provider<int>((ref) {
  return ref.watch(bookingProvider).passengers;
});