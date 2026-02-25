import 'package:equatable/equatable.dart';

abstract class ConnectionState extends Equatable {
  const ConnectionState();
  @override
  List<Object?> get props => [];
}

class ConnectionIdle extends ConnectionState {
  const ConnectionIdle();
}

/// Sender is advertising and waiting for a Receiver to discover it.
class Advertising extends ConnectionState {
  final String deviceName;
  const Advertising(this.deviceName);
  @override
  List<Object?> get props => [deviceName];
}

/// Sender received a connection request; waiting for user to accept/reject.
class ConnectionRequestReceived extends ConnectionState {
  final String endpointId;
  final String endpointName;
  const ConnectionRequestReceived(this.endpointId, this.endpointName);
  @override
  List<Object?> get props => [endpointId, endpointName];
}

/// Receiver is scanning for nearby Senders.
class Discovering extends ConnectionState {
  final String deviceName;
  const Discovering(this.deviceName);
  @override
  List<Object?> get props => [deviceName];
}

/// Receiver found one or more Senders.
class DiscoveredEndpoints extends ConnectionState {
  final List<({String id, String name})> endpoints;
  const DiscoveredEndpoints(this.endpoints);
  @override
  List<Object?> get props => [endpoints];
}

/// Receiver tapped a Sender and is waiting for the Sender to accept.
class AwaitingAccept extends ConnectionState {
  const AwaitingAccept();
}

/// Sender tapped ACCEPT and is waiting for the Nearby handshake to complete.
class AcceptingConnection extends ConnectionState {
  const AcceptingConnection();
}

/// Both sides established a connection.
class Connected extends ConnectionState {
  final String endpointId;
  final String remoteName;
  const Connected(this.endpointId, this.remoteName);
  @override
  List<Object?> get props => [endpointId, remoteName];
}

class ConnectionError extends ConnectionState {
  final String message;
  const ConnectionError(this.message);
  @override
  List<Object?> get props => [message];
}
