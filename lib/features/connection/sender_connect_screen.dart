import 'package:flutter/material.dart' hide ConnectionState;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'bloc/connection_bloc.dart';
import '../../core/constants.dart';

class SenderConnectScreen extends StatefulWidget {
  const SenderConnectScreen({super.key});

  @override
  State<SenderConnectScreen> createState() => _SenderConnectScreenState();
}

class _SenderConnectScreenState extends State<SenderConnectScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  String _deviceName = 'CUE-Sender';

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _loadDeviceName();
    _requestPermissionsAndAdvertise();
  }

  Future<void> _loadDeviceName() async {
    // Use hostname or a default.
    setState(() => _deviceName = 'CUE-Sender');
  }

  Future<void> _requestPermissionsAndAdvertise() async {
    // Check location services toggle (GPS must be ON for Nearby Connections).
    final locationService = await Permission.location.serviceStatus;
    if (locationService != ServiceStatus.enabled && mounted) {
      context.read<ConnectionBloc>().add(
        const ConnectionErrorOccurred(
          'Location services are OFF.\n\nGo to Android Settings → Location and turn it ON. '
          'Nearby Connections requires Location to scan for devices.',
        ),
      );
      return;
    }

    final statuses = await [
      Permission.bluetooth,
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.location,
      Permission.nearbyWifiDevices,
    ].request();

    final denied = statuses.values.any(
      (s) => s == PermissionStatus.denied || s == PermissionStatus.permanentlyDenied,
    );

    if (denied && mounted) {
      context.read<ConnectionBloc>().add(
        const ConnectionErrorOccurred('Some permissions were denied. Tap RETRY and allow all permissions.'),
      );
      return;
    }

    if (mounted) {
      context.read<ConnectionBloc>().add(StartAdvertising(_deviceName));
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConnectionBloc, ConnectionState>(
      listener: (context, state) {
        if (state is Connected) {
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) context.go('/sender');
          });
        }
        if (state is ConnectionError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              action: SnackBarAction(
                label: 'RETRY',
                onPressed: () => context
                    .read<ConnectionBloc>()
                    .add(StartAdvertising(_deviceName)),
              ),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: kBgColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.go('/'),
          ),
          title: const Text(
            'SENDER',
            style: TextStyle(color: Colors.white, letterSpacing: 2),
          ),
        ),
        body: BlocBuilder<ConnectionBloc, ConnectionState>(
          builder: (context, state) {
            if (state is Connected) return _buildConnected(state.remoteName);
            if (state is ConnectionRequestReceived) return _buildRequestReceived(context, state);
            if (state is ConnectionError) return _buildError(context, state.message);
            return _buildAdvertising();
          },
        ),
      ),
    );
  }

  Widget _buildAdvertising() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Opacity(
                  opacity: 0.5 + _pulseController.value * 0.5,
                  child: child,
                );
              },
              child: const Icon(
                Icons.broadcast_on_personal,
                size: 80,
                color: Color(0xFF4A9EFF),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Waiting for receiver\nto connect...',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Device name: $_deviceName',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.45),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestReceived(BuildContext context, ConnectionRequestReceived state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.devices, size: 64, color: Color(0xFFFFE600)),
            const SizedBox(height: 24),
            const Text(
              'Connection Request',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '"${state.endpointName}" wants to connect',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.65),
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 40),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context
                        .read<ConnectionBloc>()
                        .add(RejectConnection(state.endpointId)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('REJECT', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => context
                        .read<ConnectionBloc>()
                        .add(AcceptConnection(state.endpointId)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A9EFF),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'ACCEPT',
                      style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnected(String remoteName) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, size: 80, color: Color(0xFF00E676)),
          const SizedBox(height: 24),
          Text(
            'Connected to $remoteName',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          const CircularProgressIndicator(color: Color(0xFF4A9EFF)),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 24),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 15),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context
                  .read<ConnectionBloc>()
                  .add(StartAdvertising(_deviceName)),
              child: const Text('RETRY'),
            ),
          ],
        ),
      ),
    );
  }
}
