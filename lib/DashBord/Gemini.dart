import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:idea_chatbot/global/common/toast.dart';

Future<String?> handleText(String inputText) async {
  final Gemini gemini = Gemini.instance;

  try {
    final gemini = Gemini.instance;
    var response = await gemini.text(inputText);
    return response?.output;
  } catch (e) {
    showToast(message:'Error handling text: $e');
  }
}
