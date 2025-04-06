
import 'package:flutter/material.dart';
import 'package:capital_market/editaccount.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  String name = "John Doe";
  String address = "123 Main St, City";
  String dateOfBirth = "January 1, 1990";
  String gender = "Male";
  String citizenshipNumber = "1 234 567 890";
  String email = "john.doe@example.com";
  String memberSince = "January 2022";
 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/profile_image.jpg'),
            ),
            const SizedBox(height: 20),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle,
                  size: 15,
                  color: Colors.blue,
                ),
                SizedBox(width: 5),
                Text(
                  'Verified',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text('Name: $name'),
            const SizedBox(height: 20),
            Text('Address: $address'),
            const SizedBox(height: 20),
            Text('Date of Birth: $dateOfBirth'),
            const SizedBox(height: 20),
            Text('Gender: $gender'),
            const SizedBox(height: 20),
            Text('Citizenship number: $citizenshipNumber'),
            const SizedBox(height: 20),
            Text('Email: $email'),
            const SizedBox(height: 20),
            Text('Member Since: $memberSince'),
            const SizedBox(height: 100),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditAccountScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.edit_document,
                      size: 20,
                      color: Colors.white,
                    ),
                    SizedBox(width: 5),
                    Text(
                      'Edit Account',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
