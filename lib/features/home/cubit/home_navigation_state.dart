import 'package:latlong2/latlong.dart';

class HomeNavigationState {
  final int tabIndex;
  final LatLng? centerMapPoint;
  final String? highlightedStationId;
  final DateTime? timestamp;

  HomeNavigationState({
    required this.tabIndex,
    this.centerMapPoint,
    this.highlightedStationId,
    this.timestamp,
  });

  HomeNavigationState copyWith({
    int? tabIndex,
    LatLng? centerMapPoint,
    String? highlightedStationId,
    DateTime? timestamp,
  }) {
    return HomeNavigationState(
      tabIndex: tabIndex ?? this.tabIndex,
      centerMapPoint: centerMapPoint ?? this.centerMapPoint,
      highlightedStationId: highlightedStationId ?? this.highlightedStationId,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
