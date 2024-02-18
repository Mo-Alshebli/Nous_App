
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../constants/image_string.dart';
import '../global/common/toast.dart';
import '../login/login_screen.dart';
import 'DashBoard_widget/navBar_ListViwe_Widget.dart';
import 'pageNav/lastConversation.dart';
import 'settings.dart';

class NavBar extends StatefulWidget {
  @override
  _NavBarState createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  final currentUser = FirebaseAuth.instance.currentUser;
  ImageProvider? _userImage;
  final _prefsKey = 'user_image_path';
  Map<String, String> companyNamesAndIds = {};
  String? selectedCompanyName;
  String? selectedCompanyid;
  final databaseReference = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    _loadSavedImage();
    getCompanyNames();

  }

  _loadSavedImage() async {
    final prefs = await SharedPreferences.getInstance();
    final imagePath = prefs.getString(_prefsKey);
    if (imagePath != null) {
      setState(() {
        _userImage = FileImage(File(imagePath));
      });
    } else {
      _userImage = AssetImage(Login);  // Default Image
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString(_prefsKey, pickedFile.path);
      setState(() {
        _userImage = FileImage(File(pickedFile.path));
      });
    }
  }// This function directly returns a Future<String> which will be used with a FutureBuilder
  Future<String> getUsername() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // This will return the username if it exists or "Anonymous" if not.
    print("=========================");
    print(prefs.getString('username') ?? currentUser?.displayName ?? "Anonymous");
    return prefs.getString('username') ?? currentUser?.displayName ?? "Anonymous";
  }


  Future<void> getCompanyNames() async {
    DataSnapshot snapshot = await databaseReference.child('CompanyInformation')
        .get();
    if (snapshot.exists && snapshot.value is Map) {
      Map<dynamic, dynamic> companies = snapshot.value as Map<dynamic, dynamic>;
      Map<String, String> namesAndIds = {};
      companies.forEach((key, value) {
        if (value is Map && value['Name'] != null) {
          namesAndIds[value['Name']] = key;
          print("======================k=================");
          print(namesAndIds[value['Name']]);
          // Access the first key
          // حفظ الاسم مع الـ ID
        }
      });
      setState(() {
        companyNamesAndIds = namesAndIds;
        var keysList = companies.keys.toList();
        selectedCompanyid = keysList[0] ;
        print(selectedCompanyid);});
    } else {
      print('No data available.');
    }
  }

  Future<void> saveCompanyId(String? companyname,String? companyId) async {
    if (companyname != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('company_name', companyname);
      await prefs.setString('company_id', companyId!);
      print('Saved Company ID: $companyId');
    }
  }

  @override
  Widget build(BuildContext context) {
    void handleDropdownSelection(String? newValue) {
      if (newValue != null) {
        print("====================");
        print(newValue);
        setState(() {
        });
      }
    }


// Use userName as needed

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: FutureBuilder<String>(
              future: getUsername(), // Call the getUsername method
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  // If we can get the username, show it; otherwise, show "Anonymous"
                  final username = snapshot.hasData ? snapshot.data : "Anonymous";
                  return UserAccountsDrawerHeader(
                    accountName: Text(
                      username!,
                      style: TextStyle(color: Colors.black),
                    ),
                    accountEmail: Text(
                      currentUser?.email ?? "No Email",
                      style: TextStyle(color: Colors.black),
                    ),
                    currentAccountPicture: CircleAvatar(
                      backgroundImage: _userImage,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      image: DecorationImage(
                        image: AssetImage(back_image),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                } else {
                  // While the future is not yet resolved, show a placeholder
                  return UserAccountsDrawerHeader(
                    accountName: CircularProgressIndicator(),
                    accountEmail: Text(
                      currentUser?.email ?? "No Email",
                      style: TextStyle(color: Colors.black),
                    ),
                    currentAccountPicture: CircleAvatar(
                      backgroundImage: AssetImage(Login), // Default image
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      image: DecorationImage(
                        image: AssetImage(back_image),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                }
              },
            ),
          ),

          listViewpro(
              title: "المحادثات السابقة",
              icon: Icon(Icons.message),
              onTap: () =>{

              Navigator.of(context).pushReplacement(
              MaterialPageRoute(
              builder: (context) => ConversationsListPage())),

          }),
          listViewpro(
              title: "الاعدادات",
              icon: Icon(Icons.settings),
              onTap: () =>{

                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                        builder: (context) => SettingsPage())),

              }),
          ListViewPro(
            title: "اختار الجهة",
            icon: Icon(Icons.business),
            companyNamesAndIds: companyNamesAndIds, // Your map of company names and IDs
            selectedCompanyName: selectedCompanyName, // Current selected company name
            onChanged: saveCompanyId, // Callback function for when a company is selected
          ),
          listViewpro(
            title: "تسجيل الخروج ",
            icon: Icon(Icons.logout),
            onTap: () {
              logOut(context);
            },
          ),
        ],
      ),
    );
  }
}
Future<void> logOut(BuildContext context) async {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? currentUser = _auth.currentUser;

  if (currentUser == null) {
    showToast(message: 'No user is currently signed in.');
    return;
  }

  try {
    await attemptDeleteAccount(context, currentUser,_auth);
  } catch (e) {
    showToast(message: 'An error occurred: $e');
  }
}

Future<void> attemptDeleteAccount(BuildContext context, User currentUser,_auth) async {
  try {
    // Show loading dialog (implement this according to your UI)

    await currentUser.delete();
    showToast(message: 'User account deleted successfully.');
    await _auth.signOut();
    navigateToLoginScreen(context);
  } on FirebaseAuthException catch (e) {
    if (e.code == 'requires-recent-login') {
      // Handle reauthentication
      String? password = await promptForPassword(context);
      if (password != null) {
        await reauthenticateUser(currentUser, password);
        await attemptDeleteAccount(context, currentUser,_auth); // Retry after successful reauthentication
      }
    } else {
      showToast(message: 'Error: ${e.message}');
    }
  } finally {
    // Dismiss loading dialog (implement this according to your UI)
  }
}

Future<void> reauthenticateUser(User currentUser, String password) async {
  AuthCredential credential = EmailAuthProvider.credential(
    email: currentUser.email!,
    password: password,
  );

  await currentUser.reauthenticateWithCredential(credential);
}

void navigateToLoginScreen(BuildContext context) {
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (context) => LoginScreen()),
        (Route<dynamic> route) => false,
  );
}

Future<String?> promptForPassword(BuildContext context) async {
  TextEditingController passwordController = TextEditingController();

  return showDialog<String>(
    context: context,
    barrierDismissible: false, // The user must tap a button to dismiss the dialog
    builder: (context) {
      return AlertDialog(
        title: Text('Reauthentication Required'),
        content: TextField(
          controller: passwordController,
          obscureText: true,
          decoration: InputDecoration(hintText: "Enter your password"),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Submit'),
            onPressed: () {
              Navigator.of(context).pop(passwordController.text);
            },
          ),
        ],
      );
    },
  );
}
