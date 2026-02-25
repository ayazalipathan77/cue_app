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
typedef OnError = void Function(String message);

/// Singleton wrapper around the nearby_connections plugin.
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
        try {
          onConnectionRequest(endpointId, info.endpointName);
        } catch (_) {}
      },
      onConnectionResult: (endpointId, status) {
        if (status == nc.Status.CONNECTED) {
          try { onConnected(endpointId); } catch (_) {}
        }
      },
      onDisconnected: (endpointId) {
        try { onDisconnected(endpointId); } catch (_) {}
      },
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
      onEndpointFound: (endpointId, name, serviceId) {
        try { onFound(endpointId, name); } catch (_) {}
      },
      onEndpointLost: (endpointId) {
        try { onLost(endpointId ?? ''); } catch (_) {}
      },
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
        if (status == nc.Status.CONNECTED) {
          try { onConnected(id); } catch (_) {}
        }
      },
      onDisconnected: (id) {
        try { onDisconnected(id); } catch (_) {}
      },
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
          try {
            onPayload(id, Uint8List.fromList(payload.bytes!));
          } catch (_) {}
        }
      },
      onPayloadTransferUpdate: (id, update) {},
    );
  }

  // ── Data transmission ─────────────────────────────────────────────────────

  Future<void> sendCue(String endpointId, CuePayload payload) async {
    await nc.Nearby().sendBytesPayload(endpointId, payload.toBytes());
  }

  // ── Cleanup (all swallow exceptions — best-effort) ────────────────────────

  Future<void> stopAdvertising() async {
    try { await nc.Nearby().stopAdvertising(); } catch (_) {}
  }

  Future<void> stopDiscovery() async {
    try { await nc.Nearby().stopDiscovery(); } catch (_) {}
  }

  Future<void> disconnectFromEndpoint(String endpointId) async {
    try { await nc.Nearby().disconnectFromEndpoint(endpointId); } catch (_) {}
  }

  Future<void> stopAll() async {
    try { await nc.Nearby().stopAllEndpoints(); } catch (_) {}
    try { await nc.Nearby().stopAdvertising(); } catch (_) {}
    try { await nc.Nearby().stopDiscovery(); } catch (_) {}
  }
}
