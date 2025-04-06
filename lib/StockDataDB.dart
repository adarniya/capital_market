import 'package:mongo_dart/mongo_dart.dart';

class MongoDBHelper {
  static Db? _db;
  static const String _stockConnectionString = 'mongodb+srv://anishkc:dukasur@cluster0.no5og.mongodb.net/market'; // Database name 'market'

  // Initialize MongoDB connection
  static Future<void> initialize() async {
    try {
      _db = await Db.create(_stockConnectionString);
      await _db?.open();
      print("MongoDB connection established.");
    } catch (e) {
      print("Error establishing MongoDB connection: $e");
    }
  }

  // Fetch the latest stock data from the given collection
  static Future<Map<String, dynamic>> getLatestStockData(String collectionName) async {
    try {
      // Ensure MongoDB connection is established
      await initialize();

      // Dynamically get the collection based on passed collection name
      var stockCollection = _db?.collection(collectionName);

      if (stockCollection == null) {
        throw Exception('Collection not found: $collectionName');
      }

      // Fetch the stock data from the collection (using an empty map as selector)
      var resultStream = stockCollection!.find({});

      // Convert the result stream to a list
      var resultList = await resultStream.toList();

      // Sort the results by date (most recent first)
      resultList.sort((a, b) {
        DateTime dateA = DateTime.parse(a['date']);
        DateTime dateB = DateTime.parse(b['date']);
        return dateB.compareTo(dateA);
      });

      if (resultList.isNotEmpty) {
        // Ensure we parse the BSON values correctly
        Map<String, dynamic> latestStock = resultList[0];

        // Convert BSON values to Dart types (e.g., double and int)
        latestStock['closePrice'] = (latestStock['closePrice'] as num).toDouble();
        latestStock['highPrice'] = (latestStock['highPrice'] as num).toDouble();
        latestStock['lowPrice'] = (latestStock['lowPrice'] as num).toDouble();
        latestStock['totalTradedQuantity'] = (latestStock['totalTradedQuantity'] as int);
        latestStock['totalTradedValue'] = (latestStock['totalTradedValue'] as num).toDouble();
        latestStock['totalTrades'] = (latestStock['totalTrades'] as int);

        return latestStock; // Return the latest stock data
      } else {
        throw Exception('No data found in the collection.');
      }
    } catch (e) {
      print("Error fetching stock data: $e");
      return {}; // Return empty map if error occurs
    }
  }

  // Close MongoDB connection
  static void closeConnection() {
    _db?.close();
    print("MongoDB connection closed.");
  }
}
