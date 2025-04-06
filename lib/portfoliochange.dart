import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'mongodbhelper.dart';

class PortfolioChangeScreen extends StatefulWidget {
  @override
  _PortfolioChangeScreenState createState() => _PortfolioChangeScreenState();
}

class _PortfolioChangeScreenState extends State<PortfolioChangeScreen> {
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _unitsController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  String _selectedTransactionType = 'Buy';

  // List of transaction types
  final List<String> _transactionTypes = ['Buy', 'Sell'];

  @override
  void initState() {
    super.initState();
    // Ensure MongoDB is initialized when the screen loads
    _initializeMongoDB();
  }

  Future<void> _initializeMongoDB() async {
    try {
      await MongoDBHelper.init();
    } catch (e) {
      _showErrorDialog('Failed to initialize database: $e');
    }
  }

  // Date picker method
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Portfolio Modification")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stock Symbol Typeahead
              Text("Stock Symbol", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              TypeAheadField<String>(
                suggestionsCallback: (query) async {
                  return await MongoDBHelper.getStockSuggestions(query);
                },
                builder: (context, controller, focusNode) {
                  return TextField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Search Stock Symbol',
                    ),
                  );
                },
                itemBuilder: (context, suggestion) {
                  return ListTile(
                    title: Text(suggestion),
                  );
                },
                onSelected: (suggestion) {
                  _stockController.text = suggestion;
                },
                controller: _stockController,
              ),
              
              SizedBox(height: 16),
              
              // Stock Price Input
              Text("Stock Price", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              TextField(
                controller: _priceController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter Price',
                  prefixText: '\$ ',
                ),
              ),
              
              SizedBox(height: 16),
              
              // Stock Units Input
              Text("Number of Units", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              TextField(
                controller: _unitsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter Units',
                ),
              ),
              
              SizedBox(height: 16),
              
              // Date Picker
              Text("Transaction Date", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      DateFormat('yyyy-MM-dd').format(_selectedDate),
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _selectDate(context),
                    child: Text('Select Date'),
                  ),
                ],
              ),
              
              SizedBox(height: 16),
              
              // Transaction Type Dropdown
              Text("Transaction Type", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedTransactionType,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: _transactionTypes.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedTransactionType = newValue!;
                  });
                },
              ),
              
              SizedBox(height: 20),
              
              // Submit Button
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Validate and process the input
                    _submitPortfolioChange();
                  },
                  child: Text("Submit Portfolio Change"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitPortfolioChange() async {
    // Validate inputs
    if (_stockController.text.isEmpty) {
      _showErrorDialog('Please select a stock symbol');
      return;
    }

    if (_priceController.text.isEmpty) {
      _showErrorDialog('Please enter the stock price');
      return;
    }

    if (_unitsController.text.isEmpty) {
      _showErrorDialog('Please enter the number of units');
      return;
    }

    try {
      // Extract both stock name and symbol from the suggestion
      Map<String, String> stockInfo = _extractStockInfo(_stockController.text);
      print("stock controller $stockInfo");
      String symbol = stockInfo['symbol']!;
      String securityName = stockInfo['securityName']!;
      print("stock symbol $symbol");
      print("stock name $securityName");

      // Call the MongoDB helper method to add the portfolio entry
      await MongoDBHelper.addPortfolioEntry(
        transactionType: _selectedTransactionType,
        symbol: symbol,
        securityName: securityName,  // Add the security name here
        price: _priceController.text,
        volume: _unitsController.text,
        date: _selectedDate.toIso8601String(),
      );

      // Show success dialog
      _showSuccessDialog();

      // Clear the form after successful submission
      _clearForm();
    } catch (e) {
      // Show error dialog if submission fails
      _showErrorDialog('Failed to submit portfolio change: $e');
    }
  }

  // Helper method to extract stock symbol and name from the suggestion

Map<String, String> _extractStockInfo(String suggestion) {
  print("Original input: $suggestion"); // Debug print to see exact input
  
  // Extract the name and symbol from "Security Name (Symbol)"
  RegExp regex = RegExp(r'(.*?)\s*\(([^)]+)\)');
  final match = regex.firstMatch(suggestion);
  
  print("Match found: ${match != null}"); // Debug print to check if match was found
  
  if (match != null && match.groupCount >= 2) {
    String securityName = match.group(1)!.trim();
    String symbol = match.group(2)!.trim();
    print("Extracted: Name=$securityName, Symbol=$symbol"); // Debug print of extracted values
    return {'securityName': securityName, 'symbol': symbol};
  } else {
    // If no match, try a different approach
    // Let's check if the string contains parentheses at all
    if (suggestion.contains('(') && suggestion.contains(')')) {
      int openParen = suggestion.lastIndexOf('(');
      int closeParen = suggestion.indexOf(')', openParen);
      
      if (openParen > 0 && closeParen > openParen) {
        String securityName = suggestion.substring(0, openParen).trim();
        String symbol = suggestion.substring(openParen + 1, closeParen).trim();
        print("Extracted (manual): Name=$securityName, Symbol=$symbol"); // Debug print of manually extracted values
        return {'securityName': securityName, 'symbol': symbol};
      }
    }
    
    print("No match found, using defaults"); // Debug print for no match
    return {'securityName': suggestion, 'symbol': suggestion};
  }
}

  void _clearForm() {
    _stockController.clear();
    _priceController.clear();
    _unitsController.clear();
    setState(() {
      _selectedDate = DateTime.now();
      _selectedTransactionType = 'Buy';
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text('Portfolio change recorded successfully!'),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    // Close database connection when the screen is disposed
    MongoDBHelper.close();
    
    // Dispose controllers
    _stockController.dispose();
    _priceController.dispose();
    _unitsController.dispose();
    
    super.dispose();
  }
}