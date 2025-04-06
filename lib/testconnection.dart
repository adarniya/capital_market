import 'package:mongo_dart/mongo_dart.dart';

class MongoDBHelper {
  static late Db _db;
  static late DbCollection _collection;

  static const String mongoUri = 'mongodb+srv://anishkc:dukasur@cluster0.no5og.mongodb.net/stocks';
  static const String databaseName = "stocks";

  static Future<void> initialize() async {
    try {
      _db = await Db.create(mongoUri);
      await _db.open();
      print("MongoDB connection established.");
    } catch (e) {
      print("Error connecting to MongoDB: $e");
    }
  }

  static Future<List<Map<String, dynamic>>> getLatestTwoStockData(String collection) async {
    try {
      _collection = _db.collection(collection);
      print("the name of  collection is $collection ");

      var stockData = await _collection
          .find(where.sortBy('date', descending: true).limit(180))
          .toList();

      return stockData;
    } catch (e) {
      print("Error fetching stock data: $e");
      return [];
    }finally {
      closeConnection(); // Ensure the connection is closed after fetching the data
    }
  }



  static void closeConnection() {
    _db.close();
  }
}
