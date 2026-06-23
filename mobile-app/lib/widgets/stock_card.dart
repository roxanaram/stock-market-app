import 'package:flutter/material.dart';

class StockCard extends StatelessWidget {
  final String symbol;
  final String exchange;
  final double close;
  final double open;
  final VoidCallback? onTap;

  const StockCard({
    super.key,
    required this.symbol,
    required this.exchange,
    required this.close,
    required this.open,
    this.onTap,
  });

  Color get _priceColor {
    final change = close - open;
    return change >= 0 ? const Color(0xFF00C897) : Colors.red;
  }

  double get _changePct {
    if (open == 0) return 0;
    return ((close - open) / open) * 100;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF161B22),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  symbol,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  exchange,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${close.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '${_changePct >= 0 ? '+' : ''}${_changePct.toStringAsFixed(2)}%',
                  style: TextStyle(
                    color: _priceColor,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}