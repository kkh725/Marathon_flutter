import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:hive_ce/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/marathon.dart';

// 앱 최초 실행 시 마라톤 데이터를 로드하여 Hive에 저장하는 서비스
class MarathonInitService {
  static const String _initKey = 'parsed_data_v7';
  static const String boxName = 'marathons';
  static const String _assetPath = 'marathons_parsed.json';

  /// 앱 초기화 시 호출 - 이미 초기화된 경우 스킵
  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final isInitialized = prefs.getBool(_initKey) ?? false;

    if (isInitialized) return;

    try {
      final jsonStr = await rootBundle.loadString(_assetPath);
      final data = jsonDecode(jsonStr);
      final marathons = data['marathons'] as List<dynamic>;

      final box = await Hive.openBox<Marathon>(boxName);
      await box.clear();

      for (int i = 0; i < marathons.length; i++) {
        final marathon = Marathon.fromParsedJson(
          marathons[i] as Map<String, dynamic>,
          i,
        );
        await box.put(marathon.id, marathon);
      }

      await prefs.setBool(_initKey, true);
    } catch (e) {
      debugLog('마라톤 데이터 초기화 실패: $e');
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
