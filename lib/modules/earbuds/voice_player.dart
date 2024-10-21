import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class VoicePlayerScreen extends StatefulWidget {
  final String audioPath;
  const VoicePlayerScreen({super.key, required this.audioPath});
  @override
  State<StatefulWidget> createState() {
    return _VoicePlayerScreenState();
  }
}

class _VoicePlayerScreenState extends State<VoicePlayerScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initializeAudio();

    // Listen to processing state changes to reset after playback completes
    _audioPlayer.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        _resetPlayback();
      }
    });
  }

  Future<void> _initializeAudio() async {
    try {
      await _audioPlayer.setFilePath(widget.audioPath);
      _audioPlayer.durationStream.listen((duration) {
        setState(() {
          _duration = duration ?? Duration.zero;
        });
      });
      _audioPlayer.positionStream.listen((position) {
        setState(() {
          _position = position;
        });
      });
    } catch (e) {
      print("Error loading audio: $e");
    }
  }

  Future<void> _playPauseAudio() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play();
    }
    setState(() {
      _isPlaying = !_isPlaying;
    });

  }

  Future<void> _stopAudio() async {
    await _audioPlayer.stop();
    setState(() {
      _isPlaying = false;
      _position = Duration.zero;
    });
  }

  // Resets the playback to the initial state after audio finishes
  Future<void> _resetPlayback() async {
    setState(() {
      _isPlaying = false;
      _position = Duration.zero;
    });

    await _audioPlayer.seek(Duration.zero);  // Reset to the start
    _playPauseAudio();
  }

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
        title: const Text('Voice Player'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display Timer for Current Playback Position
            Text(
              _formatDuration(_position),
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Audio Player Slider
            Slider(
              min: 0.0,
              max: _duration.inMilliseconds.toDouble(),
              value: _position.inMilliseconds.toDouble(),
              onChanged: (double value) async {
                final position = Duration(milliseconds: value.toInt());
                await _audioPlayer.seek(position);
                setState(() {
                  _position = position;
                });
              },
            ),

            const SizedBox(height: 20),

            // Play/Pause Button
            IconButton(
              icon: Icon(
                _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                size: 64,
                color: Colors.blueAccent,
              ),
              onPressed: _playPauseAudio,
            ),

            const SizedBox(height: 20),

            // Stop Button
            IconButton(
              icon: const Icon(Icons.stop_circle, size: 64, color: Colors.red),
              onPressed: _stopAudio,
            ),

            const SizedBox(height: 20),

            // Display File Path
            Text(
              'Playing: ${widget.audioPath}',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
