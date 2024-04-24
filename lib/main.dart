import 'package:flutter/material.dart';
import 'package:speech_translation/pages/speech.dart';
import 'package:speech_translation/utils/audio_to_text.dart';
import 'package:speech_translation/utils/text_to_speech.dart';
import 'package:speech_translation/utils/translator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    MyTts();
    // MyStt();
    MyAtt();
    MyTranslator();
    return const MaterialApp(
      title: 'Speech Translation',
      home: SpeechPage(),
    );
  }
}
