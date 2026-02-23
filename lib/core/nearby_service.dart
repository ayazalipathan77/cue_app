import 'dart:typed_data';
import 'package:nearby_connections/nearby_connections.dart' as nc;
import 'constants.dart';
import 'payload_model.dart';

typedef OnConnectionRequest = void Function(String endpointId, String endpointName);
typedef OnConnected = void Function(String endpointId);
typedef OnPayloadReceived = void Function(String endpointId, Uint8List bytes);
typedef OnEndpointFound = void Function(String endpointId, String endpointName);
typedef OnEndpointLost = void Function(String endpointId);
typedef OnDisconnected = void Function(String endpointId);

/// Singleton wrapper around the nearby_connections plugin.
/// All calls are fire-and-forget; errors are surfaced via callbacks where needed.
class NearbyService {
  NearbyService._();
  static final NearbyService instance = NearbyService._();

  // ── Advertising (Sender role) ─────────────────────────────────────────────

  Future<void> startAdvertising(
    String deviceName, {
    required OnConnectionRequest onConnectionRequest,
    required OnConnected onConnected,
    required OnPayloadReceived onPayload,
    required OnDisconnected onDisconnected,
  }) async {
    await nc.Nearby().startAdvertising(
      deviceName,
      nc.Strategy.P2P_POINT_TO_POINT,
      onConnectionInitiated: (endpointId, info) {
        onConnectionRequest(endpointId, info.endpointName);
      },
      onConnectionResult: (endpointId, status) {
        if (status == nc.Status.CONNECTED) onConnected(endpointId);
      },
      onDisconnected: (endpointId) => onDisconnected(endpointId),
      serviceId: kServiceId,
    );
  }

  // ── Discovery (Receiver role) ─────────────────────────────────────────────

  Future<void> startDiscovery(
    String deviceName, {
    required OnEndpointFound onFound,
    required OnEndpointLost onLost,
  }) async {
    await nc.Nearby().startDiscovery(
      deviceName,
      nc.Strategy.P2P_POINT_TO_POINT,
      onEndpointFound: (endpointId, name, serviceId) => onFound(endpointId, name),
      onEndpointLost: (endpointId) => onLost(endpointId ?? ''),
      serviceId: kServiceId,
    );
  }

  // ── Connection handshake ──────────────────────────────────────────────────

  /// Receiver calls this to initiate a connection to a discovered Sender.
  Future<void> requestConnection(
    String localDeviceName,
    String endpointId, {
    required OnConnected onConnected,
    required OnPayloadReceived onPayload,
    required OnDisconnected onDisconnected,
  }) async {
    await nc.Nearby().requestConnection(
      localDeviceName,
      endpointId,
      onConnectionInitiated: (id, info) {
        // Auto-accept on Receiver side.
        acceptConnection(id, onPayload: onPayload);
      },
      onConnectionResult: (id, status) {
        if (status == nc.Status.CONNECTED) onConnected(id);
      },
      onDisconnected: (id) => onDisconnected(id),
    );
  }

  /// Accept an incoming connection request (called by Sender on approval).
  Future<void> acceptConnection(
    String endpointId, {
    required OnPayloadReceived onPayload,
  }) async {
    await nc.Nearby().acceptConnection(
      endpointId,
      onPayLoadRecieved: (id, payload) {
        if (payload.type == nc.PayloadType.BYTES && payload.bytes != null) {
          onPayload(id, Uint8List.fromList(payload.bytes!));
        }
      },
      onPayloadTransferUpdate: (id, update) {},
    );
  }

  // ── Data transmission ─────────────────────────────────────────────────────

  Future<void> sendCue(String endpointId, CuePayload payload) async {
    await nc.Nearby().sendBytesPayload(endpointId, payload.toBytes());
  }

  // ── Cleanup ───────────────────────────────────────────────────────────────

  Future<void> stopAdvertising() async {
    await nc.Nearby().stopAdvertising();
  }

  Future<void> stopDiscovery() async {
    await nc.Nearby().stopDiscovery();
  }

  Future<void> disconnectFromEndpoint(String endpointId) async {
    await nc.Nearby().disconnectFromEndpoint(endpointId);
  }

  Future<void> stopAll() async {
    await nc.Nearby().stopAllEndpoints();
    await nc.Nearby().stopAdvertising();
    await nc.Nearby().stopDiscovery();
  }
}
