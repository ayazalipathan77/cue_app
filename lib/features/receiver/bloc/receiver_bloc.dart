import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/payload_model.dart';
import 'receiver_event.dart';
import 'receiver_state.dart';

export 'receiver_event.dart';
export 'receiver_state.dart';

class ReceiverBloc extends Bloc<ReceiverEvent, ReceiverState> {
  StreamSubscription<int>? _timerSub;
  StreamSubscription<int>? _countdownSub;

  ReceiverBloc() : super(const ReceiverWaiting()) {
    on<ReceiverPayloadReceived>(_onPayload);
    on<ReceiverTimerTick>(_onTimerTick);
    on<ReceiverDisconnected>(_onDisconnected);
    on<ReceiverCountdownTick>(_onCountdownTick);
  }

  // ── Payload handler ───────────────────────────────────────────────────────

  Future<void> _onPayload(
    ReceiverPayloadReceived event,
    Emitter<ReceiverState> emit,
  ) async {
    final p = event.payload;

    switch (p.type) {
      case PayloadType.text:
        _cancelTimer();
        emit(ReceiverShowText(
          text: p.value,
          textColor: hexToColor(p.textColor),
          bgColor: hexToColor(p.bgColor),
        ));

      case PayloadType.timer:
        await _handleTimer(p, emit);

      case PayloadType.counter:
        _handleCounter(p, emit);

      case PayloadType.flash:
        _cancelTimer();
        if (p.action == 'start') {
          emit(ReceiverShowFlash(
            flashColor: hexToColor(p.flashColor),
            hz: p.hz,
          ));
        } else {
          emit(const ReceiverWaiting());
        }

      case PayloadType.clear:
        _cancelTimer();
        emit(const ReceiverWaiting());

      case PayloadType.hello:
        // Sender identified itself — no display change needed.
        break;
    }
  }

  // ── Timer logic ───────────────────────────────────────────────────────────

  Future<void> _handleTimer(
    CuePayload p,
    Emitter<ReceiverState> emit,
  ) async {
    switch (p.action) {
      case 'start':
        _cancelTimer();
        final timerState = ReceiverShowTimer(
          seconds: p.seconds,
          running: true,
          countingDown: p.direction == 'down',
        );
        emit(timerState);
        _startTimerStream();

      case 'pause':
        if (state is ReceiverShowTimer) {
          _cancelTimer();
          emit((state as ReceiverShowTimer).copyWith(running: false));
        }

      case 'resume':
        if (state is ReceiverShowTimer) {
          emit((state as ReceiverShowTimer).copyWith(running: true));
          _startTimerStream();
        }

      case 'reset':
        _cancelTimer();
        if (state is ReceiverShowTimer) {
          emit((state as ReceiverShowTimer).copyWith(seconds: 0, running: false));
        }
    }
  }

  void _startTimerStream() {
    _timerSub = Stream.periodic(
      const Duration(seconds: 1),
      (i) => i,
    ).listen((_) => add(const ReceiverTimerTick()));
  }

  void _cancelTimer() {
    _timerSub?.cancel();
    _timerSub = null;
  }

  void _onTimerTick(ReceiverTimerTick event, Emitter<ReceiverState> emit) {
    if (state is! ReceiverShowTimer) return;
    final t = state as ReceiverShowTimer;
    if (!t.running) return;

    if (t.countingDown) {
      if (t.seconds <= 0) {
        _cancelTimer();
        emit(t.copyWith(seconds: 0, running: false));
      } else {
        emit(t.copyWith(seconds: t.seconds - 1));
      }
    } else {
      emit(t.copyWith(seconds: t.seconds + 1));
    }
  }

  // ── Counter logic ─────────────────────────────────────────────────────────

  void _handleCounter(CuePayload p, Emitter<ReceiverState> emit) {
    final current =
        state is ReceiverShowCounter ? (state as ReceiverShowCounter).value : 0;

    switch (p.action) {
      case 'set':
        emit(ReceiverShowCounter(p.counterValue));
      case 'increment':
        emit(ReceiverShowCounter(current + p.step));
      case 'decrement':
        emit(ReceiverShowCounter(current - p.step));
    }
  }

  // ── Disconnect ────────────────────────────────────────────────────────────

  void _onDisconnected(ReceiverDisconnected event, Emitter<ReceiverState> emit) {
    _cancelTimer();
    emit(const ReceiverDisconnecting(3));
    _countdownSub?.cancel();
    _countdownSub = Stream.periodic(
      const Duration(seconds: 1),
      (i) => 2 - i,
    ).take(3).listen((remaining) => add(const ReceiverCountdownTick()));
  }

  void _onCountdownTick(ReceiverCountdownTick event, Emitter<ReceiverState> emit) {
    if (state is ReceiverDisconnecting) {
      final d = state as ReceiverDisconnecting;
      if (d.countdown <= 1) {
        // Navigation is handled by the screen via BlocListener.
        emit(const ReceiverDisconnecting(0));
      } else {
        emit(ReceiverDisconnecting(d.countdown - 1));
      }
    }
  }

  @override
  Future<void> close() {
    _cancelTimer();
    _countdownSub?.cancel();
    return super.close();
  }
}
