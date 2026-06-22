import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'suggestion_state.dart';
import '../repositories/suggestion_repository.dart';

class SuggestionCubit extends Cubit<SuggestionState> {
  final SuggestionRepository _suggestionRepository;
  StreamSubscription? _suggestionSubscription;

  SuggestionCubit({required SuggestionRepository suggestionRepository})
      : _suggestionRepository = suggestionRepository,
        super(SuggestionInitial());

  void loadPendingSuggestions() {
    emit(SuggestionLoading());
    _suggestionSubscription?.cancel();
    _suggestionSubscription = _suggestionRepository.getPendingSuggestions().listen(
      (suggestions) {
        emit(SuggestionLoaded(suggestions));
      },
      onError: (e) {
        emit(SuggestionError(e.toString()));
      },
    );
  }

  Future<void> approveSuggestion(String suggestionId) async {
    try {
      await _suggestionRepository.updateSuggestionStatus(suggestionId, 'approved');
    } catch (e) {
      emit(SuggestionError('Erro ao aprovar: $e'));
    }
  }

  Future<void> rejectSuggestion(String suggestionId) async {
    try {
      await _suggestionRepository.updateSuggestionStatus(suggestionId, 'rejected');
    } catch (e) {
      emit(SuggestionError('Erro ao rejeitar: $e'));
    }
  }

  @override
  Future<void> close() {
    _suggestionSubscription?.cancel();
    return super.close();
  }
}
