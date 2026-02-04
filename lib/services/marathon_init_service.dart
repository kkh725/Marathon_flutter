import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive_ce/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/marathon.dart';

// 앱 최초 실행 시 AIMS 마라톤 데이터를 다운로드하여 Hive에 저장하는 서비스
class MarathonInitService {
  static const String _initKey = 'aims_data_initialized';
  static const String boxName = 'marathons';
  static const String _dataUrl =
      'https://kkh725.github.io/Marathon_Crolling/aims_marathons.json';

  /// 앱 초기화 시 호출 - 이미 초기화된 경우 스킵
  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final isInitialized = prefs.getBool(_initKey) ?? false;

    if (isInitialized) return;

    try {
      final response = await http.get(Uri.parse(_dataUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final events = data['events'] as List<dynamic>;

        final box = await Hive.openBox<Marathon>(boxName);
        await box.clear();

        for (int i = 0; i < events.length; i++) {
          final marathon = Marathon.fromAimsJson(events[i] as Map<String, dynamic>, i);
          await box.put(marathon.id, marathon);
        }

        await prefs.setBool(_initKey, true);
      }
    } catch (e) {
      // 네트워크 오류 시 다음 실행에서 재시도
      debugLog('AIMS 데이터 초기화 실패: $e');
    }
  }

  static void debugLog(String message) {
    assert(() {
      // ignore: avoid_print
      print(message);
      return true;
    }());
  }
}
