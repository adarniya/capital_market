// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'dart:developer';

// import 'package:stock_loan/homepage.dart';
// import 'package:stock_loan/signup.dart';

// class SignIn extends StatefulWidget {
//   const SignIn({Key? key}) : super(key: key);
//   @override
//   State<SignIn> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<SignIn> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final _auth = FirebaseAuth.instance;

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   String? _validateEmail(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Please enter your email';
//     }
//     String pattern = r'^[^@]+@[^@]+\.[^@]+';
//     RegExp regex = RegExp(pattern);
//     if (!regex.hasMatch(value)) {
//       return 'Enter a valid email';
//     }
//     return null;
//   }

//   String? _validatePassword(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Please enter your password';
//     } else if (value.length < 6) {
//       return 'Password must be at least 6 characters long';
//     }
//     return null;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SingleChildScrollView(
//         child: Container(
//           height: MediaQuery.of(context).size.height,
//           width: MediaQuery.of(context).size.width,
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [Colors.tealAccent.shade400, Colors.teal.shade700],
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter,
//             ),
//           ),
//           child: Center(
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Card(
//                       elevation: 5,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.all(20.0),
//                         child: Column(
//                           children: [
//                             TextFormField(
//                               controller: _emailController,
//                               decoration: InputDecoration(
//                                 filled: true,
//                                 fillColor: Colors.grey[200],
//                                 prefixIcon: const Icon(Icons.person_outline),
//                                 hintText: 'Enter your email',
//                                 labelText: 'Email',
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(12.0),
//                                   borderSide: BorderSide.none,
//                                 ),
//                               ),
//                               validator: _validateEmail,
//                             ),
//                             const SizedBox(height: 20),
//                             TextFormField(
//                               controller: _passwordController,
//                               obscureText: true,
//                               decoration: InputDecoration(
//                                 filled: true,
//                                 fillColor: Colors.grey[200],
//                                 prefixIcon: const Icon(Icons.lock_outline),
//                                 hintText: 'Enter your password',
//                                 labelText: 'Password',
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(12.0),
//                                   borderSide: BorderSide.none,
//                                 ),
//                               ),
//                               validator: _validatePassword,
//                             ),
//                             const SizedBox(height: 30),
//                             ElevatedButton(
//                               style: ElevatedButton.styleFrom(
//                                 padding: const EdgeInsets.symmetric(
//                                     horizontal: 50, vertical: 15),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(20),
//                                 ),
//                                 backgroundColor: Colors.teal.shade800,
//                               ),
//                               onPressed: () async {
//                                 if (_formKey.currentState?.validate() ?? false) {
//                                   final user = await loginUserWithEmailAndPassword(
//                                     _emailController.text.trim(),
//                                     _passwordController.text.trim(),
//                                   );

//                                   if (user != null) {
//                                     print('user  :  $user');
//                                     Navigator.pushReplacement(
//                                       context,
//                                       MaterialPageRoute(
//                                           builder: (context) => const HomePage()),
//                                     );
//                                   } else {
//                                     ScaffoldMessenger.of(context).showSnackBar(
//                                       const SnackBar(
//                                           content: Text('Login failed. Please check your credentials.')),
//                                     );
//                                   }
//                                 }
//                               },
//                               child: const Text(
//                                 'Sign In',
//                                 style: TextStyle(fontSize: 18, color: Colors.white),
//                               ),
//                             ),
//                             const SizedBox(height: 10),
//                             TextButton(
//                               onPressed: () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                       builder: (context) => const SignupScreen()),
//                                 );
//                               },
//                               child: const Text(
//                                 'Don\'t have an account? Sign Up',
//                                 style: TextStyle(color: Colors.teal),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Future<User?> loginUserWithEmailAndPassword(String email, String password) async {
//     try {
//       final credentials = await _auth.signInWithEmailAndPassword(
//           email: email, password: password);
//       return credentials.user;
//     } catch (e) {
//       log('something went wrong: $e'); // Show error message in logs
//       return null;
//     }
//   }
// }
