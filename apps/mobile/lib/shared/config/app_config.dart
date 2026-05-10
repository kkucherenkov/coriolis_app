import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

class AppConfig {
  const AppConfig({
    required this.apiBaseUrl,
    required this.authBaseUrl,
    required this.realtimeWsUrl,
  });

  factory AppConfig.fromEnv() {
    const apiOverride = String.fromEnvironment('API_BASE_URL');
    const authOverride = String.fromEnvironment('AUTH_BASE_URL');
    const realtimeOverride = String.fromEnvironment('REALTIME_WS_URL');

    final host = _defaultHost();
    return AppConfig(
      apiBaseUrl: apiOverride.isNotEmpty ? apiOverride : 'http://$host:3010/api/v1',
      authBaseUrl: authOverride.isNotEmpty ? authOverride : 'http://$host:3010',
      // Centrifugo websocket — mirrors the docker-compose container
      // at port 8000. The session-detail page subscribes to
      // `session.{id}` here for live DP / roll-pushed updates
      // (Phase 4 Feature 7.4). Production overrides via
      // `--dart-define=REALTIME_WS_URL=wss://realtime.example.com/...`.
      realtimeWsUrl: realtimeOverride.isNotEmpty
          ? realtimeOverride
          : 'ws://$host:8000/connection/websocket',
    );
  }

  final String apiBaseUrl;
  final String authBaseUrl;
  final String realtimeWsUrl;

  static String _defaultHost() {
    if (kIsWeb) return 'localhost';
    if (Platform.isAndroid) return '10.0.2.2';
    return 'localhost';
  }
}
