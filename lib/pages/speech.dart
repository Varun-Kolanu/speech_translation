import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:speech_translation/utils/audio_to_text.dart';
import 'package:speech_translation/utils/text_to_speech.dart';
import 'package:speech_translation/utils/translator.dart';
import 'package:speech_translation/utils/tts_state.dart';

class SpeechPage extends StatefulWidget {
  const SpeechPage({super.key});

  @override
  State<SpeechPage> createState() => _SpeechPageState();
}

class _SpeechPageState extends State<SpeechPage> {
  final MyAtt _att = MyAtt();
  final MyTts _tts = MyTts();
  final MyTranslator _translator = MyTranslator();

  File? _selectedFile;
  String _selectedInputLanguage = 'en-US';
  String _selectedOutputLanguage = 'hi-IN';
  TtsState _status = TtsState.initialized;
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
    _tts.callback = updateStatus;
  }

  String _getLanguageCode(String language) {
    return language.split("-")[0];
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowCompression: true,
    );

    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
      await _translateSpeech();
    }
  }

  Future<void> _translateSpeech() async {
    String transcribedText =
        await _att.getText(_selectedInputLanguage, _selectedFile!.path);
    String translatedOutput = await _translator.getTranslation(
      transcribedText,
      _getLanguageCode(_selectedInputLanguage),
      _getLanguageCode(
        _selectedOutputLanguage,
      ),
    );
    await _tts.download(
        translatedOutput,
        (_voices
            .where((voice) => voice["id"] == _selectedOutputLanguage)
            .toList())[0]["name"]);
  }

  void updateStatus(TtsState status) {
    setState(() {
      _status = status;
    });
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
              ),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
                onPressed: _pickFile,
                child: const Text(
                  "Pick Audio",
                )),
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
            ),
            _status == TtsState.downloading
                ? const Text("Downloading...")
                : _status == TtsState.initialized
                    ? const Text("")
                    : const Text(
                        "See downloaded file in Audio section of phone",
                      )
          ],
        ),
      ),
    );
  }
}
