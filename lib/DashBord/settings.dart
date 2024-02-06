import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'DataBase/DataBase.dart';
import 'HomeScreen.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _selectedLanguage = 'Man';
  String _selectedAnswerLength = 'Short'; // Default answer length

  @override
  Widget build(BuildContext context) {
    List<String> languages = ['Man', 'Woman'];
    List<String> answerLengths = ['Short', 'Long']; // Answer lengths

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: Colors.cyan,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () async {

            DatabaseHelper dbHelper = DatabaseHelper.instance;
            int? latestConversationId = await dbHelper.getLatestConversationId();
            // Navigate back to the previous screen
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                    builder: (context) => ChatterScreen(conversationId:latestConversationId)));

          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Language Dropdown
            _buildDropdown('Select Language:', _selectedLanguage, languages, (String? newValue) {
              setState(() {
                _selectedLanguage = newValue!;
                if (_selectedLanguage=='Man'){
                  _saveLanguagePreference("ar-xa-x-ard-local");

                }
                else{
                  _saveLanguagePreference("es-us-x-sfb-local");

                }                       });
            }),

            SizedBox(height: 30),

            // Answer Length Dropdown
            _buildDropdown('Select Answer Length:', _selectedAnswerLength, answerLengths, (String? newValue) {
              setState(() {
                _selectedAnswerLength = newValue!;

                print(_selectedAnswerLength);
                if (_selectedAnswerLength=='Short'){
                  _saveAnswerLengthPreference("Short");

                }
                else if (_selectedAnswerLength=='Long'){
                  _saveAnswerLengthPreference("Long");

                }

              });

            }),

            // Add more settings options here
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(String title, String selectedValue, List<String> options, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        DropdownButton<String>(
          value: selectedValue,
          isExpanded: true,
          items: options.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: onChanged,
          style: TextStyle(color: Colors.black, fontSize: 16),
          underline: Container(
            height: 2,
            color: Colors.cyan,
          ),
        ),
      ],
    );
  }

  void _saveLanguagePreference(String language) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('lang', language);
  }

  void _saveAnswerLengthPreference(String answerLength) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('answerLength', answerLength);
    print("================djdjjdjdjjdjd");
  }
}
