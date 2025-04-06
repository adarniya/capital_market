
import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
class MongoDBPage extends StatefulWidget {
  const MongoDBPage({super.key});

  @override
  _MongoDBPageState createState() => _MongoDBPageState();
}

class _MongoDBPageState extends State<MongoDBPage> {
  final TextEditingController _controller = TextEditingController();
  List<String> _items = [];
  final String mongoUrl = "mongodb+srv://anishkc:dukasur@cluster0.no5og.mongodb.net/myDatabase";
  final String collectionName = "users";

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    var db = await mongo.Db.create(mongoUrl);
    await db.open();
    var collection = db.collection(collectionName);
    var data = await collection.find().toList();
    await db.close();
    setState(() {
      _items = data.map((doc) => doc['name'].toString()).toList();
    });
  }

  Future<void> _addData(String text) async {
    if (text.isEmpty) return;
    var db = await mongo.Db.create(mongoUrl);
    await db.open();
    var collection = db.collection(collectionName);
    await collection.insertOne({"name": text});
    await db.close();
    _controller.clear();
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("MongoDB Flutter")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(labelText: "Enter Name"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _addData(_controller.text),
              child: const Text("Submit"),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_items[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
