import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class SenderEvent extends Equatable {
  const SenderEvent();
  @override
  List<Object?> get props => [];
}

class SendTextCue extends SenderEvent {
  final String value;
  final Color textColor;
  final Color bgColor;
  const SendTextCue(this.value, this.textColor, this.bgColor);
  @override
  List<Object?> get props => [value, textColor, bgColor];
}

class SendClearCue extends SenderEvent {
  const SendClearCue();
}

class StartTimerCue extends SenderEvent {
  final bool countDown;
  final int seconds;
  const StartTimerCue({required this.countDown, required this.seconds});
  @override
  List<Object?> get props => [countDown, seconds];
}

class PauseTimerCue extends SenderEvent {
  const PauseTimerCue();
}

class ResumeTimerCue extends SenderEvent {
  const ResumeTimerCue();
}

class ResetTimerCue extends SenderEvent {
  const ResetTimerCue();
}

class IncrementCounterCue extends SenderEvent {
  final int step;
  const IncrementCounterCue(this.step);
  @override
  List<Object?> get props => [step];
}

class DecrementCounterCue extends SenderEvent {
  final int step;
  const DecrementCounterCue(this.step);
  @override
  List<Object?> get props => [step];
}

class SetCounterCue extends SenderEvent {
  final int value;
  const SetCounterCue(this.value);
  @override
  List<Object?> get props => [value];
}

class ResetCounterCue extends SenderEvent {
  const ResetCounterCue();
}

class StartFlashCue extends SenderEvent {
  final Color color;
  final double hz;
  const StartFlashCue(this.color, this.hz);
  @override
  List<Object?> get props => [color, hz];
}

class StopFlashCue extends SenderEvent {
  const StopFlashCue();
}

class ChangeTab extends SenderEvent {
  final int tabIndex;
  const ChangeTab(this.tabIndex);
  @override
  List<Object?> get props => [tabIndex];
}
