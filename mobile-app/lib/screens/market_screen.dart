import 'package:flutter/material.dart';
import '../services/stock_service.dart';
import '../services/location_service.dart';
import 'stock_detail_screen.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  final StockService _stockService = StockService();
  final LocationService _locationService = LocationService();

  List<Map<String, dynamic>> _stocks = [];
  bool _loading = true;
  String _country = 'Germany';
  String _selectedCurrency = 'USD';
  bool _searchMode = false;
  final TextEditingController _searchController = TextEditingController();

  final List<String> _currencies = ['USD', 'EUR', 'GBP'];
  final Map<String, double> _currencyRates = {
    'USD': 1.0,
    'EUR': 0.92,
    'GBP': 0.79,
  };

  final List<Map<String, String>> _news = [
    {'title': 'Markets rally as inflation data comes in lower than expected', 'source': 'Reuters', 'time': '2h ago'},
    {'title': 'Tech stocks lead gains amid strong earnings reports', 'source': 'Bloomberg', 'time': '4h ago'},
    {'title': 'Central banks signal pause in rate hikes', 'source': 'Financial Times', 'time': '6h ago'},
    {'title': 'DAX hits record high as German economy shows resilience', 'source': 'Reuters', 'time': '8h ago'},
  ];

  @override
  void initState() {
    super.initState();
    _init();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    final country = await _locationService.getCountry();
    _country = country;
    await _loadCountryStocks();
  }

  Future<void> _loadCountryStocks() async {
    setState(() => _loading = true);
    final stocks = await _stockService.getStocksForCountry(_country);
    setState(() {
      _stocks = stocks;
      _loading = false;
    });
  }

  void _changeCountry(String country) {
    _searchController.clear();
    setState(() {
      _country = country;
      _searchMode = false;
    });
    _loadCountryStocks();
  }

  Future<void> _onSearchChanged() async {
    final q = _searchController.text.trim();
    if (q.isEmpty) {
      setState(() => _searchMode = false);
      _loadCountryStocks();
      return;
    }
    setState(() {
      _searchMode = true;
      _loading = true;
    });
    final results = await _stockService.search(q);
    setState(() {
      _stocks = results;
      _loading = false;
    });
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
    final countries = _locationService.supportedCountriesList;
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
            const Text('Market',
                style: TextStyle(
                    color: Color(0xFFF8FAFC),
                    fontWeight: FontWeight.bold,
                    fontSize: 20)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFFAAB6C8)),
            onPressed: _searchMode ? _onSearchChanged : _loadCountryStocks,
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar
            TextField(
              controller: _searchController,
              style: const TextStyle(color: Color(0xFFF8FAFC)),
              decoration: InputDecoration(
                hintText: 'Search by company, country, or symbol...',
                hintStyle: const TextStyle(color: Color(0xFFAAB6C8)),
                prefixIcon: const Icon(Icons.search, color: Color(0xFFAAB6C8)),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Color(0xFFAAB6C8)),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFF142238),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.12)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF4CC9F0)),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Country selector (hidden while searching)
            if (!_searchMode) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF142238),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.12)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.public, color: Color(0xFF4CC9F0)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _country,
                          isExpanded: true,
                          dropdownColor: const Color(0xFF142238),
                          style: const TextStyle(
                              color: Color(0xFFF8FAFC),
                              fontSize: 15,
                              fontWeight: FontWeight.w600),
                          icon: const Icon(Icons.arrow_drop_down,
                              color: Color(0xFFAAB6C8)),
                          items: countries
                              .map((c) => DropdownMenuItem(
                                  value: c, child: Text(c)))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) _changeCountry(val);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Currency
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 8),
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

              // News
              const Text('Latest News',
                  style: TextStyle(
                      color: Color(0xFFF8FAFC),
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ..._news.map((n) => _newsCard(n)),
              const SizedBox(height: 20),
            ],

            // Header
            Text(
                _searchMode
                    ? 'Search Results (${_stocks.length})'
                    : 'Stock Prices — $_country',
                style: const TextStyle(
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
            else if (_stocks.isEmpty)
              const Center(
                  child: Padding(
                padding: EdgeInsets.symmetric(vertical: 30),
                child: Text('No stocks found',
                    style: TextStyle(color: Color(0xFFAAB6C8))),
              ))
            else ...[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF101C2F),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Expanded(flex: 3, child: Text('Company', style: TextStyle(color: Color(0xFFAAB6C8), fontSize: 12))),
                    Expanded(flex: 2, child: Text('Price', textAlign: TextAlign.right, style: TextStyle(color: Color(0xFFAAB6C8), fontSize: 12))),
                    Expanded(flex: 2, child: Text('Change', textAlign: TextAlign.right, style: TextStyle(color: Color(0xFFAAB6C8), fontSize: 12))),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              ..._stocks.map((s) => _stockRow(s)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _newsCard(Map<String, String> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF142238),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item['title']!,
              style: const TextStyle(color: Color(0xFFF8FAFC), fontSize: 14)),
          const SizedBox(height: 6),
          Row(children: [
            Text(item['source']!,
                style: const TextStyle(color: Color(0xFF4CC9F0), fontSize: 12)),
            const SizedBox(width: 8),
            Text(item['time']!,
                style: const TextStyle(color: Color(0xFFAAB6C8), fontSize: 12)),
          ]),
        ],
      ),
    );
  }

  Widget _stockRow(Map<String, dynamic> stock) {
    final symbol = stock['symbol'] ?? '';
    final name = stock['name'] ?? '';
    final close = (stock['close'] ?? 0.0).toDouble();
    final open = (stock['open'] ?? 0.0).toDouble();
    final change = close - open;
    final pct = open != 0 ? (change / open) * 100 : 0.0;
    final color = _priceColor(change);

    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => StockDetailScreen(symbol: symbol))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF142238),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(symbol,
                      style: const TextStyle(
                          color: Color(0xFFF8FAFC),
                          fontWeight: FontWeight.bold)),
                  Text(name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Color(0xFFAAB6C8), fontSize: 11)),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                  '$_currencySymbol${_convert(close).toStringAsFixed(2)}',
                  textAlign: TextAlign.right,
                  style: const TextStyle(color: Color(0xFFF8FAFC))),
            ),
            Expanded(
              flex: 2,
              child: Text(
                  '${pct >= 0 ? '+' : ''}${pct.toStringAsFixed(2)}%',
                  textAlign: TextAlign.right,
                  style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
