// portfoliocalc.dart
import 'package:capital_market/mvoui.dart';
import 'package:capital_market/valueatrisk.dart';
import 'package:flutter/material.dart';
import 'package:capital_market/testconnection.dart';

class PortfolioCalcScreen extends StatefulWidget {
  final String stockName;
  final int shares;
  final double value;

  const PortfolioCalcScreen({
    Key? key, 
    required this.stockName,
    required this.shares,
    required this.value,
  }) : super(key: key);

  @override
  State<PortfolioCalcScreen> createState() => _PortfolioCalcScreenState();
}

class _PortfolioCalcScreenState extends State<PortfolioCalcScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> stockData = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchStockData();
  }

  Future<void> fetchStockData() async {
    await MongoDBHelper.initialize();
    // Use the stockName from the widget parameters
    stockData = await MongoDBHelper.getLatestTwoStockData(widget.stockName); 
    print("portfolio calc main $widget.stockName");
     print("portfolio calc main ${widget.stockName}"); 
    setState(() {}); // Rebuild after data fetch
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.stockName} - Analysis"),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: "MVO"),
            Tab(text: "VaR"),
          ],
        ),
      ),
      body: stockData.isEmpty
          ? Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                MVOScreen(
                  stockData: stockData,
                   shares: widget.shares,
                   value: widget.value,
                ),
                VaRCalculator(
                  stockData: stockData,
                  //shares: widget.shares,
                  //value: widget.value,
                ),
              ],
            ),
    );
  }
}