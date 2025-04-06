import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:fl_chart/fl_chart.dart'; // Make sure to add this dependency

class LoanTabThree extends StatefulWidget {
  final String collectionName;
  
  const LoanTabThree({Key? key, required this.collectionName}) : super(key: key);

  @override
  _LoanTabThreeState createState() => _LoanTabThreeState();
}

class _LoanTabThreeState extends State<LoanTabThree> {
  bool _isLoading = true;
  Map<String, dynamic> _analyticsData = {};
  List<Color> gradientColors = [
    Colors.blue,
    Colors.blueAccent,
  ];
  
  @override
  void initState() {
    super.initState();
    _fetchAnalyticsData();
  }
  
  Future<void> _fetchAnalyticsData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Connect to MongoDB
      var db = await mongo.Db.create('mongodb+srv://anishkc:dukasur@cluster0.no5og.mongodb.net/loans');
      await db.open();
      
      var collection = db.collection(widget.collectionName);
      
      // Get analytics data or calculate it from loan data
      var analytics = await collection.findOne({'type': 'analytics'});
      
      if (analytics == null) {
        // If no analytics document exists, calculate it from loans
        var loans = await collection.find({'type': 'loan'}).toList();
        
        // Calculate total loan amount
        double totalLoanAmount = 0;
        double totalInterest = 0;
        Map<String, double> principalByMonth = {};
        Map<String, double> interestByMonth = {};
        
        for (var loan in loans) {
          totalLoanAmount += loan['loanAmount'] ?? 0;
          totalInterest += loan['totalInterest'] ?? 0;
          
          // Get schedules for this loan
          var schedules = await collection.find({
            'type': 'schedule',
            'loanId': loan['_id']
          }).toList();
          
          for (var payment in schedules) {
            // Group payments by month for the chart
            String month = _getMonthYear(payment['dueDate']);
            principalByMonth[month] = (principalByMonth[month] ?? 0) + (payment['principal'] ?? 0);
            interestByMonth[month] = (interestByMonth[month] ?? 0) + (payment['interest'] ?? 0);
          }
        }
        
        // Create analytics object
        analytics = {
          'type': 'analytics',
          'totalLoanAmount': totalLoanAmount,
          'totalInterest': totalInterest,
          'interestToLoanRatio': totalLoanAmount > 0 ? (totalInterest / totalLoanAmount) : 0,
          'principalByMonth': principalByMonth,
          'interestByMonth': interestByMonth,
          'lastUpdated': DateTime.now().toIso8601String(),
        };
        
        // Save analytics to database for future use
        await collection.insert(analytics);
      }
      
      // Fix: Check if analytics is not null before assigning
      if (analytics != null) {
        setState(() {
          _analyticsData = Map<String, dynamic>.from(analytics!);
        });
      } else {
        // Handle the null case by setting a default empty map
        setState(() {
          _analyticsData = {};
        });
      }
      
      await db.close();
    } catch (e) {
      print('Error fetching analytics data: $e');
      // Make sure to set _analyticsData to an empty map if there's an error
      setState(() {
        _analyticsData = {};
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  String _getMonthYear(dynamic dateValue) {
    if (dateValue == null) return 'Unknown';
    try {
      final date = dateValue is String 
          ? DateTime.parse(dateValue)
          : DateTime.fromMillisecondsSinceEpoch(dateValue.$date);
      return '${date.month}/${date.year}';
    } catch (e) {
      return 'Invalid Date';
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    
    if (_analyticsData.isEmpty) {
      return Center(
        child: Text('No analytics data available. Add loans to see analytics.'),
      );
    }
    
    // This is a simplified implementation - you would need to transform your data
    // to match the expected format for the charts
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
                  _buildSummaryRow('Total Loan Amount', '\$${(_analyticsData['totalLoanAmount'] ?? 0).toStringAsFixed(2)}'),
                  _buildSummaryRow('Total Interest', '\$${(_analyticsData['totalInterest'] ?? 0).toStringAsFixed(2)}'),
                  _buildSummaryRow(
                    'Interest/Loan Ratio', 
                    '${((_analyticsData['interestToLoanRatio'] ?? 0) * 100).toStringAsFixed(2)}%'
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 24),
          Card(
            elevation: 3,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Principal vs Interest', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 16),
                  Container(
                    height: 200,
                    child: Stack(
                      children: [
                        // Placeholder for a chart - in a real app, you'd replace this with an actual chart
                        // For example, using the fl_chart package
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            gradient: LinearGradient(
                              colors: [Colors.blue[100]!, Colors.blue[50]!],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Principal vs. Interest Chart\n(Implement with fl_chart package)',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 24),
          Card(
            elevation: 3,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Payment Distribution', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 16),
                  Container(
                    height: 200,
                    child: Stack(
                      children: [
                        // Placeholder for a pie chart
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            gradient: LinearGradient(
                              colors: [Colors.green[100]!, Colors.green[50]!],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Payment Distribution Chart\n(Implement with fl_chart package)',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
}