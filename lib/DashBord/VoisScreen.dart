import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../constants/image_string.dart';
import '../global/common/toast.dart';
import 'DataBase/DataBase.dart';
import 'HomeScreen.dart';
import 'ReaitimeData.dart';
import 'chatbot.dart';
import 'navBar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dart_openai/dart_openai.dart';
import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';


class VoicChat extends StatefulWidget {
  final int? conversationId;
  const VoicChat({Key? key, this.conversationId}) : super(key: key);
  @override
  _VoicChatScreenState createState() => _VoicChatScreenState();
}

class _VoicChatScreenState extends State<VoicChat> {
  bool showSecondAnimation = false; // State variable for second animation visibility
  bool mic=true;
  late stt.SpeechToText _speech;
  late FlutterTts flutterTts;
  bool _isListening = false;
  String buffer = "";
  String colltext = "";
  String bufferdon = "";
  bool don=false;
  String lang='Man';
  bool isProcessing = false;
  StreamSubscription? chatStreamSubscription;
  String _text = '';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    flutterTts = FlutterTts();
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) {
            setState(() {
              _text = val.recognizedWords;
              if (val.finalResult) {
                _isListening = false;
                _processVoiceInput(_text);
              }
            });
          },
          localeId: 'ar_SA', // Set your locale
        );
      }
    } else {
      _stopListening();
    }
  }


  void _stopListening() {
    _speech.stop();
    setState(() {
        _isListening = false;});
  }
  void setupTts() async {

  }

  Future<void> addMessageWithDelay(String text,usertext) async {
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
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        lang =prefs.getString('lang')!;

      });

      // Your existing setup
      await flutterTts.setLanguage("ar");
      await flutterTts.setVoice({"name": lang!, "locale": "ar"});
      await flutterTts.setSpeechRate(0.5);
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
      // await writeDataRealTime(usertext,colltext,humantokens);


      // Speak
      await flutterTts.speak(bufferdon);
      // Adding the completion handler
      flutterTts.setCompletionHandler(() {
        setState(() {
          mic=!mic;

        });
print("====================================");
        // Add any other actions you want to perform after speaking here
      });
      setState(() {

  don=false;
  showSecondAnimation=false;
  mic=!mic;
  bufferdon="";
  colltext="";
});
      buffer = "";
        }, onError: (error) {
      showToast(message: '$error');
      setState(() => isProcessing = false); // Error occurred, stop streaming

    });
  }

  Future<int?> getSavedConversationId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? x=prefs.getInt('conversationId');
    return x;
  }
  void appendText(String text) {
    setState(() {

      bufferdon+=text;
      } );
  }
  void stopStreaming() {
    chatStreamSubscription?.cancel(); // Cancel the stream subscription
  }
  Future<void> _processVoiceInput(String text) async {
    // Process the text and get the response
    try {
      setState(() {

          don=true;
          showSecondAnimation=true;

        });
      final response = await respons(text);
      addMessageWithDelay(response,text);

    } catch (e) {
      showToast(message: '$e .');
    }
    // Speak out the response
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(

      endDrawer: NavBar(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Center(child: Text('روبوت نوس')),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () async {
            DatabaseHelper dbHelper = DatabaseHelper.instance;
            int? latestConversationId = await dbHelper.getLatestConversationId();
            // Navigate back to the previous screen
            flutterTts.stop();
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                    builder: (context) => ChatterScreen(conversationId:latestConversationId)));
            },
        ),),
      body: Card(
        margin: EdgeInsets.all(10),
        child: Stack(
          children: [
            if (showSecondAnimation) //wev
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 500.0,
                    height: 300.0,
                    child: Lottie.asset(wav),
                  ),
                ),
              ),
            if (don )//loop
              Positioned(
                top: 0,
                left:-10,
                right: -30,
                child: Center(
                  child: Container(
                    width: 600.0,
                    height: 500.0,
                    child: Lottie.asset(roboy_loop),
                  ),
                ),
              ),

            // First Lottie animation (centered)
            if (!showSecondAnimation)
              Positioned(
              top: 0,
              left:-10,
              right: -30,
                child: GestureDetector(
                onTap: () {
                  print("object");

                },
              child: Center(
                child: Container(
                  width: 500.0,
                  height: 500.0,
                  child: Lottie.asset(robot),
                ),
              ),
            )),

            // GestureDetector for the second Lottie animation
            // if(mic)
            Positioned(
              left: 140,
              bottom: 90,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    showSecondAnimation =!showSecondAnimation;
                    don=!don;
                    // mic=!mic;// Toggle the visibility of the second animation

                  });
                  _listen();

                },
                child: Container(
                  width: 100.0,
                  height: 100.0,
                  child: Lottie.asset(microphon),
                ),
              ),
            ),
            if(!mic)
              Positioned(
                left: 110,
                bottom: -30,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      print("================");
                      flutterTts.stop();
                      setState(() {
                        mic=!mic;

                      });
                      // mic=!mic;// Toggle the visibility of the second animation

                    });

                  },
                  child: Container(
                    width: 150.0,
                    height: 150.0,
                    child: Lottie.asset(stop),
                  ),
                ),
              ),
            // Second Lottie animation (displayed conditionally)

          ],
        ),
      ),
    );
  }
}
