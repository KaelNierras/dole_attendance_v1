import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  // ignore: use_key_in_widget_constructors
  const LoadingScreen({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/Dole.png',
              width: 100.0,
            ),
            const SizedBox(height: 16.0),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.blue), // Customize the color
              strokeWidth: 3, // Customize the stroke width
            ),
          ],
        ),
      ),
    );
  }
}
