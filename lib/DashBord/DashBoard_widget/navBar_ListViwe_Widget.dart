import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:idea_chatbot/DashBord/style.dart';

import 'package:flutter/material.dart';

import '../../global/common/toast.dart';

class ListViewpro extends StatelessWidget {
  const ListViewpro({
    Key? key,
    required this.title,
    required this.icon,
    required this.onTap,
    required this.onDelete,
  }) : super(key: key);

  final String title;
  final Icon icon;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    // Enhanced container with padding and alignment
    return Padding(
      padding: const EdgeInsets.all(10),
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor, // Dynamic color based on theme
            borderRadius: BorderRadius.circular(20),
            // boxShadow: [
            //   BoxShadow(
            //     color: Colors.grey.withOpacity(0.5),
            //     spreadRadius: 1,
            //     blurRadius: 5,
            //     offset: Offset(0, 3),
            //   ),
            // ],
          ),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            leading: icon,
            title: Text(
              title,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
          ),
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
      showToast(message: "Error logging out");
    }
  }
}


// class ListViewPro extends StatelessWidget {
//   final String title;
//   final Icon icon;
//   final Map<String, String> companyNamesAndIds; // Changed to Map
//   final String? selectedCompanyName; // Nullable to handle initial state
//   final Function(String?, String?) onChanged; // Adjusted to pass company name and ID
//
//   const ListViewPro({
//     required this.title,
//     required this.icon,
//     required this.companyNamesAndIds,
//     this.selectedCompanyName,
//     required this.onChanged,
//     Key? key,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.all(10),
//       child: Align(
//         alignment: Alignment.centerRight,
//         child: ListTile(
//           tileColor: const Color.fromARGB(39, 33, 149, 243),
//           contentPadding: const EdgeInsets.fromLTRB(40, 0, 40, 0),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20),
//           ),
//           leading: icon, // Use the passed Icon
//           title: DropdownButton<String>(
//             value: selectedCompanyName,
//             icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
//             elevation: 16,
//             style: const TextStyle(color: Colors.black),
//             onChanged: (String? newValue) {
//               onChanged(newValue, companyNamesAndIds[newValue]);
//             },
//             items: companyNamesAndIds.entries
//                 .map<DropdownMenuItem<String>>((MapEntry<String, String> entry) {
//               return DropdownMenuItem<String>(
//                 value: entry.key,
//                 child: Text(
//                   entry.key,
//                   textDirection: TextDirection.rtl,
//                 ),
//               );
//             }).toList(),
//           ),
//         ),
//       ),
//     );
//   }
// }
