import 'package:capital_market/addloandetails.dart';
import 'package:capital_market/mongodbhelper.dart';
import 'package:capital_market/stockloan_db.dart';
import 'package:capital_market/testui.dart';
import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:flutter_typeahead/flutter_typeahead.dart';

class AddLoanPage extends StatefulWidget {
  final String collectionName;
  
  const AddLoanPage({Key? key, required this.collectionName}) : super(key: key);

  @override
  _AddLoanPageState createState() => _AddLoanPageState();
}

class _AddLoanPageState extends State<AddLoanPage> {
  final TextEditingController _loanAmountController = TextEditingController();
  final TextEditingController _loanTermController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();

  String? _loanAmountError;
  String? _loanTermError;
  String? _stockError;
  bool _isProcessing = false;
  late String selectedStockSymbol = '';
  
  @override
  void dispose() {
    _loanAmountController.dispose();
    _loanTermController.dispose();
    _stockController.dispose();
    super.dispose();
  }
  
  Future<void> _validateAndCheck() async {
    // Reset error messages
    setState(() {
      _loanAmountError = null;
      _loanTermError = null;
      _stockError = null;
      _isProcessing = true;
    });
    
    // Validate stock selection
    if (selectedStockSymbol.isEmpty) {
      setState(() {
        _stockError = 'Please select a stock';
        _isProcessing = false;
      });
      return;
    }
    
    // Validate loan amount
    if (_loanAmountController.text.isEmpty) {
      setState(() {
        _loanAmountError = 'Share amount cannot be empty';
        _isProcessing = false;
      });
      return;
    }
    
    double? loanAmount = double.tryParse(_loanAmountController.text);
    if (loanAmount == null || loanAmount <= 0) {
      setState(() {
        _loanAmountError = 'Please enter a valid share amount';
        _isProcessing = false;
      });
      return;
    }
    
    // Validate loan term
    if (_loanTermController.text.isEmpty) {
      setState(() {
        _loanTermError = 'Loan term cannot be empty';
        _isProcessing = false;
      });
      return;
    }
    
    int? loanTerm = int.tryParse(_loanTermController.text);
    if (loanTerm == null || loanTerm <= 0) {
      setState(() {
        _loanTermError = 'Please enter a valid loan term in months';
        _isProcessing = false;
      });
      return;
    }
    
    try {
      // Check loan eligibility by querying the database
      final stockData = await MongoDBHelperdb.getStockLoanEligibility(selectedStockSymbol);
      
      setState(() {
        _isProcessing = false;
      });
      
      if (stockData == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Stock $selectedStockSymbol not found in database'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      
      final loanEligibility = stockData['Loan Eligibility']?.toString().toLowerCase() ?? 'no';
      
      if (loanEligibility == 'yes') {
        // Stock is eligible for loan
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LoanDetailsPage(
              stockSymbol: selectedStockSymbol,
              stockData: stockData,
              loanAmount: loanAmount,
              loanTerm: loanTerm,
            ),
          ),
        );
      } else {
        // Stock is not eligible for loan
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Loan Not Available'),
            content: Text('$selectedStockSymbol has no loan eligibility.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Loan'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
                    errorText: _stockError,
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
                RegExp regExp = RegExp(r'\(([^)]*)\)');
                var match = regExp.firstMatch(suggestion);
                if (match != null && match.groupCount >= 1) {
                  setState(() {
                    selectedStockSymbol = match.group(1)!;
                  });
                  print('Selected stock symbol var: $selectedStockSymbol');
                }
              },
              controller: _stockController,
            ),
            SizedBox(height: 16),
            
            // Loan amount input
            TextField(
              controller: _loanAmountController,
              decoration: InputDecoration(
                labelText: 'Share Amount (\$)',
                errorText: _loanAmountError,
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            SizedBox(height: 16),
            
            // Loan term input
            TextField(
              controller: _loanTermController,
              decoration: InputDecoration(
                labelText: 'Loan Term (Months)',
                errorText: _loanTermError,
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calendar_today),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 24),
            
            // Check button
            ElevatedButton(
              onPressed: _isProcessing ? null : _validateAndCheck,
              child: _isProcessing 
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text('Check'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
