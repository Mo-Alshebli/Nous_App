
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
 import 'package:sqflite/sqflite.dart';
import '../global/common/toast.dart';
import '../login_screen.dart';
import 'About.dart';
import 'ChatStream.dart';
import 'DataBase/DataBase.dart'as db1;
import 'DataBase/DataBase.dart';
import 'ReaitimeData.dart';
import 'VoisScreen.dart';
import 'chatbot.dart';
import 'loading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dart_openai/dart_openai.dart';
import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'pageNav/lastConversation.dart';
import 'style.dart';
import 'settings.dart';
import '../Category.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ChatterScreen extends StatefulWidget {
  final int? conversationId;

  const ChatterScreen({Key? key,  this.conversationId}) : super(key: key);

  @override
  _ChatterScreenState createState() => _ChatterScreenState();
}
final dbHelper = db1.DatabaseHelper.instance;
List<Map<String, String>> messages = [
  {
    'text': 'مرحبا، كيف أستطيع مساعدتك؟',
    'sender': 'ChatBot',
  },
];

class _ChatterScreenState extends State<ChatterScreen> {

  int? currentConversationId ;// Assuming 1 as a default value
  int? Numconv ;// Assuming 1 as a default value
  String buffer = "";
  String colltext="";
  bool isTextFieldEnabled = true;

  String voictextbuffer = "";
  StreamSubscription? chatStreamSubscription;
  late stt.SpeechToText _speech;
  final FlutterTts flutterTts = FlutterTts();
  bool isSendButtonVisible = false; // Initialize the visibility state as false
  bool isTextFieldEmpty=false;
  bool isSending=false;
  bool _isListening = false;
  final chatMsgTextController = TextEditingController();
  List<Map<String, String>> messages = [
    {
      'text': 'مرحبا، كيف أستطيع مساعدتك؟',
      'sender': 'ChatBot',
    },
  ];
  bool isProcessing = false;
  bool isTranscribing = false; // Flag to track ongoing transcription

  Future<void> saveConversation(int conversationId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('conversationId', conversationId);
  }


  Future<int?> getSavedConversationId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? x=prefs.getInt('conversationId');

    return x;
  }


  @override
  void initState() {
    super.initState();
    loadPreferences();
    if (widget.conversationId==null) {
      startNewConversation(); // Start a new conversation when the screen is first loaded
    }   setState(() {
      Numconv = widget.conversationId;

    });

    loadImagePath();
    _speech = stt.SpeechToText();
    int id=generateRandomNumber();

    saveConversation(widget.conversationId ?? 1 );
    if (widget.conversationId != null) {
      _loadChatHistoryForConversation(widget.conversationId ?? 1);
    }
    initAsync();
    // startNewConversation();
  }


  Future<void> initAsync() async {
    var data = await readData();
    OpenAI.apiKey = data['Openai_API']['api'];
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) {       },
        onError: (val) => showToast(message: 'onError: $val'),
      );
      if (available) {
        setState(() {
          _isListening = true;
          isTranscribing = true;
        });
        _speech.listen(
          onResult: (val) {
            if (val.finalResult) {
              _processFinalSpeechResult(val.recognizedWords);
            }
          },
          localeId: 'ar_SA',
        );
      }
    } else {
      setState(() {
        isTextFieldEnabled = true;  // Disable the text field
      });
      _stopListening();

    }
  }

  void _processFinalSpeechResult(String text) {
    setState(() {
      voictextbuffer = text;
      _isListening = false;
      isTranscribing = false;
    });
    _sendMessageAfterSpeech();
  }




  void _stopListening() async {
    setState(() {
      _isListening = false;
      isTranscribing = false;
      isProcessing = true;
    });
  }

  Future<void> _deleteMessage(String messageText) async {
    int? conversationId = await getSavedConversationId();
    if (conversationId != null) {
      int messageIndex = messages.indexWhere((msg) => msg['text'] == messageText);
      if (messageIndex > 0) {
        String senderMessage = messages[messageIndex - 1]['text']!;
        await dbHelper.deleteMessagePair(senderMessage, messageText, conversationId);
        setState(() {
          messages.removeAt(messageIndex);    // Remove chatbot message
          messages.removeAt(messageIndex - 1); // Remove sender message
        });
      }
    }
  }


  _loadChatHistoryForConversation(int conversationId) async {
    var dbMessages = await dbHelper.getMessagesForConversation(widget.conversationId!);
    setState(() {
      messages = dbMessages.map((e) => {
        'text': e['text'].toString(),
        'sender': e['sender'].toString(),
      }).toList();
    });
  }


  Future<Object?> Geminirespons(String inputText) async {
    print(inputText);
    try {
      final gemini = Gemini.instance;
      var response = await gemini.text(inputText);
      return response;
    } catch (e) {
      print('Error handling text: $e');
      return "";
    }
  }

  Future<Map<String, dynamic>> ModelName() async {
    DatabaseReference companytype = FirebaseDatabase.instance.ref('companyType');
    DataSnapshot snapshot = await companytype.get();
    if (snapshot.exists && snapshot.value is Map) {
      print("==============================");
      return Map<String, dynamic>.from(snapshot.value as Map);
      print("==============================");

    }else {
      showToast(message: 'The firebase is not allowed');
      return {"id":"null"};
    }
  }
  Future<String> resualt(userMessage) async {
    try {

      final response = await respons(userMessage);
      return response;
    } catch (e) {
      showToast(message: '$e .');
      showToast(message: '$e .');
      return '$e';
    }
  }

  Future<void> _sendMessageAfterSpeech() async {
    if (voictextbuffer.isNotEmpty) {
      Map<String, String> message = {
        'text': voictextbuffer,
        'sender': "User", // Null check added
      };
      messages.add(message);

      int? fetchedConversationId = await getSavedConversationId();
      if (fetchedConversationId != null) {
        dbHelper.insertMessage(
            {'text': message['text'], 'sender': message['sender']},
            fetchedConversationId);
      }
      String botResponse = await resualt(voictextbuffer);
      addMessageWithDelay(botResponse,voictextbuffer);
      voictextbuffer = "";
    }
  }

  final currentUser = FirebaseAuth.instance.currentUser;
  void sendMessage(String messageText) async {
    if (messageText.isNotEmpty || !messageText.contains("Error")) {
      setState(() {
        isProcessing = true;
      });
      Map<String, String> message = {
        'text': messageText,
        'sender': "User", // Null check added
      };
      messages.add(message);

      int? fetchedConversationId = await getSavedConversationId();
      if (fetchedConversationId != null) {
        dbHelper.insertMessage(
            {'text': message['text'], 'sender': message['sender']},
            fetchedConversationId);
      }
      chatMsgTextController.clear();
    }
    setState(() => isProcessing = true); // Start processing
  }




  Future<void> clearCurrentConversation() async {
    Database db = await dbHelper.database;
    int? fetchedConversationId = Numconv;
    if (fetchedConversationId != null) {
      int rowsDeletedMessages = await db.delete(
        DatabaseHelper.tableMessages,
        where: '${DatabaseHelper.columnConversationId} = ?',
        whereArgs: [fetchedConversationId],
      );
      int rowsDeletedConversation = await db.delete(
        DatabaseHelper.tableConversations,
        where: '${DatabaseHelper.columnConversationId} = ?',
        whereArgs: [fetchedConversationId],
      );
      if (rowsDeletedMessages > 0 ) {
        showToast(message: 'Conversation cleared!');
        int? highestConversationId = await dbHelper.getHighestConversationId();
        if (highestConversationId != null) {
          int newId = await dbHelper.createNewConversation(highestConversationId+1);
          setState(() {
            setState(() {
              Numconv=newId;
            });
            saveConversation(newId);
            currentConversationId = newId;
            messages = [
              {
                'text': 'مرحبا، كيف أستطيع مساعدتك؟',
                'sender': 'ChatBot',
              },
            ];  // clear current message list on screen
          });
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => ChatterScreen(conversationId: Numconv)));

        } else {
          showToast(message: 'Error creating new conversation.');
        }
      } else {
        showToast(message: 'Error clearing conversation.');
      }
    } else {
      showToast(message: 'No conversation ID found.');
    }
  }


  Future<void> startNewConversation() async {
    int newId = await dbHelper.createNewConversation();
    setState(() {
      setState(() {
        Numconv=newId;
      });
      saveConversation(newId);
      currentConversationId = newId;
      messages = [
        {
          'text': 'مرحبا، كيف أستطيع مساعدتك؟',
          'sender': 'ChatBot',
        },
      ];  // clear current message list on screen
    });
  }
  String convertToString(dynamic data) {
    if (data == null) {
      return "null";
    }

 if (data is List || data is Map) {
      // Converting collections to JSON strings
      return jsonEncode(data);
    } else {
      // Default to using toString for all other data types
      return data.toString();
    }
  }

  Future<void> handleGemini(String inputText,String usertext) async {
    try {

      final gemini = Gemini.instance; // Ensure Gemini's instance is correctly initialized
      var response = await gemini.text(inputText);
      var d=response!.content!.parts!.last!.text;
      String text=convertToString(d);
      // var decodedData = jsonDecode(response as String);
      //
      // // Access the nested text
      // String text = decodedData['Candidates']['Content']['parts'][0]['text'];
      //
      // // Convert the response into the expected format
      List<String> words = text.split(' ');
      print(words);
      // var content = [OpenAIChatCompletionChoiceMessageContentItemModel.text(response)];
      for (var item in words) {
        if (item != null) {
          // Process each character in the word
          for (var char in item.split('')) {
            buffer += char;
          }

          // After finishing the word, append a space to separate it from the next word
          buffer += ' '; // Add a space after each word before appending it to the text

          // Append the buffer to the text and update the state
          if (buffer.isNotEmpty) {
            appendText(buffer.trim()); // trim() is used to remove any trailing spaces just before appending
            setState(() {
              colltext += buffer;
            });
            buffer = ""; // Clear the buffer after adding to the colltext
          }
        }
      }
      finalProcessing(usertext,text);
    } catch (e) {
      print('Error handling text: $e');
      // Handle error by showing a toast or similar
      showToast(message: 'Error handling text: $e');
      setState(() => isProcessing = false); // Stop processing on error
    }
  }

  // Process the response (common logic for both OpenAI and Gemini)


  // Function to add a message with a delay and handle response using the appropriate model.
  Future<void> addMessageWithDelay(String text, String usertext) async {
    var data = await readData();
    if (text.trim().isEmpty) return;

    setState(() => isProcessing = true); // Start processing

    var id = await ModelName();
    if (id["id"] == "gemini") {
      print("[[[[[[[[[[[[[[[[[[[[[[]]]]]]]]]]]]]]]]]]]]]]");
      await handleGemini(text,usertext);
    } else {
      print("[[[[[[[[[[[[[[[[[[[[[[]]]]]]]]]]]]]]]]]]]]]]");
      print(id);
      var userMessage = OpenAIChatCompletionChoiceMessageModel(
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(text),
            ],
            role: OpenAIChatMessageRole.user,
          );

          chatStreamSubscription = OpenAI.instance.chat.createStream(
            model: data['Openai_API']['model_name'],
            messages: [userMessage],
          ).listen((streamChatCompletion) {
            final choices = streamChatCompletion.choices;
            if (choices != null && choices.isNotEmpty) {
              final content = choices.first.delta.content;
              if (content != null) {
          for (var item in content) {
            if (item!.text != null) {
              for (var char in item.text!.split('')) {
                buffer += char;
                if (char.trim().isEmpty) {
                  if (buffer.isNotEmpty) {
                    appendText(buffer);
                    setState(() {
                      colltext += buffer;
                    });
                    buffer = "";
                  }
                }
              }
            }
          }}
        }
      }, onDone: () async {
        finalProcessing(text,usertext);
      }, onError: handleError);
    }
  }

  // Finalize processing and handle common cleanup tasks
  void finalProcessing(String usertext ,String text) async {
    appendText(buffer);
    setState(() {
      colltext+=buffer;
    });
    if (colltext.isNotEmpty) {
      int humantokens=countTokens(text);
      await writeDataRealTime(usertext, colltext,humantokens);
    }else{
      showToast(message: "لم يتم حفظ النص لانه فارغ");
    }
    buffer = "";
    colltext="";
    int? fetchedConversationId = await getSavedConversationId();



    dbHelper.insertMessage({
      'text': messages.last['text']!,
      'sender': 'ChatBot',
    },fetchedConversationId!);
    setState(() => isProcessing = false); // Stop streaming (show send icon)
  }

  // Handle errors during streaming
  void handleError(error) {
    showToast(message: '$error');
    setState(() => isProcessing = false); // Handle error
  }

  bool isTextValid(String text) {
    // Check if text is empty or only contains whitespace
    if (text.trim().isEmpty || text.trim().length <= 1) {
      return false;
    }
    else{
      return true;
    }

    // Check if text contains any alphabetic character
    // return RegExp(r'[a-zA-Z]').hasMatch(text);
  }

  void appendText(String text) {
    setState(() {
      if (messages.isNotEmpty && messages.last['sender'] == 'ChatBot') {
        messages.last['text'] = messages.last['text']! + " " + text;
      } else {
        messages.add({
          'text': text,
          'sender': 'ChatBot',
        });
      }
    });
  }
  void stopStreaming() {
    buffer = "";
    chatStreamSubscription?.cancel(); // Cancel the stream subscription
    setState(() => isProcessing = false);
  }

  Widget _buildProgressIndicator() {
    return isProcessing
        ? Padding(
      padding: const EdgeInsets.all(8.0),
      child: Align(
        alignment: Alignment.topCenter,
        child: ThreeDotLoadingIndicator(
          color: kOrangeColor, // You can change the color
          size: 20.0, // And the size
        ),
      ),
    )
        : const SizedBox.shrink(); // Return an empty container when not processing
  }

  Widget _buildProgressStop() {
    return isProcessing
        ? Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 0, 65),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Container(
            width: 110, // Set the width of the button
            height: 25, // Set the height of the button
            child: FloatingActionButton(
              onPressed: () {
                stopStreaming();
                setState(() {
                  isTextFieldEmpty = false;
                });
              },
              backgroundColor: kOrangeColor, // Background color: red
              elevation: 4, // Elevation for a 3D effect
              shape: RoundedRectangleBorder( // Rounded corners
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Text("تـوقـف",style: TextStyle(color: Colors.white,fontFamily: 'lama'),)
            ),
          ),
        ),
      ),
    )
        : const SizedBox.shrink(); // Return an empty container when not processing
  }

  String dropdownValue="Chat";
  final Map<String, IconData> dropdownItems = {
    'Chat': Icons.chat,
    'Voic': Icons.voice_chat,
    // Add other items and their icons here
  };
  final GlobalKey<ScaffoldState> _key = GlobalKey();

  //==============================appBar==========================

  int? selectedCardIndex;
  late SharedPreferences prefs; // Declare SharedPreferences instance
  String? Selected_name;


  // String? username = await getUserUser();
  var selectedImageFile;
  Future<void> pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        selectedImageFile = File(image.path);
      });
      // Save the path
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('imagePath', image.path);
    }
  }
  Future<void> loadImagePath() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? imagePath = prefs.getString('imagePath');
    if (imagePath != null) {
      setState(() {
        selectedImageFile = File(imagePath);
      });
    }
  }


  // Asynchronous method to load preferences
  Future<void> loadPreferences() async {
    prefs = await SharedPreferences.getInstance();
    Selected_name = prefs.getString('Selected_name'); // Make sure the key matches what you set
    setState(() {
      // This will trigger a rebuild with the updated value
    });
  }
  //==============================appBar==========================




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,

      drawer: Drawer(
        backgroundColor: kBlueDarkColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: kLightDarkColor),
              accountName: FutureBuilder<String?>(
                future: getUserUser(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text('Loading...');
                  } else {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      return Text(
                        snapshot.data ?? 'No Username',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }
                  }
                },
              ),
              accountEmail: FutureBuilder<String?>(
                future: getUserEmail(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text('Loading...');
                  } else {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      return Text(
                        snapshot.data ?? 'No Email',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }
                  }
                },
              ),
              currentAccountPicture: GestureDetector(
                onTap: () {
                  pickImage(); // Call the method to pick an image
                },
                child: CircleAvatar(
                  backgroundImage: selectedImageFile != null ? FileImage(selectedImageFile) : null,
                  radius: 30,
                  child: selectedImageFile == null ? Icon(Icons.add_a_photo) : null,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                " الجهة المحددة",
                style: TextStyle(color: kOrangeColor, fontSize: 15),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: GestureDetector(
                onTap: () {},
                child: Card(
                  color: Colors.white.withOpacity(0.07),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.grey, width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    title: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('${Selected_name}',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.published_with_changes_sharp,
                color: Colors.white,
              ),
              title: const Text(' تغير الجهة',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => MyPage()));
              },
            ),

            Divider(
              color: Colors.grey,
            ),
            ListTile(
              leading: Icon(
                Icons.home,
                color: Colors.white,
              ),
              title: const Text('المحادثات السابقة',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => ConversationsListPage()));
              },
            ),
            ListTile(
              leading: Icon(
                Icons.settings,
                color: Colors.white,
              ),
              title: const Text('الإعدادات',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              onTap: () async {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => SettingsPage(conversationId: Numconv),
                  ),
                );             },
            ),
            ListTile(
              leading: Icon(
                Icons.person_pin_outlined,
                color: Colors.white,
              ),
              title: const Text('من نحن',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              onTap: () async {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => AboutUsPage(),
                  ),
                );             },
            ),
            ListTile(
              leading: Icon(
                Icons.logout,
                color: Colors.white,
              ),
              title: const Text('تسجيل الخروج ',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              onTap: () async {
                await FirebaseAuth.instance.signOut();

                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => LoginScreen(),
                  ),
                );             },
            ),


          ],
        ),
      ),
    appBar: AppBar(
        backgroundColor: kBlueDarkColor,
          title: Center(child: Text("$Selected_name Assistant",style: TextStyle(color:kOrangeColor),)),
      leading:                     IconButton(
        icon: Icon(
          Icons.menu,
          color: Colors.white,
          size: 30,
        ),
        onPressed: () {
          _key.currentState!.openDrawer();
        },
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(
            Icons.add_comment_outlined, // Just an example, replace with any icon you need
            color: kGreen,
            size: 30,
          ),
          onPressed: () {
            startNewConversation();          },
        ),
        IconButton(
          icon: Icon(
            Icons.headphones, // Just an example, replace with any icon you need
            color: kGreen,
            size: 30,
          ),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => VoicChat()));
            },
        ),

      ],

    ),



      body: Directionality(
        textDirection: TextDirection.ltr,
        child: Container(
          color: kBlueDarkColor,
          child: Column(
            children: [
              // Place IconButton directly in the Column for it to appear at the top
              // Expanded widget to fill the remaining space with your Stack layout
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 0), // Adjusted padding to avoid overlap
                  child:Stack(

                      children: [

                        // Container(
                        //   decoration: const BoxDecoration(
                        //     image: DecorationImage(
                        //       image: AssetImage(chatback), // Replace with your image asset path
                        //       fit: BoxFit.contain, // Contain the image within the center of the container
                        //       alignment: Alignment.center, // Center the image
                        //     ),
                        //   ),
                        // ),



                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            // initializeDateFormatting().then((_) => runApp( MyApp())),
                            ChatStream(
                              messages: messages,
                              onDeleteMessage: _deleteMessage,
                              flutterTts: flutterTts, // Pass the flutterTts instance
                            ),

                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 0),
                              child: Row(
                                // crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  MaterialButton(
                                    shape: const CircleBorder(),
                                    color: _isListening ? Colors.red: kGreen,
                                    onPressed:()
                                    {

                                      _listen();



                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Icon(
                                        _isListening ? Icons.mic : Icons.mic_none , // Mic icon if listening, else mic off icon
                                        color:Colors.white,
                                        size: _isListening ? 30 : 25
                                        ,// Red when listening, otherwise blue
                                      ),
                                    ),
                                  ),

                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                      child: SizedBox(
                                        height: 45,
                                        child: Material(
                                          borderRadius: BorderRadius.circular(10),
                                          color: Colors.white70,
                                          elevation: 5,
                                          child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                              child:TextField(
                                                enabled: isTextFieldEnabled,
                                                decoration: const InputDecoration(
                                                  border: InputBorder.none,
                                                  contentPadding: EdgeInsets.symmetric(vertical: 14.0),
                                                  hintText: 'اكتب رسالتك...', // Add the hint text
                                                ),
                                                onChanged: (value) {
                                                  setState(() {
                                                  });
                                                },
                                                controller: chatMsgTextController,
                                                textAlign: TextAlign.right,
                                                textDirection: TextDirection.rtl,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontFamily: 'lama',
                                                ),
                                              )


                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (!isTextFieldEmpty)
                                    MaterialButton(
                                      shape: const CircleBorder(),
                                      color: kGreen,
                                      onPressed: () async {
                                        if (isProcessing) {
                                          stopStreaming(); // Implement this to handle stopping
                                        }

                                        else {
                                          setState(()  {
                                            isSending = true;

                                          });
                                          String Text_ = chatMsgTextController.text;
                                          if(!isTextValid(Text_)){
                                            setState(() {
                                              isTextFieldEmpty=true;

                                            });
                                            showToast(message: "الرسالة فارغة ");
                                          }
                                          else{
                                            sendMessage(Text_);
                                            String botResponse = await resualt(Text_);
                                            await addMessageWithDelay(botResponse,Text_);

                                            if(!isTextValid(Text_)){
                                              setState(() {
                                                isTextFieldEmpty=true;

                                              });
                                            }
                                          }// Assumes you start sending the message
                                          // Implement your sending logic here, then set isSending to false once done
                                        }

                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Icon(
                                          // Choose icon based on whether we are currently sending or processing
                                          Icons.send,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),


                                ],
                              ),
                            )
                          ],
                        ),

                        Positioned(child: _buildProgressIndicator()),
                        Positioned(child: _buildProgressStop()),


                      ]
                  ),
                ),
              ),
            ],
          ),
        ),
      ),




    );
  }
}



