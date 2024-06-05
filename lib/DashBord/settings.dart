import 'package:flutter/material.dart';
import 'package:idea_chatbot/DashBord/style.dart';
import 'package:idea_chatbot/global/common/toast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'HomeScreen.dart';
// Assuming HomeScreen.dart and style.dart are correctly imported.

class SettingsPage extends StatefulWidget {
  final int? conversationId;

  const SettingsPage({Key? key, this.conversationId}) : super(key: key);
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int _selectedLanguageIndex = 0;
  int _selectedAnswerLengthIndex = 0;
  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  void _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int savedLanguageIndex = prefs.getInt('selectedLanguageIndex') ?? 0;
    int savedAnswerLengthIndex = prefs.getInt('selectedAnswerLengthIndex') ?? 0;
    setState(() {
      _selectedLanguageIndex = savedLanguageIndex;
      _selectedAnswerLengthIndex = savedAnswerLengthIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> languages = ['رجـل', 'إمـراة'];
    List<String> answerLengths = ['قـصيـر', 'طـويل'];

    return Scaffold(
      backgroundColor: kLightDarkColor,
      appBar: AppBar(
        title: Text(
          'الإعدادات',
          style: TextStyle(color: Colors.white, fontSize: 25),
        ),
        backgroundColor: Theme.of(context).primaryColor, // Assuming a primary color is set
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => ChatterScreen(conversationId: widget.conversationId)));

          }
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              _buildSectionTitle("قم باختيار الصوت المراد النطق بها"),
              _buildOptionCards(languages, _selectedLanguageIndex, 0),
              SizedBox(height: 30),
              _buildSectionTitle("قم باختيار كمية البيانات المعروضة"),
              _buildOptionCards(answerLengths, _selectedAnswerLengthIndex, 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(
      title,
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
    ),
  );

  Widget _buildOptionCards(List<String> options, int selectedIndex, int baseIndex) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: List.generate(
      options.length,
          (index) => Expanded(
        child: _buildCard(baseIndex + index, options[index]),
      ),
    ),
  );

  Widget _buildCard(int index, String name) {
    bool isSelected = index == _selectedLanguageIndex || index == _selectedAnswerLengthIndex + 2;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () => _onCardTap(index),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: isSelected ? kGreen : kOrangeColor,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [BoxShadow(color: Colors.black.withOpacity(0.2), spreadRadius: 0, blurRadius: 10, offset: Offset(0, 4))]
                : [],
          ),
          child: ListTile(
            leading: Icon(isSelected ? Icons.check : Icons.circle, color: isSelected ? Colors.white : Colors.grey[700]),
            title: Text(name, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  void _onCardTap(int index) {
    setState(() {
      if (index < 2) {
        _selectedLanguageIndex = index;
        _savePreference('selectedLanguageIndex', index );
        _savePreference('language', index == 0 ? "ar-xa-x-ard-local" : "es-us-x-sfb-local");
      } else {
        _selectedAnswerLengthIndex = index - 2;
        _savePreference('selectedAnswerLengthIndex', index - 2);
        _savePreference('answerLength', index == 2 ? "Short" : "Long");
      }
    });
  }

  void _savePreference(String key, dynamic value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (value is int) {
      await prefs.setInt(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    } else {
      // Handle other types or throw an error
      showToast(message: "Unsupported type for SharedPreferences");
    }
  }

}
