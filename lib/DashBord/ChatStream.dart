import 'style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter/services.dart';
import '../constants/image_string.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:url_launcher/url_launcher.dart';
class ChatStream extends StatelessWidget {
  final List<Map<String, String>> messages;
  final Function(String) onDeleteMessage;
  final FlutterTts flutterTts;

  ChatStream({
    required this.messages,
    required this.onDeleteMessage,
    required this.flutterTts,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView(
        reverse: true,
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        children: messages.reversed.map((message) {
          return MessageBubble(
            msgText: message['text'] ?? '', // Providing a default value to avoid null
            msgSender: message['sender'] ?? '', // Providing a default value to avoid null
            onDelete: onDeleteMessage,
            flutterTts: flutterTts,
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
  final FlutterTts flutterTts;

  MessageBubble({
    required this.msgText,
    required this.msgSender,
    required this.onDelete,
    required this.flutterTts,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  bool _isListening = false;
  late AudioPlayer player;

  @override
  void initState() {
    super.initState();
    _initializeTts();
  }

  Future<void> _initializeTts() async {
    player = AudioPlayer();
    player.setReleaseMode(ReleaseMode.stop);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? lang = prefs.getString('language') ;

    if (lang == null) {
      // Handle null case, maybe set a default value or show an error message
      lang = 'ar-xa-x-ard-local'; // Example: defaulting to a certain language
    }
    await widget.flutterTts.setLanguage("ar");
    await widget.flutterTts.setVoice({"name": lang!, "locale": "ar"});
  }
  // Function to show bottom sheet for message options
  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return SafeArea(
          child: Container(
            margin: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 3,
                  blurRadius: 7,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Wrap(
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.copy, color: Colors.blue),
                  title: const Text('نـسـخ', style: TextStyle(color: Colors.black)),
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: widget.msgText));
                    Navigator.pop(context);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('حــذف ', style: TextStyle(color: Colors.black)),
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

  // Function to read the message aloud
  Future<void> _readMessage(String text) async {

    if (text.isNotEmpty) {
      setState(() => _isListening = true);
      await widget.flutterTts.setSpeechRate(0.5);// Providing a default value
      await widget.flutterTts.speak(text);

    }
  }
  Future<void> _launchURL(LinkableElement link) async {
    final url = link.url.startsWith('http') ? link.url : 'http://${link.url}';
    await launchUrl(Uri.parse(url));
  }
  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: TextDirection.ltr,
        child:Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[

          Row(
            mainAxisAlignment: widget.msgSender == "User" ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              if (widget.msgSender != "User")
                Column(
                  children: [

                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: CircleAvatar(
                        backgroundImage: AssetImage(icon), // Add path to your bot icon
                        radius: 16,
                      ),
                    ),
                    SizedBox(height: 10,),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Container(
                        margin: const EdgeInsets.only(left: 0),
                        child: GestureDetector(
                          onTap: () {
                            if (_isListening) {
                              // If already listening (speaking), then stop
                              widget.flutterTts.stop();
                              setState(() => _isListening = false);
                            } else {
                              // If not listening, start reading the message
                              _readMessage(widget.msgText);
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _isListening ? Colors.red.withOpacity(0.3) : Colors.grey.withOpacity(0.3),
                            ),
                            padding: const EdgeInsets.all(8),
                            child: Icon(
                              _isListening ? Icons.voice_over_off : Icons.record_voice_over,
                              color: _isListening ? Colors.red : kGreen,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),

                  ],
                ),
              Flexible(
                child: GestureDetector(
                  onLongPress: () => _showBottomSheet(context),
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: widget.msgSender == "User" ? kBlueDarkColo : kGreen,
                      borderRadius: BorderRadius.only(
                        topLeft: widget.msgSender == "User" ? Radius.circular(12.0) : Radius.circular(0),
                        topRight: widget.msgSender != "User" ? Radius.circular(12.0) : Radius.circular(0),
                        bottomLeft: const Radius.circular(12.0),
                        bottomRight: const Radius.circular(12.0),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        if (widget.msgSender != "User")
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Text(
                              "Nous",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,

                                color: kBlueDarkColor,
                              ),
                            ),
                          ),

                        Directionality(
                          textDirection: TextDirection.rtl,
                          child: Linkify(
                            onOpen: _launchURL,
                            text: widget.msgText,
                            style: TextStyle(

                              fontSize: 14,
                              fontFamily: 'Lama',
                              color: widget.msgSender == "User" ? Colors.white70 : Colors.black87,
                            ),
                            linkifiers: [
                              BitlyLinkifier(),
                            ],
                            linkStyle: TextStyle(
                              color: Colors.cyanAccent,
                              fontSize: 14,
                              fontWeight: FontWeight.bold, // Making the links bold
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

        ],
      ),
    ),);
  }

  @override
  void dispose() {
    widget.flutterTts.stop();
    super.dispose();
    player.dispose();

  }
}



class BitlyLinkifier extends Linkifier {
  @override

  List<LinkifyElement> parse(List<LinkifyElement> elements, LinkifyOptions options) {
    final List<LinkifyElement> newElements = [];

    final regex = RegExp(
      r'(https?://[^\s]+|bit\.ly/[^\s]+)',
      caseSensitive: false,
    );
    for (final element in elements) {
      if (element is! TextElement) {
        newElements.add(element);
        continue;
      }

      final text = element.text;
      int lastEnd = 0;

      for (final match in regex.allMatches(text)) {
        if (match.start > lastEnd) {
          newElements.add(TextElement(text.substring(lastEnd, match.start)));
        }
        newElements.add(UrlElement(match.group(0)!));
        lastEnd = match.end;
      }

      if (lastEnd < text.length) {
        newElements.add(TextElement(text.substring(lastEnd)));
      }
    }

    return newElements;
  }
}
