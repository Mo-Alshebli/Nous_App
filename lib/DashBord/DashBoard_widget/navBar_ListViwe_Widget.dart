import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class listViewpro extends StatelessWidget {
  const listViewpro({
    required this.title,
    required this.icon,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  final String title;
  final Icon icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      child: Align(
        alignment: Alignment.centerRight,
        child: ListTile(
          tileColor: Color.fromARGB(39, 33, 149, 243),
          contentPadding: EdgeInsets.fromLTRB(40, 0, 40, 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          leading: icon, // Use the passed Icon
          title: Text(
            title, // Use the passed title
            textDirection: TextDirection.rtl,
            style: TextStyle(
              color: Color.fromARGB(255, 0, 0, 0),
            ),
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}

class logout extends StatelessWidget {
  const logout({
    required this.title,
    required this.icon,
    Key? key,
    required Null Function() onPressed,
  }) : super(key: key);

  final String title;
  final Icon icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      child: Align(
        alignment: Alignment.bottomRight,
        child: ListTile(
          tileColor: Color.fromARGB(39, 243, 33, 33),
          contentPadding: EdgeInsets.fromLTRB(40, 0, 40, 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          leading: icon, // Use the passed Icon
          title: Text(
            title, // Use the passed title
            textDirection: TextDirection.rtl,
            style: TextStyle(
              color: Color.fromARGB(255, 0, 0, 0),
            ),
          ),
          onTap: logoutFromAcount,
        ),
      ),
    );
  }

  void logoutFromAcount() async {
    try {
      // Sign out the user from Firebase Authentication
      await FirebaseAuth.instance.signOut();

      // Exit the app
      SystemNavigator.pop();
    } catch (e) {
      print('Error logging out: $e');
    }
  }
}
