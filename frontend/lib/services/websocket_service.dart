import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/foundation.dart';
import 'dart:async';
import './token_storage_service.dart';

class WebSocketService {
  static WebSocketService? _instance;
  IO.Socket? _socket;

  final String _baseUrl = 'http://localhost:3001';
  final _connectionStatusController = ValueNotifier<bool>(false);

  final Map<String, Function(dynamic)> _pendingListeners = {};

  static WebSocketService get instance {
    _instance ??= WebSocketService._internal();
    return _instance!;
  }

  WebSocketService._internal();

  ValueNotifier<bool> get connectionStatus => _connectionStatusController;

  Future<void> connect() async {
    if (_socket != null && _socket!.connected) return;

    try {
      final tokenStorage = TokenStorageImpl();
      final accessToken = await tokenStorage.getAccessToken();

      if (accessToken == null) {
        throw Exception('No access token found');
      }

      final completer = Completer<void>();

      _socket = IO.io(_baseUrl, <String, dynamic>{
        'transports': ['websocket', 'polling'],
        'autoConnect': false,
        'auth': {'token': accessToken},
      });

      _socket!.onConnect((_) {
        _connectionStatusController.value = true;
        _applyPendingListeners();
        if (!completer.isCompleted) {
          completer.complete();
        }
      });

      _socket!.onDisconnect((_) {
        _connectionStatusController.value = false;
      });

      _socket!.onConnectError((error) {
        _connectionStatusController.value = false;
        if (!completer.isCompleted) {
          completer.completeError(error);
        }
      });

      _socket!.onError((error) {
        if (!completer.isCompleted) {
          completer.completeError(error);
        }
      });

      _socket!.connect();

      await completer.future;
    } catch (e) {
      rethrow;
    }
  }

  void _applyPendingListeners() {
    if (_socket == null) return;

    _pendingListeners.forEach((event, callback) {
      _socket!.on(event, callback);
    });

    _pendingListeners.clear();
  }

  void disconnect() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket = null;
      _connectionStatusController.value = false;
    }
  }

  void emit(String event, dynamic data) {
    if (_socket == null || !_socket!.connected) {
      return;
    }
    _socket!.emit(event, data);
  }

  void on(String event, Function(dynamic) callback) {
    if (_socket == null || !_socket!.connected) {
      _pendingListeners[event] = callback;
      return;
    }
    _socket!.on(event, callback);
  }

  void off(String event) {
    if (_socket == null) {
      _pendingListeners.remove(event);
      return;
    }
    _socket!.off(event);
  }

  bool get isConnected => _socket != null && _socket!.connected;

  void dispose() {
    disconnect();
    _connectionStatusController.dispose();
    _pendingListeners.clear();
  }
}
