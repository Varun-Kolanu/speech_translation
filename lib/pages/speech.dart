import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:speech_translation/pages/output.dart';
import 'package:speech_translation/utils/audio_to_text.dart';
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
  final MyAtt _att = MyAtt();
  final MyTts _tts = MyTts();
  final MyStt _stt = MyStt();
  final MyTranslator _translator = MyTranslator();

  bool _loading = false;

  String? _selectedFilePath;
  String _selectedInputLanguage = 'en_US';
  String _selectedOutputLanguage = 'hi-IN';
  SttState _status = SttState.stopped;
  final List<dynamic> _voices = [
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

  @override
  void initState() {
    super.initState();
    _stt.callback = _onSpeechResult;
  }

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
      _status = status;
    });
    if (emitted == "done") {
      await _translateSpeech(text);
    }
  }

  Future<void> _pickFile() async {
    setState(() {
      _loading = true;
    });
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowCompression: true,
    );

    if (result != null) {
      setState(() {
        _selectedFilePath = result.files.single.path!;
      });
      String transcribedText =
          await _att.getText(_selectedInputLanguage, _selectedFilePath!);
      await _translateSpeech(transcribedText);
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _translateSpeech(String text) async {
    String translatedOutput = await _translator.getTranslation(
      text,
      _getLanguageCode(_selectedInputLanguage, "input"),
      _getLanguageCode(_selectedOutputLanguage, "output"),
    );

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Output(
                  text: translatedOutput,
                  outputLang: (_voices
                      .where((voice) => voice["id"] == _selectedOutputLanguage)
                      .toList())[0]["name"],
                )),
      );
    }
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
      body: Center(
        child: Container(
          height: double.infinity,
          color: Colors.blue[100],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                children: [
                  Column(
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
                  Column(
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
                        items: _voices
                            .map<DropdownMenuItem<String>>(
                              (voice) => DropdownMenuItem<String>(
                                value: voice["id"],
                                child: Text(voice["name"]),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 20.0),
              Column(
                children: [
                  _loading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _pickFile,
                          child: const Text(
                            "Upload Audio",
                          ),
                        ),
                  ElevatedButton(
                    onPressed: _handleSpeech,
                    child: const Text(
                      "Speak",
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
