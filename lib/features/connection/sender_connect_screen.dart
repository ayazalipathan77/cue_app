import 'package:flutter/material.dart' hide ConnectionState;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'bloc/connection_bloc.dart';
import '../../core/constants.dart';
import '../../core/device_name_service.dart';

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

    _loadNameThenAdvertise();
  }

  /// Load persisted name first, then start advertising so the name is correct.
  Future<void> _loadNameThenAdvertise() async {
    final name = await DeviceNameService.senderName();
    if (mounted) setState(() => _deviceName = name);
    await _requestPermissionsAndAdvertise();
  }

  Future<void> _requestPermissionsAndAdvertise() async {
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

    final permissions = [
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.location,
      Permission.nearbyWifiDevices,
    ];

    final currentStatuses = await Future.wait(permissions.map((p) => p.status));
    final needsRequest = currentStatuses.any((s) => !s.isGranted);

    if (needsRequest) {
      final statuses = await permissions.request();
      final permanentlyBlocked = statuses.values.any(
        (s) => s == PermissionStatus.permanentlyDenied,
      );
      if (permanentlyBlocked && mounted) {
        context.read<ConnectionBloc>().add(
          const ConnectionErrorOccurred(
            'Permissions are permanently denied.\n\nOpen Android Settings → Apps → CUE → Permissions and enable all.',
          ),
        );
        return;
      }
    }

    if (mounted) {
      context.read<ConnectionBloc>().add(StartAdvertising(_deviceName));
    }
  }

  Future<void> _editDeviceName() async {
    final controller = TextEditingController(text: _deviceName);
    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Device Name', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 20,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'e.g. Main Stage Sender',
            hintStyle:
                TextStyle(color: Colors.white.withValues(alpha: 0.35)),
            counterStyle:
                TextStyle(color: Colors.white.withValues(alpha: 0.35)),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.06),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  BorderSide(color: Colors.white.withValues(alpha: 0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF4A9EFF)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style:
                    TextStyle(color: Colors.white.withValues(alpha: 0.5))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A9EFF)),
            child:
                const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (newName != null) {
      final trimmed =
          newName.trim().isEmpty ? 'CUE-Sender' : newName.trim();
      await DeviceNameService.saveSenderName(trimmed);
      if (mounted) {
        setState(() => _deviceName = trimmed);
        // Restart advertising with the updated name.
        context.read<ConnectionBloc>().add(StartAdvertising(trimmed));
      }
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
          final router = GoRouter.of(context);
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) router.go('/sender');
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
            if (state is AcceptingConnection) return _buildAccepting();
            if (state is ConnectionRequestReceived) {
              return _buildRequestReceived(context, state);
            }
            if (state is ConnectionError) {
              return _buildError(context, state.message);
            }
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
            const SizedBox(height: 20),
            // Tappable device name badge — tap to rename.
            GestureDetector(
              onTap: _editDeviceName,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.12)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.devices,
                        size: 14,
                        color: Colors.white.withValues(alpha: 0.45)),
                    const SizedBox(width: 6),
                    Text(
                      _deviceName,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.65),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(Icons.edit,
                        size: 13,
                        color: Colors.white.withValues(alpha: 0.35)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestReceived(
      BuildContext context, ConnectionRequestReceived state) {
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
                    child: const Text('REJECT',
                        style: TextStyle(fontWeight: FontWeight.w700)),
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
                      style: TextStyle(
                          fontWeight: FontWeight.w700, color: Colors.white),
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

  Widget _buildAccepting() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFF00E676)),
          SizedBox(height: 28),
          Text(
            'Connecting...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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
