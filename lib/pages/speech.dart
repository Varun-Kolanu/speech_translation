import 'package:flutter/material.dart';
import 'package:speech_translation/utils/speech_to_text.dart';
import 'package:speech_translation/utils/stt_state.dart';
import 'package:speech_translation/utils/text_to_speech.dart';
import 'package:speech_translation/utils/translator.dart';

class SpeechPage extends StatefulWidget {
  const SpeechPage({super.key});

  @override
  State<SpeechPage> createState() => _SpeechPageState();
}

class _SpeechPageState extends State<SpeechPage> {
  final MyStt _stt = MyStt();
  final MyTts _tts = MyTts();
  final MyTranslator _translator = MyTranslator();
  String _spokenText = '';
  String _translatedText = '';
  SttState _status = SttState.stopped;
  String _selectedInputLanguage = 'en_US';
  String _selectedOutputLanguage = 'en-US';
  final List<dynamic> _ttsVoices = [
    {
      "name": "English",
      "id": "en-US",
    },
    {
      "name": "Hindi",
      "id": "hi-IN",
    },
    {
      "name": "Korean",
      "id": "ko-KR",
    },
    {
      "name": "Japanese",
      "id": "ja-JP",
    },
    {
      "name": "Russian",
      "id": "ru-RU",
    },
    {
      "name": "Arabic",
      "id": "ar",
    },
    {
      "name": "French",
      "id": "fr-FR",
    },
    {
      "name": "Portuguese",
      "id": "pt-PT",
    },
    {
      "name": "Malay",
      "id": "ms-MY",
    },
  ];
  final List<dynamic> _sttVoices = [
    {
      "name": "English",
      "id": "en_US",
    },
    {
      "name": "Hindi",
      "id": "hi_IN",
    },
    {
      "name": "Korean",
      "id": "ko_KR",
    },
    {
      "name": "Japanese",
      "id": "ja_JP",
    },
    {
      "name": "Russian",
      "id": "ru_RU",
    },
    {
      "name": "Arabic",
      "id": "ar_AE",
    },
    {
      "name": "French",
      "id": "fr_FR",
    },
    {
      "name": "Portuguese",
      "id": "pt_PT",
    },
    {
      "name": "Malay",
      "id": "ms_MY",
    },
  ];

  String _getLanguageCode(String language, String type) {
    if (type == "input") {
      return language.split("_")[0];
    } else {
      return language.split("-")[0];
    }
  }

  Future<void> _handleSpeech() async {
    if (_status != SttState.listening) {
      await _stt.startListening();
    } else {
      await _stt.stopListening();
    }
  }

  void _onSpeechResult(String text, SttState status, String emitted) async {
    setState(() {
      _spokenText = text;
      _status = status;
    });
    if (emitted == "done") {
      String translatedOutput = await _translator.getTranslation(
        text,
        _getLanguageCode(_selectedInputLanguage, "input"),
        _getLanguageCode(_selectedOutputLanguage, "output"),
      );
      setState(() {
        _translatedText = translatedOutput;
      });
      await _tts.speak(translatedOutput);
    }
  }

  @override
  void initState() {
    super.initState();
    _stt.callback = _onSpeechResult;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Speech Translation',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _buildSpeechInputSection(),
          const SizedBox(height: 20.0),
          _buildTranslationOutputSection(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _handleSpeech,
        tooltip: 'Listen',
        child: Icon(_status == SttState.listening ? Icons.mic : Icons.mic_none),
      ),
    );
  }

  Widget _buildSpeechInputSection() {
    return Container(
      color: Colors.blue[200],
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.3,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: double.infinity,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Input Language',
                      style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800]),
                    ),
                  ),
                  DropdownButton<String>(
                    value: _selectedInputLanguage,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedInputLanguage = newValue!;
                      });
                      _stt.setLocaleId(newValue!);
                    },
                    items: _sttVoices
                        .map<DropdownMenuItem<String>>(
                          (voice) => DropdownMenuItem<String>(
                            value: voice["id"],
                            child: Text(voice["name"]),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20.0),
            Text(
              _spokenText,
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.blue[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTranslationOutputSection() {
    return Container(
      color: Colors.green[200],
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Output Language',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                  ),
                ),
                const SizedBox(height: 10.0),
                DropdownButton<String>(
                  value: _selectedOutputLanguage,
                  onChanged: (newValue) async {
                    setState(() {
                      _selectedOutputLanguage = newValue!;
                    });
                    await _tts.setLanguage(newValue!);
                  },
                  items: _ttsVoices
                      .map<DropdownMenuItem<String>>(
                        (voice) => DropdownMenuItem<String>(
                          value: voice["id"],
                          child: Text(voice["name"]),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
            const SizedBox(height: 20.0),
            _translatedText == ""
                ? const Text("")
                : Text(
                    'Translated Text:',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                  ),
            const SizedBox(height: 10.0),
            Text(
              _translatedText,
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.green[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
