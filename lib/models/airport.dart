class Airport {
  final String code;
  final String name;
  final String city;
  final double latitude;
  final double longitude;
  final double? temperature; // Make sure this property exists

  const Airport({
    required this.code,
    required this.name,
    required this.city,
    required this.latitude,
    required this.longitude,
    this.temperature,
  });

  // Add this copyWith method
  Airport copyWith({
    String? code,
    String? name,
    String? city,
    double? latitude,
    double? longitude,
    double? temperature,
  }) {
    return Airport(
      code: code ?? this.code,
      name: name ?? this.name,
      city: city ?? this.city,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      temperature: temperature ?? this.temperature,
    );
  }
}