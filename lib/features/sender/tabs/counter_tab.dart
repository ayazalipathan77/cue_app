import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/sender_bloc.dart';

class CounterTab extends StatefulWidget {
  const CounterTab({super.key});

  @override
  State<CounterTab> createState() => _CounterTabState();
}

class _CounterTabState extends State<CounterTab> {
  int _step = 1;
  final _setController = TextEditingController();

  @override
  void dispose() {
    _setController.dispose();
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
              // Last sent description acts as the live counter readout.
              Container(
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                ),
                child: Column(
                  children: [
                    Text(
                      'COUNTER',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.3),
                        fontSize: 10,
                        letterSpacing: 3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      state.lastSentDescription.isEmpty
                          ? '—'
                          : state.lastSentDescription,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Step selector.
              Row(
                children: [
                  Text(
                    'STEP:',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.45),
                      fontSize: 11,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(width: 12),
                  ...([1, 5, 10].map((s) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text('$s'),
                      selected: _step == s,
                      onSelected: (_) => setState(() => _step = s),
                      selectedColor: const Color(0xFF4A9EFF).withValues(alpha: 0.25),
                      backgroundColor: Colors.white.withValues(alpha: 0.05),
                      labelStyle: TextStyle(
                        color: _step == s ? const Color(0xFF4A9EFF) : Colors.white.withValues(alpha: 0.55),
                        fontWeight: FontWeight.w700,
                      ),
                      side: BorderSide(
                        color: _step == s
                            ? const Color(0xFF4A9EFF).withValues(alpha: 0.5)
                            : Colors.transparent,
                      ),
                    ),
                  ))),
                ],
              ),
              const SizedBox(height: 24),

              // Decrement / Increment row.
              Row(
                children: [
                  Expanded(
                    child: _counterBtn(
                      label: '−',
                      color: Colors.white.withValues(alpha: 0.7),
                      bgColor: Colors.white.withValues(alpha: 0.06),
                      onTap: () => context.read<SenderBloc>()
                          .add(DecrementCounterCue(_step)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _counterBtn(
                      label: '+',
                      color: const Color(0xFF4A9EFF),
                      bgColor: const Color(0xFF4A9EFF).withValues(alpha: 0.12),
                      onTap: () => context.read<SenderBloc>()
                          .add(IncrementCounterCue(_step)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Set value row.
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _setController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Set value...',
                        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.25)),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.05),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF4A9EFF)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      final v = int.tryParse(_setController.text);
                      if (v != null) {
                        context.read<SenderBloc>().add(SetCounterCue(v));
                        _setController.clear();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A9EFF),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('SET',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, color: Colors.white)),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // RESET button.
              TextButton.icon(
                onPressed: () =>
                    context.read<SenderBloc>().add(const ResetCounterCue()),
                icon: Icon(Icons.replay, color: Colors.white.withValues(alpha: 0.4), size: 16),
                label: Text(
                  'RESET COUNTER',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    letterSpacing: 1.5,
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

  Widget _counterBtn({
    required String label,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 42,
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
      ),
    );
  }
}
