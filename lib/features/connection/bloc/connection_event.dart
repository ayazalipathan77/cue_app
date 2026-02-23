import 'dart:typed_data';
import 'package:equatable/equatable.dart';

abstract class ConnectionEvent extends Equatable {
  const ConnectionEvent();
  @override
  List<Object?> get props => [];
}

class StartAdvertising extends ConnectionEvent {
  final String deviceName;
  const StartAdvertising(this.deviceName);
  @override
  List<Object?> get props => [deviceName];
}

class StartDiscovery extends ConnectionEvent {
  final String deviceName;
  const StartDiscovery(this.deviceName);
  @override
  List<Object?> get props => [deviceName];
}

class EndpointFound extends ConnectionEvent {
  final String endpointId;
  final String endpointName;
  const EndpointFound(this.endpointId, this.endpointName);
  @override
  List<Object?> get props => [endpointId, endpointName];
}

class EndpointLost extends ConnectionEvent {
  final String endpointId;
  const EndpointLost(this.endpointId);
  @override
  List<Object?> get props => [endpointId];
}

/// Sender received a connection request from a Receiver.
class IncomingConnectionRequested extends ConnectionEvent {
  final String endpointId;
  final String endpointName;
  const IncomingConnectionRequested(this.endpointId, this.endpointName);
  @override
  List<Object?> get props => [endpointId, endpointName];
}

class AcceptConnection extends ConnectionEvent {
  final String endpointId;
  const AcceptConnection(this.endpointId);
  @override
  List<Object?> get props => [endpointId];
}

class RejectConnection extends ConnectionEvent {
  final String endpointId;
  const RejectConnection(this.endpointId);
  @override
  List<Object?> get props => [endpointId];
}

/// Receiver tapped a discovered Sender to connect.
class RequestConnectionToSender extends ConnectionEvent {
  final String endpointId;
  final String localDeviceName;
  const RequestConnectionToSender(this.endpointId, this.localDeviceName);
  @override
  List<Object?> get props => [endpointId, localDeviceName];
}

class ConnectionEstablished extends ConnectionEvent {
  final String endpointId;
  final String remoteName;
  const ConnectionEstablished(this.endpointId, this.remoteName);
  @override
  List<Object?> get props => [endpointId, remoteName];
}

class Disconnected extends ConnectionEvent {
  const Disconnected();
}

class PayloadReceived extends ConnectionEvent {
  final String endpointId;
  final Uint8List bytes;
  const PayloadReceived(this.endpointId, this.bytes);
  @override
  List<Object?> get props => [endpointId];
}

class ConnectionErrorOccurred extends ConnectionEvent {
  final String message;
  const ConnectionErrorOccurred(this.message);
  @override
  List<Object?> get props => [message];
}
