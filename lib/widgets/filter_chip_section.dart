import 'package:flutter/material.dart';

// 필터 칩 가로 스크롤 섹션
class FilterChipSection extends StatelessWidget {
  final String selectedFilter; // 현재 선택된 필터
  final Function(String) onFilterChanged; // 필터 변경 콜백

  const FilterChipSection({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    // 필터 목록 정의
    final filters = [
      '전체',
      '입문자 추천',
      '기록 노리기',
      '접수 임박',
      '메이저 대회',
    ];

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 12),
      // 가로 스크롤 리스트
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = filter == selectedFilter;

          // 필터 칩 버튼
          return GestureDetector(
            onTap: () => onFilterChanged(filter),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              // 선택 상태에 따른 스타일 변경
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF0F172A) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? const Color(0xFF0F172A) : Colors.grey[300]!,
                ),
              ),
              child: Text(
                filter,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : Colors.grey[700],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
