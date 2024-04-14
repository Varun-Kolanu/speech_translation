import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_translation/utils/stt_state.dart';

typedef SpeechRecognitionResultCallback = void Function(
  String text,
  SttState status,
  String emitted,
);

class MyStt {
  late SpeechToText stt;
  List<LocaleName> localeNames = [];
  String lastWords = "";
  bool hasSpeech = false;
  String _localeId = "en_US";
  SpeechRecognitionResultCallback? callback;
  SpeechListenOptions listenOptions = SpeechListenOptions(
    cancelOnError: true,
    listenMode: ListenMode.dictation,
  );

  static final MyStt _instance = MyStt._internal();

  factory MyStt() => _instance;
  MyStt._internal() {
    stt = SpeechToText();
    initStt();
  }

  Future<void> initStt() async {
    try {
      await stt.initialize(
        onStatus: (status) {
          print('status: $status');
          if (status == 'done') {
            callback?.call(lastWords, SttState.stopped, 'done');
            lastWords = "";
          } else {
            callback?.call(lastWords, SttState.listening, 'listening');
          }
          hasSpeech = true;
        },
        onError: (error) {
          print('error: $error');
          lastWords = "";
          callback?.call(lastWords, SttState.stopped, 'stop');
          hasSpeech = false;
        },
      );

      if (hasSpeech) {
        // Get the list of languages installed on the supporting platform so they
        // can be displayed in the UI for selection by the user.
        localeNames = await stt.locales();
      }
    } catch (e) {
      print('Speech recognition failed: ${e.toString()}');
    }
  }

  Future<dynamic> getLanguages() async {
    final locales = (await stt.locales())
        .map((e) => {
              "name": e.name,
              "locale": (e.localeId),
            })
        .toList();
    return locales;
  }

  Future<void> startListening() async {
    print("Listening...");
    await stt.listen(
        onResult: (SpeechRecognitionResult result) {
          lastWords = result.recognizedWords;
          print(result.recognizedWords);
          callback?.call(result.recognizedWords, SttState.listening, 'result');
        },
        listenOptions: listenOptions,
        localeId: _localeId);
  }

  Future<void> stopListening() async {
    await stt.stop();
    print("Stopped Listening...");
    lastWords = "";
    callback?.call(lastWords, SttState.stopped, 'done');
  }

  void setLocaleId(String id) {
    _localeId = id;
  }
}
