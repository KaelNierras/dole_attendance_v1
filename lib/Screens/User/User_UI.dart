import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../loading/userload.dart';
import '../User/collapsible_list.dart';
import '../Login/Login_UI.dart';

class UserPage extends StatefulWidget {
  UserPage({Key? key}) : super(key: key);

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final List<Item> items = [
    Item(
      headerValue: 'Personal QR Code',
      expandedValue: 'assets/images/qrcode.png',
    ),
  ];

  late User? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? currentUser = auth.currentUser;

    setState(() {
      _user = currentUser;
      _isLoading = false;
    });
  }

  Future<void> _simulateLoading() async {
    await Future.delayed(Duration(seconds: 2)); // Adjust the duration as needed
  }

  void _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    print('Successfully Logged Out');
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return LoadingScreen();
    } else if (_user == null) {
      return LoginPage();
    } else {
      return MaterialApp(
        title: 'Admin Page',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          appBarTheme: const AppBarTheme(
            color: Colors.white,
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
                        onPressed: () => _signOut(context), // Sign out the user
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
                const SizedBox(
                  height: 50,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage:
                            AssetImage('assets/images/profile-img.png'),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Kyle Anthony Nierras",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              "kyleanthony47@gmail.com",
                              style: TextStyle(
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
}
