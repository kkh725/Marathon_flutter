import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import '../models/marathon.dart';
import '../services/marathon_init_service.dart';

// 마라톤 목록 Provider (Hive DB에서 데이터 로드)
final marathonProvider = Provider<List<Marathon>>((ref) {
  final box = Hive.box<Marathon>(MarathonInitService.boxName);
  final marathons = box.values.toList();

  // 날짜순 정렬
  marathons.sort((a, b) => a.date.compareTo(b.date));

  return marathons;
});
