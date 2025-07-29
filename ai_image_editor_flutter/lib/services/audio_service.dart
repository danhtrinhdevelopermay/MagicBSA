import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _isMuted = false;
  double _volume = 0.3; // Default volume (30%)

  bool get isPlaying => _isPlaying;
  bool get isMuted => _isMuted;
  double get volume => _volume;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _isMuted = prefs.getBool('audio_muted') ?? false;
    _volume = prefs.getDouble('audio_volume') ?? 0.3;
    
    await _audioPlayer.setVolume(_isMuted ? 0.0 : _volume);
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
  }

  Future<void> playBackgroundMusic() async {
    if (_isPlaying || _isMuted) return;
    
    try {
      // Placeholder for background music - user can replace with their own audio file
      // await _audioPlayer.play(AssetSource('audio/background_music.mp3'));
      
      // For now, we'll create a simple notification sound
      _isPlaying = true;
      print('🎵 Background music would play here');
      print('📁 Add your music file to: assets/audio/background_music.mp3');
    } catch (e) {
      print('Error playing background music: $e');
    }
  }

  Future<void> stopBackgroundMusic() async {
    if (!_isPlaying) return;
    
    await _audioPlayer.stop();
    _isPlaying = false;
  }

  Future<void> pauseBackgroundMusic() async {
    if (!_isPlaying) return;
    
    await _audioPlayer.pause();
  }

  Future<void> resumeBackgroundMusic() async {
    if (!_isPlaying || _isMuted) return;
    
    await _audioPlayer.resume();
  }

  Future<void> toggleMute() async {
    _isMuted = !_isMuted;
    await _audioPlayer.setVolume(_isMuted ? 0.0 : _volume);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('audio_muted', _isMuted);
    
    if (_isMuted) {
      await pauseBackgroundMusic();
    } else {
      await resumeBackgroundMusic();
    }
  }

  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    await _audioPlayer.setVolume(_isMuted ? 0.0 : _volume);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('audio_volume', _volume);
  }

  Future<void> playClickSound() async {
    if (_isMuted) return;
    
    try {
      // Placeholder for click sound effect
      print('🔊 Click sound effect');
    } catch (e) {
      print('Error playing click sound: $e');
    }
  }

  Future<void> playProcessingSound() async {
    if (_isMuted) return;
    
    try {
      // Placeholder for processing sound effect
      print('🔊 Processing sound effect');
    } catch (e) {
      print('Error playing processing sound: $e');
    }
  }

  Future<void> playSuccessSound() async {
    if (_isMuted) return;
    
    try {
      // Placeholder for success sound effect
      print('🔊 Success sound effect');
    } catch (e) {
      print('Error playing success sound: $e');
    }
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}