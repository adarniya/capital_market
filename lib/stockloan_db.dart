import 'package:mongo_dart/mongo_dart.dart' as mongo;

class MongoDBHelperdb {
  static mongo.Db? _db;
  
  // Initialize connection to MongoDB
  static Future<void> connect() async {
    if (_db == null || !_db!.isConnected) {
      try {
        _db = await mongo.Db.create('mongodb+srv://anishkc:dukasur@cluster0.no5og.mongodb.net/market');
        await _db!.open();
        print('Connected to MongoDB amrkett');
      } catch (e) {
        print('Error connecting to MongoDB: $e');
        throw e;
      }
    }
  }
  

  
  // Get stock loan eligibility data
  static Future<Map<String, dynamic>?> getStockLoanEligibility(String symbol) async {
    try {
      await connect();
      
      final collection = _db!.collection('loanable');
      final result = await collection.findOne(mongo.where.eq('Symbol', symbol));
      
      return result;
    } catch (e) {
      print('Error checking loan eligibility: $e');
      throw e;
    }
  }
  
  // Close MongoDB connection
  static Future<void> close() async {
    if (_db != null && _db!.isConnected) {
      await _db!.close();
      print('Closed MongoDB connection');
    }
  }
}