/// Sorting options for journal entries
enum JournalSort {
  /// Sort by date, newest first
  dateDesc,

  /// Sort by date, oldest first
  dateAsc,

  /// Sort by P&L, highest first
  pnlDesc,

  /// Sort by P&L, lowest first
  pnlAsc,

  /// Sort by risk/reward ratio, highest first
  rrDesc,
}

/// Extension methods for JournalSort
extension JournalSortX on JournalSort {
  /// Display name for UI
  String get displayName {
    switch (this) {
      case JournalSort.dateDesc:
        return 'Date (Newest)';
      case JournalSort.dateAsc:
        return 'Date (Oldest)';
      case JournalSort.pnlDesc:
        return 'P&L (Highest)';
      case JournalSort.pnlAsc:
        return 'P&L (Lowest)';
      case JournalSort.rrDesc:
        return 'R:R (Highest)';
    }
  }
}
