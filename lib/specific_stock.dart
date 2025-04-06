import 'package:flutter/material.dart';

class OverviewTab extends StatelessWidget {
  final String stockSymbol;
  final Map<String, dynamic> statistics;
  final List<Map<String, dynamic>> chartData;
  
  const OverviewTab({
    Key? key, 
    required this.stockSymbol,
    required this.statistics,
    required this.chartData,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Last updated info
          if (statistics['lastUpdated'] != null && statistics['lastUpdated'].isNotEmpty)
            Padding(
              padding: EdgeInsets.only(bottom: 16.0),
              child: Text(
                'Last Updated: ${statistics['lastUpdated']}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          
          // Stock Price Card
          Card(
            elevation: 4,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stockSymbol,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'NPR ${statistics['latestPrice']?.toStringAsFixed(2) ?? '0.00'}',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            statistics['percentChange'] >= 0 
                                ? Icons.arrow_upward 
                                : Icons.arrow_downward,
                            color: statistics['percentChange'] >= 0 
                                ? Colors.green 
                                : Colors.red,
                          ),
                          Text(
                            '${statistics['percentChange']?.toStringAsFixed(2) ?? '0.00'}%',
                            style: TextStyle(
                              fontSize: 18,
                              color: statistics['percentChange'] >= 0 
                                  ? Colors.green 
                                  : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          SizedBox(height: 16),
          
          // Chart Placeholder (you can replace with a real chart library)
          Card(
            elevation: 4,
            child: Container(
              height: 250,
              width: double.infinity,
              padding: EdgeInsets.all(16),
              child: chartData.isEmpty
                  ? Center(child: Text('No chart data available'))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Price History',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Expanded(
                          child: _buildPriceLine(),
                        ),
                      ],
                    ),
            ),
          ),
          
          SizedBox(height: 16),
          
          // Volume Card
          Card(
            elevation: 4,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Trading Summary',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildInfoRow('Average Volume', '${statistics['averageVolume'] ?? 0}'),
                  SizedBox(height: 8),
                  _buildInfoRow(
                    'Total Trades (Latest)', 
                    chartData.isNotEmpty 
                        ? '${chartData.last['trades'] ?? 0}'
                        : '0'
                  ),
                  SizedBox(height: 8),
                  _buildInfoRow(
                    'Total Volume (Latest)', 
                    chartData.isNotEmpty 
                        ? '${chartData.last['volume'] ?? 0}'
                        : '0'
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  
  // Basic visual representation of price trend
  Widget _buildPriceLine() {
    if (chartData.isEmpty) {
      return Center(child: Text('No data available'));
    }
    
    // Extract close prices
    List<double> prices = chartData
        .map((data) => (data['close'] ?? 0.0) as double)
        .toList();
    
    // Find min and max for scaling
    double minPrice = prices.reduce((a, b) => a < b ? a : b);
    double maxPrice = prices.reduce((a, b) => a > b ? a : b);
    double range = maxPrice - minPrice;
    
    // Padding to avoid drawing at the very edges
    double padding = range * 0.1;
    maxPrice += padding;
    minPrice -= padding;
    range = maxPrice - minPrice;
    
    return CustomPaint(
      size: Size.infinite,
      painter: PriceChartPainter(
        prices: prices,
        minPrice: minPrice,
        maxPrice: maxPrice,
        lineColor: Colors.blue,
      ),
    );
  }
}

// Custom painter for a simple line chart
class PriceChartPainter extends CustomPainter {
  final List<double> prices;
  final double minPrice;
  final double maxPrice;
  final Color lineColor;
  
  PriceChartPainter({
    required this.prices,
    required this.minPrice,
    required this.maxPrice,
    required this.lineColor,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    if (prices.isEmpty) return;
    
    final Paint paint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    
    final double width = size.width;
    final double height = size.height;
    final double xStep = width / (prices.length - 1);
    
    final path = Path();
    path.moveTo(0, height - ((prices[0] - minPrice) / (maxPrice - minPrice) * height));
    
    for (int i = 1; i < prices.length; i++) {
      final double x = i * xStep;
      final double normalizedPrice = (prices[i] - minPrice) / (maxPrice - minPrice);
      final double y = height - (normalizedPrice * height);
      path.lineTo(x, y);
    }
    
    canvas.drawPath(path, paint);
    
    // Draw reference lines
    final Paint gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    
    // Horizontal reference lines (3 lines)
    for (int i = 1; i <= 3; i++) {
      final double y = height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(width, y), gridPaint);
      
      // Draw price labels
      final double price = maxPrice - ((maxPrice - minPrice) * i / 4);
      final TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: price.toStringAsFixed(2),
          style: TextStyle(color: Colors.grey, fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(5, y - 12));
    }
  }
  
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}