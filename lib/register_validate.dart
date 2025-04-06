import 'dart:io';


import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:capital_market/email_otp.dart';

class RegisterValidationScreen extends StatefulWidget {
  const RegisterValidationScreen({Key? key, required this.email})
      : super(key: key);

  final String email;

  @override
  // ignore: library_private_types_in_public_api
  _RegisterValidationScreenState createState() =>
      _RegisterValidationScreenState();
}

class _RegisterValidationScreenState extends State<RegisterValidationScreen> {
  String selectedCardType = '';
  String? _imagePath;
 // ignore: unused_field
 final TextEditingController _emailController = TextEditingController();
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
    String email = widget.email;//variable to value of email
  
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 30),
                const Text(
                  "Verification Details",
                  style: TextStyle(
                    fontSize: 25,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'EMAIL:',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  readOnly: true,
                  controller: TextEditingController(text: widget.email),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.email_outlined),
                    prefixIconColor: Colors.black,
                    filled: true,
                    fillColor: Colors.white,
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
                const SizedBox(height: 20),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Profile photo:',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(20),
        ),
                    width: 200,
                    height: 130,
                    child: GestureDetector(
                      onTap: _getImage,
                      child: _imagePath != null
                          ? Image.file(
                              File(_imagePath!),
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            )
                          : const Icon(
                              Icons.photo_camera,
                              size: 75,
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Identify Card Types',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    Row(
                      children: [
                        Radio(
                          value: 'Citizenship',
                          groupValue: selectedCardType,
                          onChanged: (String? value) {
                            setState(() {
                              selectedCardType = value!;
                            });
                          },
                        ),
                        const Text('Citizenship',
                        style: TextStyle(
                        fontSize: 16,
                        
                      ),),
                      ],
                    ),
                    Row(
                      children: [
                        Radio(
                          value: 'License',
                          groupValue: selectedCardType,
                          onChanged: (String? value) {
                            setState(() {
                              selectedCardType = value!;
                            });
                          },
                        ),
                        const Text('License',
                        style: TextStyle(
                        fontSize: 16,
                        
                      ),),
                      ],
                    ),
                    Row(
                      children: [
                        Radio(
                          value: 'National Card',
                          groupValue: selectedCardType,
                          onChanged: (String? value) {
                            setState(() {
                              selectedCardType = value!;
                            });
                          },
                        ),
                        const Text('National Card',
                        style: TextStyle(
                        fontSize: 16,
                        
                      ),),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
                
Row(
  children: [
Expanded(
  child: Column(
    children: [
      const Text('Front side:',
      style: TextStyle(
                  fontSize: 20,
                ),
      ),
      const SizedBox(height: 20),
      Container(decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(20),
        ),
        width: 200,
        height: 120, // Background color for the GestureDetector
        child: GestureDetector(
          onTap: _getImage,
          child: _imagePath != null
              ? Image.file(
                  File(_imagePath!),
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                )
              : const Icon(
                  Icons.photo_camera,
                  size: 75,
                ),
        ),
      ),
    ],
  ),
),
const SizedBox(width: 10),
Expanded(
  child: Column(
    children: [
      const Text('Back side:',
      style: TextStyle(
                  fontSize: 20,
                ),
      ),
      const SizedBox(height: 20),
      Container(
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(20),
        ),
        width: 200,
        height: 120, // Background color for the GestureDetector
        child: GestureDetector(
          onTap: _getImage,
          child: _imagePath != null
              ? Image.file(
                  File(_imagePath!),
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                )
              : const Icon(
                  Icons.photo_camera,
                  size: 75,
                ),
        ),
      ),
    ],
  ),
),

  ],
)
,
const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
    // Handle login logic or any other necessary tasks
// ignore: avoid_print
print(email);


    // Navigate to the register validate page
    Navigator.push(
      context,
      MaterialPageRoute(
         builder: (context) => EmailOtpScreen(email: email),
        ),
    );
  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(200, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text('Continue', style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
