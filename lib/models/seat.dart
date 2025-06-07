class Seat {
  final String id;
  final int row;
  final String letter;
  final bool isOccupied;
  final bool isSelected;
  final double price;
  final bool isDisabled;
  final SeatType type;

  const Seat({
    required this.id,
    required this.row,
    required this.letter,
    this.isOccupied = false,
    this.isSelected = false,
    required this.price,
    this.isDisabled = false,
    this.type = SeatType.standard,
  });

  Seat copyWith({
    String? id,
    int? row,
    String? letter,
    bool? isOccupied,
    bool? isSelected,
    double? price,
    bool? isDisabled,
    SeatType? type,
  }) {
    return Seat(
      id: id ?? this.id,
      row: row ?? this.row,
      letter: letter ?? this.letter,
      isOccupied: isOccupied ?? this.isOccupied,
      isSelected: isSelected ?? this.isSelected,
      price: price ?? this.price,
      isDisabled: isDisabled ?? this.isDisabled,
      type: type ?? this.type,
    );
  }
}

enum SeatType {
  standard,
  disabled,
}