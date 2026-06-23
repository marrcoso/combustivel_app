import 'package:flutter_bloc/flutter_bloc.dart';
import 'filter_state.dart';
import '../../stations/models/fuel_type.dart';

class FilterCubit extends Cubit<FilterState> {
  FilterCubit() : super(const FilterState());

  void updateSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  void updateSelectedFuel(FuelType? fuelType) {
    emit(state.copyWith(selectedFuel: fuelType, clearFuel: fuelType == null));
  }

  void updateMaxDistance(double? radius) {
    emit(state.copyWith(maxDistanceRadius: radius, clearDistance: radius == null));
  }

  void clearFilters() {
    emit(const FilterState());
  }
}
