import 'package:capital_market/global.dart';
import 'package:capital_market/mongodbhelper.dart';
import 'package:capital_market/stockloan_db.dart';
import 'package:capital_market/testui.dart';
import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';

class LoanDetailsPage extends StatefulWidget {
  final String stockSymbol;
  final Map<String, dynamic> stockData;
  final double loanAmount; // Number of shares
  final int loanTerm;
  
  const LoanDetailsPage({
    Key? key,
    required this.stockSymbol,
    required this.stockData,
    required this.loanAmount,
    required this.loanTerm,
  }) : super(key: key);

  @override
  _LoanDetailsPageState createState() => _LoanDetailsPageState();
}

class _LoanDetailsPageState extends State<LoanDetailsPage> {
  bool _isProcessing = false;
  late double valuationPrice;
  late double totalValuation;
  late double loanValue;
  late DateTime loanEndDate;
  
  @override
  void initState() {
    super.initState();
    _calculateValues();
  }
  
  void _calculateValues() {
    final ltp = widget.stockData['LTP'] ?? 0.0;
    final avg180Day = widget.stockData['180 Davg'] ?? 0.0;
    
    // Determine which value to use for valuation (lower of LTP or 180-day average)
    valuationPrice = avg180Day < ltp ? avg180Day : ltp;
    
    // Calculate total valuation based on share amount
    totalValuation = valuationPrice * widget.loanAmount;
    
    // Calculate loan value (70% of total valuation)
    loanValue = totalValuation * 0.7;
    
    // Calculate loan end date
    final now = DateTime.now();
    loanEndDate = DateTime(now.year, now.month + widget.loanTerm, now.day);
  }
  
  Future<bool> _saveLoanToDatabase() async {
    setState(() {
      _isProcessing = true;
    });
    
    try {
      // Get current user email from Global
      String currentUserEmail = Global.userEmail;
      
      // Connection URI
      final String connectionString = 'mongodb+srv://anishkc:dukasur@cluster0.no5og.mongodb.net/loans';
      
      // Connect to MongoDB
      var db = await mongo.Db.create(connectionString);
      await db.open();
      
      // Access the collection based on user email
      var collection = db.collection('${currentUserEmail}');
      
      final loanDocument = {
        'stockSymbol': widget.stockSymbol,
        'ltp': widget.stockData['LTP'],
        'avg180Day': widget.stockData['180 Davg'],
        'shareAmount': widget.loanAmount,
        'valuationPrice': valuationPrice,
        'totalValuation': totalValuation,
        'loanValue': loanValue,
        'loanTerm': widget.loanTerm,
        'loanStartDate': DateFormat("yyyy-MM-dd").format(DateTime.now()),
        'loanEndDate': DateFormat("yyyy-MM-dd").format(loanEndDate),
        'status': 'Pending',
        'createdAt': DateFormat("yyyy-MM-dd").format(DateTime.now()),
        'userEmail': currentUserEmail
      };
      
      // Insert document
      await collection.insert(loanDocument);
      
      // Close connection
      await db.close();
      
      setState(() {
        _isProcessing = false;
      });
      
      return true;
    } catch (e) {
      print('Error saving loan: $e');
      setState(() {
        _isProcessing = false;
      });
      return false;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final ltp = widget.stockData['LTP'] ?? 0.0;
    final avg180Day = widget.stockData['180 Davg'] ?? 0.0;
    final formatter = NumberFormat("#,##0.00", "en_US");
    final dateFormatter = DateFormat("MMM dd, yyyy");
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Loan Details'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Stock: ${widget.stockSymbol}',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Last Trading Price', 'Rs. ${formatter.format(ltp)}'),
                    _buildInfoRow('180 Day Average', 'Rs. ${formatter.format(avg180Day)}'),
                    _buildInfoRow('Valuation Price', 'Rs. ${formatter.format(valuationPrice)}'),
                    _buildInfoRow('Number of Shares', '${widget.loanAmount.toStringAsFixed(0)}'),
                    _buildInfoRow('Total Valuation', 'Rs. ${formatter.format(totalValuation)}'),
                    _buildInfoRow('Loan Amount (70%)', 'Rs. ${formatter.format(loanValue)}'),
                    _buildInfoRow('Loan Term', '${widget.loanTerm} months'),
                    _buildInfoRow('Loan End Date', dateFormatter.format(loanEndDate)),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isProcessing ? null : () async {
                // Process and save the loan application
                final result = await _saveLoanToDatabase();
                
                if (result) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Loan application submitted successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to submit loan application. Please try again.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: _isProcessing 
                ? CircularProgressIndicator(color: Colors.white)
                : Text('Apply for Loan'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12),
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}