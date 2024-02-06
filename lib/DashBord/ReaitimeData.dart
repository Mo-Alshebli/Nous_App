
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../global/common/toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'dart:math';


String? getUserEmail() {
  User? user = FirebaseAuth.instance.currentUser;
  return user?.email; // This will return the email or null if no user is logged in.
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
    showToast(message: 'Failed to write messages data in real time: $error');
  }
}





String generateUserId() {
  var uuid = Uuid();
  return uuid.v4();  // Generates a version 4 UUID, which is a random UUID
}

Future<void> UserData() async {
  var num=generateUserId();
  String currentDateTime = getCurrentDateTime();

  User? user = FirebaseAuth.instance.currentUser;
  var emai=user?.email;
  var name=user?.displayName;
  final prefs = await SharedPreferences.getInstance();
  String? idcom=await prefs.getString('company_id');
  await prefs.setString('num',num);
  DatabaseReference databaseRef = FirebaseDatabase.instance.ref('Users/$idcom/$num');
  Map<String, dynamic> messagesData = {

    "UserName": "$name",
    "Email": "$emai",
    "DataAndTime":"$currentDateTime"

  };


  try {
    // كتابة البيانات في الوقت الفعلي
    await databaseRef.set(messagesData);
  } catch (error) {
    showToast(message: 'Failed to write messages data in real time: $error');
  }
}