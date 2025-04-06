
import 'package:capital_market/biddingpage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';



class AuctionPage extends StatefulWidget {
  final int showindex;
  final String photoUrls;
  final String descriptionText;

  const AuctionPage({
    Key? key,
    required this.showindex,
    required this.photoUrls,
    required this.descriptionText,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _AuctionPageState createState() => _AuctionPageState();
}

class _AuctionPageState extends State<AuctionPage> {
  String? _imagePath;
  int _showTabs=0;

  @override
  void initState() {
    super.initState();
    _showTabs = widget.showindex;
  }

  Future<void> _getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    int showtabs = _showTabs;

    String photoUrls = widget.photoUrls;
    String descriptionText = widget.descriptionText;

    return Scaffold(
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                  2,
                  (index) => GestureDetector(
                    onTap: () {
                      setState(() {
                        _showTabs = index;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 50,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: showtabs == index
                            ? Colors.blue
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        index == 0 ? 'add shares' : 'other shares',
                        style: TextStyle(
                          color: showtabs == index
                              ? Colors.white
                              : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Builder(
                builder: (BuildContext context) {
                  if (showtabs == 0) {
                    return SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextField(
                            decoration: InputDecoration(
                              labelText: 'stock name',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          

                          const SizedBox(height: 20),
                          TextField(
                            decoration: InputDecoration(
                              labelText: 'price',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            decoration: InputDecoration(
                              labelText: 'Set date',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.red[200],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.all(16),
                            height: 60,
                            width: 400,
                            child: const Text(
                              'check data',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                         
                          const SizedBox(height: 30),
                          ElevatedButton(
                            onPressed: () {
                              // Add your logic for handling the button press here
                            },
                            style: ElevatedButton.styleFrom(
                              elevation: 5,
                              padding: const EdgeInsets.all(15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40),
                              ),
                              minimumSize: const Size(250, 40),
                              backgroundColor: Colors.blue,
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.shopping_bag,
                                  size: 30,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 15),
                                Text(
                                  'save',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  } else if (showtabs == 1) {
                    return BiddingPage(
                      photoUrls: photoUrls,
                      descriptionText: descriptionText,
                    );
                  } else {
                    return const Center(
                      child: Text('Invalid Index'),
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
