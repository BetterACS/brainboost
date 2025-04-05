import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Setting',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: const BackButton(),
        backgroundColor: const Color(0xFFECF5FF),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1), // กำหนดความสูงของเส้น Divider
          child: Container(
            color: Colors.grey, // สีของเส้น Divider
            height: 1, // ความหนาของเส้น Divider
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
