import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/nearby_service.dart';

class ConnectionStatusBar extends StatelessWidget {
  final String remoteName;
  final String endpointId;

  const ConnectionStatusBar({
    super.key,
    required this.remoteName,
    required this.endpointId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white.withValues(alpha: 0.04),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          // Green connected dot.
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: const Color(0xFF00E676),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00E676).withValues(alpha: 0.6),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              remoteName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
          TextButton.icon(
            onPressed: () async {
              await NearbyService.instance.stopAll();
              if (context.mounted) context.go('/');
            },
            icon: const Icon(Icons.link_off, size: 16, color: Colors.red),
            label: const Text(
              'Disconnect',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
