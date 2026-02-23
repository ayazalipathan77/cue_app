import 'package:equatable/equatable.dart';

class SenderState extends Equatable {
  final int activeTab;
  final String lastSentDescription;
  final bool timerRunning;

  const SenderState({
    this.activeTab = 0,
    this.lastSentDescription = '',
    this.timerRunning = false,
  });

  SenderState copyWith({
    int? activeTab,
    String? lastSentDescription,
    bool? timerRunning,
  }) {
    return SenderState(
      activeTab: activeTab ?? this.activeTab,
      lastSentDescription: lastSentDescription ?? this.lastSentDescription,
      timerRunning: timerRunning ?? this.timerRunning,
    );
  }

  @override
  List<Object?> get props => [activeTab, lastSentDescription, timerRunning];
}
