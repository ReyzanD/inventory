import 'dart:convert';
import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/inventory_item.dart';
import '../models/product.dart';

class WebSocketService {
  static WebSocketService? _instance;
  static WebSocketService get instance => _instance ??= WebSocketService._();
  WebSocketService._();

  WebSocketChannel? _channel;
  bool _isConnected = false;
  Timer? _reconnectTimer;

  final List<Function(Map<String, dynamic>)> _inventoryUpdateCallbacks = [];
  final List<Function(Map<String, dynamic>)> _productUpdateCallbacks = [];
  final List<Function(Map<String, dynamic>)> _notificationCallbacks = [];

  bool get isConnected => _isConnected;

  Future<void> connect(String url) async {
    try {
      _channel?.sink.close();
      _channel = WebSocketChannel.connect(Uri.parse(url));
      
      _channel?.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDone,
      );
      
      _isConnected = true;
      
      // Cancel any reconnect attempts since we're now connected
      _reconnectTimer?.cancel();
    } catch (e) {
      _isConnected = false;
      _scheduleReconnect();
    }
  }

  void _onMessage(dynamic message) {
    if (message is String) {
      try {
        final data = jsonDecode(message) as Map<String, dynamic>;
        final eventType = data['event_type'];
        
        switch (eventType) {
          case 'inventory_update':
            _inventoryUpdateCallbacks.forEach((callback) => callback(data));
            break;
          case 'product_update':
            _productUpdateCallbacks.forEach((callback) => callback(data));
            break;
          case 'notification':
            _notificationCallbacks.forEach((callback) => callback(data));
            break;
          default:
            // Handle other events
            break;
        }
      } catch (e) {
        // Handle JSON parsing errors
      }
    }
  }

  void _onError(Object error) {
    _isConnected = false;
    _scheduleReconnect();
  }

  void _onDone() {
    _isConnected = false;
    _channel = null;
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    _reconnectTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (!_isConnected) {
        connect('ws://localhost:8080/ws'); // Default URL, should be configurable
      }
    });
  }

  void addInventoryUpdateListener(Function(Map<String, dynamic>) callback) {
    _inventoryUpdateCallbacks.add(callback);
  }

  void removeInventoryUpdateListener(Function(Map<String, dynamic>) callback) {
    _inventoryUpdateCallbacks.remove(callback);
  }

  void addProductUpdateListener(Function(Map<String, dynamic>) callback) {
    _productUpdateCallbacks.add(callback);
  }

  void removeProductUpdateListener(Function(Map<String, dynamic>) callback) {
    _productUpdateCallbacks.remove(callback);
  }

  void addNotificationListener(Function(Map<String, dynamic>) callback) {
    _notificationCallbacks.add(callback);
  }

  void removeNotificationListener(Function(Map<String, dynamic>) callback) {
    _notificationCallbacks.remove(callback);
  }

  void sendInventoryUpdate(InventoryItem item) {
    if (_isConnected) {
      final data = {
        'event_type': 'inventory_update',
        'item': item.toMap(),
      };
      _channel?.sink.add(jsonEncode(data));
    }
  }

  void sendProductUpdate(Product product) {
    if (_isConnected) {
      final data = {
        'event_type': 'product_update',
        'product': product.toMap(),
      };
      _channel?.sink.add(jsonEncode(data));
    }
  }

  void sendNotification(String type, String message) {
    if (_isConnected) {
      final data = {
        'event_type': 'notification',
        'type': type,
        'message': message,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      _channel?.sink.add(jsonEncode(data));
    }
  }

  void disconnect() {
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _isConnected = false;
  }
}