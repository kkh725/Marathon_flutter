import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/marathon.dart';
import 'package:intl/intl.dart';

// 마라톤 대회 정보 카드 위젯
class MarathonCard extends StatelessWidget {
  final Marathon marathon;

  const MarathonCard({
    super.key,
    required this.marathon,
  });

  @override
  Widget build(BuildContext context) {
    // 카드 컨테이너 스타일 설정
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단 이미지 영역
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
            child: Stack(
              children: [
                // 이미지 표시 (URL이 있으면 네트워크, 없으면 기본 이미지)
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: marathon.image.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: marathon.image,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) => Image.asset(
                            'assets/images/default_marathon.png',
                            fit: BoxFit.cover,
                          ),
                        )
                      : Image.asset(
                          'assets/images/default_marathon.png',
                          fit: BoxFit.cover,
                        ),
                ),
                // 난이도 뱃지 (좌상단)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getDifficultyColor(marathon.difficulty),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      marathon.difficulty.displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                // D-day 뱃지 (우상단)
                Positioned(
                  top: 12,
                  right: 12,
                  child: _buildDdayBadge(),
                ),
              ],
            ),
          ),

          // 콘텐츠 영역 (제목, 위치, 정보 등)
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 대회명
                Text(
                  marathon.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // 개최지
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        marathon.location,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 대회일/접수/이동 정보 그리드
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        icon: Icons.calendar_today_outlined,
                        label: '대회일',
                        value: DateFormat('yyyy.MM.dd').format(marathon.date),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: marathon.regDate.isNotEmpty
                            ? () => launchUrl(Uri.parse(marathon.regDate))
                            : null,
                        child: _buildInfoRow(
                          icon: Icons.how_to_reg_outlined,
                          label: '접수',
                          value: marathon.regDate.isNotEmpty ? '바로가기' : '-',
                          isLink: marathon.regDate.isNotEmpty,
                        ),
                      ),
                      if (marathon.price.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          icon: Icons.payments_outlined,
                          label: '참가비',
                          value: marathon.price,
                        ),
                      ],
                      if (marathon.accessibility.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          icon: Icons.flight_outlined,
                          label: '이동',
                          value: marathon.accessibility,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 태그 목록 (최대 4개)
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: marathon.tags.where((tag) => tag.isNotEmpty).take(4).map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // 상세보기 버튼
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to detail
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '자세히 보기',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward, size: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 정보 행 위젯 (아이콘 + 라벨 + 값)
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    bool isLink = false,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey[400],
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isLink ? const Color(0xFF2563EB) : null,
              decoration: isLink ? TextDecoration.underline : null,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  // D-day 뱃지 위젯
  Widget _buildDdayBadge() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final raceDay = DateTime(marathon.date.year, marathon.date.month, marathon.date.day);
    final diff = raceDay.difference(today).inDays;

    final String label;
    final Color bgColor;
    final Color textColor;

    if (diff > 0) {
      label = 'D-$diff';
      bgColor = const Color(0xFF2563EB);
      textColor = Colors.white;
    } else if (diff == 0) {
      label = 'D-Day';
      bgColor = const Color(0xFFEF4444);
      textColor = Colors.white;
    } else {
      label = '종료';
      bgColor = Colors.grey[600]!;
      textColor = Colors.white;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: textColor,
        ),
      ),
    );
  }

  // 난이도별 색상 반환 (입문:녹색, 중급:주황, 상급:빨강, 극한:보라)
  Color _getDifficultyColor(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.beginner:
        return const Color(0xFF10B981);
      case Difficulty.intermediate:
        return const Color(0xFFF59E0B);
      case Difficulty.advanced:
        return const Color(0xFFEF4444);
      case Difficulty.extreme:
        return const Color(0xFF7C3AED);
    }
  }
}
