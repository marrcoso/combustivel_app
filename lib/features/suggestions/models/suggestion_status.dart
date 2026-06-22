enum SuggestionStatus {
  pending,
  approved,
  rejected,
}

extension SuggestionStatusExtension on SuggestionStatus {
  String get value {
    switch (this) {
      case SuggestionStatus.pending:
        return 'pending';
      case SuggestionStatus.approved:
        return 'approved';
      case SuggestionStatus.rejected:
        return 'rejected';
    }
  }

  static SuggestionStatus fromString(String val) {
    switch (val) {
      case 'approved':
        return SuggestionStatus.approved;
      case 'rejected':
        return SuggestionStatus.rejected;
      default:
        return SuggestionStatus.pending;
    }
  }
}
