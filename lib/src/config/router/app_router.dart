import 'package:go_router/go_router.dart';

import '../../screens/map/map_page.dart';

final appRouter = GoRouter(
  initialLocation: '/homeMap',
  routes: [
    ///* Auth Routes
    // GoRoute(
    //   path: '/home',
    //   builder: (context, state) => MyMap(),
    // ),
    GoRoute(
      path: '/homeMap',
      builder: (context, state) => const MapPage(),
    ),
  ],
);
