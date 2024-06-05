import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chromadb/chromadb.dart';
import 'package:dart_openai/dart_openai.dart' as openai;
import 'dart:convert';
import 'package:http/http.dart' as http;
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
    return {"id":"null","url":"null"};
  }
}

Future<Map<String, dynamic>> readData() async {
  final prefs = await SharedPreferences.getInstance();
  String? idcom=await prefs.getString('company_id');
  DatabaseReference databaseRef = FirebaseDatabase.instance.ref('APIS/$idcom');
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
    include: [
      Include.embeddings,
      Include.metadatas,
      Include.documents,
      Include.distances,
    ]

  );
    var limit = 1.4;
// Use the null-aware access operator `?.` and `[]` to safely access the elements
    // Use the null assertion operator `!` because we've checked that it is not null and not empty
    double? firstDistance = queryResults.distances?[0][0];
    double? secondDistance = queryResults.distances?[0][1];
    // Ensure both distances are not null before comparing
    if (firstDistance != null && firstDistance < limit && secondDistance != null && secondDistance < limit ) {

      // Code to handle the case where the first distance is less than the limit
      return queryResults.documents?[0][0];

    }
    else if (secondDistance != null && secondDistance > limit) {
      return "لا توجد معلومات في قاعدةالبيانات قم باجابة السؤال من تلقاء نفسك";
      // Code to handle the case where the second distance is less than the limit
    }
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

Future<Map<String, dynamic>> sendRequest(String userMessage) async {
  var data_ = await readData();
  var serverurl = await ModelName();
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  // Check if starting a new conversation
  bool isNewConversation = prefs.getBool('startNewConversation') ?? false;
  if (isNewConversation) {
    // Clear the history if new conversation
    await prefs.setStringList('userMessageHistory', []);
    await prefs.setBool('startNewConversation', false); // Reset the flag
  }

  // Save the current message to history
  List<String> history = prefs.getStringList('userMessageHistory') ?? [];
  history.add(userMessage);
  await prefs.setStringList('userMessageHistory', history);

  var prompt = "";
  String? templ = await prefs.getString('answerLength');
  if (templ == "Short") {
    prompt = data_['Openai_API']['Shorttemplate'];
  } else {
    prompt = data_['Openai_API']['Template'];
  }

  var CollectionName= data_["Embbeding"]["CollectionName"];
  print(history);
  var url = Uri.parse(serverurl["url"]); 
  print(url);// Adjust as necessary
  var data = {
    "text": userMessage,
    "collectionName": CollectionName,
    "prompt": prompt,
    "history": history,  // Send history along with the current message

  };
  var headers = {'Content-Type': 'application/json'};

  try {
    var response = await http.post(
      url,
      headers: headers,
      body: json.encode(data),
    ).timeout(Duration(seconds: 60));

    if (response.statusCode == 200) {
      var responseJson = jsonDecode(utf8.decode(response.bodyBytes));

      return responseJson;
    } else {
      throw Exception("Failed to get response");
    }
  } catch (e) {
    throw Exception("An error occurred while requesting");
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
                  $templatechat
                  
                  \n\n\n
                    سؤال المستخدم                    $query
      \n\n
                  البيانات من قاعدة البيانات                  $matchContext
                  
                 
                  
      """;

      return template.toString();
    } catch (e) {
      showToast(message: '$e');
      return 'Error'; // Handle the error appropriately
    }
  }

