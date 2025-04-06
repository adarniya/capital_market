import 'package:capital_market/global.dart';
import 'package:capital_market/loan_analysis.dart';
import 'package:capital_market/loan_overview.dart';
import 'package:capital_market/loan_shedule.dart';
import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
 // Adjust to your actual globals file


class LoanAmortizationPage extends StatefulWidget {
  const LoanAmortizationPage({Key? key}) : super(key: key);

  @override
  _LoanAmortizationPageState createState() => _LoanAmortizationPageState();
}

class _LoanAmortizationPageState extends State<LoanAmortizationPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  bool _collectionExists = false;
  String _userCollectionName = '';
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _checkUserCollection();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _checkUserCollection() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      String currentUserEmail = Global.userEmail;
      // Sanitize email to create a valid collection name
      _userCollectionName = currentUserEmail;
      
      // Connect to MongoDB
      var db = await mongo.Db.create('mongodb+srv://anishkc:dukasur@cluster0.no5og.mongodb.net/loans');
      await db.open();
      
      // Check if collection exists
      var collections = await db.getCollectionNames();
      _collectionExists = collections.contains(_userCollectionName);
      
      await db.close();
    } catch (e) {
      print('Error checking collection: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _createUserCollection() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Connect to MongoDB
      var db = await mongo.Db.create('mongodb+srv://anishkc:dukasur@cluster0.no5og.mongodb.net/loans');
      await db.open();
      
      // Create collection
      await db.createCollection(_userCollectionName);
      print("global var is $_userCollectionName");
      // Add initial data if needed
      var collection = db.collection(_userCollectionName);
      await collection.insert({
        'createdAt': DateTime.now().toIso8601String(),
        'loanInitialized': true,
        'settings': {
          'currency': 'USD',
          'defaultInterestRate': 5.0,
        }
      });
      
      await db.close();
      
      setState(() {
        _collectionExists = true;
      });
    } catch (e) {
      print('Error creating collection: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to initialize loan management: $e'))
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Loan Amortization')),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    if (!_collectionExists) {
      return Scaffold(
        appBar: AppBar(title: Text('Loan Amortization')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Loan Management Not Initialized',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text('You need to set up loan management to continue.'),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _createUserCollection,
                child: Text('Get Started'),
              ),
            ],
          ),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Loan Amortization'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Overview'),
            Tab(text: 'Schedule'),
            Tab(text: 'Analytics'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          LoanTabOne(collectionName: _userCollectionName),
          LoanAmortizationPagee(collectionName: _userCollectionName),
          LoanTabThree(collectionName: _userCollectionName),
        ],
      ),
    );
  }
}