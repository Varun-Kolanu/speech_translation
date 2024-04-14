import 'package:translator/translator.dart';

class MyTranslator {
  late GoogleTranslator _translator;

  // Singleton instance
  static final MyTranslator _instance = MyTranslator._internal();

  factory MyTranslator() => _instance;

  MyTranslator._internal() {
    _translator = GoogleTranslator();
  }

  Future<String> getTranslation(String text, String from, String to) async {
    return (await _translator.translate(text, from: from, to: to)).toString();
  }
}
