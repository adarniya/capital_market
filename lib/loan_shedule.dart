import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:capital_market/global.dart';

class LoanAmortizationPagee extends StatefulWidget {
   final String collectionName;
  const LoanAmortizationPagee({Key? key, required this.collectionName}) : super(key: key);
  

  @override
  State<LoanAmortizationPagee> createState() => _LoanAmortizationPageState();
}

class _LoanAmortizationPageState extends State<LoanAmortizationPagee> {
  static const String _connectionString = 'mongodb+srv://anishkc:dukasur@cluster0.no5og.mongodb.net/loans';
  static mongo.Db? _db;
  static mongo.DbCollection? _collection;

  Map<String, dynamic>? _loan;
  List<Map<String, dynamic>> _amortizationSchedule = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchLoanAndCalculate();
  }

  Future<void> _fetchLoanAndCalculate() async {
    try {
      if (_db == null) {
        _db = await mongo.Db.create(_connectionString);
        await _db!.open();
      }

      _collection = _db!.collection(Global.userEmail);

      // Fetch one loan (you can modify to pick by ID or latest)
      final loanData = await _collection!.findOne({
        
        'loanValue': {'\$exists': true}
      });

      if (loanData != null) {
        _loan = loanData;
        _calculateAmortization();
      }

      setState(() {
        _loading = false;
      });
    } catch (e) {
      print('Error: $e');
      setState(() {
        _loading = false;
      });
    }
  }

  void _calculateAmortization() {
    final double principal = (_loan!['loanValue'] as num).toDouble();
    final double annualRate = 10.0; // 10% interest
    final int termMonths = _loan!['loanTerm'] ?? 12;

    final double monthlyRate = annualRate / 12 / 100;
    final double emi = principal * monthlyRate * 
      (pow(1 + monthlyRate, termMonths)) /
      (pow(1 + monthlyRate, termMonths) - 1);

    double remaining = principal;

    for (int i = 1; i <= termMonths; i++) {
      double interest = remaining * monthlyRate;
      double principalPaid = emi - interest;
      remaining -= principalPaid;

      _amortizationSchedule.add({
        'month': i,
        'emi': emi,
        'interest': interest,
        'principalPaid': principalPaid,
        'remainingBalance': remaining < 0 ? 0 : remaining,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return Center(child: CircularProgressIndicator());

    if (_loan == null) return Center(child: Text('No loan data found.'));

    return Scaffold(
      appBar: AppBar(title: Text('Loan Amortization')),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _amortizationSchedule.length,
        itemBuilder: (context, index) {
          final entry = _amortizationSchedule[index];
          return Card(
            child: ListTile(
              title: Text('Month ${entry['month']}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('EMI: Rs. ${entry['emi'].toStringAsFixed(2)}'),
                  Text('Interest: Rs. ${entry['interest'].toStringAsFixed(2)}'),
                  Text('Principal Paid: Rs. ${entry['principalPaid'].toStringAsFixed(2)}'),
                  Text('Remaining Balance: Rs. ${entry['remainingBalance'].toStringAsFixed(2)}'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
