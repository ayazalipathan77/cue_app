import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/sender_bloc.dart';
import '../widgets/color_picker_row.dart';
import '../../../core/constants.dart';

class FlashTab extends StatefulWidget {
  const FlashTab({super.key});

  @override
  State<FlashTab> createState() => _FlashTabState();
}

class _FlashTabState extends State<FlashTab>
    with SingleTickerProviderStateMixin {
  Color _flashColor = const Color(0xFFFF1744);
  double _hz = 2.0;
  bool _isFlashing = false;

  // Preview animation.
  late final AnimationController _previewController;

  @override
  void initState() {
    super.initState();
    _previewController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _previewController.dispose();
    super.dispose();
  }

  void _startPreview() {
    _previewController
      ..duration = Duration(milliseconds: (1000 / _hz).round())
      ..repeat(reverse: true);
  }

  void _stopPreview() {
    _previewController.stop();
    _previewController.value = 0;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Warning banner.
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber, color: Colors.amber, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Activates high-intensity flashing on receiver screen.',
                    style: TextStyle(
                        color: Colors.amber.withValues(alpha: 0.85), fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Colour selector.
          ColorPickerRow(
            label: 'FLASH COLOUR',
            colors: kFlashColorPresets,
            selectedColor: _flashColor,
            onColorSelected: (c) => setState(() => _flashColor = c),
          ),
          const SizedBox(height: 24),

          // Hz slider.
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'FREQUENCY:  ${_hz.toStringAsFixed(1)} Hz',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.45),
                  fontSize: 11,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Slider(
                value: _hz,
                min: 0.5,
                max: 5.0,
                divisions: 9,
                activeColor: _flashColor,
                inactiveColor: Colors.white.withValues(alpha: 0.1),
                onChanged: (v) {
                  setState(() => _hz = v);
                  if (_isFlashing) {
                    _startPreview();
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Preview strip.
          AnimatedBuilder(
            animation: _previewController,
            builder: (context, _) {
              final isOn = _isFlashing && _previewController.value > 0.5;
              return Container(
                height: 52,
                decoration: BoxDecoration(
                  color: isOn ? _flashColor : Colors.black,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: Center(
                  child: Text(
                    'PREVIEW',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.3),
                      fontSize: 10,
                      letterSpacing: 3,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // START / STOP button.
          ElevatedButton.icon(
            onPressed: () {
              final bloc = context.read<SenderBloc>();
              if (_isFlashing) {
                bloc.add(const StopFlashCue());
                setState(() => _isFlashing = false);
                _stopPreview();
              } else {
                bloc.add(StartFlashCue(_flashColor, _hz));
                setState(() => _isFlashing = true);
                _startPreview();
              }
            },
            icon: Icon(
              _isFlashing ? Icons.flash_off : Icons.flash_on,
              color: Colors.white,
            ),
            label: Text(
              _isFlashing ? 'STOP FLASH' : 'START FLASH',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _isFlashing ? Colors.red : _flashColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
