import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import '../models/marathon.dart';
import '../services/marathon_init_service.dart';

const _asia = {
  'KR', 'JP', 'CN', 'TW', 'HK', 'MO', 'TH', 'VN', 'SG', 'MY', 'ID', 'PH',
  'MM', 'KH', 'LA', 'BN', 'TL', 'IN', 'BD', 'LK', 'NP', 'PK', 'AF', 'MV',
  'BT', 'MN', 'KZ', 'UZ', 'TM', 'KG', 'TJ', 'AZ', 'GE', 'AM', 'IL', 'JO',
  'LB', 'SA', 'AE', 'QA', 'BH', 'KW', 'OM', 'YE', 'IQ', 'IR', 'SY', 'TR',
  'CY',
};

const _europe = {
  'GB', 'FR', 'DE', 'IT', 'ES', 'PT', 'NL', 'BE', 'LU', 'CH', 'AT', 'IE',
  'IS', 'NO', 'SE', 'FI', 'DK', 'PL', 'CZ', 'SK', 'HU', 'RO', 'BG', 'HR',
  'SI', 'RS', 'BA', 'ME', 'MK', 'AL', 'GR', 'EE', 'LV', 'LT', 'UA', 'BY',
  'MD', 'MT', 'MC', 'AD', 'SM', 'VA', 'LI', 'RU',
};

const _northAmerica = {
  'US', 'CA', 'MX', 'GT', 'BZ', 'SV', 'HN', 'NI', 'CR', 'PA', 'CU', 'JM',
  'HT', 'DO', 'PR', 'TT', 'BB', 'BS', 'AG', 'DM', 'GD', 'KN', 'LC', 'VC',
};

int _continentRank(String countryCode) {
  if (_asia.contains(countryCode)) return 0;
  if (_europe.contains(countryCode)) return 1;
  if (_northAmerica.contains(countryCode)) return 2;
  return 3;
}

bool _hasFullInfo(Marathon m) => m.regDate.isNotEmpty && m.price.isNotEmpty;

// 마라톤 목록 Provider
// 1) 다가오는 대회 우선
// 2) 접수+참가비 둘 다 있는 대회가 앞, 없으면 뒤로
// 3) 날짜 가까운 순
// 4) 같은 날짜면 아시아 > 유럽 > 북미 > 기타
// 5) 지난 대회는 맨 뒤
final marathonProvider = Provider<List<Marathon>>((ref) {
  final box = Hive.box<Marathon>(MarathonInitService.boxName);
  final marathons = box.values.toList();
  final now = DateTime.now();

  marathons.sort((a, b) {
    final aFuture = a.date.isAfter(now);
    final bFuture = b.date.isAfter(now);

    if (aFuture != bFuture) return aFuture ? -1 : 1;

    if (aFuture) {
      // 접수+참가비 있는 것 우선
      final aFull = _hasFullInfo(a);
      final bFull = _hasFullInfo(b);
      if (aFull != bFull) return aFull ? -1 : 1;

      // 날짜 가까운 순
      final dateCmp = a.date.compareTo(b.date);
      if (dateCmp != 0) return dateCmp;

      // 같은 날짜면 대륙 순
      return _continentRank(a.countryCode).compareTo(_continentRank(b.countryCode));
    }

    return b.date.compareTo(a.date);
  });

  return marathons;
});
