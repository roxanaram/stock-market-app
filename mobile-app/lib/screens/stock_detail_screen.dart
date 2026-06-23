import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/stock_service.dart';

class StockDetailScreen extends StatefulWidget {
  final String symbol;
  const StockDetailScreen({super.key, required this.symbol});

  @override
  State<StockDetailScreen> createState() => _StockDetailScreenState();
}

class _StockDetailScreenState extends State<StockDetailScreen> {
  final StockService _stockService = StockService();
  List<Map<String, dynamic>> _history = [];
  bool _loading = true;
  int _selectedDays = 30;
  String _selectedCurrency = 'USD';
  String _name = '';
  String _exchange = '';

  final List<String> _currencies = ['USD', 'EUR', 'GBP'];
  final Map<String, double> _currencyRates = {
    'USD': 1.0,
    'EUR': 0.92,
    'GBP': 0.79,
  };

  final List<Map<String, dynamic>> _timeRanges = [
    {'label': '1 Day', 'days': 1},
    {'label': '1 Month', 'days': 30},
    {'label': '3 Months', 'days': 90},
    {'label': '1 Year', 'days': 365},
  ];

  @override
  void initState() {
    super.initState();
    final entry = _stockService.getCatalogEntry(widget.symbol);
    _name = entry?['name'] ?? widget.symbol;
    _exchange = entry?['exchange'] ?? '';
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final history = await _stockService.getStockHistory(widget.symbol);
    setState(() {
      _history = history;
      _loading = false;
    });
  }

  Future<void> _openWebsite() async {
    final uri = Uri.parse(
      'https://roxanaram.github.io/stock-market-final/market.html',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openCompanyNews() async {
    final query = Uri.encodeComponent('$_name ${widget.symbol} stock news');
    final uri = Uri.parse('https://news.google.com/search?q=$query');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openMarketProfile() async {
    final uri = Uri.parse('https://finance.yahoo.com/quote/${widget.symbol}');
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

  String _fmt(double value) =>
      '$_currencySymbol${_convert(value).toStringAsFixed(2)}';

  Color _priceColor(double change) =>
      change >= 0 ? const Color(0xFF2ECC71) : const Color(0xFFFF5C5C);

  List<Map<String, dynamic>> get _filtered {
    if (_history.isEmpty) return [];
    final take = _selectedDays == 1 ? 2 : _selectedDays;
    return _history.take(take).toList().reversed.toList();
  }

  double get _close =>
      _history.isEmpty ? 0 : (_history.first['close'] ?? 0.0).toDouble();
  double get _open =>
      _history.isEmpty ? 0 : (_history.first['open'] ?? 0.0).toDouble();
  double get _change => _close - _open;
  double get _changePct => _open != 0 ? (_change / _open) * 100 : 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF08111F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF08111F),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFFF8FAFC)),
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
            Text(widget.symbol,
                style: const TextStyle(
                    color: Color(0xFFF8FAFC),
                    fontWeight: FontWeight.bold,
                    fontSize: 20)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_browser, color: Color(0xFF4CC9F0)),
            onPressed: _openWebsite,
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF4CC9F0)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price header
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
                        Text(_name,
                            style: const TextStyle(
                                color: Color(0xFFF8FAFC),
                                fontSize: 16,
                                fontWeight: FontWeight.w600)),
                        Text(_exchange,
                            style: const TextStyle(
                                color: Color(0xFFAAB6C8), fontSize: 12)),
                        const SizedBox(height: 8),
                        Text(_fmt(_close),
                            style: const TextStyle(
                                color: Color(0xFFF8FAFC),
                                fontSize: 32,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Row(children: [
                          Icon(
                              _change >= 0
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                              color: _priceColor(_change),
                              size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${_change >= 0 ? '+' : ''}${_fmt(_change)} (${_changePct.toStringAsFixed(2)}%)',
                            style: TextStyle(
                                color: _priceColor(_change),
                                fontSize: 14,
                                fontWeight: FontWeight.w600),
                          ),
                        ]),
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

                  const Text('Price History',
                      style: TextStyle(
                          color: Color(0xFFF8FAFC),
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _timeRanges.map((r) {
                        final sel = _selectedDays == r['days'];
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedDays = r['days']),
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
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
                            child: Text(r['label'],
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
                  ),

                  const SizedBox(height: 16),

                  if (_filtered.isNotEmpty)
                    Container(
                      height: 220,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF142238),
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.12)),
                      ),
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            getDrawingHorizontalLine: (_) =>
                                FlLine(color: Colors.white10, strokeWidth: 1),
                            getDrawingVerticalLine: (_) =>
                                FlLine(color: Colors.white10, strokeWidth: 1),
                          ),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 60,
                                getTitlesWidget: (val, meta) => Text(
                                  '$_currencySymbol${_convert(val).toStringAsFixed(0)}',
                                  style: const TextStyle(
                                      color: Color(0xFFAAB6C8), fontSize: 9),
                                ),
                              ),
                            ),
                            bottomTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                          ),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: _filtered
                                  .asMap()
                                  .entries
                                  .map((e) => FlSpot(
                                      e.key.toDouble(),
                                      _convert((e.value['close'] ?? 0.0)
                                          .toDouble())))
                                  .toList(),
                              isCurved: true,
                              color: _priceColor(_change),
                              barWidth: 2,
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                color: _priceColor(_change).withOpacity(0.1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 20),

                  const Text('Key Information',
                      style: TextStyle(
                          color: Color(0xFFF8FAFC),
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF142238),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.12)),
                    ),
                    child: Column(
                      children: [
                        _row('Open', _fmt(_open), true),
                        _row('Close', _fmt(_close), false),
                        _row('High', _fmt(((_history.isNotEmpty ? _history.first['high'] : 0.0) ?? 0.0).toDouble()), true),
                        _row('Low', _fmt(((_history.isNotEmpty ? _history.first['low'] : 0.0) ?? 0.0).toDouble()), false),
                        _row('Volume', '${((_history.isNotEmpty ? _history.first['volume'] : 0) ?? 0)}', true),
                        _row('Date', (_history.isNotEmpty ? _history.first['date'] ?? '' : '').toString().substring(0, 10), false),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text('Related News',
                      style: TextStyle(
                          color: Color(0xFFF8FAFC),
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _openCompanyNews,
                          icon: const Icon(Icons.article),
                          label: const Text('Company News'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _openMarketProfile,
                          icon: const Icon(Icons.public),
                          label: const Text('Market Profile'),
                        ),
                      ),
                    ],
                  ),


                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _openWebsite,
                      icon: const Icon(Icons.open_in_browser),
                      label: const Text('View Full Charts on Website'),
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
    );
  }

  Widget _row(String label, String value, bool shaded) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: shaded ? const Color(0xFF101C2F) : const Color(0xFF142238),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: Color(0xFFAAB6C8), fontSize: 14)),
          Text(value,
              style: const TextStyle(color: Color(0xFFF8FAFC), fontSize: 14)),
        ],
      ),
    );
  }
}
