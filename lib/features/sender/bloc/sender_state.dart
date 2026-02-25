import 'package:equatable/equatable.dart';

class SenderState extends Equatable {
  final int activeTab;
  final String lastSentDescription;
  final bool timerRunning;
  /// True when a timer was started then paused — shows RESUME instead of START.
  final bool timerPaused;
  /// Non-null when the last send failed — displayed in the sender status bar.
  final String? sendError;

  const SenderState({
    this.activeTab = 0,
    this.lastSentDescription = '',
    this.timerRunning = false,
    this.timerPaused = false,
    this.sendError,
  });

  SenderState copyWith({
    int? activeTab,
    String? lastSentDescription,
    bool? timerRunning,
    bool? timerPaused,
    String? sendError,
    bool clearSendError = false,
  }) {
    return SenderState(
      activeTab: activeTab ?? this.activeTab,
      lastSentDescription: lastSentDescription ?? this.lastSentDescription,
      timerRunning: timerRunning ?? this.timerRunning,
      timerPaused: timerPaused ?? this.timerPaused,
      sendError: clearSendError ? null : (sendError ?? this.sendError),
    );
  }

  @override
  List<Object?> get props =>
      [activeTab, lastSentDescription, timerRunning, timerPaused, sendError];
}
