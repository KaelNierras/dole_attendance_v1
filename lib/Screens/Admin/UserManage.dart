// ignore_for_file: file_names, prefer_const_constructors_in_immutables, library_private_types_in_public_api, avoid_print,  prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Admin/Admin_UI.dart';

class UserManage extends StatefulWidget {
  UserManage({Key? key}) : super(key: key);

  @override
  _UserManageState createState() => _UserManageState();
}

class _UserManageState extends State<UserManage> {
  final List<String> usernames = [];
  final List<String> emails = [];
  final List<String> genders = [];
  final List<String> addresses = [];

  late Future<void> _fetchUserDataFuture;

  String currentUser = '';
  String currentUserEmail = '';

  @override
  void initState() {
    super.initState();
    fetchCurrentUser();
    _fetchUserDataFuture = fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('users').get();

      print('Data count: ${snapshot.docs.length}'); // Debug statement

      // ignore: avoid_function_literals_in_foreach_calls
      snapshot.docs.forEach((doc) {
        final userData = doc.data() as Map<String, dynamic>;
        final username = userData['username'] as String;
        final email = userData['email'] as String;
        final gender = userData['gender'] as String;
        final address = userData['address'] as String;

        usernames.add(username);
        emails.add(email);
        genders.add(gender);
        addresses.add(address);
      });

      print('Usernames: $usernames'); // Debug statement
      print('Emails: $emails'); // Debug statement
      print('Genders: $genders'); // Debug statement
      print('Addresses: $addresses'); // Debug statement

      // Data successfully fetched
      // You can perform additional actions or updates here
    } catch (error) {
      // Error occurred while fetching data
      // Handle the error as per your requirement
      print('Error fetching user data: $error');
    }
  }

  Future<void> fetchCurrentUser() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final snapshot = await FirebaseFirestore.instance
            .collection('admin')
            .where('email', isEqualTo: currentUser.email)
            .limit(1)
            .get();

        if (snapshot.docs.isNotEmpty) {
          // ignore: unnecessary_cast
          final userData = snapshot.docs[0].data() as Map<String, dynamic>;
          final username = userData['username'] as String;
          setState(() {
            this.currentUser = username;
            currentUserEmail = currentUser.email ?? '';
          });
        }
      }
    } catch (error) {
      print('Error fetching current user: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin Page',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          color: Colors.white, // Set the color of the AppBar to white
        ),
      ),
      home: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: AppBar(
              elevation: 0,
              automaticallyImplyLeading: false,
              title: Padding(
                padding: const EdgeInsets.all(10.0), // Add padding here
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_sharp),
                      color: Colors.black,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AdminPage(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 10),
                    Image.asset(
                      'assets/images/Dole2.png',
                      width: 200.0,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 50,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundImage:
                          AssetImage('assets/images/profile-img.png'),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentUser,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            currentUserEmail,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              const Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "User Management",
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              // Display loading indicator or data table based on the future status
              FutureBuilder(
                future: _fetchUserDataFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return const Center(
                      child: Text('Error fetching user data'),
                    );
                  } else {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: [
                          const DataColumn(label: Text('Username')),
                          const DataColumn(label: Text('Email')),
                          const DataColumn(label: Text('Gender')),
                          const DataColumn(label: Text('Address')),
                        ],
                        rows: List<DataRow>.generate(
                          usernames.length,
                          (index) => DataRow(
                            cells: [
                              DataCell(Text(usernames[index])),
                              DataCell(Text(emails[index])),
                              DataCell(Text(genders[index])),
                              DataCell(Text(addresses[index])),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
