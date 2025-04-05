import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90),
        child: AppBar(
          title: const Padding(
            padding: EdgeInsets.only(top: 30),
            child: Text(
              'Setting',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          leading: const Padding(
            padding: EdgeInsets.only(top: 20),
            child: BackButton(),
          ),
          backgroundColor: const Color(0xFFECF5FF),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              color: const Color(0xFF092866),
              height: 1,
            ),
          ),
        ),
      ),
      body: ListView(
        children: const [
          ListTile(
            title:
                Text('Language', style: TextStyle(fontWeight: FontWeight.bold)),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
          ),
          Divider(),
          ListTile(
            title: Text('About App',
                style: TextStyle(fontWeight: FontWeight.bold)),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
          ),
        ],
      ),
    );
  }
}
