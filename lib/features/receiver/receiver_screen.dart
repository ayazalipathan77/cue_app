import 'dart:async';
import 'package:flutter/material.dart' hide ConnectionState;
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../connection/bloc/connection_bloc.dart';
import 'bloc/receiver_bloc.dart';
import '../../core/nearby_service.dart';
import '../../core/payload_model.dart';
import 'widgets/text_display.dart';
import 'widgets/timer_display.dart';
import 'widgets/counter_display.dart';
import 'widgets/flash_display.dart';

class ReceiverScreen extends StatefulWidget {
  const ReceiverScreen({super.key});

  @override
  State<ReceiverScreen> createState() => _ReceiverScreenState();
}

class _ReceiverScreenState extends State<ReceiverScreen> {
  late final ReceiverBloc _receiverBloc;
  StreamSubscription<Uint8List>? _payloadSub;
  StreamSubscription<ConnectionState>? _connectionSub;

  @override
  void initState() {
    super.initState();

    // Keep screen on, lock to landscape, hide all system UI.
    WakelockPlus.enable();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _receiverBloc = ReceiverBloc();

    // Wire up payload delivery from the Connection layer after first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _listenForPayloads();
    });
  }

  void _listenForPayloads() {
    final connBloc = context.read<ConnectionBloc>();

    // Forward raw payload bytes to ReceiverBloc via the broadcast stream.
    _payloadSub = connBloc.payloadStream.listen(_handlePayloadBytes);

    // Watch for disconnects.
    _connectionSub = connBloc.stream.listen((state) {
      if (state is ConnectionIdle) {
        _receiverBloc.add(const ReceiverDisconnected());
      }
    });
  }

  void _handlePayloadBytes(Uint8List bytes) {
    try {
      final payload = CuePayload.fromBytes(bytes);
      _receiverBloc.add(ReceiverPayloadReceived(payload));
    } catch (_) {
      // Malformed payload — ignore.
    }
  }

  @override
  void dispose() {
    _payloadSub?.cancel();
    _connectionSub?.cancel();
    WakelockPlus.disable();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _receiverBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _receiverBloc,
      child: BlocListener<ReceiverBloc, ReceiverState>(
        listener: (context, state) {
          if (state is ReceiverDisconnecting && state.countdown == 0) {
            NearbyService.instance.stopAll();
            context.go('/');
          }
        },
        child: Scaffold(
          backgroundColor: Colors.black,
          body: BlocBuilder<ReceiverBloc, ReceiverState>(
            builder: (context, state) {
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _buildContent(state),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContent(ReceiverState state) {
    if (state is ReceiverShowText) {
      return TextDisplay(
        key: const ValueKey('text'),
        text: state.text,
        textColor: state.textColor,
        bgColor: state.bgColor,
      );
    }

    if (state is ReceiverShowTimer) {
      return TimerDisplay(
        key: const ValueKey('timer'),
        seconds: state.seconds,
        countingDown: state.countingDown,
      );
    }

    if (state is ReceiverShowCounter) {
      return CounterDisplay(
        key: const ValueKey('counter'),
        value: state.value,
      );
    }

    if (state is ReceiverShowFlash) {
      return FlashDisplay(
        key: ValueKey('flash-${state.hz}-${state.flashColor}'),
        flashColor: state.flashColor,
        hz: state.hz,
      );
    }

    if (state is ReceiverDisconnecting) {
      return Container(
        key: const ValueKey('disconnecting'),
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.link_off, color: Colors.white54, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Sender disconnected',
                style: TextStyle(color: Colors.white60, fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                'Returning in ${state.countdown}...',
                style: const TextStyle(color: Colors.white38, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    // Default: ReceiverWaiting.
    return Container(
      key: const ValueKey('waiting'),
      color: Colors.black,
      child: const Center(
        child: Text(
          'Waiting...',
          style: TextStyle(color: Colors.white24, fontSize: 18),
        ),
      ),
    );
  }
}
