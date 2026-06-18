import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/station_model.dart';
import '../repositories/station_repository.dart';
import 'station_state.dart';

class StationCubit extends Cubit<StationState> {
  final StationRepository _stationRepository;
  StreamSubscription<List<StationModel>>? _stationsSubscription;

  StationCubit({required StationRepository stationRepository})
      : _stationRepository = stationRepository,
        super(StationInitial()) {
    _init();
  }

  void _init() {
    emit(StationLoading());
    _stationsSubscription = _stationRepository.getStationsStream().listen(
      (stations) {
        emit(StationLoaded(stations));
      },
      onError: (error) {
        emit(StationError('Erro ao carregar postos: $error'));
      },
    );
  }

  @override
  Future<void> close() {
    _stationsSubscription?.cancel();
    return super.close();
  }
}
