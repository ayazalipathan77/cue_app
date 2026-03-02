import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/sender_bloc.dart';
import '../widgets/color_picker_row.dart';
import '../../../core/constants.dart';
import '../../../core/preset_service.dart';

class TextTab extends StatefulWidget {
  const TextTab({super.key});

  @override
  State<TextTab> createState() => _TextTabState();
}

class _TextTabState extends State<TextTab> {
  final _controller = TextEditingController();
  Color _textColor = Colors.white;
  Color _bgColor = Colors.black;
  List<String> _presets = [];

  @override
  void initState() {
    super.initState();
    _loadPresets();
  }

  Future<void> _loadPresets() async {
    final p = await PresetService.load();
    if (mounted) setState(() => _presets = p);
  }

  Future<void> _savePreset() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    await PresetService.save(text);
    await _loadPresets();
  }

  Future<void> _deletePreset(String text) async {
    await PresetService.delete(text);
    await _loadPresets();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SenderBloc, SenderState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Input field ──────────────────────────────────────────────
              TextField(
                controller: _controller,
                maxLines: 4,
                style: const TextStyle(color: Colors.white, fontSize: 18),
                decoration: InputDecoration(
                  hintText: 'TYPE YOUR CUE HERE...',
                  hintStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.2),
                      fontSize: 14),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                        color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        const BorderSide(color: Color(0xFF4A9EFF)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                        color: Colors.white.withValues(alpha: 0.1)),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Text colour ──────────────────────────────────────────────
              ColorPickerRow(
                label: 'TEXT COLOUR',
                colors: kTextColorPresets,
                selectedColor: _textColor,
                onColorSelected: (c) => setState(() => _textColor = c),
              ),
              const SizedBox(height: 16),

              // ── Background colour ────────────────────────────────────────
              ColorPickerRow(
                label: 'BACKGROUND',
                colors: kBgColorPresets,
                selectedColor: _bgColor,
                onColorSelected: (c) => setState(() => _bgColor = c),
              ),
              const SizedBox(height: 28),

              // ── SEND button ──────────────────────────────────────────────
              ElevatedButton.icon(
                onPressed: () {
                  final text = _controller.text.trim();
                  if (text.isEmpty) return;
                  context
                      .read<SenderBloc>()
                      .add(SendTextCue(text, _textColor, _bgColor));
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

              // ── CLEAR button ─────────────────────────────────────────────
              OutlinedButton.icon(
                onPressed: () {
                  _controller.clear();
                  context.read<SenderBloc>().add(const SendClearCue());
                },
                icon: Icon(Icons.clear,
                    color: Colors.white.withValues(alpha: 0.6)),
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
                  side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.15)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),

              // ── Presets section ──────────────────────────────────────────
              const SizedBox(height: 24),
              Row(
                children: [
                  Text(
                    'PRESETS',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.35),
                      fontSize: 10,
                      letterSpacing: 2.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  // Save current text as a preset.
                  GestureDetector(
                    onTap: _savePreset,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4A9EFF).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: const Color(0xFF4A9EFF)
                                .withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.bookmark_add_outlined,
                              size: 13, color: const Color(0xFF4A9EFF).withValues(alpha: 0.8)),
                          const SizedBox(width: 4),
                          Text(
                            'SAVE',
                            style: TextStyle(
                              color: const Color(0xFF4A9EFF)
                                  .withValues(alpha: 0.8),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              if (_presets.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'No presets yet — type a cue and tap SAVE',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.2),
                      fontSize: 12,
                    ),
                  ),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _presets.map((preset) {
                    return GestureDetector(
                      onTap: () {
                        setState(() => _controller.text = preset);
                        _controller.selection = TextSelection.fromPosition(
                          TextPosition(offset: preset.length),
                        );
                      },
                      onLongPress: () => _showDeleteConfirm(preset),
                      child: Container(
                        constraints:
                            const BoxConstraints(maxWidth: 220),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color:
                                  Colors.white.withValues(alpha: 0.1)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                preset,
                                style: TextStyle(
                                  color:
                                      Colors.white.withValues(alpha: 0.75),
                                  fontSize: 13,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

              if (_presets.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Tap to load  •  Long-press to delete',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.2),
                      fontSize: 10,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),

              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirm(String preset) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Delete Preset',
            style: TextStyle(color: Colors.white)),
        content: Text(
          '"$preset"',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deletePreset(preset);
            },
            child: const Text('Delete',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
