import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';

class SensorService extends ChangeNotifier {
  static final SensorService _instance = SensorService._internal();
  factory SensorService() => _instance;
  SensorService._internal();

  Timer? _noiseTimer;
  Timer? _motionTimer;

  // Tiếng ồn
  double _currentDecibels = 42.0;
  double _peakDecibels = 48.0;
  bool _isMonitoringNoise = false;
  final List<double> _noiseHistory = [40, 42, 45, 41, 43, 39, 44, 46, 42, 43];

  double get currentDecibels => _currentDecibels;
  double get peakDecibels => _peakDecibels;
  bool get isMonitoringNoise => _isMonitoringNoise;
  List<double> get noiseHistory => List.unmodifiable(_noiseHistory);

  // Chuyển động & Gia tốc (G-Force)
  double _accelX = 0.05;
  double _accelY = 0.12;
  double _accelZ = 9.81; // 1G trọng lực
  double _totalGForce = 1.0;
  bool _isFallDetected = false;
  bool _isMonitoringMotion = false;

  double get accelX => _accelX;
  double get accelY => _accelY;
  double get accelZ => _accelZ;
  double get totalGForce => _totalGForce;
  bool get isFallDetected => _isFallDetected;
  bool get isMonitoringMotion => _isMonitoringMotion;

  // Callback cảnh báo
  Function(double db)? onHighNoiseAlert;
  Function()? onFallAlert;

  // 1. KHỞI ĐỘNG ĐO TIẾNG ỒN THỜI GIAN THỰC
  void startNoiseMonitoring() {
    if (_isMonitoringNoise) return;
    _isMonitoringNoise = true;
    _noiseTimer = Timer.periodic(const Duration(milliseconds: 600), (timer) {
      final random = Random();
      // Giả lập mức decibel môi trường dao động chân thực quanh 40-55dB
      final variation = (random.nextDouble() * 12.0) - 6.0;
      _currentDecibels = (_currentDecibels + variation).clamp(32.0, 95.0);

      if (_currentDecibels > _peakDecibels) {
        _peakDecibels = _currentDecibels;
      }

      _noiseHistory.add(_currentDecibels);
      if (_noiseHistory.length > 20) {
        _noiseHistory.removeAt(0);
      }

      // Kiểm tra cảnh báo tiếng ồn lớn bất thường
      if (_currentDecibels >= 80.0) {
        onHighNoiseAlert?.call(_currentDecibels);
      }

      notifyListeners();
    });
    notifyListeners();
  }

  void stopNoiseMonitoring() {
    _noiseTimer?.cancel();
    _noiseTimer = null;
    _isMonitoringNoise = false;
    notifyListeners();
  }

  // Kích hoạt tiếng ồn bất thường để biểu diễn (Scream / Loud noise test)
  void triggerLoudNoiseSimulation() {
    _currentDecibels = 86.5;
    _peakDecibels = 89.0;
    _noiseHistory.add(_currentDecibels);
    onHighNoiseAlert?.call(_currentDecibels);
    notifyListeners();
  }

  // 2. KHỞI ĐỘNG CẢM BIẾN CHUYỂN ĐỘNG / GIA TỐC
  void startMotionMonitoring() {
    if (_isMonitoringMotion) return;
    _isMonitoringMotion = true;
    _motionTimer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
      final random = Random();
      _accelX = (random.nextDouble() * 0.4) - 0.2;
      _accelY = (random.nextDouble() * 0.4) - 0.2;
      _accelZ = 9.8 + ((random.nextDouble() * 0.3) - 0.15);

      final mag = sqrt(_accelX * _accelX + _accelY * _accelY + _accelZ * _accelZ);
      _totalGForce = (mag / 9.81);

      notifyListeners();
    });
    notifyListeners();
  }

  void stopMotionMonitoring() {
    _motionTimer?.cancel();
    _motionTimer = null;
    _isMonitoringMotion = false;
    notifyListeners();
  }

  // Kích hoạt mô phỏng cú rơi mạnh / va chạm
  void triggerFallImpactSimulation() {
    _isFallDetected = true;
    _accelX = 4.2;
    _accelY = 5.8;
    _accelZ = 28.5;
    _totalGForce = 3.8; // Cú sốc 3.8G
    onFallAlert?.call();
    notifyListeners();

    // Tự động hồi phục sau 5 giây
    Future.delayed(const Duration(seconds: 5), () {
      _isFallDetected = false;
      notifyListeners();
    });
  }

  void dismissFallAlert() {
    _isFallDetected = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _noiseTimer?.cancel();
    _motionTimer?.cancel();
    super.dispose();
  }
}
