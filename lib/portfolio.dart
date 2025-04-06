import 'package:capital_market/portfolioclac.dart';
import 'package:flutter/material.dart';
import 'package:capital_market/mongodbhelper.dart';

class PortfolioPage extends StatefulWidget {
  const PortfolioPage({super.key});

  @override
  _PortfolioPageState createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> {
  List<Map<String, dynamic>> _portfolioData = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadPortfolioData();
  }

  Future<void> _loadPortfolioData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Close any existing connections first
      await MongoDBHelper.close();

      // Reinitialize the connection
      await MongoDBHelper.init();

      // Fetch portfolio entries
      final entries = await MongoDBHelper.getPortfolioEntries();
      
      // Process entries to consolidate by stock name
      Map<String, Map<String, dynamic>> consolidatedStocks = {};
      
      for (var entry in entries) {
        String stockName = entry['symbol'] ?? '';
        String securityName=entry['securityName'] ?? '';
        double price = (entry['price'] is num) ? (entry['price'] as num).toDouble() : 0.0;
        int volume = (entry['volume'] is num) ? (entry['volume'] as num).toInt() : 0;
        String transactionType = entry['transactionType'] ?? '';
        
        // For buy, add to portfolio; for sell, subtract
        int multiplier = transactionType.toLowerCase() == 'buy' ? 1 : -1;
        
        if (!consolidatedStocks.containsKey(stockName)) {
          consolidatedStocks[stockName] = {
            'name': stockName,
            'securityName': securityName,
            'shares': 0,
            'ltp': price, // Using latest transaction price as LTP
            'value': 0,
          };
        }
        
        var stock = consolidatedStocks[stockName]!;
        stock['shares'] = (stock['shares'] as int) + (volume * multiplier);
        
        // Update LTP with the most recent price
        stock['ltp'] = price;
        
        // Calculate current value
        stock['value'] = (stock['shares'] as int) * (stock['ltp'] as double);
      }
      
      // Filter out stocks with zero shares
      var activeStocks = consolidatedStocks.values
          .where((stock) => stock['shares'] > 0)
          .toList();

      setState(() {
        _portfolioData = activeStocks;
        _isLoading = false;
      });

      print('Loaded ${_portfolioData.length} active stocks');
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading portfolio: $e';
        _isLoading = false;
      });
      print(_errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Portfolio"),
        backgroundColor: Colors.blueGrey[900],
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadPortfolioData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadPortfolioData,
        child: _buildPortfolioContent(),
      ),
    );
  }

  Widget _buildPortfolioContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage,
              style: TextStyle(color: Colors.red),
            ),
            ElevatedButton(
              onPressed: _loadPortfolioData,
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    double totalValue = _portfolioData.fold(
      0, 
      (sum, item) => sum + (item["value"] as double)
    );

    return Column(
      children: [
        Card(
          margin: const EdgeInsets.all(10),
          child: ListTile(
            title: const Text(
              "Total Current Share Value",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              "Rs. ${totalValue.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        Expanded(
          child: _portfolioData.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.query_stats, size: 50, color: Colors.grey),
                      SizedBox(height: 10),
                      Text(
                        'No stocks in your portfolio yet',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                      Text(
                        'Add your first stock transaction',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
  itemCount: _portfolioData.length,
  itemBuilder: (context, index) {
    var item = _portfolioData[index];
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: InkWell( // Make the entire card clickable
        onTap: () {
          // Navigate to portfolio calculation page with the selected stock data
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PortfolioCalcScreen(
                stockName: item["securityName"],
                shares: item["shares"],
                value: item["value"],
                // You can pass additional data if needed
              ),
            ),
          );
        },
        child: ListTile(
          title: Text(
            item["name"],
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          subtitle: Text("${item["shares"]} Shares, LTP: ${item["ltp"]}"),
          trailing: Text(
            "Rs. ${item["value"].toStringAsFixed(2)}",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  },
),
        ),
      ],
    );
  }
}