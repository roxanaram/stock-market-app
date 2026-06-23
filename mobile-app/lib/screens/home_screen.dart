import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/stock_service.dart';
import '../services/location_service.dart';
import 'stock_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StockService _stockService = StockService();
  final LocationService _locationService = LocationService();

  List<Map<String, dynamic>> _stocks = [];
  String _country = 'Germany';
  bool _loading = true;
  bool _autoDetected = false;
  String _selectedCurrency = 'USD';

  final List<String> _currencies = ['USD', 'EUR', 'GBP'];
  final Map<String, double> _currencyRates = {
    'USD': 1.0,
    'EUR': 0.92,
    'GBP': 0.79,
  };

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    setState(() => _loading = true);
    final country = await _locationService.getCountry();
    _country = country;
    _autoDetected = true;
    await _loadStocks();
  }

  Future<void> _loadStocks() async {
    setState(() => _loading = true);
    final stocks = await _stockService.getStocksForCountry(_country);
    setState(() {
      _stocks = stocks;
      _loading = false;
    });
  }

  void _changeCountry(String country) {
    setState(() => _country = country);
    _loadStocks();
  }

  Future<void> _openWebsite() async {
    final uri = Uri.parse(
      'https://roxanaram.github.io/stock-market-final/index.html',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
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
            const Text('StockScope',
                style: TextStyle(
                    color: Color(0xFFF8FAFC),
                    fontWeight: FontWeight.bold,
                    fontSize: 20)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.language, color: Color(0xFF4CC9F0)),
            onPressed: _openWebsite,
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFFAAB6C8)),
            onPressed: _loadStocks,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadStocks,
        color: const Color(0xFF4CC9F0),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 120,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: const Color(0xFF142238),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.12)),
                ),
                child: Image.asset(
                  'assets/images/stockscope_logo.png',
                  fit: BoxFit.contain,
                ),
              ),

              // Country selector
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
                    const Icon(Icons.location_on, color: Color(0xFF4CC9F0)),
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
                                    value: c,
                                    child: Text(c),
                                  ))
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
              if (_autoDetected)
                const Padding(
                  padding: EdgeInsets.only(top: 6, left: 4),
                  child: Text('Auto-detected — tap to change manually',
                      style: TextStyle(color: Color(0xFFAAB6C8), fontSize: 11)),
                ),

              const SizedBox(height: 18),

              // Currency selector
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

              Text('Market Snapshot — $_country',
                  style: const TextStyle(
                      color: Color(0xFFF8FAFC),
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              if (_loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFF4CC9F0))),
                )
              else if (_stocks.isEmpty)
                const Center(
                    child: Text('No data available',
                        style: TextStyle(color: Color(0xFFAAB6C8))))
              else
                ..._stocks.map((s) => _stockCard(s)),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _openWebsite,
                  icon: const Icon(Icons.open_in_browser),
                  label: const Text('View Detailed Charts on Website'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CC9F0),
                    foregroundColor: const Color(0xFF08111F),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stockCard(Map<String, dynamic> stock) {
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
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF142238),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(symbol,
                      style: const TextStyle(
                          color: Color(0xFFF8FAFC),
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                  Text(name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Color(0xFFAAB6C8), fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('$_currencySymbol${_convert(close).toStringAsFixed(2)}',
                    style: const TextStyle(
                        color: Color(0xFFF8FAFC),
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                Text('${pct >= 0 ? '+' : ''}${pct.toStringAsFixed(2)}%',
                    style: TextStyle(
                        color: color,
                        fontSize: 13,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
