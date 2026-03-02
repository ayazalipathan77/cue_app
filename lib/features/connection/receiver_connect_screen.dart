import 'package:flutter/material.dart' hide ConnectionState;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'bloc/connection_bloc.dart';
import '../../core/constants.dart';
import '../../core/device_name_service.dart';

class ReceiverConnectScreen extends StatefulWidget {
  const ReceiverConnectScreen({super.key});

  @override
  State<ReceiverConnectScreen> createState() => _ReceiverConnectScreenState();
}

class _ReceiverConnectScreenState extends State<ReceiverConnectScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _radarController;
  String _deviceName = 'CUE-Receiver';

  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _loadNameThenDiscover();
  }

  /// Load persisted name first, then start discovery so the name is correct.
  Future<void> _loadNameThenDiscover() async {
    final name = await DeviceNameService.receiverName();
    if (mounted) setState(() => _deviceName = name);
    await _requestPermissionsAndDiscover();
  }

  Future<void> _requestPermissionsAndDiscover() async {
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
      context.read<ConnectionBloc>().add(StartDiscovery(_deviceName));
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
            hintText: 'e.g. Stage Monitor',
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
              borderSide: const BorderSide(color: Color(0xFF00E676)),
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
                backgroundColor: const Color(0xFF00E676)),
            child: const Text('Save',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (newName != null) {
      final trimmed =
          newName.trim().isEmpty ? 'CUE-Receiver' : newName.trim();
      await DeviceNameService.saveReceiverName(trimmed);
      if (mounted) {
        setState(() => _deviceName = trimmed);
        // Restart discovery with the updated name.
        context.read<ConnectionBloc>().add(StartDiscovery(trimmed));
      }
    }
  }

  @override
  void dispose() {
    _radarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConnectionBloc, ConnectionState>(
      listener: (context, state) {
        if (state is Connected) {
          final router = GoRouter.of(context);
          Future.delayed(const Duration(milliseconds: 800), () {
            if (mounted) router.go('/receiver');
          });
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
            'RECEIVER',
            style: TextStyle(color: Colors.white, letterSpacing: 2),
          ),
        ),
        body: BlocBuilder<ConnectionBloc, ConnectionState>(
          builder: (context, state) {
            if (state is Connected) return _buildConnected(state.remoteName);
            if (state is AwaitingAccept) return _buildAwaitingAccept();
            if (state is DiscoveredEndpoints && state.endpoints.isNotEmpty) {
              return _buildEndpointList(context, state.endpoints);
            }
            if (state is ConnectionError) {
              return _buildError(context, state.message);
            }
            return _buildScanning();
          },
        ),
      ),
    );
  }

  Widget _buildScanning() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RotationTransition(
            turns: _radarController,
            child: const Icon(
              Icons.radar,
              size: 80,
              color: Color(0xFF00E676),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Scanning for sender...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Make sure the Sender app is open and advertising',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.45),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 24),
          // Tappable device name badge — tap to rename.
          GestureDetector(
            onTap: _editDeviceName,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(20),
                border:
                    Border.all(color: Colors.white.withValues(alpha: 0.12)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.monitor,
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
    );
  }

  Widget _buildEndpointList(
    BuildContext context,
    List<({String id, String name})> endpoints,
  ) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Text(
            'Found ${endpoints.length} sender${endpoints.length > 1 ? 's' : ''}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.55),
              fontSize: 13,
              letterSpacing: 1,
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: endpoints.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final ep = endpoints[i];
              return Material(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => context
                      .read<ConnectionBloc>()
                      .add(RequestConnectionToSender(ep.id, _deviceName)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 18),
                    child: Row(
                      children: [
                        const Icon(Icons.broadcast_on_personal,
                            color: Color(0xFF4A9EFF)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            ep.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white.withValues(alpha: 0.3),
                          size: 14,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAwaitingAccept() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFF4A9EFF)),
          SizedBox(height: 28),
          Text(
            'Waiting for sender\nto accept...',
            textAlign: TextAlign.center,
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
                  .add(StartDiscovery(_deviceName)),
              child: const Text('RETRY'),
            ),
          ],
        ),
      ),
    );
  }
}
