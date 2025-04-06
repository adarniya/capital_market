// import 'package:capital_market/StockDataDB.dart';
// import 'package:flutter/material.dart';

// class StockDetailPage extends StatefulWidget {
//   final String stockSymbol; // Stock symbol passed from previous page

//   StockDetailPage({required this.stockSymbol});

//   @override
//   _StockDetailPageState createState() => _StockDetailPageState();
// }

// class _StockDetailPageState extends State<StockDetailPage> {
//   Map<String, dynamic> _stockData = {};
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _fetchStockData();
//   }

//   // Fetch stock data when the page loads
//   _fetchStockData() async {
//     // Initialize MongoDB with the dynamic collection name passed from the navigation
//     await MongoDBHelper.initialize();

//     // Define the specific date you want to query for
//     String targetDate = "2025-03-24"; // Example date
//     var data = await MongoDBHelper.getStockDataByDate(widget.stockSymbol, targetDate);

//     setState(() {
//       _stockData = data;
//       _isLoading = false;
//     });
//   }

//   @override
//   void dispose() {
//     MongoDBHelper.closeConnection(); // Close connection when the page is disposed
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Stock Details")),
//       body: _isLoading
//           ? Center(child: CircularProgressIndicator())
//           : _stockData.isEmpty
//               ? Center(child: Text("No data available for this date"))
//               : Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text("Date: ${_stockData['date']}", style: TextStyle(fontSize: 18)),
//                       Text("Close Price: \$${_stockData['closePrice']}", style: TextStyle(fontSize: 18)),
//                       Text("High Price: \$${_stockData['highPrice']}", style: TextStyle(fontSize: 18)),
//                       Text("Low Price: \$${_stockData['lowPrice']}", style: TextStyle(fontSize: 18)),
//                       Text("Total Traded Quantity: ${_stockData['totalTradedQuantity']}", style: TextStyle(fontSize: 18)),
//                       Text("Total Traded Value: \$${_stockData['totalTradedValue']}", style: TextStyle(fontSize: 18)),
//                       Text("Total Trades: ${_stockData['totalTrades']}", style: TextStyle(fontSize: 18)),
//                     ],
//                   ),
//                 ),
//     );
//   }
// }
