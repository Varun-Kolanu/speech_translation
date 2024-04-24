import 'dart:io';

import 'package:flutter/services.dart';
import 'package:google_speech/google_speech.dart';
import 'package:path_provider/path_provider.dart';
import 'package:speech_translation/utils/att_state.dart';

class WavHeader {
  int sampleRate;
  int audioChannels;

  WavHeader(this.sampleRate, this.audioChannels);
}

class MyAtt {
  late SpeechToText _att;
  AttState state = AttState.stopped;

  static final MyAtt _instance = MyAtt._internal();

  factory MyAtt() => _instance;
  MyAtt._internal() {
    _initStt();
  }

  void _initStt() async {
    try {
      final serviceAccount = ServiceAccount.fromString(
        (await rootBundle.loadString('assets/speech-translation.json')),
      );
      _att = SpeechToText.viaServiceAccount(serviceAccount);
    } catch (e) {
      print("Errorrr: $e");
    }
  }

  Future<WavHeader> _getWavHeader(String filePath) async {
    final File audioFile = File(filePath);
    final bytes = await audioFile.readAsBytes();

    // Extract sample rate
    int sampleRate =
        bytes[24] | (bytes[25] << 8) | (bytes[26] << 16) | (bytes[27] << 24);

    // Extract audio channels
    int audioChannels = bytes[22] | (bytes[23] << 8);

    return WavHeader(sampleRate, audioChannels);
  }

  Future<List<int>> _getAudioContent(String path) async {
    return File(path).readAsBytesSync().toList();
  }

  Future<String> getText(
    String language,
    String path,
  ) async {
    state = AttState.transcribing;
    WavHeader wavHeader = await _getWavHeader(path);
    final config = RecognitionConfig(
      encoding: AudioEncoding.LINEAR16,
      model: RecognitionModel.basic,
      enableAutomaticPunctuation: true,
      sampleRateHertz: wavHeader.sampleRate,
      audioChannelCount: wavHeader.audioChannels,
      languageCode: language,
    );

    final audioContent = await _getAudioContent(path);
    final response = await _att.recognize(config, audioContent);

    final transcribedText = response.results
        .map((result) => result.alternatives.first.transcript)
        .join(' ');

    state = AttState.stopped;
    return transcribedText;
  }
}
