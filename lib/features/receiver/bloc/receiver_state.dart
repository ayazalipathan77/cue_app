import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class ReceiverState extends Equatable {
  const ReceiverState();
  @override
  List<Object?> get props => [];
}

/// Default state: black screen, "Waiting..." text.
class ReceiverWaiting extends ReceiverState {
  const ReceiverWaiting();
}

/// Text cue received.
class ReceiverShowText extends ReceiverState {
  final String text;
  final Color textColor;
  final Color bgColor;

  const ReceiverShowText({
    required this.text,
    required this.textColor,
    required this.bgColor,
  });

  @override
  List<Object?> get props => [text, textColor, bgColor];
}

/// Timer cue active.
class ReceiverShowTimer extends ReceiverState {
  final int seconds;
  final bool running;
  final bool countingDown;

  const ReceiverShowTimer({
    required this.seconds,
    required this.running,
    required this.countingDown,
  });

  ReceiverShowTimer copyWith({int? seconds, bool? running, bool? countingDown}) {
    return ReceiverShowTimer(
      seconds: seconds ?? this.seconds,
      running: running ?? this.running,
      countingDown: countingDown ?? this.countingDown,
    );
  }

  @override
  List<Object?> get props => [seconds, running, countingDown];
}

/// Counter cue active.
class ReceiverShowCounter extends ReceiverState {
  final int value;
  const ReceiverShowCounter(this.value);
  @override
  List<Object?> get props => [value];
}

/// Flash cue active.
class ReceiverShowFlash extends ReceiverState {
  final Color flashColor;
  final double hz;
  const ReceiverShowFlash({required this.flashColor, required this.hz});
  @override
  List<Object?> get props => [flashColor, hz];
}

/// Sender disconnected — showing 3-second countdown before returning to role select.
class ReceiverDisconnecting extends ReceiverState {
  final int countdown;
  const ReceiverDisconnecting(this.countdown);
  @override
  List<Object?> get props => [countdown];
}
