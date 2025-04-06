import 'package:flutter/material.dart';

class BiddingPage extends StatefulWidget {
  const BiddingPage({Key? key, required this.photoUrls, required this.descriptionText})
      : super(key: key);

  final String photoUrls ;
  final String descriptionText;

  @override
  // ignore: library_private_types_in_public_api
  _BiddingPageState createState() => _BiddingPageState();
}

class _BiddingPageState extends State<BiddingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
         Container(
  height: 100,
  width: 100,
  decoration: BoxDecoration(
    image: DecorationImage(
      image: AssetImage(widget.photoUrls), // Use AssetImage for asset images
      fit: BoxFit.cover,
    ),
  ),
),

   const SizedBox(height: 10),

              // Description text in a light grey container
              Container(
                color: Colors.grey[200],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    widget.descriptionText,
                    style: const TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              const SizedBox(height: 50),

              // Bidding section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: 150,
                    child: TextField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.monetization_on),
                        prefixIconColor: Colors.blue,
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        isDense: true,
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.purple,
                            style: BorderStyle.solid,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.blue,
                            style: BorderStyle.solid,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Add functionality for the Bid button
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 5,
                      padding: const EdgeInsets.all(15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      minimumSize: const Size(80, 10),
                      backgroundColor: Colors.blue,
                    ),
                    child: const Text(
                      'Bid',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Add functionality for the Edit button
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 5,
                      padding: const EdgeInsets.all(15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      minimumSize: const Size(75, 10),
                      backgroundColor: Colors.green,
                    ),
                    child: const Text(
                      'Edit',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // My Bids section
              const Text(
                'My Bids',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            

              // Auctions table
              _buildAuctionsTable(),
            ],
          ),
        ),
      ),
    );
  }

  // Function to build the auctions table
  Widget _buildAuctionsTable() {
    return Table(
      border: TableBorder.all(),
      children: [
        TableRow(
          decoration: BoxDecoration(color: Colors.grey[200]),
          children: const [
            TableCell(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Product Name'),
              ),
            ),
            TableCell(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Original Price'),
              ),
            ),
            TableCell(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Highest Bid'),
              ),
            ),
            TableCell(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Lowest Bid'),
              ),
            ),
            TableCell(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Opening Bid'),
              ),
            ),
          ],
        ),
        // Sample auction rows, replace with actual data
        _buildAuctionRow('Product 1', '100', '150', '80', '90'),
        _buildAuctionRow('Product 2', '200', '250', '180', '190'),
        _buildAuctionRow('Product 3', '300', '350', '280', '290'),
      ],
    );
  }

  // Function to build an auction row
  TableRow _buildAuctionRow(
    String productName,
    String originalPrice,
    String highestBid,
    String lowestBid,
    String openingBid,
  ) {
    return TableRow(
      children: [
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(productName),
          ),
        ),
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(originalPrice),
          ),
        ),
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(highestBid),
          ),
        ),
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(lowestBid),
          ),
        ),
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(openingBid),
          ),
        ),
      ],
    );
  }
}
