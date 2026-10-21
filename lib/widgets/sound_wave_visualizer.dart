import 'dart:math';
import 'package:flutter/material.dart';

class SoundWaveVisualizer extends StatefulWidget {
  final double decibels;
  final bool isRecording;
  final Color barColor;

  const SoundWaveVisualizer({
    super.key,
    required this.decibels,
    this.isRecording = true,
    this.barColor = const Color(0xFF6366F1),
  });

  @override
  State<SoundWaveVisualizer> createState() => _SoundWaveVisualizerState();
}

class _SoundWaveVisualizerState extends State<SoundWaveVisualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  final List<double> _randomFactors = List.generate(24, (i) => 0.2 + (i % 5) * 0.15);

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Chuẩn hóa decibels (30 - 100 dB) sang tỉ lệ chiều cao (0.1 - 1.0)
    final normalized = ((widget.decibels - 30) / 70).clamp(0.1, 1.0);

    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        return SizedBox(
          height: 80,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(24, (index) {
              final factor = _randomFactors[index];
              final wave = sin((_animController.value * 2 * pi) + (index * 0.4));
              double height = 80 * normalized * (factor + 0.3 * wave.abs());
              if (!widget.isRecording) height = 6.0;
              height = height.clamp(4.0, 78.0);

              Color barColor = widget.barColor;
              if (widget.decibels > 80) {
                barColor = Colors.redAccent;
              } else if (widget.decibels > 65) {
                barColor = Colors.amber;
              }

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: 4,
                height: height,
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
