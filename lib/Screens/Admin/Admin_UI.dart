import 'package:flutter/material.dart';
import '../Admin/collapsible_list.dart';
import '../Admin/UserManage.dart';
import '../Login/Login_UI.dart';
import '../loading/adminload.dart'; // Import the loading screen file
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({Key? key}) : super(key: key);

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final List<Item> items = [
    Item(
      headerValue: 'Personal QR Code',
      expandedValue: 'assets/images/qrcode.png',
    ),
    Item(
      headerValue: 'Attendance Report',
      expandedValue: 'assets/images/samplegraph.png',
    ),
  ];

  bool isLoading = true; // Set this flag based on your loading condition

  String currentUser = '';
  String currentUserEmail = '';

  @override
  void initState() {
    super.initState();
    _loadData(); // Call your loading data function
    fetchCurrentUser();
  }

  Future<void> _loadData() async {
    // Simulating loading data process
    await Future.delayed(Duration(seconds: 2));

    // Update the loading state
    setState(() {
      isLoading = false;
    });
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
        appBarTheme: AppBarTheme(
          color: Colors.white,
        ),
      ),
      home: isLoading
          ? LoadingScreen() // Display the loading screen if isLoading is true
          : Scaffold(
              appBar: PreferredSize(
                preferredSize: const Size.fromHeight(kToolbarHeight),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: AppBar(
                    elevation: 0,
                    automaticallyImplyLeading: false,
                    title: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/images/Dole2.png',
                            width: 200.0,
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.logout),
                            color: Colors.black,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginPage(),
                                ),
                              );
                            },
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
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  currentUserEmail,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.people),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => UserManage()),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 50),
                    const Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Hi, Kyle.",
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Welcome!",
                            style: TextStyle(
                              color: Color.fromARGB(150, 1, 140, 232),
                              fontSize: 25,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 50),
                    Expanded(
                      child: SingleChildScrollView(
                        child: CollapsibleList(items: items),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
