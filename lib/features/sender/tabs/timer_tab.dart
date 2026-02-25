import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/sender_bloc.dart';

class TimerTab extends StatefulWidget {
  const TimerTab({super.key});

  @override
  State<TimerTab> createState() => _TimerTabState();
}

class _TimerTabState extends State<TimerTab> {
  bool _countDown = true;
  final _minutesController = TextEditingController(text: '05');
  final _secondsController = TextEditingController(text: '00');

  int get _totalSeconds {
    final m = int.tryParse(_minutesController.text) ?? 0;
    final s = int.tryParse(_secondsController.text) ?? 0;
    return m * 60 + s;
  }

  @override
  void dispose() {
    _minutesController.dispose();
    _secondsController.dispose();
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
              // Direction toggle.
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: Row(
                  children: [
                    _directionBtn('COUNT DOWN', true),
                    _directionBtn('COUNT UP', false),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // MM:SS input.
              Row(
                children: [
                  Expanded(child: _timeField(_minutesController, 'MIN')),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      ':',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 36,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                  Expanded(child: _timeField(_secondsController, 'SEC')),
                ],
              ),
              const SizedBox(height: 24),

              // Control buttons grid.
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2.8,
                children: [
                  // START / PAUSE / RESUME — mutually exclusive.
                  if (state.timerRunning)
                    _actionBtn(
                      label: 'PAUSE',
                      icon: Icons.pause,
                      color: const Color(0xFFFFE600),
                      onTap: () => context.read<SenderBloc>().add(const PauseTimerCue()),
                    )
                  else if (state.timerPaused)
                    _actionBtn(
                      label: 'RESUME',
                      icon: Icons.play_circle_outline,
                      color: const Color(0xFF4A9EFF),
                      onTap: () => context.read<SenderBloc>().add(const ResumeTimerCue()),
                    )
                  else
                    _actionBtn(
                      label: 'START',
                      icon: Icons.play_arrow,
                      color: const Color(0xFF00E676),
                      onTap: () => context.read<SenderBloc>().add(
                        StartTimerCue(countDown: _countDown, seconds: _totalSeconds),
                      ),
                    ),

                  _actionBtn(
                    label: 'RESET',
                    icon: Icons.replay,
                    color: Colors.white.withValues(alpha: 0.6),
                    onTap: () => context.read<SenderBloc>().add(const ResetTimerCue()),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Last sent status.
              if (state.lastSentDescription.contains('Timer'))
                Center(
                  child: Text(
                    state.lastSentDescription,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _directionBtn(String label, bool value) {
    final selected = _countDown == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _countDown = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF4A9EFF).withValues(alpha: 0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? const Color(0xFF4A9EFF) : Colors.white.withValues(alpha: 0.4),
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }

  Widget _timeField(TextEditingController controller, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          maxLength: 2,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 40,
            fontWeight: FontWeight.w700,
            fontFamily: 'monospace',
          ),
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF4A9EFF)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.35),
              fontSize: 10,
              letterSpacing: 2,
            )),
      ],
    );
  }

  Widget _actionBtn({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 13,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
