import 'package:hive_ce/hive.dart';
import '../constants/marathon_images.dart';

part 'marathon.g.dart';

// 마라톤 대회 정보 모델 (Hive DB 저장용)
@HiveType(typeId: 0)
class Marathon {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String location;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final String regDate;

  @HiveField(5)
  final List<String> distance;

  @HiveField(6)
  final EntryMethod entryMethod;

  @HiveField(7)
  final Difficulty difficulty;

  @HiveField(8)
  final int suitability;

  @HiveField(9)
  final String accessibility;

  @HiveField(10)
  final String jetLag;

  @HiveField(11)
  final String accommodation;

  @HiveField(12)
  final String image;

  @HiveField(13)
  final List<String> tags;

  @HiveField(14)
  final String? recommendationReason;

  @HiveField(15)
  final String visaInfo;

  @HiveField(16)
  final String officialUrl;

  @HiveField(17)
  final String price;

  @HiveField(18)
  final String countryCode;

  Marathon({
    required this.id,
    required this.name,
    required this.location,
    required this.date,
    required this.regDate,
    required this.distance,
    required this.entryMethod,
    required this.difficulty,
    required this.suitability,
    required this.accessibility,
    required this.jetLag,
    required this.accommodation,
    required this.image,
    required this.tags,
    this.recommendationReason,
    required this.visaInfo,
    required this.officialUrl,
    required this.price,
    required this.countryCode,
  });

  // courseDifficulty(한글) → Difficulty enum 매핑
  static const _difficultyMap = <String, Difficulty>{
    '평평해요': Difficulty.beginner,
    '조금 출렁여요': Difficulty.intermediate,
    '언덕이 많아요': Difficulty.advanced,
    '한계에 가까워요': Difficulty.extreme,
  };

  static const _defaultImageHost = 'wmimg.azureedge.net';

  // 기본 이미지이거나 비어있으면 Unsplash 이미지 배정
  static String _pickImage(String imageUrl, int index) {
    if (imageUrl.isEmpty || imageUrl.contains(_defaultImageHost)) {
      return marathonImageUrls[index % marathonImageUrls.length];
    }
    return imageUrl;
  }

  // worldsmarathons.com parsed JSON → Marathon 객체 변환 (한글 원본 그대로 사용)
  factory Marathon.fromParsedJson(Map<String, dynamic> json, int index) {
    final raceTypeLabel = json['raceTypeLabel'] as String? ?? '';
    final uniqueDistances = (json['uniqueDistances'] as List<dynamic>?)
            ?.map((d) => d.toString())
            .toList() ??
        [];
    final tags = (json['tags'] as List<dynamic>?)
            ?.map((t) => t.toString())
            .toList() ??
        [];

    final difficultyRaw = (json['courseDifficulty'] as String? ?? '').trim();
    final difficulty = _difficultyMap[difficultyRaw] ?? Difficulty.intermediate;

    return Marathon(
      id: json['id'] ?? 'parsed-$index',
      name: json['title'] ?? '',
      location: json['location'] as String? ?? '',
      date: DateTime.parse(json['dateNextRace'] ?? json['firstRaceDate']),
      regDate: json['website'] ?? '',
      distance: [raceTypeLabel, ...uniqueDistances],
      entryMethod: EntryMethod.firstCome,
      difficulty: difficulty,
      suitability: 3,
      accessibility: '',
      jetLag: '',
      accommodation: '',
      image: _pickImage(json['image'] as String? ?? '', index),
      tags: [raceTypeLabel, if ((json['surface'] as String? ?? '').isNotEmpty) json['surface'] as String, ...tags],
      visaInfo: '',
      officialUrl: json['selfLink'] ?? '',
      price: json['minPriceFormatted'] as String? ?? '',
      countryCode: json['countryCode'] as String? ?? '',
    );
  }

  // AIMS JSON -> Marathon 객체 변환
  factory Marathon.fromAimsJson(Map<String, dynamic> json, int index) {
    final distances = (json['distances'] as List<dynamic>?)?.map((d) {
      switch (d) {
        case 'FULL':
          return '풀';
        case 'HALF':
          return '하프';
        default:
          return d.toString();
      }
    }).toList() ?? [];

    final countryCode = json['country_code'] ?? '';
    final city = json['city'] ?? '';
    final location = city.isNotEmpty ? '$city, $countryCode' : countryCode;

    return Marathon(
      id: 'aims-$index',
      name: json['event_name'] ?? '',
      location: location,
      date: DateTime.parse(json['start_date']),
      regDate: json['end_date'] != json['start_date']
          ? '${json['start_date']} ~ ${json['end_date']}'
          : '',
      distance: distances,
      entryMethod: EntryMethod.firstCome,
      difficulty: Difficulty.beginner,
      suitability: 3,
      accessibility: '',
      jetLag: '',
      accommodation: '',
      image: '',
      tags: distances,
      visaInfo: '',
      officialUrl: json['aims_url'] ?? '',
      price: '',
      countryCode: json['country_code'] ?? '',
    );
  }

  // JSON -> Marathon 객체 변환
  factory Marathon.fromJson(Map<String, dynamic> json) {
    return Marathon(
      id: json['id'],
      name: json['name'],
      location: json['location'],
      date: DateTime.parse(json['date']),
      regDate: json['regDate'],
      distance: List<String>.from(json['distance']),
      // enum 문자열을 EntryMethod로 변환
      entryMethod: EntryMethod.values.firstWhere(
        (e) => e.toString().split('.').last == json['entryMethod'],
      ),
      // enum 문자열을 Difficulty로 변환
      difficulty: Difficulty.values.firstWhere(
        (e) => e.toString().split('.').last == json['difficulty'],
      ),
      suitability: json['suitability'],
      accessibility: json['accessibility'],
      jetLag: json['jetLag'],
      accommodation: json['accommodation'],
      image: json['image'],
      tags: List<String>.from(json['tags']),
      recommendationReason: json['recommendationReason'],
      visaInfo: json['visaInfo'],
      officialUrl: json['officialUrl'],
      price: json['price'] ?? '',
      countryCode: json['countryCode'] ?? '',
    );
  }

  // Marathon 객체 -> JSON 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'date': date.toIso8601String(),
      'regDate': regDate,
      'distance': distance,
      'entryMethod': entryMethod.toString().split('.').last,
      'difficulty': difficulty.toString().split('.').last,
      'suitability': suitability,
      'accessibility': accessibility,
      'jetLag': jetLag,
      'accommodation': accommodation,
      'image': image,
      'tags': tags,
      'recommendationReason': recommendationReason,
      'visaInfo': visaInfo,
      'officialUrl': officialUrl,
      'price': price,
      'countryCode': countryCode,
    };
  }
}

// 접수 방식 enum
@HiveType(typeId: 1)
enum EntryMethod {
  @HiveField(0)
  lottery, // 추첨

  @HiveField(1)
  firstCome, // 선착순

  @HiveField(2)
  qualifying, // 기록컷
}

// 대회 난이도 enum (Flat/Rolling/Hilly/Extreme)
@HiveType(typeId: 2)
enum Difficulty {
  @HiveField(0)
  beginner, // 입문 (Flat)

  @HiveField(1)
  intermediate, // 중급 (Rolling)

  @HiveField(2)
  advanced, // 상급 (Hilly)

  @HiveField(3)
  extreme, // 극한 (Extreme)
}

// 접수 방식 한글 표시명 반환
extension EntryMethodExtension on EntryMethod {
  String get displayName {
    switch (this) {
      case EntryMethod.lottery:
        return '추첨';
      case EntryMethod.firstCome:
        return '선착순';
      case EntryMethod.qualifying:
        return '기록컷';
    }
  }
}

// 난이도 한글 표시명 반환
extension DifficultyExtension on Difficulty {
  String get displayName {
    switch (this) {
      case Difficulty.beginner:
        return '평평해요';
      case Difficulty.intermediate:
        return '조금 출렁여요';
      case Difficulty.advanced:
        return '언덕이 많아요';
      case Difficulty.extreme:
        return '한계에 가까워요';
    }
  }
}
