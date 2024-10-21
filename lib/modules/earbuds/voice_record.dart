import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:sparkle/modules/earbuds/voice_player.dart';

class VoiceRecorderScreen extends StatefulWidget {
  const VoiceRecorderScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _VoiceRecorderScreenState();
  }
}



class _VoiceRecorderScreenState extends State<VoiceRecorderScreen> {
  final audioRecorderNew = AudioRecorder();
  String recordedAudioPath = "";
  bool _isRecording = false;
  bool _isPaused = false;
  Timer? _timer;
  Duration _recordingDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
  }

  // Start recording and timer
  Future<void> startVoiceRecording() async {
    try {
      final isSupported = await audioRecorderNew.isEncoderSupported(AudioEncoder.aacLc);
      if (kDebugMode) {
        print("${AudioEncoder.aacLc.name} supported : $isSupported");
        print("************ Recording started *********** ");
      }

      final dir = await getApplicationDocumentsDirectory();
      final path = '${dir.path}/audio0_${DateTime.now().millisecondsSinceEpoch}.wav';

      await audioRecorderNew.start(
        const RecordConfig(
          noiseSuppress: true,
          encoder: AudioEncoder.wav,
          bitRate: 128000,
          echoCancel: true,
        ),
        path: path,
      );

      setState(() {
        _isRecording = true;
        _isPaused = false;
        _startTimer();  // Start the timer when recording starts
      });
    } catch (e) {
      if (kDebugMode) {
        print("Error occurred : $e");
      }
    }
  }

  // Stop recording and timer
  Future<void> stopVoiceRecording() async {
    final path = await audioRecorderNew.stop();
    if (path != null) {
      recordedAudioPath = path;
      if (kDebugMode) {
        print("Recorded audio path: $recordedAudioPath");
      }
    }

    setState(() {
      _isRecording = false;
      _isPaused = false;
      _stopTimer(); // Stop the timer when recording ends
    });
  }

  // Pause recording and timer
  Future<void> pauseVoiceRecording() async {
    await audioRecorderNew.pause();
    setState(() {
      _isPaused = true;
      _stopTimer(); // Stop the timer while paused
    });
  }

  // Resume recording and timer
  Future<void> resumeVoiceRecording() async {
    await audioRecorderNew.resume();
    setState(() {
      _isPaused = false;
      _startTimer();  // Resume the timer when recording resumes
    });
  }

  // Start the timer
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _recordingDuration += const Duration(seconds: 1);
      });
    });
  }

  // Stop the timer
  void _stopTimer() {
    _timer?.cancel();
  }

  // Format the timer duration into mm:ss format
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Recorder'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Timer Display
            Text(
              _formatDuration(_recordingDuration),
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Start/Stop Button
            IconButton(
              icon: Icon(
                _isRecording ? Icons.stop_circle : Icons.mic,
                size: 64,
                color: _isRecording ? Colors.red : Colors.blueAccent,
              ),
              onPressed: _isRecording ? stopVoiceRecording : startVoiceRecording,
            ),
            const SizedBox(height: 20),

            // Recording status text
            Text(
              _isRecording ? (_isPaused ? 'Paused' : 'Recording...') : 'Tap to Record',
              style: TextStyle(
                fontSize: 18,
                color: _isRecording ? (_isPaused ? Colors.orange : Colors.red) : Colors.black,
              ),
            ),
            const SizedBox(height: 20),

            // Pause/Resume Button (Only visible when recording)
            if (_isRecording)
              IconButton(
                icon: Icon(
                  _isPaused ? Icons.play_circle_fill : Icons.pause_circle_filled,
                  size: 64,
                  color: Colors.orangeAccent,
                ),
                onPressed: _isPaused ? resumeVoiceRecording : pauseVoiceRecording,
              ),

            // Display Recorded Path after recording is done
            if (recordedAudioPath.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Recorded File: $recordedAudioPath',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
              ),

            if(recordedAudioPath.isNotEmpty)
              buildNavigateButton()

          ],
        ),
      ),
    );
  }

  Widget buildNavigateButton() {
    return GestureDetector(
      onTap: () {
        if (recordedAudioPath.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VoicePlayerScreen(audioPath: recordedAudioPath),
            ),
          );
        }
      },
      child: Container(
        height: 60,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.purpleAccent, Colors.blueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.blueAccent.withOpacity(0.5),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            'Play Recorded Voice',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ),
    );
  }
  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
}