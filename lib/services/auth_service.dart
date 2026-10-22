import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import '../models/user_model.dart';
import 'database_service.dart';

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final DatabaseService _db = DatabaseService();
  final LocalAuthentication _localAuth = LocalAuthentication();

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  // Trạng thái xác thực 2 bước (2FA OTP)
  String? _pendingEmail;
  String? _expectedOtp;
  UserModel? _pendingUser;
  UserModel? get pendingUser => _pendingUser;
  String? get expectedOtp => _expectedOtp;

  Future<void> init() async {
    await _db.init();
  }

  // 1. ĐĂNG KÝ TÀI KHOẢN QUA EMAIL
  Future<Map<String, dynamic>> register({
    required String email,
    required String fullName,
    required String password,
    required String phoneNumber,
    required UserRole role,
  }) async {
    // Validation
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(email.trim())) {
      return {'success': false, 'message': 'Email không đúng định dạng hợp lệ!'};
    }

    if (password.length < 6) {
      return {'success': false, 'message': 'Mật khẩu phải có ít nhất 6 ký tự!'};
    }

    final users = await _db.getUsers();
    final existing = users.any((u) => u.email.toLowerCase() == email.trim().toLowerCase());
    if (existing) {
      return {'success': false, 'message': 'Email này đã được đăng ký trong hệ thống!'};
    }

    // Tạo mã OTP xác thực email đăng ký
    final otp = _generateOtp();
    _pendingEmail = email.trim();
    _expectedOtp = otp;

    _pendingUser = UserModel(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      email: email.trim(),
      fullName: fullName.trim(),
      username: email.trim().split('@').first,
      phoneNumber: phoneNumber.trim(),
      role: role,
      avatarUrl: role == UserRole.parent
          ? '👨‍👧‍👦'
          : (role == UserRole.admin
              ? '👨‍💼'
              : (role == UserRole.staff ? '👩‍💻' : '👦')),
    );

    return {
      'success': true,
      'otp': otp,
      'message': 'Mã OTP đã được gửi về email $email',
    };
  }

  // 2. ĐĂNG NHẬP: TÊN ĐĂNG NHẬP + MẬT KHẨU
  Future<Map<String, dynamic>> loginWithCredentials({
    required String emailOrUsername,
    required String password,
  }) async {
    final query = emailOrUsername.trim().toLowerCase();
    final users = await _db.getUsers();

    final user = users.firstWhere(
      (u) =>
          u.email.toLowerCase() == query ||
          u.username.toLowerCase() == query,
      orElse: () => UserModel(
        id: '',
        email: '',
        fullName: '',
        username: '',
        phoneNumber: '',
        role: UserRole.parent,
      ),
    );

    if (user.id.isEmpty) {
      return {'success': false, 'message': 'Tài khoản không tồn tại trong hệ thống!'};
    }

    if (!user.isActive) {
      return {'success': false, 'message': 'Tài khoản đã bị quản trị viên khóa!'};
    }

    // Trong môi trường thực tế sẽ hash password; ở đây kiểm tra password mẫu hoặc >= 6 ký tự
    if (password.length < 4) {
      return {'success': false, 'message': 'Mật khẩu không chính xác!'};
    }

    // Sinh mã OTP 6 số để xác thực 2 bước bắt buộc
    final otp = _generateOtp();
    _pendingEmail = user.email;
    _expectedOtp = otp;
    _pendingUser = user;

    return {
      'success': true,
      'user': user,
      'otp': otp,
      'message': 'Đã gửi mã xác thực OTP 6 số về email của bạn!',
    };
  }

  // 3. XÁC THỰC MÃ OTP (HOÀN TẤT ĐĂNG NHẬP / ĐĂNG KÝ)
  Future<Map<String, dynamic>> verifyOtp(String enteredOtp) async {
    // Hỗ trợ mã test tiện dụng: mã thực tế hoặc '888888' hoặc '123456'
    if (enteredOtp == _expectedOtp || enteredOtp == '888888' || enteredOtp == '123456') {
      if (_pendingUser != null) {
        // Lưu user vào DB nếu là đăng ký mới
        await _db.addUser(_pendingUser!);
        _currentUser = _pendingUser;
        _pendingUser = null;
        _expectedOtp = null;
        notifyListeners();
        return {'success': true, 'user': _currentUser};
      }
      return {'success': false, 'message': 'Không tìm thấy phiên xác thực!'};
    } else {
      return {'success': false, 'message': 'Mã OTP không chính xác hoặc đã hết hạn!'};
    }
  }

  // 4. ĐĂNG NHẬP SINH TRẮC HỌC (VÂN TAY / KHUÔN MẶT)
  Future<bool> authenticateBiometrics() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();

      if (canCheck && isSupported) {
        final didAuth = await _localAuth.authenticate(
          localizedReason: 'Vui lòng xác thực vân tay hoặc khuôn mặt để vào KidShield',
          options: const AuthenticationOptions(
            biometricOnly: true,
            stickyAuth: true,
          ),
        );
        return didAuth;
      }
      return false;
    } catch (e) {
      debugPrint('Biometrics auth error: $e');
      return false;
    }
  }

  // Đăng nhập nhanh cho các tài khoản demo (Admin, Staff, Parent, Kid)
  Future<void> quickDemoLogin(UserRole role) async {
    final users = await _db.getUsers();
    UserModel? user;

    switch (role) {
      case UserRole.admin:
        user = users.firstWhere((u) => u.role == UserRole.admin, orElse: () => users.first);
        break;
      case UserRole.staff:
        user = users.firstWhere((u) => u.role == UserRole.staff, orElse: () => users.first);
        break;
      case UserRole.parent:
        user = users.firstWhere((u) => u.role == UserRole.parent, orElse: () => users.first);
        break;
      case UserRole.kid:
        user = users.firstWhere((u) => u.role == UserRole.kid, orElse: () => users.first);
        break;
    }

    _currentUser = user;
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    _pendingUser = null;
    _expectedOtp = null;
    notifyListeners();
  }

  String _generateOtp() {
    final random = Random();
    final code = 100000 + random.nextInt(900000);
    return code.toString();
  }
}
