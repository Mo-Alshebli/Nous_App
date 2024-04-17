import 'package:firebase_database/firebase_database.dart';

Future<Map<String, String>> getCompanyNamesAndIds() async {
  final databaseReference = FirebaseDatabase.instance.ref();
  DataSnapshot snapshot = await databaseReference.child('').get();

  Map<String, String> companyNamesAndIds = {};

  if (snapshot.exists && snapshot.value is Map) {
    Map<dynamic, dynamic> companies = snapshot.value as Map<dynamic, dynamic>;
    companies.forEach((key, value) {
      if (value is Map ) {
        print(value);
      }
    });
  } else {
    print('No company information available.');
  }

  return companyNamesAndIds;
}
