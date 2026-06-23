import 'package:flutter/material.dart';
import '../services/stock_service.dart';
import '../services/watchlist_store.dart';
import 'stock_detail_screen.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  final StockService _stockService = StockService();

  final WatchlistStore _store = WatchlistStore.instance;
  List<String> get _watchlist => _store.symbols;
  Map<String, Map<String, dynamic>> _stockData = {};
  bool _loading = true;
  String _selectedCurrency = 'USD';
  final TextEditingController _addController = TextEditingController();

  final List<String> _currencies = ['USD', 'EUR', 'GBP'];
  final Map<String, double> _currencyRates = {
    'USD': 1.0,
    'EUR': 0.92,
    'GBP': 0.79,
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _addController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (_watchlist.isEmpty) {
      setState(() {
        _stockData = {};
        _loading = false;
      });
      return;
    }
    setState(() => _loading = true);
    final stocks = await _stockService.getLatestForSymbols(_watchlist);
    final map = <String, Map<String, dynamic>>{};
    for (final s in stocks) {
      map[s['symbol'] as String] = s;
    }
    setState(() {
      _stockData = map;
      _loading = false;
    });
  }

  void _addStock() {
    final symbol = _addController.text.trim().toUpperCase();
    if (symbol.isEmpty) return;
    final entry = _stockService.getCatalogEntry(symbol);
    if (entry == null) {
      _snack('"$symbol" not found. Try AAPL, SAP, BMW, TSLA...', isError: true);
      return;
    }
    if (_watchlist.contains(symbol)) {
      _snack('$symbol is already in your watchlist.', isError: true);
      return;
    }
    setState(() {
      _store.add(symbol);
      _addController.clear();
    });
    _loadData();
    _snack('$symbol added to your watchlist.');
  }

  void _removeStock(String symbol) {
    setState(() {
      _store.remove(symbol);
      _stockData.remove(symbol);
    });
    _snack('$symbol removed from your watchlist.');
  }

  void _snack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor:
          isError ? const Color(0xFFFF5C5C) : const Color(0xFF2ECC71),
    ));
  }

  String get _currencySymbol {
    switch (_selectedCurrency) {
      case 'EUR': return 'EUR ';
      case 'GBP': return 'GBP ';
      default: return 'USD ';
    }
  }

  double _convert(double value) =>
      value * (_currencyRates[_selectedCurrency] ?? 1.0);

  Color _priceColor(double change) =>
      change >= 0 ? const Color(0xFF2ECC71) : const Color(0xFFFF5C5C);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF08111F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF08111F),
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF4CC9F0).withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text('S',
                    style: TextStyle(
                        color: Color(0xFF4CC9F0),
                        fontWeight: FontWeight.bold,
                        fontSize: 18)),
              ),
            ),
            const SizedBox(width: 8),
            const Text('Portfolio',
                style: TextStyle(
                    color: Color(0xFFF8FAFC),
                    fontWeight: FontWeight.bold,
                    fontSize: 20)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFFAAB6C8)),
            onPressed: _loadData,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF142238),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.12)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('My Watchlist',
                      style:
                          TextStyle(color: Color(0xFFAAB6C8), fontSize: 13)),
                  const SizedBox(height: 4),
                  Text('${_watchlist.length} stocks tracked',
                      style: const TextStyle(
                          color: Color(0xFFF8FAFC),
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Text('Currency',
                style: TextStyle(
                    color: Color(0xFFF8FAFC),
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              children: _currencies.map((c) {
                final sel = _selectedCurrency == c;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCurrency = c),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    decoration: BoxDecoration(
                      color: sel
                          ? const Color(0xFF4CC9F0)
                          : const Color(0xFF142238),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: sel
                              ? const Color(0xFF4CC9F0)
                              : Colors.white.withOpacity(0.12)),
                    ),
                    child: Text(c,
                        style: TextStyle(
                            color: sel
                                ? const Color(0xFF08111F)
                                : const Color(0xFFAAB6C8),
                            fontWeight: FontWeight.bold,
                            fontSize: 13)),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _addController,
                    style: const TextStyle(color: Color(0xFFF8FAFC)),
                    textCapitalization: TextCapitalization.characters,
                    onSubmitted: (_) => _addStock(),
                    decoration: InputDecoration(
                      hintText: 'Add symbol (e.g. MSFT, BMW)',
                      hintStyle: const TextStyle(color: Color(0xFFAAB6C8)),
                      filled: true,
                      fillColor: const Color(0xFF142238),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            BorderSide(color: Colors.white.withOpacity(0.12)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF4CC9F0)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _addStock,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CC9F0),
                    foregroundColor: const Color(0xFF08111F),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Add',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),

            const SizedBox(height: 20),

            const Text('Tracked Stocks',
                style: TextStyle(
                    color: Color(0xFFF8FAFC),
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(
                    child: CircularProgressIndicator(color: Color(0xFF4CC9F0))),
              )
            else if (_watchlist.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 30),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.show_chart, color: Color(0xFFAAB6C8), size: 48),
                      SizedBox(height: 12),
                      Text('Your watchlist is empty',
                          style:
                              TextStyle(color: Color(0xFFAAB6C8), fontSize: 16)),
                      SizedBox(height: 6),
                      Text('Add a stock symbol above to start tracking',
                          style:
                              TextStyle(color: Color(0xFFAAB6C8), fontSize: 13)),
                    ],
                  ),
                ),
              )
            else
              ..._watchlist.map((s) => _watchCard(s)),
          ],
        ),
      ),
    );
  }

  Widget _watchCard(String symbol) {
    final stock = _stockData[symbol];
    final close = stock != null ? (stock['close'] ?? 0.0).toDouble() : 0.0;
    final open = stock != null ? (stock['open'] ?? 0.0).toDouble() : 0.0;
    final name = stock != null ? (stock['name'] ?? symbol) : symbol;
    final change = close - open;
    final pct = open != 0 ? (change / open) * 100 : 0.0;
    final color = _priceColor(change);

    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => StockDetailScreen(symbol: symbol))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF142238),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF4CC9F0).withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  symbol.substring(0, symbol.length > 2 ? 2 : symbol.length),
                  style: const TextStyle(
                      color: Color(0xFF4CC9F0),
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(symbol,
                      style: const TextStyle(
                          color: Color(0xFFF8FAFC),
                          fontWeight: FontWeight.bold,
                          fontSize: 15)),
                  Text(name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Color(0xFFAAB6C8), fontSize: 12)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                    stock != null
                        ? '$_currencySymbol${_convert(close).toStringAsFixed(2)}'
                        : '--',
                    style: const TextStyle(
                        color: Color(0xFFF8FAFC),
                        fontWeight: FontWeight.bold,
                        fontSize: 15)),
                Text(
                    stock != null
                        ? '${pct >= 0 ? '+' : ''}${pct.toStringAsFixed(2)}%'
                        : '--',
                    style: TextStyle(
                        color: color,
                        fontSize: 13,
                        fontWeight: FontWeight.bold)),
              ],
            ),
            IconButton(
              icon:
                  const Icon(Icons.close, color: Color(0xFFAAB6C8), size: 18),
              onPressed: () => _removeStock(symbol),
            ),
          ],
        ),
      ),
    );
  }
}

