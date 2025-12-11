import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import '../services/logging_service.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._privateConstructor();
  ConnectivityService._privateConstructor();

  // Singleton accessor
  factory ConnectivityService() {
    return _instance;
  }

  Connectivity? _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isPluginAvailable = false;

  // Stream to broadcast connectivity status
  StreamController<bool> _connectionStatusController = StreamController.broadcast();
  Stream<bool> get connectionStatus => _connectionStatusController.stream;

  bool _hasConnection = true; // Assume online by default

  // Check initial connectivity status
  Future<void> initialize() async {
    try {
      // Try to initialize connectivity plugin
      _connectivity = Connectivity();
      
      // Test if plugin is available by attempting a check
      try {
        await _connectivity!.checkConnectivity();
        _isPluginAvailable = true;
        _hasConnection = await _checkConnectivity();
        _connectionStatusController.add(_hasConnection);

        // Start listening for connectivity changes
        _connectivitySubscription = _connectivity!.onConnectivityChanged.listen(
          _updateConnectionStatus,
          onError: (error) {
            LoggingService.warning('Connectivity stream error: $error');
            // Assume online if stream fails
            _hasConnection = true;
            _connectionStatusController.add(_hasConnection);
          },
        );
      } on MissingPluginException catch (e) {
        // Plugin not available on this platform
        _isPluginAvailable = false;
        LoggingService.warning('Connectivity plugin not available on this platform: $e');
        // Default to online mode
        _hasConnection = true;
        _connectionStatusController.add(_hasConnection);
      } on PlatformException catch (e) {
        // Platform-specific error
        _isPluginAvailable = false;
        LoggingService.warning('Connectivity platform error: $e');
        // Default to online mode
        _hasConnection = true;
        _connectionStatusController.add(_hasConnection);
      }
    } catch (e) {
      // Any other error
      _isPluginAvailable = false;
      LoggingService.warning('Failed to initialize connectivity service: $e');
      // Default to online mode
      _hasConnection = true;
      _connectionStatusController.add(_hasConnection);
    }
  }

  // Check current connectivity status
  Future<bool> get hasConnection async {
    if (!_isPluginAvailable) {
      return true; // Default to online if plugin not available
    }
    return await _checkConnectivity();
  }

  // Internal method to check connectivity
  Future<bool> _checkConnectivity() async {
    if (!_isPluginAvailable || _connectivity == null) {
      return true; // Default to online if plugin not available
    }
    
    try {
      final result = await _connectivity!.checkConnectivity();
      return result.isNotEmpty && !result.contains(ConnectivityResult.none);
    } on MissingPluginException {
      _isPluginAvailable = false;
      LoggingService.warning('Connectivity plugin became unavailable');
      return true; // Default to online
    } on PlatformException catch (e) {
      LoggingService.warning('Connectivity check platform error: $e');
      return true; // Default to online
    } catch (e) {
      LoggingService.warning('Connectivity check error: $e');
      return true; // Default to online
    }
  }

  // Update connection status based on connectivity changes
  void _updateConnectionStatus(List<ConnectivityResult> results) {
    if (!_isPluginAvailable) {
      return; // Don't update if plugin not available
    }
    
    try {
      // Check if any connection type is available (WiFi, cellular, etc.)
      bool hasConnection = results.isNotEmpty && (
        results.contains(ConnectivityResult.wifi) || 
        results.contains(ConnectivityResult.mobile) || 
        results.contains(ConnectivityResult.ethernet) ||
        results.contains(ConnectivityResult.vpn) ||
        results.contains(ConnectivityResult.bluetooth) ||
        results.contains(ConnectivityResult.other)
      );
      
      // Specifically check if no connection is available
      if (results.contains(ConnectivityResult.none)) {
        hasConnection = false;
      }

      if (_hasConnection != hasConnection) {
        _hasConnection = hasConnection;
        _connectionStatusController.add(hasConnection);
      }
    } catch (e) {
      LoggingService.warning('Error updating connection status: $e');
    }
  }

  // Get current connection status
  bool get currentStatus => _hasConnection;

  // Cleanup resources
  void dispose() {
    _connectivitySubscription?.cancel();
    _connectionStatusController.close();
  }
}