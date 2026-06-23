import '../../stations/models/fuel_type.dart';

class FilterState {
  final String searchQuery;
  final FuelType? selectedFuel;
  final double? maxDistanceRadius;

  const FilterState({
    this.searchQuery = '',
    this.selectedFuel,
    this.maxDistanceRadius,
  });

  FilterState copyWith({
    String? searchQuery,
    FuelType? selectedFuel,
    bool clearFuel = false,
    double? maxDistanceRadius,
    bool clearDistance = false,
  }) {
    return FilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedFuel: clearFuel ? null : (selectedFuel ?? this.selectedFuel),
      maxDistanceRadius: clearDistance ? null : (maxDistanceRadius ?? this.maxDistanceRadius),
    );
  }
}
