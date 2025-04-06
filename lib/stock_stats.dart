import 'package:flutter/material.dart';

class StatisticsTab extends StatelessWidget {
  final String stockSymbol;
  final Map<String, dynamic> statistics;
  
  const StatisticsTab({
    Key? key, 
    required this.stockSymbol,
    required this.statistics,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
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
            
          Card(
            elevation: 4,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Key Statistics for $stockSymbol',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Divider(),
                  _buildStatRow('Latest Price', 'NPR ${statistics['latestPrice']?.toStringAsFixed(2) ?? '0.00'}'),
                  _buildStatRow('Price Change', '${statistics['priceChange']?.toStringAsFixed(2) ?? '0.00'} (${statistics['percentChange']?.toStringAsFixed(2) ?? '0.00'}%)'),
                  _buildStatRow('Highest Price (30d)', 'NPR ${statistics['highestPrice']?.toStringAsFixed(2) ?? '0.00'}'),
                  _buildStatRow('Highest Date', '${statistics['highestDate'] ?? 'N/A'}'),
                  _buildStatRow('Lowest Price (30d)', 'NPR ${statistics['lowestPrice']?.toStringAsFixed(2) ?? '0.00'}'),
                  _buildStatRow('Lowest Date', '${statistics['lowestDate'] ?? 'N/A'}'),
                  _buildStatRow('Average Volume', '${statistics['averageVolume'] ?? '0'}'),
                ],
              ),
            ),
          ),
          
          SizedBox(height: 16),
          
          // Trading performance card
          Card(
            elevation: 4,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Technical Indicators',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Divider(),
                  _buildPriceStrengthIndicator(
                    'Price Strength', 
                    calculatePriceStrength(
                      statistics['latestPrice'] ?? 0.0, 
                      statistics['lowestPrice'] ?? 0.0, 
                      statistics['highestPrice'] ?? 0.0
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildStatRow(
                    'Market Phase', 
                    determineMarketPhase(statistics['percentChange'] ?? 0.0)
                  ),
                  _buildStatRow(
                    'Volatility', 
                    calculateVolatility(
                      statistics['highestPrice'] ?? 0.0, 
                      statistics['lowestPrice'] ?? 0.0, 
                      statistics['latestPrice'] ?? 0.0
                    )
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16)),
          Text(
            value, 
            style: TextStyle(
              fontSize: 16, 
              fontWeight: FontWeight.bold,
              color: value.contains('-') && value.contains('%') 
                  ? Colors.red 
                  : (value.contains('%') ? Colors.green : null),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPriceStrengthIndicator(String label, double strength) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 16)),
        SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: strength,
            minHeight: 20,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              strength < 0.25 
                  ? Colors.red 
                  : (strength < 0.5 
                      ? Colors.orange 
                      : (strength < 0.75 
                          ? Colors.yellow 
                          : Colors.green)),
            ),
          ),
        ),
        SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Min', style: TextStyle(fontSize: 12, color: Colors.grey)),
            Text('Average', style: TextStyle(fontSize: 12, color: Colors.grey)),
            Text('Max', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ],
    );
  }
  
  double calculatePriceStrength(double currentPrice, double lowPrice, double highPrice) {
    if (highPrice == lowPrice) return 0.5;
    return (currentPrice - lowPrice) / (highPrice - lowPrice);
  }
  
  String determineMarketPhase(double percentChange) {
    if (percentChange > 5) return 'Strong Uptrend';
    if (percentChange > 2) return 'Moderate Uptrend';
    if (percentChange >= 0) return 'Stable/Slight Uptrend';
    if (percentChange > -2) return 'Stable/Slight Downtrend';
    if (percentChange > -5) return 'Moderate Downtrend';
    return 'Strong Downtrend';
  }
  
  String calculateVolatility(double high, double low, double current) {
    if (high == 0 || low == 0) return 'N/A';
    
    // Calculate percentage range from high to low
    double range = ((high - low) / current) * 100;
    
    if (range > 20) return 'Very High';
    if (range > 15) return 'High';
    if (range > 10) return 'Moderate';
    if (range > 5) return 'Low';
    return 'Very Low';
  }
}