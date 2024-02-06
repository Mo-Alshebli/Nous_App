
import 'dart:convert';
import 'package:langchain/langchain.dart';
import 'package:langchain_openai/langchain_openai.dart';
import 'package:pinecone/pinecone.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:chromadb/chromadb.dart';
import 'package:dart_openai/dart_openai.dart' as openai;

import '../global/common/toast.dart';

String templatechat = '';

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

//
// class FindMatching {
//
//
//   Future<String> getMatching(String arguments) async {
//     var data = await readData();
//
//
//     final client = PineconeClient(
//       apiKey: data['Embbeding']['API_embedded'],
//     );
//     final embeddings = OpenAIEmbeddings(
//         apiKey:data['Openai_API']['api'] );
//     try {
//       final res = await embeddings.embedQuery(arguments);
//
//       QueryResponse queryResponse = await client.queryVectors(
//         indexName: data['Embbeding']['indexname'],
//         projectId: data['Embbeding']['proid'],
//         environment: data['Embbeding']['env'],
//         request: QueryRequest(
//           vector: res,
//         ),
//       );
//       print("====================kkk======");
//       print(queryResponse.matches[0].id);
//       return gettext([
//         queryResponse.matches[0].id,
//         queryResponse.matches[1].id,
//
//       ]);
//     } catch (e) {
//       showToast(message: 'Error No Internet :$e');
//       return 'Error'; // Handle the error appropriately
//     }
//   }
//
//   Future<String> gettext(var id) async {
//     var data = await readData();
//
//     final client = PineconeClient(
//         apiKey: data['Embbeding']['API_embedded']
//     );
//
//     try {
//       FetchResponse fetchResponse = await client.fetchVectors(
//         indexName: data['Embbeding']['indexname'],
//         projectId: data['Embbeding']['proid'],
//         environment: data['Embbeding']['env'],
//         ids: id,
//       );
//       var res_id = fetchResponse.vectors.keys.toList();
//       String text = '';
//       for (int i = 0; i < res_id.length; i++) {
//         text += utf8.decode(
//             fetchResponse.vectors[res_id[i]]?.metadata?['text'].codeUnits);
//       }
//       return text;
//     } catch (e) {
//       showToast(message: 'Error No Internet : $e');
//       return 'Error'; // Handle the error appropriately
//     }
//   }

Future<String?> DataMatching(String quary) async {
  var data = await readData();
  var embeddurl =data['Embbeding']['baseUrl'];
  var CollectionName =data['Embbeding']['CollectionName'];
  print("========================jjjj");
  print(embeddurl);

  // Initialize the Chroma client
  final client = ChromaClient(
    baseUrl: embeddurl,
  );
  // Create a new collection or get an existing one
  final collection = await client.getCollection(name: CollectionName);
  final embeddings = await getEmbedding(quary);
  print("=====================kkkk");

  // Perform a query
  final queryResults = await collection.query(
    queryEmbeddings: [embeddings], // Replace with actual embeddings
    nResults: 2,
  );

  // Print the results
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
    print("Error occurred: $e");
    return []; // Return an empty list in case of an error
  }
}
  Future<String> respons(String query) async {

    var data = await readData();
    try {

      final matchContext = await DataMatching(query);
      print(matchContext);


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
                  {$query}
      
                  البيانات من قاعدة البيانات:
                  {$matchContext}
                  
                  تعليمات الروبوت 'Nous':
                  {$templatechat}
      """;

      return template.toString();
    } catch (e) {
      showToast(message: '$e');
      return 'Error'; // Handle the error appropriately
    }
  }

