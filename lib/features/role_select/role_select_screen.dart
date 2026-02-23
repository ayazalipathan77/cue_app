import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';

class RoleSelectScreen extends StatefulWidget {
  const RoleSelectScreen({super.key});

  @override
  State<RoleSelectScreen> createState() => _RoleSelectScreenState();
}

class _RoleSelectScreenState extends State<RoleSelectScreen>
    with TickerProviderStateMixin {
  late final AnimationController _titleController;
  late final AnimationController _card1Controller;
  late final AnimationController _card2Controller;

  late final Animation<double> _titleFade;
  late final Animation<double> _card1Fade;
  late final Animation<double> _card2Fade;
  late final Animation<Offset> _card1Slide;
  late final Animation<Offset> _card2Slide;

  @override
  void initState() {
    super.initState();
    // Lock to portrait on this screen.
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    _titleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _card1Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _card2Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _titleFade = CurvedAnimation(parent: _titleController, curve: Curves.easeOut);
    _card1Fade = CurvedAnimation(parent: _card1Controller, curve: Curves.easeOut);
    _card2Fade = CurvedAnimation(parent: _card2Controller, curve: Curves.easeOut);
    _card1Slide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _card1Controller, curve: Curves.easeOut));
    _card2Slide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _card2Controller, curve: Curves.easeOut));

    // Staggered entry.
    _titleController.forward();
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) _card1Controller.forward();
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _card2Controller.forward();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _card1Controller.dispose();
    _card2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Title ──────────────────────────────────────────────────────
              FadeTransition(
                opacity: _titleFade,
                child: Column(
                  children: [
                    const Icon(
                      Icons.radio_button_checked,
                      size: 56,
                      color: Color(0xFF4A9EFF),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'CUE',
                      style: TextStyle(
                        fontSize: 52,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'OFFLINE WIRELESS PROMPTER',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.35),
                        letterSpacing: 3,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 56),

              // ── Sender Card ────────────────────────────────────────────────
              FadeTransition(
                opacity: _card1Fade,
                child: SlideTransition(
                  position: _card1Slide,
                  child: _RoleCard(
                    icon: Icons.broadcast_on_personal,
                    label: 'SENDER',
                    subtitle: 'Control the display',
                    accentColor: const Color(0xFF4A9EFF),
                    onTap: () => context.go('/sender/connect'),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── Receiver Card ──────────────────────────────────────────────
              FadeTransition(
                opacity: _card2Fade,
                child: SlideTransition(
                  position: _card2Slide,
                  child: _RoleCard(
                    icon: Icons.monitor,
                    label: 'RECEIVER',
                    subtitle: 'Show the content',
                    accentColor: const Color(0xFF00E676),
                    onTap: () => context.go('/receiver/connect'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color accentColor;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: accentColor, size: 30),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.45),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white.withValues(alpha: 0.3),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
