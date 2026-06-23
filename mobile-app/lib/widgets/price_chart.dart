import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class PriceChart extends StatelessWidget {
  final List<dynamic> history;
  final Color lineColor;

  const PriceChart({
    super.key,
    required this.history,
    required this.lineColor,
  });

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return const Center(
        child: Text(
          'No chart data available',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    final spots = history.asMap().entries.map((e) {
      return FlSpot(
        e.key.toDouble(),
        (e.value['close'] ?? 0.0).toDouble(),
      );
    }).toList();

    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(12),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            getDrawingHorizontalLine: (_) => FlLine(
              color: Colors.white10,
              strokeWidth: 1,
            ),
            getDrawingVerticalLine: (_) => FlLine(
              color: Colors.white10,
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 50,
                getTitlesWidget: (value, meta) => Text(
                  '\$${value.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
            bottomTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: lineColor,
              barWidth: 2,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: lineColor.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}