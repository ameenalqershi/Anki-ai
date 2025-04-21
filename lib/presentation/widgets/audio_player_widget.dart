import 'package:flutter/material.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String url; // رابط ملف الصوت (محلي أو نتورك)
  const AudioPlayerWidget({super.key, required this.url});

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  bool isPlaying = false;
  double progress = 0.0;
  Duration duration = const Duration(seconds: 12);

  // ملاحظة: هذا مجرد تمثيل شكلي، يمكن دمج حزمة صوت حقيقية مثل just_audio
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            isPlaying ? Icons.pause_circle : Icons.play_circle_fill,
            color: Colors.blueAccent,
            size: 32,
          ),
          onPressed: () => setState(() => isPlaying = !isPlaying),
        ),
        Expanded(
          child: Slider(
            value: progress,
            onChanged: (v) => setState(() => progress = v),
            min: 0,
            max: duration.inSeconds.toDouble(),
            activeColor: Colors.blueAccent,
            inactiveColor: Colors.blue[100],
          ),
        ),
        Text(
          "${(duration.inSeconds - progress).clamp(0, duration.inSeconds).toInt()}s",
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
