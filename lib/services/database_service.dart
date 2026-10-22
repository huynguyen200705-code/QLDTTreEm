import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/child_device_model.dart';
import '../models/app_rule_model.dart';
import '../models/safe_zone_model.dart';
import '../models/schedule_model.dart';
import '../models/activity_log_model.dart';
import '../models/chore_task_model.dart';
import '../models/support_ticket_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static const String _keyUsers = 'kidshield_users';
  static const String _keyChildren = 'kidshield_children';
  static const String _keyAppRules = 'kidshield_app_rules';
  static const String _keySafeZones = 'kidshield_safe_zones';
  static const String _keySchedules = 'kidshield_schedules';
  static const String _keyLogs = 'kidshield_logs';
  static const String _keyChores = 'kidshield_chores';
  static const String _keyTickets = 'kidshield_tickets';

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _seedInitialDataIfEmpty();
  }

  // ===================== SEED INITIAL DATA =====================
  Future<void> _seedInitialDataIfEmpty() async {
    if (_prefs == null) return;

    if (!_prefs!.containsKey(_keyUsers) || (_prefs!.getStringList(_keyUsers)?.isEmpty ?? true)) {
      // 1. Users: Admin, Staff, Parent, Kid
      final defaultUsers = [
        UserModel(
          id: 'admin_1',
          email: 'admin@kidshield.vn',
          fullName: 'Trần Văn Quản Trị',
          username: 'admin',
          phoneNumber: '0901234567',
          role: UserRole.admin,
          avatarUrl: '👨‍💼',
        ),
        UserModel(
          id: 'staff_1',
          email: 'staff@kidshield.vn',
          fullName: 'Lê Thị Thu Hằng (Support)',
          username: 'staff',
          phoneNumber: '0912345678',
          role: UserRole.staff,
          avatarUrl: '👩‍💻',
        ),
        UserModel(
          id: 'parent_1',
          email: 'parent@kidshield.vn',
          fullName: 'Nguyễn Văn Hùng',
          username: 'parenthung',
          phoneNumber: '0987654321',
          role: UserRole.parent,
          avatarUrl: '👨‍👧‍👦',
        ),
        UserModel(
          id: 'kid_user_1',
          email: 'bean@kidshield.vn',
          fullName: 'Bé Nguyễn Nhật An',
          username: 'kid_an',
          phoneNumber: '0987000111',
          role: UserRole.kid,
          avatarUrl: '👦',
          linkedChildId: 'child_1',
        ),
      ];
      await saveUsers(defaultUsers);

      // 2. Children & Devices
      final defaultChildren = [
        ChildDeviceModel(
          id: 'child_1',
          parentId: 'parent_1',
          name: 'Bé An',
          age: 10,
          gender: 'Nam',
          avatar: '👦',
          deviceName: 'Samsung Galaxy A53',
          batteryLevel: 86,
          isOnline: true,
          isLocked: false,
          latitude: 10.7769,
          longitude: 106.7009,
          currentAddress: 'Trường Tiểu học Nguyễn Huệ, Quận 1, TP.HCM',
          pairingCode: 'KID-889',
          screenTimeUsedMinutes: 48,
          screenTimeLimitMinutes: 120,
          currentNoiseDb: 42.5,
        ),
        ChildDeviceModel(
          id: 'child_2',
          parentId: 'parent_1',
          name: 'Bé Minh',
          age: 7,
          gender: 'Nam',
          avatar: '🧒',
          deviceName: 'iPad Gen 9 (Wifi)',
          batteryLevel: 64,
          isOnline: true,
          isLocked: false,
          latitude: 10.7725,
          longitude: 106.6980,
          currentAddress: 'Nhà riêng, Phường Bến Nghé, Quận 1, TP.HCM',
          pairingCode: 'KID-334',
          screenTimeUsedMinutes: 20,
          screenTimeLimitMinutes: 90,
          currentNoiseDb: 35.0,
        ),
      ];
      await saveChildren(defaultChildren);

      // 3. App Rules (CRUD 2)
      final defaultRules = [
        AppRuleModel(
          id: 'rule_1',
          childId: 'child_1',
          appName: 'TikTok',
          packageOrUrl: 'com.zhiliaoapp.musically',
          category: 'Mạng xã hội',
          iconEmoji: '🎵',
          isBlocked: false,
          dailyLimitMinutes: 30,
          usedMinutesToday: 25,
          isEnabled: true,
        ),
        AppRuleModel(
          id: 'rule_2',
          childId: 'child_1',
          appName: 'Roblox',
          packageOrUrl: 'com.roblox.client',
          category: 'Trò chơi',
          iconEmoji: '🎮',
          isBlocked: true,
          dailyLimitMinutes: 0,
          usedMinutesToday: 0,
          isEnabled: true,
        ),
        AppRuleModel(
          id: 'rule_3',
          childId: 'child_1',
          appName: 'YouTube Kids',
          packageOrUrl: 'com.google.android.apps.youtube.kids',
          category: 'Video & Phim',
          iconEmoji: '▶️',
          isBlocked: false,
          dailyLimitMinutes: 60,
          usedMinutesToday: 35,
          isEnabled: true,
        ),
        AppRuleModel(
          id: 'rule_4',
          childId: 'child_1',
          appName: 'Facebook / Messenger',
          packageOrUrl: 'com.facebook.katana',
          category: 'Mạng xã hội',
          iconEmoji: '💬',
          isBlocked: true,
          dailyLimitMinutes: 0,
          usedMinutesToday: 0,
          isEnabled: true,
        ),
        AppRuleModel(
          id: 'rule_5',
          childId: 'child_1',
          appName: 'Duolingo Học Ngoại Ngữ',
          packageOrUrl: 'com.duolingo',
          category: 'Học tập',
          iconEmoji: '🦉',
          isBlocked: false,
          dailyLimitMinutes: 180,
          usedMinutesToday: 20,
          isEnabled: true,
        ),
        // Global blacklist (do Admin thêm)
        AppRuleModel(
          id: 'rule_global_1',
          childId: 'GLOBAL',
          appName: 'Trang cá cược trực tuyến',
          packageOrUrl: 'https://casino-bet-online.com',
          category: 'Cờ bạc & Độc hại',
          iconEmoji: '🎰',
          isBlocked: true,
          dailyLimitMinutes: 0,
          usedMinutesToday: 0,
          isEnabled: true,
          isGlobalRule: true,
        ),
      ];
      await saveAppRules(defaultRules);

      // 4. Safe Zones (CRUD 3)
      final defaultZones = [
        SafeZoneModel(
          id: 'zone_1',
          childId: 'child_1',
          name: 'Trường Tiểu học Nguyễn Huệ',
          address: 'Số 12 Lê Thánh Tôn, Bến Nghé, Quận 1',
          latitude: 10.7769,
          longitude: 106.7009,
          radiusMeters: 250.0,
          alertOnExit: true,
          alertOnEnter: true,
          iconEmoji: '🏫',
        ),
        SafeZoneModel(
          id: 'zone_2',
          childId: 'child_1',
          name: 'Nhà riêng',
          address: 'Chung cư Vinhome Đồng Khởi, Quận 1',
          latitude: 10.7725,
          longitude: 106.6980,
          radiusMeters: 150.0,
          alertOnExit: true,
          alertOnEnter: true,
          iconEmoji: '🏡',
        ),
        SafeZoneModel(
          id: 'zone_3',
          childId: 'child_1',
          name: 'CLB Bơi Lội Rạch Miễu',
          address: '01 Hoa Phượng, Phường 2, Phú Nhuận',
          latitude: 10.7932,
          longitude: 106.6854,
          radiusMeters: 300.0,
          alertOnExit: true,
          alertOnEnter: false,
          iconEmoji: '🏊',
        ),
      ];
      await saveSafeZones(defaultZones);

      // 5. Schedules (CRUD 4)
      final defaultSchedules = [
        ScheduleModel(
          id: 'sched_1',
          childId: 'child_1',
          title: 'Giờ ngủ ban đêm',
          startTime: '22:00',
          endTime: '06:30',
          daysOfWeek: [1, 2, 3, 4, 5, 6, 7],
          isLockDevice: true,
          isEnabled: true,
          iconEmoji: '🌙',
        ),
        ScheduleModel(
          id: 'sched_2',
          childId: 'child_1',
          title: 'Giờ học trên trường',
          startTime: '07:30',
          endTime: '11:30',
          daysOfWeek: [1, 2, 3, 4, 5],
          isLockDevice: true,
          isEnabled: true,
          iconEmoji: '📚',
        ),
      ];
      await saveSchedules(defaultSchedules);

      // 6. Chores (Tính năng mới)
      final defaultChores = [
        ChoreTaskModel(
          id: 'chore_1',
          childId: 'child_1',
          title: 'Đọc 15 trang sách truyện thiếu nhi',
          description: 'Đọc sách truyện Khoa học hoặc Tiếng Anh',
          rewardMinutes: 20,
          isCompletedByKid: true,
          isApprovedByParent: false,
          iconEmoji: '📖',
          proofNote: 'Con đã đọc xong chương 3 sách Vũ Trụ Kỳ Thú ạ!',
        ),
        ChoreTaskModel(
          id: 'chore_2',
          childId: 'child_1',
          title: 'Dọn phòng & xếp góc học tập ngăn nắp',
          description: 'Gấp chăn mền và lau dọn bàn máy tính',
          rewardMinutes: 15,
          isCompletedByKid: false,
          isApprovedByParent: false,
          iconEmoji: '🧹',
        ),
        ChoreTaskModel(
          id: 'chore_3',
          childId: 'child_1',
          title: 'Hoàn thành bài tập toán về nhà',
          description: 'Làm xong bài tập 1 đến 5 trang 42',
          rewardMinutes: 30,
          isCompletedByKid: true,
          isApprovedByParent: true,
          iconEmoji: '📐',
        ),
      ];
      await saveChores(defaultChores);

      // 7. Activity Logs
      final defaultLogs = [
        ActivityLogModel(
          id: 'log_1',
          childId: 'child_1',
          childName: 'Bé An',
          type: LogType.geofenceEnter,
          message: 'Bé An đã vào vùng an toàn Trường Tiểu học Nguyễn Huệ lúc 07:15 sáng.',
          timestamp: DateTime.now().subtract(const Duration(hours: 3)),
          latitude: 10.7769,
          longitude: 106.7009,
        ),
        ActivityLogModel(
          id: 'log_2',
          childId: 'child_1',
          childName: 'Bé An',
          type: LogType.appBlocked,
          message: 'Bé An vừa cố gắng mở ứng dụng bị cấm Roblox.',
          timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
        ),
        ActivityLogModel(
          id: 'log_3',
          childId: 'child_1',
          childName: 'Bé An',
          type: LogType.noiseAlert,
          message: 'Phát hiện tiếng ồn 84dB (ồn ào bất thường) tại khu vực bé đang đứng.',
          timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
        ),
      ];
      await saveLogs(defaultLogs);

      // 8. Staff Support Tickets
      final defaultTickets = [
        SupportTicketModel(
          id: 'ticket_1',
          parentId: 'parent_1',
          parentName: 'Nguyễn Văn Hùng',
          title: 'Hướng dẫn ghép nối với máy tính bảng iPad mới',
          content: 'Tôi muốn kết nối thêm một máy tính bảng iPad của bé thứ 2 qua mã QR nhưng camera máy phụ quét bị chậm.',
          priority: 'Trung bình',
          status: TicketStatus.inProgress,
          staffName: 'Lê Thị Thu Hằng',
          staffResponse: 'Em đang hỗ trợ anh kiểm tra camera và cập nhật mã PIN ghép nối 6 chữ số trực tiếp ạ.',
        ),
        SupportTicketModel(
          id: 'ticket_2',
          parentId: 'parent_lan',
          parentName: 'Trần Thị Thu Lan',
          title: 'Báo cáo website giả mạo trò chơi điện tử',
          content: 'Bé nhà tôi xem được đường link lạ trên mạng xã hội, nhờ nhân viên kiểm duyệt đưa vào danh sách đen toàn cầu.',
          priority: 'Khẩn cấp',
          status: TicketStatus.pending,
        ),
      ];
      await saveTickets(defaultTickets);
    }
  }

  // ===================== CRUD USERS =====================
  Future<List<UserModel>> getUsers() async {
    final list = _prefs?.getStringList(_keyUsers) ?? [];
    return list.map((item) => UserModel.fromJson(item)).toList();
  }

  Future<void> saveUsers(List<UserModel> users) async {
    final list = users.map((u) => u.toJson()).toList();
    await _prefs?.setStringList(_keyUsers, list);
  }

  Future<void> addUser(UserModel user) async {
    final users = await getUsers();
    users.removeWhere((u) => u.id == user.id || u.email.toLowerCase() == user.email.toLowerCase());
    users.add(user);
    await saveUsers(users);
  }

  Future<void> updateUser(UserModel user) async {
    final users = await getUsers();
    final index = users.indexWhere((u) => u.id == user.id);
    if (index != -1) {
      users[index] = user;
      await saveUsers(users);
    }
  }

  Future<void> deleteUser(String id) async {
    final users = await getUsers();
    users.removeWhere((u) => u.id == id);
    await saveUsers(users);
  }

  // ===================== CRUD CHILDREN & DEVICES (CRUD 1) =====================
  Future<List<ChildDeviceModel>> getChildren({String? parentId}) async {
    final list = _prefs?.getStringList(_keyChildren) ?? [];
    final all = list.map((item) => ChildDeviceModel.fromJson(item)).toList();
    if (parentId != null) {
      return all.where((c) => c.parentId == parentId).toList();
    }
    return all;
  }

  Future<void> saveChildren(List<ChildDeviceModel> children) async {
    final list = children.map((c) => c.toJson()).toList();
    await _prefs?.setStringList(_keyChildren, list);
  }

  Future<void> addChild(ChildDeviceModel child) async {
    final list = await getChildren();
    list.removeWhere((c) => c.id == child.id);
    list.add(child);
    await saveChildren(list);
  }

  Future<void> updateChild(ChildDeviceModel child) async {
    final list = await getChildren();
    final index = list.indexWhere((c) => c.id == child.id);
    if (index != -1) {
      list[index] = child;
      await saveChildren(list);
    }
  }

  Future<void> deleteChild(String id) async {
    final list = await getChildren();
    list.removeWhere((c) => c.id == id);
    await saveChildren(list);
  }

  // ===================== CRUD APP RULES (CRUD 2) =====================
  Future<List<AppRuleModel>> getAppRules({String? childId}) async {
    final list = _prefs?.getStringList(_keyAppRules) ?? [];
    final all = list.map((item) => AppRuleModel.fromJson(item)).toList();
    if (childId != null) {
      return all.where((r) => r.childId == childId || r.isGlobalRule).toList();
    }
    return all;
  }

  Future<void> saveAppRules(List<AppRuleModel> rules) async {
    final list = rules.map((r) => r.toJson()).toList();
    await _prefs?.setStringList(_keyAppRules, list);
  }

  Future<void> addAppRule(AppRuleModel rule) async {
    final list = await getAppRules();
    list.removeWhere((r) => r.id == rule.id);
    list.add(rule);
    await saveAppRules(list);
  }

  Future<void> updateAppRule(AppRuleModel rule) async {
    final list = await getAppRules();
    final index = list.indexWhere((r) => r.id == rule.id);
    if (index != -1) {
      list[index] = rule;
      await saveAppRules(list);
    }
  }

  Future<void> deleteAppRule(String id) async {
    final list = await getAppRules();
    list.removeWhere((r) => r.id == id);
    await saveAppRules(list);
  }

  // ===================== CRUD SAFE ZONES (CRUD 3) =====================
  Future<List<SafeZoneModel>> getSafeZones({String? childId}) async {
    final list = _prefs?.getStringList(_keySafeZones) ?? [];
    final all = list.map((item) => SafeZoneModel.fromJson(item)).toList();
    if (childId != null) {
      return all.where((z) => z.childId == childId).toList();
    }
    return all;
  }

  Future<void> saveSafeZones(List<SafeZoneModel> zones) async {
    final list = zones.map((z) => z.toJson()).toList();
    await _prefs?.setStringList(_keySafeZones, list);
  }

  Future<void> addSafeZone(SafeZoneModel zone) async {
    final list = await getSafeZones();
    list.removeWhere((z) => z.id == zone.id);
    list.add(zone);
    await saveSafeZones(list);
  }

  Future<void> updateSafeZone(SafeZoneModel zone) async {
    final list = await getSafeZones();
    final index = list.indexWhere((z) => z.id == zone.id);
    if (index != -1) {
      list[index] = zone;
      await saveSafeZones(list);
    }
  }

  Future<void> deleteSafeZone(String id) async {
    final list = await getSafeZones();
    list.removeWhere((z) => z.id == id);
    await saveSafeZones(list);
  }

  // ===================== CRUD SCHEDULES (CRUD 4) =====================
  Future<List<ScheduleModel>> getSchedules({String? childId}) async {
    final list = _prefs?.getStringList(_keySchedules) ?? [];
    final all = list.map((item) => ScheduleModel.fromJson(item)).toList();
    if (childId != null) {
      return all.where((s) => s.childId == childId).toList();
    }
    return all;
  }

  Future<void> saveSchedules(List<ScheduleModel> schedules) async {
    final list = schedules.map((s) => s.toJson()).toList();
    await _prefs?.setStringList(_keySchedules, list);
  }

  Future<void> addSchedule(ScheduleModel schedule) async {
    final list = await getSchedules();
    list.removeWhere((s) => s.id == schedule.id);
    list.add(schedule);
    await saveSchedules(list);
  }

  Future<void> updateSchedule(ScheduleModel schedule) async {
    final list = await getSchedules();
    final index = list.indexWhere((s) => s.id == schedule.id);
    if (index != -1) {
      list[index] = schedule;
      await saveSchedules(list);
    }
  }

  Future<void> deleteSchedule(String id) async {
    final list = await getSchedules();
    list.removeWhere((s) => s.id == id);
    await saveSchedules(list);
  }

  // ===================== CRUD CHORES (Gamified Screen Time) =====================
  Future<List<ChoreTaskModel>> getChores({String? childId}) async {
    final list = _prefs?.getStringList(_keyChores) ?? [];
    final all = list.map((item) => ChoreTaskModel.fromJson(item)).toList();
    if (childId != null) {
      return all.where((c) => c.childId == childId).toList();
    }
    return all;
  }

  Future<void> saveChores(List<ChoreTaskModel> chores) async {
    final list = chores.map((c) => c.toJson()).toList();
    await _prefs?.setStringList(_keyChores, list);
  }

  Future<void> addChore(ChoreTaskModel chore) async {
    final list = await getChores();
    list.removeWhere((c) => c.id == chore.id);
    list.add(chore);
    await saveChores(list);
  }

  Future<void> updateChore(ChoreTaskModel chore) async {
    final list = await getChores();
    final index = list.indexWhere((c) => c.id == chore.id);
    if (index != -1) {
      list[index] = chore;
      await saveChores(list);
    }
  }

  Future<void> deleteChore(String id) async {
    final list = await getChores();
    list.removeWhere((c) => c.id == id);
    await saveChores(list);
  }

  // ===================== CRUD LOGS =====================
  Future<List<ActivityLogModel>> getLogs({String? childId}) async {
    final list = _prefs?.getStringList(_keyLogs) ?? [];
    final all = list.map((item) => ActivityLogModel.fromJson(item)).toList();
    all.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    if (childId != null) {
      return all.where((l) => l.childId == childId).toList();
    }
    return all;
  }

  Future<void> saveLogs(List<ActivityLogModel> logs) async {
    final list = logs.map((l) => l.toJson()).toList();
    await _prefs?.setStringList(_keyLogs, list);
  }

  Future<void> addLog(ActivityLogModel log) async {
    final list = await getLogs();
    list.insert(0, log);
    await saveLogs(list);
  }

  // ===================== CRUD TICKETS (Staff) =====================
  Future<List<SupportTicketModel>> getTickets() async {
    final list = _prefs?.getStringList(_keyTickets) ?? [];
    final all = list.map((item) => SupportTicketModel.fromJson(item)).toList();
    all.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return all;
  }

  Future<void> saveTickets(List<SupportTicketModel> tickets) async {
    final list = tickets.map((t) => t.toJson()).toList();
    await _prefs?.setStringList(_keyTickets, list);
  }

  Future<void> addTicket(SupportTicketModel ticket) async {
    final list = await getTickets();
    list.insert(0, ticket);
    await saveTickets(list);
  }

  Future<void> updateTicket(SupportTicketModel ticket) async {
    final list = await getTickets();
    final index = list.indexWhere((t) => t.id == ticket.id);
    if (index != -1) {
      list[index] = ticket;
      await saveTickets(list);
    }
  }

  Future<void> deleteTicket(String id) async {
    final list = await getTickets();
    list.removeWhere((t) => t.id == id);
    await saveTickets(list);
  }
}
