import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../connection/bloc/connection_bloc.dart';
import 'bloc/sender_bloc.dart';
import 'tabs/text_tab.dart';
import 'tabs/timer_tab.dart';
import 'tabs/counter_tab.dart';
import 'tabs/flash_tab.dart';
import 'widgets/connection_status_bar.dart';
import '../../core/constants.dart';

class SenderScreen extends StatelessWidget {
  const SenderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Pull connection info from ConnectionBloc.
    final connState = context.read<ConnectionBloc>().state;
    final endpointId = connState is Connected ? connState.endpointId : '';
    final remoteName = connState is Connected ? connState.remoteName : 'Unknown';

    return BlocProvider(
      create: (_) => SenderBloc(endpointId),
      child: DefaultTabController(
        length: 4,
        child: Scaffold(
          backgroundColor: kBgColor,
          body: SafeArea(
            child: Column(
              children: [
                // ── Connection status bar ─────────────────────────────────
                ConnectionStatusBar(remoteName: remoteName, endpointId: endpointId),

                // ── Tab bar ───────────────────────────────────────────────
                Container(
                  color: Colors.white.withValues(alpha: 0.03),
                  child: TabBar(
                    indicatorColor: const Color(0xFF4A9EFF),
                    indicatorWeight: 2.5,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white.withValues(alpha: 0.35),
                    labelStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                    tabs: const [
                      Tab(icon: Icon(Icons.text_fields, size: 20), text: 'TEXT'),
                      Tab(icon: Icon(Icons.timer_outlined, size: 20), text: 'TIMER'),
                      Tab(icon: Icon(Icons.tag, size: 20), text: 'COUNTER'),
                      Tab(icon: Icon(Icons.flash_on, size: 20), text: 'FLASH'),
                    ],
                  ),
                ),

                // ── Last sent info ────────────────────────────────────────
                BlocBuilder<SenderBloc, SenderState>(
                  builder: (context, state) {
                    if (state.lastSentDescription.isEmpty) return const SizedBox();
                    return Container(
                      color: Colors.white.withValues(alpha: 0.02),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle_outline,
                              size: 12, color: Colors.white.withValues(alpha: 0.35)),
                          const SizedBox(width: 6),
                          Text(
                            'Last: ${state.lastSentDescription}',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.35),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                // ── Tab content ───────────────────────────────────────────
                const Expanded(
                  child: TabBarView(
                    children: [
                      TextTab(),
                      TimerTab(),
                      CounterTab(),
                      FlashTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
