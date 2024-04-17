import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'dart:convert'; // For JSON encoding
import 'dart:io'; // For file operations
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../global/common/toast.dart';
import 'package:uuid/uuid.dart';
import 'dart:math';
import 'package:path_provider/path_provider.dart'; // Add path_provider dependency
Future<String?> getUserUser()async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  var username=await prefs.getString('username');

  User? user = FirebaseAuth.instance.currentUser;
  print(user?.displayName);
  if (user?.displayName!=null){
    return user?.displayName;

  }
  else{
    return username;
  }

}
Future<String?> getUserEmail() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  var email=await prefs.getString('email');
  User? user = FirebaseAuth.instance.currentUser;
  if (user?.displayName!=null){
    return user?.email; // This will return the email or null if no user is logged in.

  }
  else{
    return email;
  }
}
String getCurrentDateTime() {
  DateTime now = DateTime.now();
  return "${now.year}-${now.month}-${now.day} ${now.hour}:${now.minute}:${now.second}";
}
int countTokens(String text) {
  if (text.isEmpty) {
    return 0;
  }
  // Splitting the text by spaces to get words (tokens)
  List<String> tokens = text.split(' ');
  return tokens.length;
}
double calculateCost(int tokenCount, double ratePerThousandTokens) {
  return (tokenCount / 1000) * ratePerThousandTokens;
}
Future<void> writeDataRealTime(var Human,ChatText,humantokens) async {
  String currentDateTime = getCurrentDateTime();
  int chattokens=countTokens(ChatText);
  int sumtokens=humantokens+chattokens;
  double cost = calculateCost(sumtokens, 0.035); // Using the rate of $0.0080 per 1K tokens

  final prefs = await SharedPreferences.getInstance();
  String? idcom=await prefs.getString('company_id');
  String? num=await prefs.getString('num');
  int? conversationId = await prefs.getInt('conversationId');
  ;

  DatabaseReference databaseRef = FirebaseDatabase.instance.ref('Messages/$idcom/$num/$conversationId');
  Map<String, dynamic> messagesData = {

    "ChatMessage": "$ChatText",
    "CostMessage": "$cost",
    "DateTime": "$currentDateTime",
    "HumanMessage": "$Human",
    "NumTokens": "$sumtokens",


  };
  try {
    // كتابة البيانات في الوقت الفعلي
    await databaseRef.push().set(messagesData);

  } catch (error) {
    showToast(message: 'خطاء في تخزين الرسائل في قاعدة البيانات : $error');
  }
}
Future<void> fetchData() async {
  final DatabaseReference databaseReference = FirebaseDatabase.instance.ref();
  final List<String> nodes = [
    'APIS',
    'Admin',
    'CompanyInformation',
    'Messages',
    'Palance',
    'Users',
  ];

  Map<String, dynamic> allData = {};
  for (String node in nodes) {
    DatabaseEvent event = await databaseReference.child(node).once();
    // Check if snapshot.value is not null and is a Map before casting.
    if (event.snapshot.value != null && event.snapshot.value is Map) {
      Map<String, dynamic> nodeData = Map<String, dynamic>.from(event.snapshot.value as Map);
      allData[node] = nodeData;
    } else {
      // Handle the case where data is null or not a map.
      allData[node] = {}; // Assign an empty map if data is null or invalid.
    }
  }
  // Convert allData to JSON String
  String jsonString = jsonEncode(allData);
  // Get the directory where you can save the file.
  final directory = await getApplicationDocumentsDirectory();
  final path = directory.path;
  final file = File('$path/file.json');
  // Save JSON String to file
  await file.writeAsString(jsonString);
}
Future<Map<String, dynamic>> readJsonFromFile() async {
  fetchData();
  final directory = await getApplicationDocumentsDirectory(); // Get the app's documents directory
  final file = File('${directory.path}/file.json'); // File path
  if (await file.exists()) {
    // If the file exists, read it
    String contents = await file.readAsString();
    Map<String, dynamic> json = jsonDecode(contents);

    return json; // The JSON data as a Dart map
  } else {
    // If the file doesn't exist, you can handle it accordingly
    showToast(message: "لا يوجد بيانات قم بتشغيل التطبيق من جديد لتحملها من قاعدة البيانات ");
    return {};
  }
}
Future<List<String>> getCategories() async {
  var data = await readJsonFromFile();
  // Assuming data["CompanyInformation"] is a Map
  var companyInformation = data["CompanyInformation"];
  // Initialize an empty list to store unique categories
  List<String> categories = [];
  // Check if companyInformation is indeed a Map
  if (companyInformation is Map) {
    // Iterate over the map entries
    companyInformation.forEach((key, value) {
      // Assuming each value is a Map that contains a "category" key
      if (value is Map) {
        String category = value["catogry"];catogry
            :
        if (!categories.contains(category)) {
          categories.add(category);
        }
      }
    });
  }
  return categories;
}
Future<List<String>> getNamesByCategory(String category) async {
  var data = await readJsonFromFile();
  var companyInformation = data["CompanyInformation"];
  List<String> names = [];
  companyInformation.forEach((key, value) {
    if (value["catogry"] == category) {
      names.add(value["Name"]);
    }
  });

  return names;
}
Future<String?> getIdByName(String name) async {
  // Parse the JSON data into a Map
  var data = await readJsonFromFile();

  // Assuming data["CompanyInformation"] is a Map
  var companyInformation = data["CompanyInformation"];
  // Iterate over each entry in the data
  for (var entry in companyInformation.entries) {
    if (entry.value["Name"] == name) {
      // Return the ID (key) if the name matches
      return entry.key;
    }
  }

  // Return null if no match is found
  return null;
}
Future<Map<String, List<String>>> getUserNameAndEmail(String id) async {
  var data = await readJsonFromFile();
  // Assuming data["CompanyInformation"] is a Map
  var companyInformation = data["Users"];
  // Initialize an empty list to store unique categories
  List<String> Emails = [];
  List<String> UserNames = [];
  // Check if companyInformation is indeed a Map
  if (companyInformation[id] is Map) {
    // Iterate over the map entries
    companyInformation[id].forEach((key, value) {
      // Assuming each value is a Map that contains a "category" key
          if (value is Map) {
            String Email = value["Email"];
            String usename = value["UserName"];
            // Add the category to the list if it's not already included
            if (!Emails.contains(Email)) {
              Emails.add(Email);
            }
            if (!UserNames.contains(usename)) {
              UserNames.add(usename);
            }
          }



    });
  }

  return {'Emails': Emails, 'UserNames': UserNames};
}
String generateUserId() {
  var uuid = Uuid();
  return uuid.v4();  // Generates a version 4 UUID, which is a random UUID
}
int generateRandomNumber() {
  // Create a random object
  final random = Random();
  // Generate a random integer between 1 and 1000
  // Random.nextInt(n) generates a value from 0 to n - 1, so we add 1 to shift the range to 1 to 1000
  return random.nextInt(1000) + 1;
}
Future<void> UserData() async {
  final prefs = await SharedPreferences.getInstance();
  String? idcom = await prefs.getString('company_id');
  var num=generateUserId();
  String currentDateTime = getCurrentDateTime();
  var result = await getUserNameAndEmail(idcom!); // This awaits the Future to complete
  List<String> emails = result["Emails"]!; // Correctly accessing the map
  List<String> userNames = result["UserNames"]!;
  User? user = FirebaseAuth.instance.currentUser;
  bool emailFound = false;  // Flag to check if email is found
  var emai=user?.email;
  var name=user?.displayName;
  for (var email in emails) {
    if (email == emai) {
      showToast(message: "اهلا وسهلا بك مجددا");
      emailFound = true;
      break;
    }
  }
  if (!emailFound) {
    await prefs.setString('num', num);
    DatabaseReference databaseRef = FirebaseDatabase.instance.ref('Users/$idcom/$num');
    Map<String, dynamic> userData = {
      "UserName": name,
      "Email": emai,
      "DataAndTime": currentDateTime
    };

    try {
      // Write the data in real time
      await databaseRef.set(userData);
    } catch (error) {
      showToast(message: 'مشكلة اثناء كتابة البيانات الخاصة بلمستخدمين في قاعدة البيانات: $error');
    }
  }

}