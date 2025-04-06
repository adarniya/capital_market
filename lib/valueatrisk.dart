import 'dart:math';
import 'package:flutter/material.dart';

class VaRCalculator extends StatefulWidget {
  final List<Map<String, dynamic>> stockData;

  const VaRCalculator({Key? key, required this.stockData}) : super(key: key);

  @override
  _VaRCalculatorState createState() => _VaRCalculatorState();
}

class _VaRCalculatorState extends State<VaRCalculator> {
  double _confidenceLevel = 0.95; // Default confidence level
  double _varResult = 0.0;
  
  // Available confidence level options
  final List<Map<String, dynamic>> _confidenceLevels = [
    {'label': '90%', 'value': 0.90},
    {'label': '95%', 'value': 0.95},
    {'label': '99%', 'value': 0.99},
    {'label': '99.9%', 'value': 0.999},
  ];

  @override
  void initState() {
    super.initState();
    // Calculate initial VaR with default confidence level
    _calculateVaR();
  }

  void _calculateVaR() {
    _varResult = _calculateVaRValue(widget.stockData, _confidenceLevel);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Value at Risk (VaR) Calculator',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Text('Select Confidence Level:'),
            const SizedBox(height: 8),
            
            // Confidence level selection with chips
            Wrap(
              spacing: 8,
              children: _confidenceLevels.map((level) {
                bool isSelected = level['value'] == _confidenceLevel;
                return ChoiceChip(
                  label: Text(level['label']),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _confidenceLevel = level['value'];
                        _calculateVaR();
                      });
                    }
                  },
                );
              }).toList(),
            ),
            
            const SizedBox(height: 24),
            
            // Display the calculated VaR
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Value at Risk (${(_confidenceLevel * 100).toStringAsFixed(1)}%)',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(_varResult * 100).toStringAsFixed(2)}%',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'With ${(_confidenceLevel * 100).toStringAsFixed(1)}% confidence, the maximum expected loss is ${(_varResult * 100).toStringAsFixed(2)}% over holding period.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Calculate Value at Risk (VaR) using the parametric method
  double _calculateVaRValue(List<Map<String, dynamic>> stockData, double confidenceLevel) {
    List<double> dailyReturns = _calculateDailyReturns(stockData);
    
    if (dailyReturns.isEmpty) return 0.0;
    
    // Calculate mean and standard deviation
    double mean = dailyReturns.reduce((a, b) => a + b) / dailyReturns.length;
    
    double variance = dailyReturns
        .map((r) => pow(r - mean, 2))
        .reduce((a, b) => a + b) / 
        dailyReturns.length;
    double stdDev = sqrt(variance);
    
    // Z-scores for common confidence levels
    double z = _getZScore(confidenceLevel);

    // Parametric VaR: VaR = -(mean - Z * stdDev)
    double varValue = -(mean - z * stdDev);

return varValue;
  }

  /// Calculate daily returns from stock data
  List<double> _calculateDailyReturns(List<Map<String, dynamic>> stockData) {
    List<double> dailyReturns = [];
    
    for (int i = 1; i < stockData.length; i++) {
      double prevClose = stockData[i - 1]['closePrice']?.toDouble() ?? 0.0;
      double currClose = stockData[i]['closePrice']?.toDouble() ?? 0.0;
      
      if (prevClose > 0) {
        double dailyReturn = (currClose - prevClose) / prevClose;
        dailyReturns.add(dailyReturn);
      }
    }
    
    return dailyReturns;
  }

  /// Returns the Z-Score for a given confidence level
  double _getZScore(double confidenceLevel) {
    Map<double, double> zScores = {
      0.90: 1.2816,
      0.95: 1.6449,
      0.99: 2.3263,
      0.999: 3.0902,
    };
    
    return zScores[confidenceLevel] ?? 1.6449; // Default to 95% confidence if not found
  }
}