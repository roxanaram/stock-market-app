// Simple in-memory store that persists the watchlist across navigation
class WatchlistStore {
  WatchlistStore._internal();
  static final WatchlistStore instance = WatchlistStore._internal();

  final List<String> symbols = ['AAPL', 'TSLA', 'SAP'];

  bool contains(String symbol) => symbols.contains(symbol);

  void add(String symbol) {
    if (!symbols.contains(symbol)) symbols.add(symbol);
  }

  void remove(String symbol) {
    symbols.remove(symbol);
  }
}
