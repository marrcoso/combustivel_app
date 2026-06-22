import '../models/suggestion_model.dart';

abstract class SuggestionState {}

class SuggestionInitial extends SuggestionState {}

class SuggestionLoading extends SuggestionState {}

class SuggestionLoaded extends SuggestionState {
  final List<SuggestionModel> suggestions;

  SuggestionLoaded(this.suggestions);
}

class SuggestionError extends SuggestionState {
  final String message;

  SuggestionError(this.message);
}
