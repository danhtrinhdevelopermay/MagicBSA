import 'package:flutter/material.dart';
import '../services/audio_service.dart';

class AudioControlsWidget extends StatefulWidget {
  const AudioControlsWidget({super.key});

  @override
  State<AudioControlsWidget> createState() => _AudioControlsWidgetState();
}

class _AudioControlsWidgetState extends State<AudioControlsWidget> {
  final AudioService _audioService = AudioService();
  bool _showVolumeSlider = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Volume control
          if (_showVolumeSlider) ...[
            Container(
              width: 100,
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 2,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                ),
                child: Slider(
                  value: _audioService.volume,
                  onChanged: (value) {
                    setState(() {
                      _audioService.setVolume(value);
                    });
                  },
                  activeColor: const Color(0xFF6366f1),
                  inactiveColor: const Color(0xFFe2e8f0),
                ),
              ),
            ),
            const SizedBox(width: 4),
          ],
          
          // Mute/Unmute button
          GestureDetector(
            onTap: () async {
              await _audioService.toggleMute();
              setState(() {});
            },
            onLongPress: () {
              setState(() {
                _showVolumeSlider = !_showVolumeSlider;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF6366f1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF6366f1).withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Icon(
                _audioService.isMuted ? Icons.volume_off : Icons.volume_up,
                color: const Color(0xFF6366f1),
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}