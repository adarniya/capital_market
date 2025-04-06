import 'package:capital_market/global.dart';
import 'package:mongo_dart/mongo_dart.dart';

class MongoDBHelper {
  static Db? _db;
  static Db? _stockDb;
  static const String _portfolioConnectionString = 'mongodb+srv://anishkc:dukasur@cluster0.no5og.mongodb.net/myDatabase';
  static const String _stockConnectionString = 'mongodb+srv://anishkc:dukasur@cluster0.no5og.mongodb.net/market';
  static const String _stockCollectionName = 'stocks';
  
  static DbCollection? _userPortfolioCollection;
  static DbCollection? _portfolioCollection;
  static DbCollection? _stockCollection;
  
  // Fetch stock name suggestions
  static Future<List<String>> getStockSuggestions(String query) async {
    try {
      // Ensure stock database is initialized
      if (_stockDb == null) {
        _stockDb = await Db.create(_stockConnectionString);
        await _stockDb?.open();
        _stockCollection = _stockDb?.collection(_stockCollectionName);
      }

      if (_stockCollection == null) {
        throw Exception("Stock database connection is not initialized.");
      }

      // Search using regular expression (case-insensitive match)
      var suggestionsCursor = _stockCollection?.find({
        '\$or': [
          {'Symbol': {'\$regex': query, '\$options': 'i'}}, // Match Symbol field
          {'Security Name': {'\$regex': query, '\$options': 'i'}} // Match Security Name field
        ]
      });

      // Transform results to "Security Name (Symbol)" format
      final suggestions = await suggestionsCursor
          ?.map((doc) {
            String securityName = doc['Security Name'] ?? '';
            String symbol = doc['Symbol'] ?? '';
            return '$securityName($symbol)'; 
          })
          .toList() ?? [];

      // Remove duplicates and limit to 5 suggestions
      final uniqueSuggestions = suggestions.toSet().toList();
      return uniqueSuggestions.take(5).toList();
    } catch (e) {
      print("Error fetching stock suggestions: $e");
      return [];
    }
  }

  // Fetch portfolio entries
  static Future<List<Map<String, dynamic>>> getPortfolioEntries() async {
    // Use Global.userEmail to get the current user's collection
    String currentUserEmail = Global.userEmail;
   

    if (_db == null) {
      await init();
    }

    _portfolioCollection = _db?.collection(currentUserEmail);

    if (_portfolioCollection == null) {
      throw Exception("MongoDB connection is not initialized.");
    }

    try {
      final cursor = _portfolioCollection?.find();
      final List<Map<String, dynamic>> results = await cursor?.toList() ?? [];
      return results;
    } catch (e) {
      print("Error fetching portfolio entries: $e");
      rethrow;
    }
  }

  // Initialize portfolio database connection
  static Future<void> init() async {
    if (_db != null) return;

    try {
      _db = await Db.create(_portfolioConnectionString);
      await _db?.open();
      // No need to set _portfolioCollection here
      print('Connected to Portfolio MongoDB successfully!');
    } catch (e) {
      print('Error connecting to Portfolio MongoDB: $e');
      rethrow;
    }
  }

  // Add a new portfolio entry
  static Future<void> addPortfolioEntry({
    required String transactionType,
    required String symbol,
   
    required String securityName,
    required String price,
    required String volume,
    required String date,
  }) async {
    // Use Global.userEmail to get the current user's collection
    String currentUserEmail = Global.userEmail;


    if (_db == null) {
      await init();
    }

    _portfolioCollection = _db?.collection(currentUserEmail);

    if (_portfolioCollection == null) {
      throw Exception("MongoDB connection is not initialized.");
    }

    try {
      final double priceValue = double.parse(price);
      final int volumeValue = int.parse(volume);
      DateTime dateValue = DateTime.parse(date);

      var portfolioEntry = {
        'transactionType': transactionType,
        'symbol':symbol,
     
        'securityName': securityName,
        'price': priceValue,
        'volume': volumeValue,
        'date': dateValue,
        'createdAt': DateTime.now(),
      };

      await _portfolioCollection?.insert(portfolioEntry);
      print("Portfolio entry added successfully!");
    } catch (e) {
      print("Error inserting into MongoDB: $e");
      rethrow;
    }
  }

  // New method to create user-specific collection
  static Future<void> createUserCollection(String email) async {
    try {
      // Ensure database connection
      if (_db == null) {
        await init();
      }

      // Create a collection named after the user's email
     
      DbCollection userCollection = _db!.collection(email);

      // Insert initial user data
      await userCollection.insert({
        'email': email,
        'registeredAt': DateTime.now(),
        'userDetails': {
          'fullName': null,
          'address': null,
          'dateOfBirth': null,
          'gender': null,
          'citizenshipNumber': null
        }
      });

      print('User collection created for: $email');
    } catch (e) {
      print('Error creating user collection: $e');
      rethrow;
    }
  }

  // New method to update user details
  static Future<void> updateUserDetails(String email, Map<String, dynamic> details) async {
    try {
      // Sanitize email to match collection name
      

      if (_db == null) {
        await init();
      }

      DbCollection userCollection = _db!.collection(email);

      // Update user details
      await userCollection.update(
        where.eq('email', email),
        modify.set('userDetails', details)
      );

      print('User details updated for: $email');
    } catch (e) {
      print('Error updating user details: $e');
      rethrow;
    }
  }

  // New method to retrieve user-specific data
  static Future<Map<String, dynamic>?> getUserData(String email) async {
    try {
      // Sanitize email to match collection name
    

      if (_db == null) {
        await init();
      }

      DbCollection userCollection = _db!.collection(email);
      return await userCollection.findOne();
    } catch (e) {
      print('Error retrieving user data: $e');
      return null;
    }
  }

  // Close database connections
  static Future<void> close() async {
    await _db?.close();
    await _stockDb?.close();
    _db = null;
    _stockDb = null;
    _portfolioCollection = null;
    _stockCollection = null;
  }

 
}