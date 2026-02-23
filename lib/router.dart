import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'features/role_select/role_select_screen.dart';
import 'features/connection/sender_connect_screen.dart';
import 'features/connection/receiver_connect_screen.dart';
import 'features/connection/bloc/connection_bloc.dart';
import 'features/sender/sender_screen.dart';
import 'features/receiver/receiver_screen.dart';

/// A single shared ConnectionBloc that lives for the lifetime of the app,
/// allowing both connect screens and the active screens to share connection
/// state without prop-drilling.
final connectionBloc = ConnectionBloc();

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const RoleSelectScreen(),
    ),
    GoRoute(
      path: '/sender/connect',
      builder: (context, state) => BlocProvider.value(
        value: connectionBloc,
        child: const SenderConnectScreen(),
      ),
    ),
    GoRoute(
      path: '/sender',
      builder: (context, state) => BlocProvider.value(
        value: connectionBloc,
        child: const SenderScreen(),
      ),
    ),
    GoRoute(
      path: '/receiver/connect',
      builder: (context, state) => BlocProvider.value(
        value: connectionBloc,
        child: const ReceiverConnectScreen(),
      ),
    ),
    GoRoute(
      path: '/receiver',
      builder: (context, state) => BlocProvider.value(
        value: connectionBloc,
        child: const ReceiverScreen(),
      ),
    ),
  ],
);
