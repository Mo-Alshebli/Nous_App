import 'dart:ffi';

import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:chromadb/chromadb.dart';
import 'package:dart_openai/dart_openai.dart' as openai;

import '../global/common/toast.dart';
import '../init_Firebase.dart';

String templatechat = '';

Future<Map<String, dynamic>> ModelName() async {
  DatabaseReference companytype = FirebaseDatabase.instance.ref('companyType');
  DataSnapshot snapshot = await companytype.get();
  if (snapshot.exists && snapshot.value is Map) {
   return Map<String, dynamic>.from(snapshot.value as Map);

  }else {
    showToast(message: 'The firebase is not allowed');
    return {"id":"null"};
  }
}

Future<Map<String, dynamic>> readData() async {

  final prefs = await SharedPreferences.getInstance();
  String? idcom=await prefs.getString('company_id');
  DatabaseReference databaseRef = FirebaseDatabase.instance.ref('APIS/$idcom');
  DatabaseReference companytype = FirebaseDatabase.instance.ref('companyType');

  DataSnapshot snapshot = await databaseRef.get();

  if (snapshot.exists && snapshot.value is Map) {
    return Map<String, dynamic>.from(snapshot.value as Map);
  } else {
    showToast(message: 'The firebase is not allowed');
    return {
      'Openai_API': {'model_name': '', 'api': '', 'Template': ''},
      'Embbeding': {'indexname': '', 'proid': '', 'env': '', 'API_embedded': ''}
    };
  }
}
Future<void> handleText(String inputText) async {
  try {
    final gemini = Gemini.instance;
    var response = await gemini.text(inputText);
  } catch (e) {
    showToast(message:'Error handling text: $e');
  }
}


Future<String?> DataMatching(String quary) async {
  getCompanyNamesAndIds();
  var data = await readData();
  var embeddurl =data['Embbeding']['baseUrl'];
  var CollectionName =data['Embbeding']['CollectionName'];

  // Initialize the Chroma client
  final client = ChromaClient(
    baseUrl: embeddurl,
  );
  // Create a new collection or get an existing one
  final collection = await client.getCollection(name: CollectionName);
  final embeddings = await getEmbedding(quary);

  // Perform a query
  final queryResults = await collection.query(
    queryEmbeddings: [embeddings], // Replace with actual embeddings
    nResults: 2,
  );

  return queryResults.documents?[0][0];
}

Future<List<double>> getEmbedding(String inputText) async {
  var data = await readData();
  var api =data['Openai_API']['api'];
  var Model_embedd =data['Embbeding']['Model_Embedd'];
  openai.OpenAI.apiKey = api;

  try {
    // Create an embedding
    final embedding = await openai.OpenAI.instance.embedding.create(
      model: Model_embedd,
      input: inputText,
    );

    // Extract and return the embeddings as a list of doubles
    return embedding.data[0].embeddings;

  } catch (e) {
   showToast(message:"Error occurred: $e");
    return []; // Return an empty list in case of an error
  }
}
  Future<String> respons(String query) async {

    var data = await readData();
    try {

      final matchContext = await DataMatching(query);


      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? templ = await prefs.getString('answerLength');
      if(templ=="Short"){
         templatechat =data['Openai_API']['Shorttemplate'];
      }
      else{
         templatechat =data['Openai_API']['Template'];
      }

      String template ="""
                    سؤال المستخدم:
                  $query
      
                  البيانات من قاعدة البيانات:
                  $matchContext
                  
                 تعليمات الروبوت 'Nous':
                  $templatechat
      """;

      return template.toString();
    } catch (e) {
      showToast(message: '$e');
      return 'Error'; // Handle the error appropriately
    }
  }

