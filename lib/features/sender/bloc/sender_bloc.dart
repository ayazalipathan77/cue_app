import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/nearby_service.dart';
import '../../../core/payload_model.dart';
import 'sender_event.dart';
import 'sender_state.dart';

export 'sender_event.dart';
export 'sender_state.dart';

/// Converts a Flutter Color to a hex string like "#RRGGBB".
String _colorToHex(Color c) {
  final r = (c.r * 255.0).round().clamp(0, 255);
  final g = (c.g * 255.0).round().clamp(0, 255);
  final b = (c.b * 255.0).round().clamp(0, 255);
  return '#${r.toRadixString(16).padLeft(2, '0')}${g.toRadixString(16).padLeft(2, '0')}${b.toRadixString(16).padLeft(2, '0')}'.toUpperCase();
}

class SenderBloc extends Bloc<SenderEvent, SenderState> {
  final NearbyService _nearby = NearbyService.instance;
  final String endpointId;

  SenderBloc(this.endpointId) : super(const SenderState()) {
    on<SendTextCue>(_onSendText);
    on<SendClearCue>(_onSendClear);
    on<StartTimerCue>(_onStartTimer);
    on<PauseTimerCue>(_onPauseTimer);
    on<ResumeTimerCue>(_onResumeTimer);
    on<ResetTimerCue>(_onResetTimer);
    on<IncrementCounterCue>(_onIncrement);
    on<DecrementCounterCue>(_onDecrement);
    on<SetCounterCue>(_onSetCounter);
    on<ResetCounterCue>(_onResetCounter);
    on<StartFlashCue>(_onStartFlash);
    on<StopFlashCue>(_onStopFlash);
    on<ChangeTab>(_onChangeTab);
  }

  /// Sends [payload] and emits success/failure via state.
  /// Returns true on success, false on failure.
  Future<bool> _trySend(
    CuePayload payload,
    Emitter<SenderState> emit,
    String description,
  ) async {
    try {
      await _nearby.sendCue(endpointId, payload);
      emit(state.copyWith(
        lastSentDescription: description,
        clearSendError: true,
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(sendError: 'Send failed: $e'));
      return false;
    }
  }

  Future<void> _onSendText(SendTextCue e, Emitter<SenderState> emit) async {
    await _trySend(
      CuePayload.text(e.value,
          color: _colorToHex(e.textColor), bg: _colorToHex(e.bgColor)),
      emit,
      'Text: "${e.value}"',
    );
  }

  Future<void> _onSendClear(SendClearCue e, Emitter<SenderState> emit) async {
    await _trySend(CuePayload.clear(), emit, 'Clear');
  }

  Future<void> _onStartTimer(StartTimerCue e, Emitter<SenderState> emit) async {
    final ok = await _trySend(
      CuePayload.timer('start',
          direction: e.countDown ? 'down' : 'up', seconds: e.seconds),
      emit,
      'Timer started (${e.countDown ? '▼' : '▲'} ${e.seconds}s)',
    );
    if (ok) emit(state.copyWith(timerRunning: true, timerPaused: false));
  }

  Future<void> _onPauseTimer(PauseTimerCue e, Emitter<SenderState> emit) async {
    final ok = await _trySend(CuePayload.timer('pause'), emit, 'Timer paused');
    if (ok) emit(state.copyWith(timerRunning: false, timerPaused: true));
  }

  Future<void> _onResumeTimer(ResumeTimerCue e, Emitter<SenderState> emit) async {
    final ok = await _trySend(CuePayload.timer('resume'), emit, 'Timer resumed');
    if (ok) emit(state.copyWith(timerRunning: true, timerPaused: false));
  }

  Future<void> _onResetTimer(ResetTimerCue e, Emitter<SenderState> emit) async {
    final ok = await _trySend(CuePayload.timer('reset'), emit, 'Timer reset');
    if (ok) emit(state.copyWith(timerRunning: false, timerPaused: false));
  }

  Future<void> _onIncrement(IncrementCounterCue e, Emitter<SenderState> emit) async {
    await _trySend(
        CuePayload.counter('increment', step: e.step), emit, 'Counter +${e.step}');
  }

  Future<void> _onDecrement(DecrementCounterCue e, Emitter<SenderState> emit) async {
    await _trySend(
        CuePayload.counter('decrement', step: e.step), emit, 'Counter -${e.step}');
  }

  Future<void> _onSetCounter(SetCounterCue e, Emitter<SenderState> emit) async {
    await _trySend(
        CuePayload.counter('set', value: e.value), emit, 'Counter set to ${e.value}');
  }

  Future<void> _onResetCounter(ResetCounterCue e, Emitter<SenderState> emit) async {
    await _trySend(CuePayload.counter('set', value: 0), emit, 'Counter reset');
  }

  Future<void> _onStartFlash(StartFlashCue e, Emitter<SenderState> emit) async {
    await _trySend(
      CuePayload.flash('start', hz: e.hz, color: _colorToHex(e.color)),
      emit,
      'Flash started @ ${e.hz}Hz',
    );
  }

  Future<void> _onStopFlash(StopFlashCue e, Emitter<SenderState> emit) async {
    await _trySend(CuePayload.flash('stop'), emit, 'Flash stopped');
  }

  void _onChangeTab(ChangeTab e, Emitter<SenderState> emit) {
    emit(state.copyWith(activeTab: e.tabIndex));
  }
}
