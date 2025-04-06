import 'package:flutter/material.dart';
import 'dart:math';
import 'mvocalc.dart';

class MVOScreen extends StatefulWidget {
  final List<Map<String, dynamic>> stockData;
  final int shares; // getting amount of shares that user has of this stock
  final double value; // value of stock in portfolio
  
  MVOScreen({
    required this.stockData,
    required this.shares,
    required this.value,
  });
  
  @override
  _MVOScreenState createState() => _MVOScreenState();
}

class _MVOScreenState extends State<MVOScreen> {
  double riskFreeRate = 0.01;
  Map<String, dynamic>? portfolioStats;
  List<double> predefinedRates = [0.01, 0.02, 0.03, 0.05, 0.10]; // 1%, 2%, 3%, 5%, 10%
  int selectedRateIndex = 0;
  bool showingMarketComparison = false;
  
  @override
  void initState() {
    super.initState();
    calculatePortfolio();
  }
  
  void calculatePortfolio() {
    setState(() {
      // Calculate based on user data (current implementation)
      portfolioStats = MVOCalculator.calculatePortfolio(widget.stockData, riskFreeRate);
      
      // If we want to show market comparison
      if (showingMarketComparison) {
        // Get market benchmark data (this would typically come from an API or database)
        // For now we'll simulate it with a modification of the user's data
        double marketReturn = portfolioStats!['expectedReturn'] * (0.8 + (Random().nextDouble() * 0.4));
        double marketStdDev = portfolioStats!['stdDev'] * (0.9 + (Random().nextDouble() * 0.2));
        double marketSharpe = (marketReturn - riskFreeRate) / marketStdDev;
        
        portfolioStats!['marketReturn'] = marketReturn;
        portfolioStats!['marketStdDev'] = marketStdDev;
        portfolioStats!['marketSharpe'] = marketSharpe;
        
        // Add performance comparison
        portfolioStats!['returnDiff'] = portfolioStats!['expectedReturn'] - marketReturn;
        portfolioStats!['riskDiff'] = portfolioStats!['stdDev'] - marketStdDev;
        portfolioStats!['sharpeDiff'] = portfolioStats!['sharpeRatio'] - marketSharpe;
      }
    });
  }
  
  void selectRiskFreeRate(int index) {
    setState(() {
      selectedRateIndex = index;
      riskFreeRate = predefinedRates[index];
    });
    calculatePortfolio();
  }
  
  void toggleMarketComparison() {
    setState(() {
      showingMarketComparison = !showingMarketComparison;
    });
    calculatePortfolio();
  }
  
  String formatPercentage(double value) {
    // Convert to percentage and format with 2 decimal places
    return "${(value * 100).toStringAsFixed(2)}%";
  }
  
  String formatRatio(double value) {
    // Format ratio with 2 decimal places
    return value.toStringAsFixed(2);
  }
  
  Color getPerformanceColor(double value, bool higherIsBetter) {
    if (value == 0) return Colors.grey;
    return (value > 0 && higherIsBetter) || (value < 0 && !higherIsBetter) 
        ? Colors.green 
        : Colors.red;
  }
  
  @override
  Widget build(BuildContext context) {
    if (portfolioStats == null) return Center(child: CircularProgressIndicator());
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blueGrey.shade50, Colors.white],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Portfolio Optimization",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey.shade800,
              ),
            ),
            SizedBox(height: 24),
            
            // Risk-Free Rate selection
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Risk-Free Rate:",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.blueGrey.shade600,
                  ),
                ),
                SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(
                      predefinedRates.length,
                      (index) => Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text("${(predefinedRates[index] * 100).toStringAsFixed(0)}%"),
                          selected: selectedRateIndex == index,
                          onSelected: (_) => selectRiskFreeRate(index),
                          selectedColor: Colors.blue,
                          labelStyle: TextStyle(
                            color: selectedRateIndex == index ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 16),
            
            // Market comparison toggle
            Row(
              children: [
                Text(
                  "Compare with Market",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.blueGrey.shade600,
                  ),
                ),
                SizedBox(width: 8),
                Switch(
                  value: showingMarketComparison,
                  onChanged: (value) {
                    toggleMarketComparison();
                  },
                  activeColor: Colors.blue,
                ),
              ],
            ),
            
            SizedBox(height: 16),
            
            // Portfolio stats cards
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
                children: _buildStats(),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  List<Widget> _buildStats() {
    List<Widget> cards = [];
    
    // Expected Return Card
    cards.add(_buildStatCard(
      title: "Expected Return",
      value: formatPercentage(portfolioStats!['expectedReturn']),
      icon: Icons.trending_up,
      color: Colors.blue,
      compareValue: showingMarketComparison ? portfolioStats!['returnDiff'] : null,
      compareLabel: "vs Market",
      higherIsBetter: true,
    ));
    
    // Risk (Std Dev) Card
    cards.add(_buildStatCard(
      title: "Risk (Volatility)",
      value: formatPercentage(portfolioStats!['stdDev']),
      icon: Icons.show_chart,
      color: Colors.orange,
      compareValue: showingMarketComparison ? portfolioStats!['riskDiff'] : null,
      compareLabel: "vs Market",
      higherIsBetter: false,
    ));
    
    // Sharpe Ratio Card
    cards.add(_buildStatCard(
      title: "Sharpe Ratio",
      value: formatRatio(portfolioStats!['sharpeRatio']),
      icon: Icons.speed,
      color: Colors.green,
      compareValue: showingMarketComparison ? portfolioStats!['sharpeDiff'] : null,
      compareLabel: "vs Market",
      higherIsBetter: true,
      description: "Return per unit of risk",
    ));
    
    // Portfolio Value Card
    cards.add(_buildStatCard(
      title: "Portfolio Value",
      value: "\$${widget.value.toStringAsFixed(2)}",
      icon: Icons.account_balance_wallet,
      color: Colors.purple,
      description: "${widget.shares} shares",
    ));
    
    return cards;
  }
  
  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String? description,
    double? compareValue,
    String? compareLabel,
    bool higherIsBetter = true,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.blueGrey.shade600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey.shade800,
              ),
            ),
            if (description != null) ...[
              SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blueGrey.shade400,
                ),
              ),
            ],
            if (compareValue != null) ...[
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    compareValue > 0 ? Icons.arrow_upward : Icons.arrow_downward,
                    color: getPerformanceColor(compareValue, higherIsBetter),
                    size: 12,
                  ),
                  SizedBox(width: 4),
                  Text(
                    "${compareValue > 0 ? '+' : ''}${formatPercentage(compareValue)}",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: getPerformanceColor(compareValue, higherIsBetter),
                    ),
                  ),
                  SizedBox(width: 4),
                  Text(
                    compareLabel!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blueGrey.shade400,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}