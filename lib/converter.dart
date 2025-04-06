import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;

class CsvUploader extends StatefulWidget {
  const CsvUploader({super.key});

  @override
  _CsvUploaderState createState() => _CsvUploaderState();
}

class _CsvUploaderState extends State<CsvUploader> {
  Future<void> uploadCsvToMongo() async {
    // Pick CSV File
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result == null) return;
    File file = File(result.files.single.path!);

    // Read CSV File
    String fileContent = await file.readAsString();
    List<List<dynamic>> csvData = const CsvToListConverter().convert(fileContent);

    if (csvData.isEmpty) return;

    // Connect to MongoDB
    var db = await mongo.Db.create("mongodb://localhost:27017/stock_database");
    await db.open();
    var collection = db.collection("stock_prices");

    // Convert CSV Data to Map and Insert
    List<Map<String, dynamic>> documents = [];
    List<dynamic> headers = csvData[0]; // First row as headers

    for (int i = 1; i < csvData.length; i++) {
      Map<String, dynamic> record = {};
      for (int j = 0; j < headers.length; j++) {
        record[headers[j].toString()] = csvData[i][j];
      }
      documents.add(record);
    }

    await collection.insertMany(documents);
    await db.close();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("CSV data imported successfully!"))
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("CSV to MongoDB")),
      body: Center(
        child: ElevatedButton(
          onPressed: uploadCsvToMongo,
          child: const Text("Upload CSV"),
        ),
      ),
    );
  }
}
