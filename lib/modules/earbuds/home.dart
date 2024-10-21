import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'dart:io';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sparkle/modules/earbuds/voice_player.dart';
import 'package:sparkle/modules/earbuds/voice_record.dart';


class KaraokeApp extends StatelessWidget {
  const KaraokeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Karaoke App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const KaraokeScreen(),
    );
  }
}

class KaraokeScreen extends StatefulWidget {
  const KaraokeScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _KaraokeScreenState();
  }


}

class _KaraokeScreenState extends State<KaraokeScreen> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final AudioPlayer _player = AudioPlayer();
  bool _isRecording = false;
  bool _isPlayingMusic = false;
  String? _filePath;
  Duration _musicDuration = Duration.zero;
  Duration _musicPosition = Duration.zero;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initializeRecorder();
    _setBluetoothAudioRoute();

    _player.positionStream.listen((position) {
      setState(() {
        _musicPosition = position;
      });
    });

    _player.durationStream.listen((duration) {
      setState(() {
        _musicDuration = duration ?? Duration.zero;
      });
    });
  }

  Future<void> _initializeRecorder() async {
    await Permission.microphone.request();
    Directory tempDir = await getTemporaryDirectory();
    _filePath = '${tempDir.path}/recorded_voice.aac';
    await _recorder.openRecorder();
  }

  // Platform channel to set audio route to Bluetooth
  static const platform = MethodChannel('com.example.bluetooth_audio');

  Future<void> _setBluetoothAudioRoute() async {
    try {
      await platform.invokeMethod('setBluetoothAudio');
    } on PlatformException catch (e) {
      print('Failed to set Bluetooth route: ${e.message}');
    }
  }

  Future<void> _startRecording() async {
    await _recorder.startRecorder(
      toFile: _filePath,
      codec: Codec.aacADTS,
    );
    setState(() {
      _isRecording = true;
    });
  }

  Future<void> _stopRecording() async {
    await _recorder.stopRecorder();
    setState(() {
      _isRecording = false;
    });
  }

  Future<void> _playMusic() async {
    // Load music from asset
    const musicAssetPath = 'assets/audio/song.mp3';
    await _player.setAsset(musicAssetPath);
    _player.play();
    setState(() {
      _isPlayingMusic = true;
    });
  }

  Future<void> _stopMusic() async {
    await _player.stop();
    setState(() {
      _isPlayingMusic = false;
    });
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    _player.dispose();
    super.dispose();
  }
  // Function to build the beautiful navigation button
  Widget _buildNavigateButton() {
    return GestureDetector(
      onTap: () {
        if (_filePath != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const VoiceRecorderScreen(),//VoicePlaybackScreen(filePath: _filePath!),
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Karaoke App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Music progress bar
            if (_isPlayingMusic)
              Column(
                children: [
                  Slider(
                    value: _musicPosition.inSeconds.toDouble(),
                    min: 0,
                    max: _musicDuration.inSeconds.toDouble(),
                    onChanged: (value) async {
                      final newPosition = Duration(seconds: value.toInt());
                      await _player.seek(newPosition);
                    },
                    activeColor: Colors.blue,
                    inactiveColor: Colors.grey,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_formatDuration(_musicPosition)),
                      Text(_formatDuration(_musicDuration)),
                    ],
                  ),
                ],
              ),
            const SizedBox(height: 40),

            // Music controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: _isPlayingMusic ? _stopMusic : _playMusic,
                  icon: Icon(
                    _isPlayingMusic ? Icons.pause_circle_filled : Icons.play_circle_fill,
                    size: 64,
                    color: Colors.blueAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // Recording controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: _isRecording ? _stopRecording : _startRecording,
                  icon: Icon(
                    _isRecording ? Icons.stop_circle : Icons.mic,
                    size: 64,
                    color: Colors.redAccent,
                  ),
                ),

                const SizedBox(height: 40),
                // Beautiful button to navigate to the voice playback screen

              ],
            ),
            _buildNavigateButton(),
          ],
        ),
      ),
    );
  }

  // Helper function to format duration in mm:ss
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }}
