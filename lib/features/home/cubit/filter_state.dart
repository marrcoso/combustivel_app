import '../../stations/models/fuel_type.dart';

class FilterState {
  final String searchQuery;
  final FuelType? selectedFuel;

  const FilterState({
    this.searchQuery = '',
    this.selectedFuel,
  });

  FilterState copyWith({
    String? searchQuery,
    FuelType? selectedFuel,
    bool clearFuel = false,
  }) {
    return FilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedFuel: clearFuel ? null : (selectedFuel ?? this.selectedFuel),
    );
  }
}
