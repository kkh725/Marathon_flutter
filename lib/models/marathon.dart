import 'package:hive_ce/hive.dart';

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
  });

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

// 대회 난이도 enum
@HiveType(typeId: 2)
enum Difficulty {
  @HiveField(0)
  beginner, // 입문

  @HiveField(1)
  intermediate, // 중급

  @HiveField(2)
  advanced, // 기록용
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
        return '입문';
      case Difficulty.intermediate:
        return '중급';
      case Difficulty.advanced:
        return '기록용';
    }
  }
}
