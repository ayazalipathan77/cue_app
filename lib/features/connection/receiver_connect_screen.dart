import 'package:flutter/material.dart' hide ConnectionState;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'bloc/connection_bloc.dart';
import '../../core/constants.dart';

class ReceiverConnectScreen extends StatefulWidget {
  const ReceiverConnectScreen({super.key});

  @override
  State<ReceiverConnectScreen> createState() => _ReceiverConnectScreenState();
}

class _ReceiverConnectScreenState extends State<ReceiverConnectScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _radarController;
  final String _deviceName = 'CUE-Receiver';

  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _requestPermissionsAndDiscover();
  }

  Future<void> _requestPermissionsAndDiscover() async {
    await [
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.location,
      Permission.nearbyWifiDevices,
    ].request();

    if (mounted) {
      context.read<ConnectionBloc>().add(StartDiscovery(_deviceName));
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
          Future.delayed(const Duration(milliseconds: 800), () {
            if (mounted) context.go('/receiver');
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
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    child: Row(
                      children: [
                        const Icon(Icons.broadcast_on_personal, color: Color(0xFF4A9EFF)),
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
}
