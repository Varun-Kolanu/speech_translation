import 'package:flutter/material.dart';
import 'package:speech_translation/utils/text_to_speech.dart';

class Output extends StatefulWidget {
  final String text;
  final String outputLang;
  Output({
    super.key,
    required this.text,
    required this.outputLang,
  });

  @override
  State<Output> createState() => _OutputState();
}

class _OutputState extends State<Output> {
  bool _loading = false;

  final MyTts _tts = MyTts();

  void _downloadFile() async {
    try {
      setState(() {
        _loading = true;
      });
      await _tts.download(
        widget.text,
        widget.outputLang,
      );
      setState(() {
        _loading = false;
      });
    } catch (e) {
      // Handle any errors that occur during the download process
      print('Error downloading file: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _loading
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: _downloadFile,
                  child: const Text(
                    "Download",
                  ),
                ),
        ],
      ),
    );
  }
}
