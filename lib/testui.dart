import 'package:flutter/material.dart';
import 'package:capital_market/testconnection.dart';
//import 'package:fl_chart/fl_chart.dart';


class StockDetailPageee extends StatefulWidget {
   final String stockSymbol;
     StockDetailPageee({required this.stockSymbol});
  @override
  _StockDetailPageState createState() => _StockDetailPageState();
}

class _StockDetailPageState extends State<StockDetailPageee> {
  List<Map<String, dynamic>> _stockData = [];
  bool _isLoading = true;
  String _stockSymbol = '';
   String name="Eastern Hydropower Limited";
  //List<Map<String, dynamic>> stockData = [];

  @override
  void initState() {
    super.initState(); 
  
      _stockSymbol = extractSecurityName(widget.stockSymbol);
       _fetchStockData();
  }

  _fetchStockData() async {
     print("Stock Symbol this valkuye is being send from another page: ${widget.stockSymbol}");
     print("Stock Symbol: '${widget.stockSymbol}'"); // The quotes will show if there are trailing spaces
print("Length: ${widget.stockSymbol.length}");
     print("Stock Symbol this valkuye is being send from another page converted: ${_stockSymbol}");
     print("Stock Symbol : '${widget.stockSymbol}'"); // The quotes will show if there are trailing spaces
print("Length of converted: ${_stockSymbol.length}");
    await MongoDBHelper.initialize();
    
    var data = await MongoDBHelper.getLatestTwoStockData(_stockSymbol);
    setState(() {
      _stockData = data;
      _isLoading = false;
    });
  }

  // Extract just the security name without the symbol in parentheses
String extractSecurityName(String fullText) {
  // Check if there's a parenthesis
  int openParenIndex = fullText.indexOf('(');
  
  if (openParenIndex != -1) {
    // Return everything before the opening parenthesis and trim any spaces
    return fullText.substring(0, openParenIndex).trim();
  } else {
    // If there's no parenthesis, return the original string
    return fullText.trim();
  }
}
  @override
  void dispose() {
    MongoDBHelper.closeConnection();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Stock Details")),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _stockData.length < 2
              ? Center(child: Text("Not enough data available "))
              : SingleChildScrollView(  // Added SingleChildScrollView here
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStockCard(),
                        SizedBox(height: 16),
                        _buildInfoContainer(),
                        SizedBox(height: 16),
                        _buildStockDetails(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildStockCard() {
    double todayClose = _extractDouble(_stockData[0]['closePrice']);
    double prevClose = _extractDouble(_stockData[1]['closePrice']);
    double change = todayClose - prevClose;
    double percentChange = (change / prevClose) * 100;
    bool isIncrease = change > 0;

  return Card(
  color: Colors.white,
  elevation: 4,
  child: Padding(
    padding: const EdgeInsets.all(16.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Wrap the Column in an Expanded widget to give it the available space
        Expanded(
          // You can adjust flex value if needed
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Make the Text widget wrap to multiple lines
              Text(
                _stockSymbol, 
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                overflow: TextOverflow.visible, // Allow overflow to be visible
                softWrap: true, // Enable text wrapping
              ),
              SizedBox(height: 8),
              Text("LTP:${todayClose.toStringAsFixed(2)}", style: TextStyle(fontSize: 18)),
            ],
          ),
        ),
        // Add some space between the columns
        SizedBox(width: 8),
        // Wrap the second Column in an Expanded widget with smaller flex 
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end, // Align to the right
            children: [
              Icon(isIncrease ? Icons.arrow_upward : Icons.arrow_downward,
                  color: isIncrease ? Colors.green : Colors.red),
              Text(
                "${change.toStringAsFixed(2)} (${percentChange.toStringAsFixed(2)}%)",
                style: TextStyle(
                  fontSize: 16,
                  color: isIncrease ? Colors.green : Colors.red,
                ),
                textAlign: TextAlign.right, // Align text to the right
              ),
            ],
          ),
        ),
      ],
    ),
  ),
);
  }

  Widget _buildInfoContainer() {
  if (_stockData.length < 2) {
    return Card(
      color: Colors.grey[200],
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Text("Not enough data for calculating Fear/Greed Index", style: TextStyle(fontSize: 18)),
        ),
      ),
    );
  }

  // Get today's and previous day's stock data
  var todayData = _stockData[0];
  var prevData = _stockData[1];

  // Extracting values for today's data (using the helper method for extraction)
  double todayClose = _extractDouble(todayData['closePrice']);
  double todayHigh = _extractDouble(todayData['highPrice']);
  double todayLow = _extractDouble(todayData['lowPrice']);
  int todayQuantity = _extractInt(todayData['totalTradedQuantity']);
  int todayTrades = _extractInt(todayData['totalTrades']);

  // Extracting values for previous day's data
  double prevClose = _extractDouble(prevData['closePrice']);
  double prevHigh = _extractDouble(prevData['highPrice']);
  double prevLow = _extractDouble(prevData['lowPrice']);
  int prevQuantity = _extractInt(prevData['totalTradedQuantity']);
  int prevTrades = _extractInt(prevData['totalTrades']);

  // Price-based Index Calculation
  double priceChange = (todayClose - prevClose) / prevClose * 100;  // Percentage change in close price
  double priceIndex = 50 + (priceChange / 2);  // Mapping to a 0-100 scale
  priceIndex = priceIndex.clamp(0, 100);  // Ensure it's within the range 0-100

  // Volume-based Index Calculation
  double volumeChange = (todayQuantity - prevQuantity) / prevQuantity * 100;  // Percentage change in traded quantity
  double volumeIndex = 50 + (volumeChange / 2);  // Mapping to a 0-100 scale
  volumeIndex = volumeIndex.clamp(0, 100);  // Ensure it's within the range 0-100

  // Trade Count-based Index Calculation
  double tradesChange = (todayTrades - prevTrades) / prevTrades * 100;  // Percentage change in number of trades
  double tradesIndex = 50 + (tradesChange / 2);  // Mapping to a 0-100 scale
  tradesIndex = tradesIndex.clamp(0, 100);  // Ensure it's within the range 0-100

  // Final Fear/Greed Index by averaging the price, volume, and trade index
  double fearGreedIndex = (priceIndex + volumeIndex + tradesIndex) / 3;
  fearGreedIndex = fearGreedIndex.clamp(0, 100);  // Ensure it's within the range 0-100

  // Display Fear/Greed Index and bar
  return Card(
    color: Colors.grey[200],
    elevation: 2,
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              "Fear/Greed Index",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 10),
          // Fear/Greed Bar and Value
          Row(
            children: [
              // Fear/Greed Bar
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    Container(
                      height: 20,
                      width: fearGreedIndex,  // Adjust width based on the fear/greed index
                      decoration: BoxDecoration(
                        color: fearGreedIndex < 50 ? Colors.red : Colors.green, // Red for fear, Green for greed
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10),
              // Display the Fear/Greed Index value
              Text(
                "${fearGreedIndex.toStringAsFixed(0)}", // Display the number without decimal
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: fearGreedIndex < 50 ? Colors.red : Colors.green,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          // Info about the index
          Text(
            fearGreedIndex < 50
                ? "The market is in Fear territory, indicating a possible downturn."
                : "The market is in Greed territory, indicating possible overconfidence.",
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    ),
  );
}

double _extractDouble(dynamic value) {
  if (value is Map) {
    return double.parse(value["\$numberDouble"]);
  }
  return value.toDouble();
}

int _extractInt(dynamic value) {
  if (value is Map) {
    return int.parse(value["\$numberInt"]);
  }
  return value.toInt();
}


  Widget _buildStockDetails() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Latest Stock Data", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            _buildDetailRow("Date", _stockData[0]['date']),
            _buildDetailRow("Close Price", _extractDouble(_stockData[0]['closePrice'])),
            _buildDetailRow("High Price", _extractDouble(_stockData[0]['highPrice'])),
            _buildDetailRow("Low Price", _extractDouble(_stockData[0]['lowPrice'])),
            _buildDetailRow("Traded Quantity", _extractInt(_stockData[0]['totalTradedQuantity'])),
            _buildDetailRow("Traded Value", _extractDouble(_stockData[0]['totalTradedValue'])),
            _buildDetailRow("Total Trades", _extractInt(_stockData[0]['totalTrades'])),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          Text(value.toString(), style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  // double _extractDouble(dynamic value) {
  //   if (value is Map) {
  //     return double.parse(value["\$numberDouble"]);
  //   }
  //   return value.toDouble();
  // }

  // int _extractInt(dynamic value) {
  //   if (value is Map) {
  //     return int.parse(value["\$numberInt"]);
  //   }
  //   return value.toInt();
  // }
}