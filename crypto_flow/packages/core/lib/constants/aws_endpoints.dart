/// AWS API Gateway REST endpoint paths.
///
/// All paths are relative to the API Gateway base URL configured in
/// [AppConfig.apiBaseUrl]. Every endpoint (except [health]) requires a
/// Cognito JWT Bearer token.
class AwsEndpoints {
  AwsEndpoints._();

  // Health
  static const health = '/health';

  // Portfolio — Holdings
  static const holdings = '/api/v1/portfolio/holdings';
  static String holding(String id) => '/api/v1/portfolio/holdings/$id';

  // Portfolio — Transactions
  static const transactions = '/api/v1/portfolio/transactions';

  // Portfolio — Summary
  static const portfolioSummary = '/api/v1/portfolio/summary';

  // Journal
  static const journalEntries = '/api/v1/journal/entries';
  static String journalEntry(String id) => '/api/v1/journal/entries/$id';
  static const journalStats = '/api/v1/journal/stats';

  // Alerts
  static const alerts = '/api/v1/alerts';
  static String alert(String id) => '/api/v1/alerts/$id';

  // Watchlist
  static const watchlist = '/api/v1/watchlist';
  static String watchlistSymbol(String symbol) => '/api/v1/watchlist/$symbol';
  static const watchlistReorder = '/api/v1/watchlist/reorder';

  // Notifications
  static const registerDevice = '/api/v1/notifications/register-device';
  static const unregisterDevice = '/api/v1/notifications/unregister-device';
  static const notificationPreferences = '/api/v1/notifications/preferences';

  // Widgets (lightweight, for iOS WidgetKit)
  static const widgetPortfolioSummary = '/api/v1/widgets/portfolio-summary';
  static const widgetWatchlistSummary = '/api/v1/widgets/watchlist-summary';

  // Reports
  static const reports = '/api/v1/reports';
  static const generateReport = '/api/v1/reports/generate';
}
