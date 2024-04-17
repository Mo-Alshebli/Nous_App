import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../constants/image_string.dart';
import '../global/common/toast.dart';
import 'DataBase/DataBase.dart';
import 'HomeScreen.dart';
import 'ReaitimeData.dart';
import 'chatbot.dart';
import 'loading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dart_openai/dart_openai.dart';
import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

import 'style.dart';


class VoicChat extends StatefulWidget {
  final int? conversationId;
  const VoicChat({Key? key, this.conversationId}) : super(key: key);
  @override
  _VoicChatScreenState createState() => _VoicChatScreenState();
}


class _VoicChatScreenState extends State<VoicChat> {
  bool showSecondAnimation = false; // State variable for second animation visibility
  bool mic=true;
  bool load=false;
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
  bool _StopStream = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    flutterTts = FlutterTts();
  }
  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => showToast(message: 'onStatus: $val'),
        onError: (val) => showToast(message: 'onError: $val'),
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
        _isListening = false;
       });
  }
  Future<void> addMessageWithDelay(String text,usertext) async {
    var data = await readData();
    if (text.trim().isEmpty) return;
    setState(() {
      isProcessing = true;
      _StopStream=true;
    } ); // Start streaming (show stop icon)
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
            if (item?.text != null) {
              for (var char in item!.text!.split('')) {
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
        _StopStream=true;
      });

      // Your existing setup
      await flutterTts.setLanguage("ar");
      await flutterTts.setVoice({"name": lang!, "locale": "ar"});
      await flutterTts.setSpeechRate(0.5);
      setState(() {
        colltext+=buffer;
      });
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
          load=true;

        });
      final response = await respons(text);
      addMessageWithDelay(response,text);

    } catch (e) {
      showToast(message: '$e .');
    }
    // Speak out the response
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
  @override
  Widget build(BuildContext context) {

    return
      Scaffold(

        backgroundColor: const Color(0xFF0A0E21), // A deep blue color
        appBar: AppBar(
          backgroundColor: kLightDarkColor,
          title: const Text(' المساعد الصوتي الذكي', style: TextStyle(color: Colors.orangeAccent)),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.orangeAccent),
            onPressed: () => Navigator.of(context).pop(),
          ),
          elevation: 0, // Removes the shadow under the app bar
        ),
        body: SafeArea(

          child: Stack(
            children:[

              Positioned.fill(
                child: Opacity(
                  opacity: 0.3,
                  child: Lottie.asset("assets/lotti/background_animation.json"),
                ),
              ),
              Center(
                child: Stack(
                  children: [
                    if(load)
                      Positioned(child: _buildProgressIndicator()),
                    if (_isListening) // Show listening related animations when _isListening is true
                      ...[
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              width: 500.0,
                              height: 300.0,
                              child: Lottie.asset("assets/lotti/wav.json"),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              width: 400.0,
                              height: 400.0,
                              child: Lottie.asset("assets/lotti/bak.json"),
                            ),
                          ),
                        ),

                      ],
                    if (!_isListening  )
                      Positioned(
                      left: 145,
                      bottom: 10,
                      child: GestureDetector(
                        onTap: (){_listen();

                          }, // Call the handler method,
                        child: Container(
                          width: 100.0,
                          height: 100.0,
                          child: Lottie.asset( "assets/lotti/microphon.json"),
                        ),
                      ),
                    ),
                    if (_isListening  )

                      Positioned(
                      left: 90,
                      bottom: -20,
                      child: GestureDetector(
                        onTap: (){_listen();

                        }, // Call the handler method,
                        child: Container(
                          width: 200.0,
                          height: 200.0,
                          child: Lottie.asset( "assets/lotti/stop.json" ),
                        ),
                      ),
                    ),
                    // Optionally, display the recognized text somewhere in your UI
                    if (!_isListening  )
                      Stack(
                        children:[
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () {
                              },
                              child: Center(
                                child: Container(
                                  width: 400.0,
                                  height: 400.0,
                                  child: Lottie.asset("assets/lotti/bak.json"),
                                ),
                              ),
                            ),
                          ) ,
                          if(_StopStream)
                          Positioned(
                          left: -72,
                          right: -40,
                          bottom: 80,
                          child: GestureDetector(
                            onTap: () {
                              stopStreaming();
                              _stopListening();
                              flutterTts.stop();

                              setState(() {
                                _StopStream=false;
                                load=false;

                              });
                            },
                            child: Center(
                              child: Container(
                                width: 150.0,
                                height: 150.0,
                                child: Lottie.asset("assets/lotti/stop.json"),
                              ),
                            ),
                          ),
                        ),

                        ]

                      ) ,



                  ],
                ),
              )],
          ),
        ),
      );
  }
}
