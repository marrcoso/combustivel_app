import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'home_navigation_state.dart';

class HomeNavigationCubit extends Cubit<HomeNavigationState> {
  HomeNavigationCubit() : super(HomeNavigationState(tabIndex: 0));

  void changeTab(int index) {
    emit(HomeNavigationState(
      tabIndex: index,
      centerMapPoint: null,
      highlightedStationId: state.highlightedStationId,
      timestamp: DateTime.now(),
    ));
  }

  void showOnMap(LatLng point, String stationId) {
    emit(state.copyWith(tabIndex: 0, centerMapPoint: point, highlightedStationId: stationId, timestamp: DateTime.now()));
  }

  void highlightStation(String stationId) {
    emit(HomeNavigationState(
      tabIndex: state.tabIndex,
      centerMapPoint: null,
      highlightedStationId: stationId,
      timestamp: DateTime.now(),
    ));
  }

  void clearHighlight() {
    emit(HomeNavigationState(
      tabIndex: state.tabIndex,
      centerMapPoint: null,
      highlightedStationId: null,
      timestamp: DateTime.now(),
    ));
  }
}
