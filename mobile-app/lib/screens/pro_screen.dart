import 'package:flutter/material.dart';

class ProScreen extends StatelessWidget {
  const ProScreen({super.key});

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
            const Text('Go Pro',
                style: TextStyle(
                    color: Color(0xFFF8FAFC),
                    fontWeight: FontWeight.bold,
                    fontSize: 20)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            // Pro badge
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4CC9F0), Color(0xFF0096FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Icon(Icons.star,
                    color: Color(0xFF08111F), size: 40),
              ),
            ),

            const SizedBox(height: 16),

            const Text('StockScope Pro',
                style: TextStyle(
                    color: Color(0xFFF8FAFC),
                    fontSize: 26,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Unlock the full power of StockScope',
                style: TextStyle(color: Color(0xFFAAB6C8), fontSize: 14),
                textAlign: TextAlign.center),

            const SizedBox(height: 32),

            _buildPricingCard(
              title: 'Monthly',
              price: '\$9.99',
              period: 'per month',
              highlighted: false,
            ),
            const SizedBox(height: 12),
            _buildPricingCard(
              title: 'Yearly',
              price: '\$59.99',
              period: 'per year — save 50%',
              highlighted: true,
            ),

            const SizedBox(height: 32),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text('What you get',
                  style: TextStyle(
                      color: Color(0xFFF8FAFC),
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),

            _buildFeatureRow(Icons.show_chart, 'Real-time stock data'),
            _buildFeatureRow(Icons.notifications_active, 'Price alerts'),
            _buildFeatureRow(Icons.article, 'Full news access'),
            _buildFeatureRow(Icons.history, 'Extended price history'),
            _buildFeatureRow(Icons.currency_exchange, 'Multi-currency support'),
            _buildFeatureRow(Icons.analytics, 'Advanced charts & analytics'),
            _buildFeatureRow(Icons.remove_red_eye, 'Unlimited watchlist'),
            _buildFeatureRow(Icons.support_agent, 'Priority support'),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Thanks for your interest in StockScope Pro!'),
                      backgroundColor: Color(0xFF2ECC71),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CC9F0),
                  foregroundColor: const Color(0xFF08111F),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Get Pro Now',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),

            const SizedBox(height: 12),

            const Text('Cancel anytime. No hidden fees.',
                style: TextStyle(color: Color(0xFFAAB6C8), fontSize: 12)),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingCard({
    required String title,
    required String price,
    required String period,
    required bool highlighted,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: highlighted
            ? const Color(0xFF4CC9F0).withOpacity(0.1)
            : const Color(0xFF142238),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: highlighted
              ? const Color(0xFF4CC9F0)
              : Colors.white.withOpacity(0.12),
          width: highlighted ? 2 : 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Color(0xFFF8FAFC),
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  if (highlighted) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CC9F0),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('BEST VALUE',
                          style: TextStyle(
                              color: Color(0xFF08111F),
                              fontSize: 10,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              Text(period,
                  style: const TextStyle(
                      color: Color(0xFFAAB6C8), fontSize: 12)),
            ],
          ),
          Text(price,
              style: TextStyle(
                  color: highlighted
                      ? const Color(0xFF4CC9F0)
                      : const Color(0xFFF8FAFC),
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF4CC9F0), size: 20),
          const SizedBox(width: 12),
          Text(text,
              style: const TextStyle(
                  color: Color(0xFFF8FAFC), fontSize: 14)),
        ],
      ),
    );
  }
}
