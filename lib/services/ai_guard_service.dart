import 'package:flutter/foundation.dart';

class AiAnalysisResult {
  final String text;
  final bool isSafe;
  final String riskCategory; // Bắt nạt mạng, Tự hại, Ngôn từ tục tĩu, Người lạ dụ dỗ, An toàn
  final double riskScore; // 0.0 - 1.0
  final String psychologistAdvice; // Lời khuyên cho phụ huynh
  final List<String> flaggedKeywords;

  AiAnalysisResult({
    required this.text,
    required this.isSafe,
    required this.riskCategory,
    required this.riskScore,
    required this.psychologistAdvice,
    required this.flaggedKeywords,
  });
}

class AiGuardService extends ChangeNotifier {
  static final AiGuardService _instance = AiGuardService._internal();
  factory AiGuardService() => _instance;
  AiGuardService._internal();

  final List<AiAnalysisResult> _recentDetections = [
    AiAnalysisResult(
      text: 'Sao bạn đó lại bảo mình vô dụng, không thèm chơi với mình nữa...',
      isSafe: false,
      riskCategory: 'Bắt nạt mạng / Tẩy chay học đường',
      riskScore: 0.78,
      psychologistAdvice:
          'Bé đang có dấu hiệu bị bạn bè cô lập hoặc tẩy chay. Phụ huynh nên ôm bé, lắng nghe chân thành mà không phán xét, hỏi han về các mối quan hệ ở lớp một cách nhẹ nhàng.',
      flaggedKeywords: ['vô dụng', 'không thèm chơi'],
    ),
    AiAnalysisResult(
      text: 'Mày chuyển cho anh 500k thẻ game anh nạp hộ cho nick xịn nè em ơi.',
      isSafe: false,
      riskCategory: 'Lừa đảo trực tuyến / Chiếm đoạt tài sản',
      riskScore: 0.92,
      psychologistAdvice:
          'Kẻ xấu đang dụ dỗ trẻ nạp tiền lừa đảo game. Hãy hướng dẫn con quy tắc không bao giờ chuyển tiền hay mua mã thẻ cho người lạ trên mạng xã hội.',
      flaggedKeywords: ['thẻ game', 'nạp hộ', 'chuyển cho anh'],
    ),
  ];

  List<AiAnalysisResult> get recentDetections => List.unmodifiable(_recentDetections);

  // Phân tích văn bản tin nhắn bằng AI Guard Engine
  AiAnalysisResult analyzeText(String input) {
    final lower = input.toLowerCase();

    // 1. Kiểm tra lừa đảo
    if (lower.contains('thẻ cào') ||
        lower.contains('chuyển khoản') ||
        lower.contains('mật khẩu') ||
        lower.contains('nạp game') ||
        lower.contains('tặng quà')) {
      final res = AiAnalysisResult(
        text: input,
        isSafe: false,
        riskCategory: 'Nguy cơ Lừa đảo / Người lạ trục lợi',
        riskScore: 0.88,
        psychologistAdvice:
            'Cảnh báo: Con đang tương tác với nội dung có dấu hiệu lừa đảo trực tuyến. Bố mẹ nên kiểm tra nhật ký liên lạc và giải thích về an toàn thông tin.',
        flaggedKeywords: ['thẻ cào', 'chuyển khoản', 'nạp game'].where((k) => lower.contains(k)).toList(),
      );
      _recentDetections.insert(0, res);
      notifyListeners();
      return res;
    }

    // 2. Kiểm tra bắt nạt / xúc phạm
    if (lower.contains('chết đi') ||
        lower.contains('ngu') ||
        lower.contains('đồ khốn') ||
        lower.contains('ghét bỏ') ||
        lower.contains('tẩy chay') ||
        lower.contains('vô dụng')) {
      final res = AiAnalysisResult(
        text: input,
        isSafe: false,
        riskCategory: 'Bắt nạt học đường / Tổn thương tâm lý',
        riskScore: 0.82,
        psychologistAdvice:
            'Chuyên gia tâm lý khuyên: Hãy dành tối nay cùng con đi dạo, tạo không gian an toàn để con giãi bày. Tuyệt đối không la mắng con vì những tin nhắn này.',
        flaggedKeywords: ['chết đi', 'ngu', 'ghét bỏ', 'vô dụng'].where((k) => lower.contains(k)).toList(),
      );
      _recentDetections.insert(0, res);
      notifyListeners();
      return res;
    }

    // 3. Nội dung bình thường / an toàn
    final safeRes = AiAnalysisResult(
      text: input,
      isSafe: true,
      riskCategory: 'An toàn & Lành mạnh',
      riskScore: 0.05,
      psychologistAdvice: 'Nội dung tích cực, phù hợp với lứa tuổi của trẻ.',
      flaggedKeywords: [],
    );
    notifyListeners();
    return safeRes;
  }
}
