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

  Future<void> _send(CuePayload payload) async {
    await _nearby.sendCue(endpointId, payload);
  }

  Future<void> _onSendText(SendTextCue e, Emitter<SenderState> emit) async {
    await _send(CuePayload.text(e.value,
        color: _colorToHex(e.textColor), bg: _colorToHex(e.bgColor)));
    emit(state.copyWith(lastSentDescription: 'Text: "${e.value}"'));
  }

  Future<void> _onSendClear(SendClearCue e, Emitter<SenderState> emit) async {
    await _send(CuePayload.clear());
    emit(state.copyWith(lastSentDescription: 'Clear'));
  }

  Future<void> _onStartTimer(StartTimerCue e, Emitter<SenderState> emit) async {
    await _send(CuePayload.timer('start',
        direction: e.countDown ? 'down' : 'up', seconds: e.seconds));
    emit(state.copyWith(
      timerRunning: true,
      lastSentDescription: 'Timer started (${e.countDown ? '▼' : '▲'} ${e.seconds}s)',
    ));
  }

  Future<void> _onPauseTimer(PauseTimerCue e, Emitter<SenderState> emit) async {
    await _send(CuePayload.timer('pause'));
    emit(state.copyWith(timerRunning: false, lastSentDescription: 'Timer paused'));
  }

  Future<void> _onResumeTimer(ResumeTimerCue e, Emitter<SenderState> emit) async {
    await _send(CuePayload.timer('resume'));
    emit(state.copyWith(timerRunning: true, lastSentDescription: 'Timer resumed'));
  }

  Future<void> _onResetTimer(ResetTimerCue e, Emitter<SenderState> emit) async {
    await _send(CuePayload.timer('reset'));
    emit(state.copyWith(timerRunning: false, lastSentDescription: 'Timer reset'));
  }

  Future<void> _onIncrement(IncrementCounterCue e, Emitter<SenderState> emit) async {
    await _send(CuePayload.counter('increment', step: e.step));
    emit(state.copyWith(lastSentDescription: 'Counter +${e.step}'));
  }

  Future<void> _onDecrement(DecrementCounterCue e, Emitter<SenderState> emit) async {
    await _send(CuePayload.counter('decrement', step: e.step));
    emit(state.copyWith(lastSentDescription: 'Counter -${e.step}'));
  }

  Future<void> _onSetCounter(SetCounterCue e, Emitter<SenderState> emit) async {
    await _send(CuePayload.counter('set', value: e.value));
    emit(state.copyWith(lastSentDescription: 'Counter set to ${e.value}'));
  }

  Future<void> _onResetCounter(ResetCounterCue e, Emitter<SenderState> emit) async {
    await _send(CuePayload.counter('set', value: 0));
    emit(state.copyWith(lastSentDescription: 'Counter reset'));
  }

  Future<void> _onStartFlash(StartFlashCue e, Emitter<SenderState> emit) async {
    await _send(CuePayload.flash('start',
        hz: e.hz, color: _colorToHex(e.color)));
    emit(state.copyWith(lastSentDescription: 'Flash started @ ${e.hz}Hz'));
  }

  Future<void> _onStopFlash(StopFlashCue e, Emitter<SenderState> emit) async {
    await _send(CuePayload.flash('stop'));
    emit(state.copyWith(lastSentDescription: 'Flash stopped'));
  }

  void _onChangeTab(ChangeTab e, Emitter<SenderState> emit) {
    emit(state.copyWith(activeTab: e.tabIndex));
  }
}
