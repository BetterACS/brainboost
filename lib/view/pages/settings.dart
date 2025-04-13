import 'package:brainboost/view/widgets/colors.dart';
import 'package:brainboost/core/language/notifier.dart';
import 'package:brainboost/main.dart';
import 'package:brainboost/provider/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MaterialApp(
    home: SettingsPage(),
  ));
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return Scaffold(
      backgroundColor:
          isDarkMode ? AppColors.backgroundDarkmode : AppColors.mainColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          title: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Text(
              AppLocalizations.of(context)!.settings,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDarkMode ? AppColors.mainColor : AppColors.buttonText,
              ),
            ),
          ),
          centerTitle: true,
          leading: Padding(
            padding: EdgeInsets.only(top: 20),
            child: BackButton(
                color: isDarkMode ? AppColors.mainColor : AppColors.gray),
          ),
          backgroundColor:
              isDarkMode ? AppColors.accentDarkmode : AppColors.buttonText,
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(
              color:
                  isDarkMode ? AppColors.accentDarkmode : AppColors.buttonText,
              height: 1,
            ),
          ),
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text(
              AppLocalizations.of(context)!.language,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDarkMode ? AppColors.white : AppColors.buttonText,
              ),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LanguageSelectionPage(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            title: Text(
              AppLocalizations.of(context)!.aboutapp,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDarkMode ? AppColors.white : AppColors.buttonText,
              ),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AboutAppPage(),
                ),
              );
            },
          ),
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
  late LanguageNotifier _languageNotifier;
  late String _selectedLanguage;

  @override
  void initState() {
    super.initState();
    _languageNotifier = GetIt.instance<LanguageNotifier>();
    // Set the initial selected language based on the current locale
    _selectedLanguage =
        _languageNotifier.locale.languageCode == 'en' ? 'English' : 'Thai';
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return Scaffold(
      backgroundColor:
          isDarkMode ? AppColors.backgroundDarkmode : AppColors.mainColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          title: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Text(
              AppLocalizations.of(context)!.language,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
          ),
          centerTitle: true,
          leading: const Padding(
            padding: EdgeInsets.only(top: 20),
            child: BackButton(color: Colors.black),
          ),
          backgroundColor:
              isDarkMode ? AppColors.accentDarkmode : AppColors.buttonText,
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(
              color: isDarkMode
                  ? AppColors.backgroundDarkmode
                  : AppColors.buttonText,
              height: 1,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          RadioListTile<String>(
            title: Text(
              'English',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDarkMode ? AppColors.white : AppColors.buttonText,
              ),
            ),
            value: 'English',
            groupValue: _selectedLanguage,
            onChanged: (value) {
              setState(() {
                _selectedLanguage = value!;
              });
              _languageNotifier.setLocale = const Locale('en');
            },
            activeColor: isDarkMode ? AppColors.white : AppColors.buttonText,
          ),
          RadioListTile<String>(
            title: Text(
              'Thai',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDarkMode ? AppColors.white : AppColors.buttonText,
              ),
            ),
            value: 'Thai',
            groupValue: _selectedLanguage,
            onChanged: (value) {
              setState(() {
                _selectedLanguage = value!;
              });
              _languageNotifier.setLocale = const Locale('th');
            },
            activeColor: isDarkMode ? AppColors.white : AppColors.buttonText,
          ),
        ],
      ),
    );
  }
}

class AboutAppPage extends StatelessWidget {
  const AboutAppPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return Scaffold(
      backgroundColor:
          isDarkMode ? AppColors.backgroundDarkmode : AppColors.mainColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          title: const Padding(
            padding: EdgeInsets.only(top: 20),
            child: Text(
              'About App',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
          ),
          centerTitle: true,
          leading: const Padding(
            padding: EdgeInsets.only(top: 20),
            child: BackButton(color: Colors.black),
          ),
          backgroundColor:
              isDarkMode ? AppColors.accentDarkmode : AppColors.buttonText,
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(
              color:
                  isDarkMode ? AppColors.accentDarkmode : AppColors.buttonText,
              height: 1,
            ),
          ),
        ),
      ),
      body: ListView(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Text(
              'Version 3.3.1',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isDarkMode ? AppColors.white : AppColors.buttonText,
              ),
            ),
          ),
          const Divider(),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: Text(
              'Terms of Use',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isDarkMode ? AppColors.white : AppColors.buttonText,
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: Text(
              'Play to learn application make you\nmemorize class lecture more efficiently',
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? AppColors.white : AppColors.accentDarkmode,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
