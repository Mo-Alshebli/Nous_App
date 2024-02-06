
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import '../constants/image_string.dart';
import '../global/common/toast.dart';
import 'ChatStream.dart';
import 'DataBase/DataBase.dart'as db1;
import 'DataBase/DataBase.dart';
import 'ReaitimeData.dart';
import 'VoisScreen.dart';
import 'chatbot.dart';
import 'loading.dart';
import 'navBar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dart_openai/dart_openai.dart';
import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

import 'settings.dart';

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
  int currentConversationId = 1;  // Assuming 1 as a default value
  String buffer = "";
  String colltext="";
  bool isTextFieldEnabled = true;

  String voictextbuffer = "";
  StreamSubscription? chatStreamSubscription;
  late stt.SpeechToText _speech;
  final FlutterTts flutterTts = FlutterTts();

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
    _speech = stt.SpeechToText();
    saveConversation(widget.conversationId ?? 1);
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
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
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
    print("========================lllllllllllllllllllllllll");
    print(dbMessages);
    setState(() {
      messages = dbMessages.map((e) => {
        'text': e['text'].toString(),
        'sender': e['sender'].toString(),
      }).toList();
    });
  }




  Future<String> resualt(userMessage) async {
    try {
      final response = await respons(userMessage);
      return response;
    } catch (e) {
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
    int? fetchedConversationId = await getSavedConversationId();
    if (fetchedConversationId != null) {
      int rowsDeletedMessages = await db.delete(
          DatabaseHelper.tableMessages,
          where: '${DatabaseHelper.columnConversationId} = ?',
          whereArgs: [fetchedConversationId]
      );
      int rowsDeletedConversation = await db.delete(
          DatabaseHelper.tableConversations,
          where: '${DatabaseHelper.columnConversationId} = ?',
          whereArgs: [fetchedConversationId]
      );

      if (rowsDeletedMessages > 0 && rowsDeletedConversation > 0) {
        showToast(message: 'Conversation cleared!');
        int? highestConversationId = await dbHelper.getHighestConversationId();
        if (highestConversationId != null) {
          await dbHelper.createNewConversation(highestConversationId + 1); // create new conversation with ID incremented by 1
        } else {
          await dbHelper.createNewConversation(); // if no highest conversation ID was found, create a new one with default ID logic
        }
        setState(() {
          messages.clear();
        });
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


  Future<void> addMessageWithDelay(String text,String usertext) async {
    var data = await readData();
    if (text.trim().isEmpty) return;

    setState(() => isProcessing = true); // Start streaming (show stop icon)
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
            if (item.text != null) {
              for (var char in item.text!.split('')) {
                buffer += char;
                if (char.trim().isEmpty) {
                  if (buffer.isNotEmpty) {
                    appendText(buffer);
                    setState(() {
                      colltext+=buffer;
                    });
                    buffer = "";
                  }
                }
              }
            }
          }
        }
      }
    },onDone: () async {
      appendText(buffer);
      setState(() {
        colltext+=buffer;
      });
      print("-=-=-=-=-==-=-==-=-");
      print(colltext);
      if (colltext.isNotEmpty) {
        int humantokens=countTokens(text);
        await writeDataRealTime(usertext, colltext,humantokens);
      }else{
        showToast(message: "لم يتم حفظ النص لانه فارغ");
      }
      buffer = "";
      int? fetchedConversationId = await getSavedConversationId();
      dbHelper.insertMessage({
        'text': messages.last['text']!,
        'sender': 'ChatBot',
      },fetchedConversationId!);
      setState(() => isProcessing = false); // Stop streaming (show send icon)
    }, onError: (error) {
      showToast(message: '$error');
      setState(() => isProcessing = false); // Error occurred, stop streaming

    });
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
          color: Colors.blue, // You can change the color
          size: 15.0, // And the size
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        endDrawer: NavBar(),
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Center(child: Text('روبوت نوس ')),
          leading: PopupMenuButton<int>(
            icon: const Icon(Icons.more_vert, color: Colors.black), // Customize the icon color
            offset: const Offset(100, 60), // Adjust position
            shape: const RoundedRectangleBorder( // Custom shape with rounded corners
              borderRadius: BorderRadius.all(Radius.circular(15.0)),
              side: BorderSide(color: Colors.grey), // Border color
            ),          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 1,
              child: ListTile(
                leading: Icon(Icons.add_comment_outlined, color: Colors.green), // Custom icon color
                title: Text(
                  'بداء محادثة جديدة',
                  style: TextStyle(color: Colors.black), // Custom text style
                ),
              ),
            ),
            const PopupMenuItem(
              value: 2,
              child: ListTile(
                leading: Icon(Icons.cleaning_services_outlined, color: Colors.red), // Custom icon color
                title: Text(
                  'حذف المحادثة الحالية',
                  style: TextStyle(color: Colors.black), // Custom text style
                ),
              ),
            ),
          ],
            onSelected: (value) async {
              if (value == 1) {
                await startNewConversation();
              } else if (value == 2) {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('حذف المحادثة'),
                    content: const Text('هل تريد حذف المحادثة الحالية ?'),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('لا'),
                        onPressed: () {
                          Navigator.of(ctx).pop();
                        },
                      ),
                      TextButton(
                        child: const Text('نعم'),
                        onPressed: () async {
                          await clearCurrentConversation();
                          Navigator.of(ctx).pop();
                        },
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ),

        body: Stack(
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
                  ChatStream(
                    messages: messages,
                    onDeleteMessage: _deleteMessage,
                    flutterTts: flutterTts, // Pass the flutterTts instance
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        MaterialButton(
                          shape: const CircleBorder(),
                          color: Colors.blue,
                          onPressed:()
                          {
                            setState(() {
                              isTextFieldEnabled = false;  // Disable the text field
                            });
                            _listen();


                            },
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Icon(
                              _isListening ? Icons.mic : Icons.mic_none, // Mic icon if listening, else mic off icon
                              color: _isListening ? Colors.red : Colors.white, // Red when listening, otherwise blue
                            ),
                          ),
                        ),
                        Expanded(
                          child: Material(
                            borderRadius: BorderRadius.circular(50),
                            color: Colors.white70,
                            elevation: 5,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8.0, top: 2, bottom: 2),
                              child: TextField(
                                enabled: isTextFieldEnabled, // Use the state variable here

                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                ),
                                onChanged: (value) {},
                                controller: chatMsgTextController,
                              ),
                            ),
                          ),
                        ),
                        MaterialButton(
                          shape: const CircleBorder(),
                          color: Colors.blue,
                          onPressed: () async {
                            if (isProcessing) {
                              stopStreaming(); // Call to stop streaming
                            } else {
                              String Text = chatMsgTextController.text;
                              if(!isTextValid(Text)){
                                showToast(message: "الرسالة فارغة ");
                              }
                              else{
                                sendMessage(Text);
                                String botResponse = await resualt(Text);
                                await addMessageWithDelay(botResponse,Text);
                              }


                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Icon(
                              isProcessing ? Icons.stop : Icons.send, // Stop icon if processing, else send icon
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: 150, // Set the width of the dropdown
                  height: 30, // Set the height of the dropdown
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: Colors.white70, // Background color of the dropdown
                    borderRadius: BorderRadius.circular(10.0), // Rounded corners
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5), // Shadow color
                        spreadRadius: 2,
                        blurRadius: 7,
                        offset: Offset(0, 3), // Changes position of shadow
                      ),
                    ],
                  ),
                  child:  Center(
                    child:Center(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: dropdownValue,
                          isExpanded: true,
                          icon: const Icon(Icons.arrow_drop_down_outlined, color: Colors.black, size: 20),
                          elevation: 10,
                          onChanged: (String? newValue) {
                            setState(() {
                              dropdownValue = newValue!;
                            });
                            if (newValue == 'Voic') {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) => VoicChat()), // Navigate to VoicChat
                              );
                            }
                          },
                          items: dropdownItems.entries.map<DropdownMenuItem<String>>((entry) {
                            return DropdownMenuItem<String>(
                              value: entry.key,
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                                child: Row(
                                  children: [
                                    Icon(entry.value, color: Colors.black, size: 16), // Icon specific to each item
                                    SizedBox(width: 5),
                                    Flexible(
                                      child: Text(
                                        entry.key,
                                        style: TextStyle(fontSize: 14),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                          dropdownColor: Colors.white,
                        ),
                      ),
                    ),
                  )

                )),              _buildProgressIndicator(),


            ]
        )
    );
  }
}



