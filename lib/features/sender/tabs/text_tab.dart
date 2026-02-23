import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/sender_bloc.dart';
import '../widgets/color_picker_row.dart';
import '../../../core/constants.dart';

class TextTab extends StatefulWidget {
  const TextTab({super.key});

  @override
  State<TextTab> createState() => _TextTabState();
}

class _TextTabState extends State<TextTab> {
  final _controller = TextEditingController();
  Color _textColor = Colors.white;
  Color _bgColor = Colors.black;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Input field.
          TextField(
            controller: _controller,
            maxLines: 4,
            style: const TextStyle(color: Colors.white, fontSize: 18),
            decoration: InputDecoration(
              hintText: 'TYPE YOUR CUE HERE...',
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.2), fontSize: 14),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFF4A9EFF)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Text colour.
          ColorPickerRow(
            label: 'TEXT COLOUR',
            colors: kTextColorPresets,
            selectedColor: _textColor,
            onColorSelected: (c) => setState(() => _textColor = c),
          ),
          const SizedBox(height: 16),

          // Background colour.
          ColorPickerRow(
            label: 'BACKGROUND',
            colors: kBgColorPresets,
            selectedColor: _bgColor,
            onColorSelected: (c) => setState(() => _bgColor = c),
          ),
          const SizedBox(height: 28),

          // SEND button.
          ElevatedButton.icon(
            onPressed: () {
              final text = _controller.text.trim();
              if (text.isEmpty) return;
              context.read<SenderBloc>().add(SendTextCue(text, _textColor, _bgColor));
            },
            icon: const Icon(Icons.send, color: Colors.white),
            label: const Text(
              'SEND CUE',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A9EFF),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // CLEAR button.
          OutlinedButton.icon(
            onPressed: () {
              _controller.clear();
              context.read<SenderBloc>().add(const SendClearCue());
            },
            icon: Icon(Icons.clear, color: Colors.white.withValues(alpha: 0.6)),
            label: Text(
              'CLEAR DISPLAY',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
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
