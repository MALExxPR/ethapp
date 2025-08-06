import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter/foundation.dart';

class BingXWebSocketService {
  static final BingXWebSocketService _instance = BingXWebSocketService._internal();
  factory BingXWebSocketService() => _instance;
  BingXWebSocketService._internal();

  WebSocketChannel? _channel;
  StreamController<Map<String, dynamic>>? _priceStreamController;
  StreamController<Map<String, dynamic>>? _tickerStreamController;
  StreamController<Map<String, dynamic>>? _klineStreamController;
  
  bool _isConnected = false;
  bool _isConnecting = false;
  Timer? _reconnectTimer;
  Timer? _mockDataTimer;
  
  // Mock data for demo purposes
  double _currentPrice = 3450.25;
  double _basePrice = 3450.25;
  final Random _random = Random();

  Stream<Map<String, dynamic>> get priceStream {
    _priceStreamController ??= StreamController<Map<String, dynamic>>.broadcast();
    return _priceStreamController!.stream;
  }

  Stream<Map<String, dynamic>> get tickerStream {
    _tickerStreamController ??= StreamController<Map<String, dynamic>>.broadcast();
    return _tickerStreamController!.stream;
  }

  Stream<Map<String, dynamic>> get klineStream {
    _klineStreamController ??= StreamController<Map<String, dynamic>>.broadcast();
    return _klineStreamController!.stream;
  }

  bool get isConnected => _isConnected;

  Future<void> connect() async {
    if (_isConnected || _isConnecting) return;

    try {
      _isConnecting = true;
      
      // For demo purposes, simulate connection with mock data
      // In production, this would connect to actual BingX WebSocket
      await _connectMockWebSocket();
      
    } catch (e) {
      if (kDebugMode) {
        print('WebSocket connection error: $e');
      }
      _isConnected = false;
      _scheduleReconnect();
    } finally {
      _isConnecting = false;
    }
  }

  Future<void> _connectMockWebSocket() async {
    // Simulate connection delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    _isConnected = true;
    _startMockDataStream();
    
    if (kDebugMode) {
      print('Mock WebSocket connected');
    }
  }

  void _startMockDataStream() {
    _mockDataTimer?.cancel();
    _mockDataTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _generateMockData();
    });
  }

  void _generateMockData() {
    if (!_isConnected) return;

    // Generate realistic price movement
    double priceChange = (_random.nextDouble() - 0.5) * 10; // ±5 price movement
    _currentPrice = _basePrice + priceChange;
    
    // Ensure price doesn't go negative
    if (_currentPrice < 100) _currentPrice = 100;

    double changePercent = ((priceChange / _basePrice) * 100);
    double volume = 50000000 + (_random.nextDouble() * 20000000); // 50M-70M volume
    
    // Price update
    final priceData = {
      'symbol': 'ETHUSDT',
      'price': _currentPrice.toStringAsFixed(2),
      'priceChange': priceChange.toStringAsFixed(2),
      'priceChangePercent': changePercent.toStringAsFixed(2),
      'volume': volume.toStringAsFixed(0),
      'high': (_currentPrice + 25 + (_random.nextDouble() * 15)).toStringAsFixed(2),
      'low': (_currentPrice - 25 - (_random.nextDouble() * 15)).toStringAsFixed(2),
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    
    _priceStreamController?.add(priceData);
    _tickerStreamController?.add(priceData);

    // Generate kline data
    final klineData = {
      'symbol': 'ETHUSDT',
      'interval': '1m',
      'openPrice': (_currentPrice - 2 + (_random.nextDouble() * 4)).toStringAsFixed(2),
      'closePrice': _currentPrice.toStringAsFixed(2),
      'highPrice': (_currentPrice + (_random.nextDouble() * 5)).toStringAsFixed(2),
      'lowPrice': (_currentPrice - (_random.nextDouble() * 5)).toStringAsFixed(2),
      'volume': (10000 + (_random.nextDouble() * 5000)).toStringAsFixed(2),
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    
    _klineStreamController?.add(klineData);
  }

  void subscribeToTicker(String symbol) {
    if (!_isConnected) {
      connect();
      return;
    }
    
    // Mock subscription - in real implementation this would send subscription message
    if (kDebugMode) {
      print('Subscribed to ticker: $symbol');
    }
  }

  void subscribeToKline(String symbol, String interval) {
    if (!_isConnected) {
      connect();
      return;
    }
    
    // Mock subscription - in real implementation this would send subscription message
    if (kDebugMode) {
      print('Subscribed to kline: $symbol @ $interval');
    }
  }

  void unsubscribeFromTicker(String symbol) {
    // Mock unsubscription
    if (kDebugMode) {
      print('Unsubscribed from ticker: $symbol');
    }
  }

  void unsubscribeFromKline(String symbol, String interval) {
    // Mock unsubscription
    if (kDebugMode) {
      print('Unsubscribed from kline: $symbol @ $interval');
    }
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      if (!_isConnected) {
        connect();
      }
    });
  }

  void disconnect() {
    _isConnected = false;
    _mockDataTimer?.cancel();
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _channel = null;
    
    if (kDebugMode) {
      print('WebSocket disconnected');
    }
  }

  void dispose() {
    disconnect();
    _priceStreamController?.close();
    _tickerStreamController?.close();
    _klineStreamController?.close();
    _priceStreamController = null;
    _tickerStreamController = null;
    _klineStreamController = null;
  }

  // Utility methods for testing
  void setMockPrice(double price) {
    _currentPrice = price;
    _basePrice = price;
  }

  void triggerPriceSpike(double multiplier) {
    _currentPrice = _basePrice * multiplier;
  }

  void resetToBasePrice() {
    _currentPrice = _basePrice;
  }
}