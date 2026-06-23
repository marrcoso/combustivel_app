import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

import '../../../home/cubit/filter_cubit.dart';
import '../../../home/cubit/filter_state.dart';
import '../../cubit/station_cubit.dart';
import '../../cubit/station_state.dart';
import '../../../auth/cubit/auth_cubit.dart';
import '../../../auth/cubit/auth_state.dart';
import '../widgets/station_card.dart';

class StationListTab extends StatelessWidget {
  final LatLng? currentPosition;

  const StationListTab({super.key, this.currentPosition});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilterCubit, FilterState>(
      builder: (context, filterState) {
        return BlocBuilder<StationCubit, StationState>(
          builder: (context, stationState) {
            if (stationState is StationLoading || stationState is StationInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (stationState is StationLoaded) {
              var stations = stationState.stations.where((s) {
                if (filterState.searchQuery.isNotEmpty && !s.name.toLowerCase().contains(filterState.searchQuery.toLowerCase())) {
                  return false;
                }
                if (filterState.selectedFuel != null) {
                  final hasFuel = s.prices.any((p) => p.fuelType == filterState.selectedFuel!.displayName && p.price > 0);
                  if (!hasFuel) return false;
                }
                if (filterState.maxDistanceRadius != null && currentPosition != null) {
                  final distance = Geolocator.distanceBetween(
                    currentPosition!.latitude,
                    currentPosition!.longitude,
                    s.latitude,
                    s.longitude,
                  );
                  if (distance > filterState.maxDistanceRadius! * 1000) {
                    return false;
                  }
                }
                return true;
              }).toList();

              final authState = context.watch<AuthCubit>().state;
              final favoriteStationId = authState is Authenticated ? authState.user.favoriteStationId : null;

              if (currentPosition != null || favoriteStationId != null) {
                stations.sort((a, b) {
                  if (a.id == favoriteStationId) return -1;
                  if (b.id == favoriteStationId) return 1;

                  if (currentPosition != null) {
                    final distA = Geolocator.distanceBetween(currentPosition!.latitude, currentPosition!.longitude, a.latitude, a.longitude);
                    final distB = Geolocator.distanceBetween(currentPosition!.latitude, currentPosition!.longitude, b.latitude, b.longitude);
                    return distA.compareTo(distB);
                  }
                  return 0;
                });
              }

              if (stations.isEmpty) {
                return const Center(child: Text('Nenhum posto encontrado.'));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: stations.length,
                itemBuilder: (context, index) {
                  final station = stations[index];
                  double? distance;
                  if (currentPosition != null) {
                    distance = Geolocator.distanceBetween(currentPosition!.latitude, currentPosition!.longitude, station.latitude, station.longitude);
                  }
                  return StationCard(station: station, distanceInMeters: distance, selectedFuel: filterState.selectedFuel);
                },
              );
            }

            return const Center(child: Text('Erro ao carregar postos.'));
          },
        );
      },
    );
  }
}
