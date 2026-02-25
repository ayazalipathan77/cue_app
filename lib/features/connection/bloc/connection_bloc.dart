import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/nearby_service.dart';
import 'connection_event.dart';
import 'connection_state.dart';

export 'connection_event.dart';
export 'connection_state.dart';

class ConnectionBloc extends Bloc<ConnectionEvent, ConnectionState> {
  final NearbyService _nearby = NearbyService.instance;

  /// Broadcast stream of raw payload bytes for ReceiverScreen to consume.
  final StreamController<Uint8List> _payloadController =
      StreamController.broadcast();
  Stream<Uint8List> get payloadStream => _payloadController.stream;

  /// Tracks discovered endpoints for the Receiver discovery list.
  final List<({String id, String name})> _discovered = [];

  ConnectionBloc() : super(const ConnectionIdle()) {
    on<StartAdvertising>(_onStartAdvertising);
    on<StartDiscovery>(_onStartDiscovery);
    on<EndpointFound>(_onEndpointFound);
    on<EndpointLost>(_onEndpointLost);
    on<IncomingConnectionRequested>(_onIncomingConnectionRequested);
    on<AcceptConnection>(_onAcceptConnection);
    on<RejectConnection>(_onRejectConnection);
    on<RequestConnectionToSender>(_onRequestConnectionToSender);
    on<ConnectionEstablished>(_onConnectionEstablished);
    on<Disconnected>(_onDisconnected);
    on<ConnectionErrorOccurred>(_onConnectionError);
    on<PayloadReceived>(_onPayloadReceived);
  }

  // ── Advertising ───────────────────────────────────────────────────────────

  Future<void> _onStartAdvertising(
    StartAdvertising event,
    Emitter<ConnectionState> emit,
  ) async {
    _advertisingDeviceName = event.deviceName;
    emit(Advertising(event.deviceName));
    try {
      await _nearby.startAdvertising(
        event.deviceName,
        onConnectionRequest: (id, name) =>
            add(IncomingConnectionRequested(id, name)),
        onConnected: (id) => add(ConnectionEstablished(id, _pendingRemoteName)),
        onPayload: (id, bytes) => add(PayloadReceived(id, bytes)),
        onDisconnected: (_) => add(const Disconnected()),
      );
    } catch (e) {
      emit(ConnectionError('Failed to start advertising: $e'));
    }
  }

  // ── Discovery ─────────────────────────────────────────────────────────────

  Future<void> _onStartDiscovery(
    StartDiscovery event,
    Emitter<ConnectionState> emit,
  ) async {
    _discovered.clear();
    emit(Discovering(event.deviceName));
    try {
      await _nearby.startDiscovery(
        event.deviceName,
        onFound: (id, name) => add(EndpointFound(id, name)),
        onLost: (id) => add(EndpointLost(id)),
      );
    } catch (e) {
      emit(ConnectionError('Failed to start discovery: $e'));
    }
  }

  void _onEndpointFound(EndpointFound event, Emitter<ConnectionState> emit) {
    if (!_discovered.any((e) => e.id == event.endpointId)) {
      _discovered.add((id: event.endpointId, name: event.endpointName));
    }
    emit(DiscoveredEndpoints(List.from(_discovered)));
  }

  void _onEndpointLost(EndpointLost event, Emitter<ConnectionState> emit) {
    _discovered.removeWhere((e) => e.id == event.endpointId);
    emit(DiscoveredEndpoints(List.from(_discovered)));
  }

  // ── Connection handshake ──────────────────────────────────────────────────

  String _pendingRemoteName = '';
  String _advertisingDeviceName = '';  // remember own name for reject/re-advertise

  void _onIncomingConnectionRequested(
    IncomingConnectionRequested event,
    Emitter<ConnectionState> emit,
  ) {
    _pendingRemoteName = event.endpointName;
    emit(ConnectionRequestReceived(event.endpointId, event.endpointName));
  }

  Future<void> _onAcceptConnection(
    AcceptConnection event,
    Emitter<ConnectionState> emit,
  ) async {
    try {
      await _nearby.acceptConnection(
        event.endpointId,
        onPayload: (id, bytes) => add(PayloadReceived(id, bytes)),
      );
    } catch (e) {
      emit(ConnectionError('Failed to accept connection: $e'));
    }
  }

  Future<void> _onRejectConnection(
    RejectConnection event,
    Emitter<ConnectionState> emit,
  ) async {
    try {
      await _nearby.disconnectFromEndpoint(event.endpointId);
    } catch (_) {}
    _pendingRemoteName = '';
    // Resume advertising under the original device name.
    emit(Advertising(_advertisingDeviceName));
  }

  Future<void> _onRequestConnectionToSender(
    RequestConnectionToSender event,
    Emitter<ConnectionState> emit,
  ) async {
    emit(const AwaitingAccept());
    try {
      await _nearby.requestConnection(
        event.localDeviceName,
        event.endpointId,
        onConnected: (id) {
          final name = _discovered.firstWhere(
            (e) => e.id == id,
            orElse: () => (id: id, name: 'Sender'),
          ).name;
          add(ConnectionEstablished(id, name));
        },
        onPayload: (id, bytes) => add(PayloadReceived(id, bytes)),
        onDisconnected: (_) => add(const Disconnected()),
      );
    } catch (e) {
      emit(ConnectionError('Connection failed: $e'));
    }
  }

  void _onConnectionEstablished(
    ConnectionEstablished event,
    Emitter<ConnectionState> emit,
  ) {
    emit(Connected(event.endpointId, event.remoteName));
  }

  void _onDisconnected(Disconnected event, Emitter<ConnectionState> emit) {
    _nearby.stopAll();
    _discovered.clear();
    emit(const ConnectionIdle());
  }

  void _onConnectionError(
    ConnectionErrorOccurred event,
    Emitter<ConnectionState> emit,
  ) {
    emit(ConnectionError(event.message));
  }

  /// Forwards raw payload bytes to the broadcast stream consumed by ReceiverScreen.
  void _onPayloadReceived(
    PayloadReceived event,
    Emitter<ConnectionState> emit,
  ) {
    if (!_payloadController.isClosed) {
      _payloadController.add(event.bytes);
    }
  }

  @override
  Future<void> close() async {
    // Stop Nearby first so no more events arrive after we close the controller.
    await _nearby.stopAll();
    await _payloadController.close();
    return super.close();
  }
}
