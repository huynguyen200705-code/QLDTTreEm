import 'dart:async';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/child_device_model.dart';
import '../models/app_rule_model.dart';
import '../models/safe_zone_model.dart';
import '../models/schedule_model.dart';
import '../models/activity_log_model.dart';
import '../models/chore_task_model.dart';
import '../models/support_ticket_model.dart';
import '../services/database_service.dart';
import '../services/auth_service.dart';
import '../services/sensor_service.dart';
import '../services/ai_guard_service.dart';

class AppStateProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  final AuthService _auth = AuthService();
  final SensorService _sensor = SensorService();
  final AiGuardService _aiGuard = AiGuardService();

  AuthService get auth => _auth;
  SensorService get sensor => _sensor;
  AiGuardService get aiGuard => _aiGuard;

  // Data lists
  List<ChildDeviceModel> _children = [];
  List<AppRuleModel> _appRules = [];
  List<SafeZoneModel> _safeZones = [];
  List<ScheduleModel> _schedules = [];
  List<ActivityLogModel> _logs = [];
  List<ChoreTaskModel> _chores = [];
  List<SupportTicketModel> _tickets = [];
  List<UserModel> _allUsers = [];

  ChildDeviceModel? _selectedChild;
  bool _isLoading = true;

  // Realtime simulation
  Timer? _gpsMovementTimer;
  bool _isSimulatingMovement = false;
  int _simulationStep = 0;

  // Getter
  List<ChildDeviceModel> get children => List.unmodifiable(_children);
  List<AppRuleModel> get appRules => List.unmodifiable(_appRules);
  List<SafeZoneModel> get safeZones => List.unmodifiable(_safeZones);
  List<ScheduleModel> get schedules => List.unmodifiable(_schedules);
  List<ActivityLogModel> get logs => List.unmodifiable(_logs);
  List<ChoreTaskModel> get chores => List.unmodifiable(_chores);
  List<SupportTicketModel> get tickets => List.unmodifiable(_tickets);
  List<UserModel> get allUsers => List.unmodifiable(_allUsers);
  ChildDeviceModel? get selectedChild => _selectedChild;
  bool get isLoading => _isLoading;
  bool get isSimulatingMovement => _isSimulatingMovement;

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    await _auth.init();
    await reloadData();

    // Lắng nghe sự kiện cảm biến tiếng ồn từ SensorService
    _sensor.onHighNoiseAlert = (db) {
      if (_selectedChild != null) {
        addLog(
          ActivityLogModel(
            id: 'log_${DateTime.now().millisecondsSinceEpoch}',
            childId: _selectedChild!.id,
            childName: _selectedChild!.name,
            type: LogType.noiseAlert,
            message: 'Phát hiện tiếng ồn ${db.toStringAsFixed(1)}dB tại khu vực của bé!',
            timestamp: DateTime.now(),
          ),
        );
      }
    };

    // Lắng nghe sự kiện té ngã / va đập
    _sensor.onFallAlert = () {
      if (_selectedChild != null) {
        addLog(
          ActivityLogModel(
            id: 'log_${DateTime.now().millisecondsSinceEpoch}',
            childId: _selectedChild!.id,
            childName: _selectedChild!.name,
            type: LogType.fallDetected,
            message: 'Khẩn cấp! Điện thoại của bé vừa ghi nhận va chạm chấn động mạnh (>3.5G).',
            timestamp: DateTime.now(),
          ),
        );
      }
    };

    _isLoading = false;
    notifyListeners();
  }

  Future<void> reloadData() async {
    _children = await _db.getChildren();
    _appRules = await _db.getAppRules();
    _safeZones = await _db.getSafeZones();
    _schedules = await _db.getSchedules();
    _logs = await _db.getLogs();
    _chores = await _db.getChores();
    _tickets = await _db.getTickets();
    _allUsers = await _db.getUsers();

    if (_children.isNotEmpty) {
      if (_selectedChild == null || !_children.any((c) => c.id == _selectedChild!.id)) {
        _selectedChild = _children.first;
      } else {
        _selectedChild = _children.firstWhere((c) => c.id == _selectedChild!.id);
      }
    } else {
      _selectedChild = null;
    }

    notifyListeners();
  }

  void setSelectedChild(ChildDeviceModel child) {
    _selectedChild = child;
    notifyListeners();
  }

  // ===================== CRUD 1: CHILDREN & DEVICES =====================
  Future<void> addChild(ChildDeviceModel child) async {
    await _db.addChild(child);
    await reloadData();
  }

  Future<void> updateChild(ChildDeviceModel child) async {
    await _db.updateChild(child);
    await reloadData();
  }

  Future<void> deleteChild(String id) async {
    await _db.deleteChild(id);
    await reloadData();
  }

  Future<void> toggleLockChildDevice(ChildDeviceModel child) async {
    final updated = child.copyWith(isLocked: !child.isLocked);
    await updateChild(updated);

    await addLog(
      ActivityLogModel(
        id: 'log_${DateTime.now().millisecondsSinceEpoch}',
        childId: child.id,
        childName: child.name,
        type: LogType.screenLocked,
        message: updated.isLocked
            ? 'Phụ huynh đã khóa máy từ xa.'
            : 'Phụ huynh đã mở khóa màn hình cho bé.',
        timestamp: DateTime.now(),
      ),
    );
  }

  // ===================== CRUD 2: APP RULES =====================
  Future<void> addAppRule(AppRuleModel rule) async {
    await _db.addAppRule(rule);
    await reloadData();
  }

  Future<void> updateAppRule(AppRuleModel rule) async {
    await _db.updateAppRule(rule);
    await reloadData();
  }

  Future<void> deleteAppRule(String id) async {
    await _db.deleteAppRule(id);
    await reloadData();
  }

  Future<void> toggleAppBlock(AppRuleModel rule) async {
    final updated = rule.copyWith(isBlocked: !rule.isBlocked);
    await updateAppRule(updated);
  }

  // ===================== CRUD 3: SAFE ZONES =====================
  Future<void> addSafeZone(SafeZoneModel zone) async {
    await _db.addSafeZone(zone);
    await reloadData();
  }

  Future<void> updateSafeZone(SafeZoneModel zone) async {
    await _db.updateSafeZone(zone);
    await reloadData();
  }

  Future<void> deleteSafeZone(String id) async {
    await _db.deleteSafeZone(id);
    await reloadData();
  }

  // ===================== CRUD 4: SCHEDULES =====================
  Future<void> addSchedule(ScheduleModel schedule) async {
    await _db.addSchedule(schedule);
    await reloadData();
  }

  Future<void> updateSchedule(ScheduleModel schedule) async {
    await _db.updateSchedule(schedule);
    await reloadData();
  }

  Future<void> deleteSchedule(String id) async {
    await _db.deleteSchedule(id);
    await reloadData();
  }

  // ===================== CHORES & GAMIFIED SCREENTIME =====================
  Future<void> addChore(ChoreTaskModel chore) async {
    await _db.addChore(chore);
    await reloadData();
  }

  Future<void> updateChore(ChoreTaskModel chore) async {
    await _db.updateChore(chore);
    await reloadData();
  }

  Future<void> deleteChore(String id) async {
    await _db.deleteChore(id);
    await reloadData();
  }

  Future<void> completeChoreByKid(String choreId, String? note) async {
    final chore = _chores.firstWhere((c) => c.id == choreId);
    final updated = chore.copyWith(isCompletedByKid: true, proofNote: note);
    await updateChore(updated);
  }

  Future<void> approveChoreByParent(String choreId) async {
    final chore = _chores.firstWhere((c) => c.id == choreId);
    final updated = chore.copyWith(isApprovedByParent: true);
    await updateChore(updated);

    // Cộng thêm thời lượng sử dụng cho bé
    if (_selectedChild != null) {
      final newLimit = _selectedChild!.screenTimeLimitMinutes + chore.rewardMinutes;
      await updateChild(_selectedChild!.copyWith(screenTimeLimitMinutes: newLimit));
    }
  }

  // ===================== LOGS & SOS =====================
  Future<void> addLog(ActivityLogModel log) async {
    await _db.addLog(log);
    await reloadData();
  }

  Future<void> triggerKidSos(String childId) async {
    final child = _children.firstWhere((c) => c.id == childId);
    final updated = child.copyWith(isSosActive: true);
    await updateChild(updated);

    await addLog(
      ActivityLogModel(
        id: 'log_${DateTime.now().millisecondsSinceEpoch}',
        childId: child.id,
        childName: child.name,
        type: LogType.sosAlert,
        message: '🚨 KHẨN CẤP: ${child.name} đã nhấn nút SOS cầu cứu từ vị trí: ${child.currentAddress}',
        latitude: child.latitude,
        longitude: child.longitude,
        timestamp: DateTime.now(),
      ),
    );
  }

  Future<void> resolveKidSos(String childId) async {
    final child = _children.firstWhere((c) => c.id == childId);
    final updated = child.copyWith(isSosActive: false);
    await updateChild(updated);
  }

  // ===================== CRUD USERS (Admin) =====================
  Future<void> addUser(UserModel user) async {
    await _db.addUser(user);
    await reloadData();
  }

  Future<void> updateUser(UserModel user) async {
    await _db.updateUser(user);
    await reloadData();
  }

  Future<void> deleteUser(String id) async {
    await _db.deleteUser(id);
    await reloadData();
  }

  Future<void> toggleUserActive(UserModel user) async {
    final updated = user.copyWith(isActive: !user.isActive);
    await updateUser(updated);
  }

  // ===================== TICKETS (Staff) =====================
  Future<void> addTicket(SupportTicketModel ticket) async {
    await _db.addTicket(ticket);
    await reloadData();
  }

  Future<void> updateTicket(SupportTicketModel ticket) async {
    await _db.updateTicket(ticket);
    await reloadData();
  }

  Future<void> deleteTicket(String id) async {
    await _db.deleteTicket(id);
    await reloadData();
  }

  // ===================== GPS SIMULATION =====================
  final List<Map<String, dynamic>> _simulatedRoute = [
    {
      'lat': 10.7769,
      'lng': 106.7009,
      'addr': 'Trường Tiểu học Nguyễn Huệ, Quận 1',
    },
    {
      'lat': 10.7750,
      'lng': 106.6995,
      'addr': 'Ngã tư Đồng Khởi - Lê Lợi, Quận 1',
    },
    {
      'lat': 10.7735,
      'lng': 106.6985,
      'addr': 'Trước Nhà hát Thành phố, Quận 1',
    },
    {
      'lat': 10.7725,
      'lng': 106.6980,
      'addr': 'Vincom Đồng Khởi, Phường Bến Nghé, Quận 1',
    },
    {
      'lat': 10.7710,
      'lng': 106.6965,
      'addr': 'Đường Nguyễn Du, Quận 1',
    },
    {
      'lat': 10.7780,
      'lng': 106.6950,
      'addr': 'Công viên Tao Đàn (Ngoài vùng an toàn)',
    },
  ];

  void toggleGpsMovementSimulation() {
    if (_isSimulatingMovement) {
      _gpsMovementTimer?.cancel();
      _isSimulatingMovement = false;
    } else {
      _isSimulatingMovement = true;
      _gpsMovementTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
        if (_selectedChild == null) return;
        _simulationStep = (_simulationStep + 1) % _simulatedRoute.length;
        final point = _simulatedRoute[_simulationStep];

        final updated = _selectedChild!.copyWith(
          latitude: point['lat'],
          longitude: point['lng'],
          currentAddress: point['addr'],
          lastSeen: DateTime.now(),
        );

        updateChild(updated);

        // Nếu bước thứ 5 (Công viên Tao Đàn - Ngoài vùng an toàn), kích hoạt cảnh báo Geofence!
        if (_simulationStep == 5) {
          addLog(
            ActivityLogModel(
              id: 'log_${DateTime.now().millisecondsSinceEpoch}',
              childId: updated.id,
              childName: updated.name,
              type: LogType.geofenceExit,
              message: '${updated.name} vừa rời khỏi vùng an toàn Trường học và Nhà riêng!',
              latitude: updated.latitude,
              longitude: updated.longitude,
              timestamp: DateTime.now(),
            ),
          );
        }
      });
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _gpsMovementTimer?.cancel();
    super.dispose();
  }
}
