import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    home: SettingsPage(),
  ));
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          title: const Padding(
            padding: EdgeInsets.only(top: 20),
            child: Text(
              'Setting',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF092866),
              ),
            ),
          ),
          centerTitle: true,
          leading: const Padding(
            padding: EdgeInsets.only(top: 20),
            child: BackButton(color: Colors.black),
          ),
          backgroundColor: const Color(0xFFECF5FF),
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(
              color: const Color(0xFF092866),
              height: 1,
            ),
          ),
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Language',
                style: TextStyle(fontWeight: FontWeight.bold)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const LanguageSelectionPage()),
              );
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('About App',
                style: TextStyle(fontWeight: FontWeight.bold)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutAppPage()),
              );
            },
          ),
          const Divider(),
        ],
      ),
    );
  }
}

class LanguageSelectionPage extends StatefulWidget {
  const LanguageSelectionPage({super.key});

  @override
  _LanguageSelectionPageState createState() => _LanguageSelectionPageState();
}

class _LanguageSelectionPageState extends State<LanguageSelectionPage> {
  String _selectedLanguage = 'English'; // ค่าเริ่มต้นที่ถูกเลือก

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          title: const Padding(
            padding: EdgeInsets.only(top: 20),
            child: Text(
              'Language',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF092866),
              ),
            ),
          ),
          centerTitle: true,
          leading: const Padding(
            padding: EdgeInsets.only(top: 20),
            child: BackButton(color: Colors.black),
          ),
          backgroundColor: const Color(0xFFECF5FF),
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(
              color: const Color(0xFF092866),
              height: 1,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          RadioListTile<String>(
            title: const Text('English',
                style: TextStyle(fontWeight: FontWeight.bold)),
            value: 'English',
            groupValue: _selectedLanguage,
            onChanged: (value) {
              setState(() {
                _selectedLanguage = value!;
              });
            },
            activeColor: const Color(0xFF05235F),
          ),
          const Divider(),
          RadioListTile<String>(
            title: const Text('Thai',
                style: TextStyle(fontWeight: FontWeight.bold)),
            value: 'Thai',
            groupValue: _selectedLanguage,
            onChanged: (value) {
              setState(() {
                _selectedLanguage = value!;
              });
            },
            activeColor: const Color(0xFF05235F),
          ),
          const Divider(),
        ],
      ),
    );
  }
}

class AboutAppPage extends StatelessWidget {
  const AboutAppPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          title: const Padding(
            padding: EdgeInsets.only(top: 20),
            child: Text(
              'About App',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF092866),
              ),
            ),
          ),
          centerTitle: true,
          leading: const Padding(
            padding: EdgeInsets.only(top: 20),
            child: BackButton(color: Colors.black),
          ),
          backgroundColor: const Color(0xFFECF5FF),
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(
              color: const Color(0xFF092866),
              height: 1,
            ),
          ),
        ),
      ),
      body: ListView(
        children: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Text(
              'Version 3.3.1',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF05235F),
              ),
            ),
          ),
          Divider(),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: Text(
              'Terms of Use',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF05235F),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: Text(
              'Play to learn application make you\nmemorize class lecture more efficiently',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
