import 'package:equatable/equatable.dart';
import '../../../core/payload_model.dart';

abstract class ReceiverEvent extends Equatable {
  const ReceiverEvent();
  @override
  List<Object?> get props => [];
}

class ReceiverPayloadReceived extends ReceiverEvent {
  final CuePayload payload;
  const ReceiverPayloadReceived(this.payload);
  @override
  List<Object?> get props => [payload];
}

class ReceiverTimerTick extends ReceiverEvent {
  const ReceiverTimerTick();
}

class ReceiverDisconnected extends ReceiverEvent {
  const ReceiverDisconnected();
}

class ReceiverCountdownTick extends ReceiverEvent {
  const ReceiverCountdownTick();
}
