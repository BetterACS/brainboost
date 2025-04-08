import 'package:flutter/material.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setting Support'),
        leading: const BackButton(),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('This is Support Page', style: TextStyle(fontSize: 20)),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
