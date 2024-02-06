

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sqflite/sqflite.dart';
import '../constants/image_string.dart';
import '../global/common/toast.dart';
import 'DataBase/DataBase.dart'as db1;
import 'DataBase/DataBase.dart';
import 'chatbot.dart';
import 'navBar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dart_openai/dart_openai.dart';
import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

class ChatStream extends StatelessWidget {
  final List<Map<String, String>> messages;
  final Function(String) onDeleteMessage;
  final FlutterTts flutterTts; // Add this

  ChatStream({
    required this.messages,
    required this.onDeleteMessage,
    required this.flutterTts, // Add this

  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView(
        reverse: true,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        children: messages.reversed.map((message) {
          return MessageBubble(
            msgText: message['text']!,
            msgSender: message['sender']!,
            onDelete: onDeleteMessage,
            flutterTts: flutterTts, // Pass the flutterTts instance

          );

        }).toList(),
      ),
    );
  }
}

class MessageBubble extends StatefulWidget {
  final String msgText;
  final String msgSender;
  final Function(String) onDelete;
  final FlutterTts flutterTts; // Add this

  MessageBubble({
    required this.msgText,
    required this.msgSender,
    required this.onDelete,
    required this.flutterTts, // Add this
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  bool _isListening=false;
  String _selectedVoice = "es-us-x-sfb-local"; // Default voice

  final currentUser = FirebaseAuth.instance.currentUser;

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, // Make modal background transparent
      builder: (BuildContext context) {
        return SafeArea(
          child: Container(
            margin: const EdgeInsets.all(58.0), // Margin for the rounded corners
            decoration: BoxDecoration(
              color: Colors.white, // Background color of the bottom sheet
              borderRadius: BorderRadius.circular(25.0), // Rounded corners
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 15,
                  blurRadius: 17,
                  offset: const Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            child: Wrap(
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.copy, color: Colors.blue), // Custom icon color
                  title: const Text('نسخ', style: TextStyle(color: Colors.black)), // Custom text style
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: widget.msgText));
                    Navigator.pop(context);
                  },
                ),
                const Divider(), // Divider for a better visual separation
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red), // Custom icon color
                  title: const Text('حذف ', style: TextStyle(color: Colors.black)), // Custom text style
                  onTap: () {
                    widget.onDelete(widget.msgText);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  Future<void> _readMessage(String text) async {

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? lang = await prefs.getString('lang');
    print("====================");
    print(lang);
    if (text.isNotEmpty) {

      await widget.flutterTts.setLanguage("ar");
      await widget.flutterTts.setVoice({"name": lang!, "locale": "ar"});

      if (mounted) {
        setState(() => _isListening = false);
      }
      await widget.flutterTts.setSpeechRate(0.5);
      setState(() => _isListening = true); // Start speaking

      await widget.flutterTts.speak(text);

      // After speaking, set _isListening to false

    }
  }



  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: (widget.msgSender == "User")
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [

              Flexible(
                child: Material(
                  borderRadius: BorderRadius.circular(8),
                  elevation: 10,
                  color: (widget.msgSender == "User")
                      ? Colors.blue
                      : Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                    child: Text(
                      widget.msgText,
                      style: TextStyle(
                        fontSize: 15,
                        color: (widget.msgSender =="User")
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
              if (widget.msgSender !="User")
                Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(left: 0),
                      child: IconButton(
                        icon: Icon(
                            _isListening ? Icons.mic : Icons.mic_none, // Mic icon if listening, else mic off icon
                            color: _isListening ? Colors.red : Colors.black, // Red when listening, otherwise blue


                            size: 20),
                        onPressed: () {
                          if (_isListening) {
                            // If already listening (speaking), then stop
                            widget.flutterTts.stop();
                            setState(() => _isListening = false);
                          } else {
                            // If not listening, start reading the message
                            _readMessage(widget.msgText);

                          }
                        },

                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 0),
                      child: IconButton(
                        icon: const Icon(Icons.more_vert, size: 20),
                        onPressed: () => _showBottomSheet(context),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );

  }
  @override
  void dispose() {
    widget.flutterTts.stop(); // Stop any ongoing speech synthesis
    super.dispose();
  }
}
