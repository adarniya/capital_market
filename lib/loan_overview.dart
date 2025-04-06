import 'package:capital_market/addloanpage.dart';
import 'package:capital_market/global.dart';
import 'package:capital_market/mongodbhelper.dart';
import 'package:capital_market/testui.dart';
import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';

class LoanTabOne extends StatefulWidget {
  final String collectionName;
  
  const LoanTabOne({Key? key, required this.collectionName}) : super(key: key);
  @override
  _LoanTabOneState createState() => _LoanTabOneState();
}

class _LoanTabOneState extends State<LoanTabOne> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _loansList = [];
  Map<String, dynamic> _loanSummary = {};
  final TextEditingController _stockController = TextEditingController();
  static const String _loanConnectionString = 'mongodb+srv://anishkc:dukasur@cluster0.no5og.mongodb.net/loans';
  static mongo.Db? _db;
  static mongo.DbCollection? _loanCollection;
  
  @override
  void initState() {
    super.initState();
    _fetchLoans();
  }
  
  // Initialize database connection
  static Future<void> init() async {
    if (_db != null) return;
    try {
      _db = await mongo.Db.create(_loanConnectionString);
      await _db?.open();
      print('Connected to loan MongoDB successfully!');
    } catch (e) {
      print('Error connecting to loan MongoDB: $e');
      rethrow;
    }
  }
  
  // Fetch loans and calculate summary
  Future<void> _fetchLoans() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Use Global.userEmail to get the current user's collection
      String currentUserEmail = Global.userEmail;
      
      if (_db == null) {
        await init();
      }
      
      _loanCollection = _db?.collection('${currentUserEmail}');
      
      if (_loanCollection == null) {
        throw Exception("MongoDB connection is not initialized.");
      }
      
      // Fetch all loans for the user
      final cursor = _loanCollection?.find({
  'loanValue': { '\$exists': true },
  'stockSymbol': { '\$exists': true },
});

      _loansList = await cursor?.toList() ?? [];
      
      // Calculate loan summary
      _calculateLoanSummary();
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching loan entries: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  // Calculate loan summary from fetched loans
  void _calculateLoanSummary() {
    double totalLoanAmount = 0;
    DateTime? nextPaymentDate;
    
    for (var loan in _loansList) {
      // Add loan amount to total
      totalLoanAmount += (loan['loanValue'] ?? 0).toDouble();
      
      // Find the earliest upcoming payment date
      if (loan['loanEndDate'] != null) {
        DateTime endDate;
        if (loan['loanEndDate'] is String) {
          endDate = DateTime.parse(loan['loanEndDate']);
        } else if (loan['loanEndDate'] is DateTime) {
          endDate = loan['loanEndDate'];
        } else {
          continue;
        }
        
        if (endDate.isAfter(DateTime.now()) && 
            (nextPaymentDate == null || endDate.isBefore(nextPaymentDate))) {
          nextPaymentDate = endDate;
        }
      }
    }
    
    _loanSummary = {
      'totalLoans': _loansList.length,
      'activeLoanAmount': totalLoanAmount,
      'totalInterestDue': totalLoanAmount * 0.1, //  10% interest 
      'nextPaymentDue': nextPaymentDate?.toString()
    };
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 3,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Loan Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 16),
                  _buildSummaryRow('Total Loans', '${_loanSummary['totalLoans'] ?? 0}'),
                  _buildSummaryRow('Active Loan Amount', 'Rs. ${(_loanSummary['activeLoanAmount'] ?? 0).toStringAsFixed(2)}'),
                  _buildSummaryRow('Total Interest Due', 'Rs. ${(_loanSummary['totalInterestDue'] ?? 0).toStringAsFixed(2)}'),
                  if (_loanSummary['nextPaymentDue'] != null)
                    _buildSummaryRow('Next Payment Due', _formatDate(_loanSummary['nextPaymentDue'])),
                ],
              ),
            ),
          ),
          SizedBox(height: 24),
          
          // Loan list
          Text('Your Loans', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          _loansList.isEmpty
              ? Center(child: Text('No loans found. Add your first loan.'))
              : ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: _loansList.length,
                  itemBuilder: (context, index) {
                    final loan = _loansList[index];
                    return Card(
                      margin: EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${loan['stockSymbol'] ?? 'Unknown Stock'}',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${loan['status'] ?? 'Pending'}',
                                    style: TextStyle(color: Colors.green.shade800),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            _buildLoanDetailRow('Loan Amount', 'Rs. ${(loan['loanValue'] ?? 0).toStringAsFixed(2)}'),
                            _buildLoanDetailRow('Number of Shares', '${(loan['shareAmount'] ?? 0).toStringAsFixed(0)}'),
                            _buildLoanDetailRow('Valuation Price', 'Rs. ${(loan['valuationPrice'] ?? 0).toStringAsFixed(2)}'),
                            _buildLoanDetailRow('Loan Term', '${loan['loanTerm'] ?? 0} months'),
                            _buildLoanDetailRow('End Date', _formatSimpleDate(loan['loanEndDate'])),
                          ],
                        ),
                      ),
                    );
                  },
                ),
          
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // Show dialog to add a new loan
              _navigateToAddLoan(context);
            },
            icon: Icon(Icons.add),
            label: Text('Add New Loan'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 12),
              minimumSize: Size(double.infinity, 50),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16)),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
  
  Widget _buildLoanDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
          Text(value, style: TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
  
  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Invalid Date';
    }
  }
  
  String _formatSimpleDate(dynamic dateValue) {
    if (dateValue == null) return 'N/A';
    try {
      DateTime date;
      if (dateValue is String) {
        date = DateTime.parse(dateValue);
      } else if (dateValue is DateTime) {
        date = dateValue;
      } else {
        return 'Invalid Date';
      }
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Invalid Date';
    }
  }
  
  void _navigateToAddLoan(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddLoanPage(collectionName: widget.collectionName),
      ),
    ).then((_) {
      // Refresh the loan list when returning from add loan page
      _fetchLoans();
    });
  }
}