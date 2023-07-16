import 'package:flutter/material.dart';
import '../Login/Login_UI.dart';
import '../Signup/SignUp_UI.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpAdmin extends StatefulWidget {
  SignUpAdmin({Key? key}) : super(key: key);

  @override
  _SignUpAdminState createState() => _SignUpAdminState();
}

class _SignUpAdminState extends State<SignUpAdmin> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  String? selectedGender;

  bool isShowingSnackBar = false; // Flag to track snack bar visibility
  bool isLoading = false; // Flag to track loading state

  void showSnackBar(BuildContext context, String message) {
    if (isShowingSnackBar) {
      return; // Skip if snack bar is already visible
    }

    final snackBar = SnackBar(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      elevation: 0,
      backgroundColor: Color.fromARGB(0, 160, 11, 0),
      content: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10.0),
          topRight: Radius.circular(10.0),
        ),
        child: Container(
          color: Colors.red,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Text(
              message,
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar)
      ..closed.then((value) {
        // Reset the flag when snack bar is closed
        setState(() {
          isShowingSnackBar = false;
        });
      });

    setState(() {
      isShowingSnackBar = true; // Set the flag to indicate snack bar is visible
    });
  }

  Future<void> signUp(BuildContext context) async {
    String username = usernameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String address = addressController.text.trim();
    String role = "admin";

    if (username.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        address.isEmpty) {
      showSnackBar(context, 'Please fill in all the required fields');
      return;
    }

    setState(() {
      isLoading = true; // Start loading animation
    });

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      print('New user created: ${user?.uid}');

      try {
        // Create a new document in the "users" collection
        await FirebaseFirestore.instance
            .collection('admin')
            .doc(user?.uid)
            .set({
          'username': username,
          'email': email,
          'gender': selectedGender,
          'address': address,
          'role': role,
        });

        print('User document added successfully!');

        // Create a new subcollection "qr_codes" within the user document
        CollectionReference qrCodesCollection = FirebaseFirestore.instance
            .collection('admin')
            .doc(user?.uid)
            .collection('scanned_qr_codes');
        DocumentReference qrCodeDoc = await qrCodesCollection.add({
          'qr_code_data': '', // Add QR code data
          // Other relevant QR code specific data
        });

        print(
            'Scanned QR code document added successfully with ID: ${qrCodeDoc.id}');

        // Navigate to the login page
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      } catch (error) {
        print('Error adding document: $error');
      }
    } catch (e) {
      print('Error creating user: $e');
    } finally {
      setState(() {
        isLoading = false; // Stop loading animation
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
        ),
        padding: const EdgeInsets.all(40.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Column(
                children: [
                  Text(
                    'DOLE',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 30,
                    ),
                  ),
                  Text(
                    'Attendance System',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 30,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20.0),
              Image.asset(
                'assets/images/Dole.png',
                width: 150.0,
                height: 150.0,
              ),
              const SizedBox(height: 10.0),
              const Text(
                "CREATE ADMIN ACCOUNT",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
              const SizedBox(height: 20.0),
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(
                  hintText: 'Username',
                  prefixIcon: Icon(Icons.account_box),
                ),
              ),
              const SizedBox(height: 10.0),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  hintText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 10.0),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  hintText: 'Gender',
                  prefixIcon: Icon(Icons.male_rounded),
                ),
                value: selectedGender,
                onChanged: (String? newValue) {
                  selectedGender = newValue;
                },
                items: <String>['Male', 'Female', 'Other']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              const SizedBox(height: 10.0),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(
                  hintText: 'Address',
                  prefixIcon: Icon(Icons.map),
                ),
              ),
              const SizedBox(height: 10.0),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(
                  hintText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 20.0),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : () => signUp(context),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  child: isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : const Text(
                          'SIGN UP',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 50.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Already have an Account?',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                      color: Colors.black,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                    child: const Text(
                      ' Log in',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'User Sign up?',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                      color: Colors.black,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignUp()),
                      );
                    },
                    child: const Text(
                      ' Sign Up Now',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
