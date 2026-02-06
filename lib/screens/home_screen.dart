import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/marathon.dart';
import '../widgets/marathon_card.dart';
import '../widgets/filter_chip_section.dart';
import '../providers/marathon_provider.dart';

// 홈 화면 (Riverpod 상태 관리 사용)
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String selectedFilter = '전체'; // 현재 선택된 필터
  String _searchQuery = ''; // 검색어
  bool _showScrollToTop = false; // 맨 위로 버튼 표시 여부
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  static const int _pageSize = 20;
  int _displayCount = _pageSize; // 현재 표시 개수
  bool _isLoadingMore = false; // 추가 로딩 중 여부

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    FocusScope.of(context).unfocus();
    // 200px 이상 스크롤하면 맨 위로 버튼 표시
    final show = _scrollController.offset > 200;
    if (show != _showScrollToTop) {
      setState(() {
        _showScrollToTop = show;
      });
    }

    // 하단 근처 도달 시 추가 로드
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore) return;

    final allMarathons = ref.read(marathonProvider);
    final filtered = _filterMarathons(allMarathons);
    if (_displayCount >= filtered.length) return;

    setState(() => _isLoadingMore = true);

    // API 호출 느낌의 딜레이
    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;
    setState(() {
      _displayCount = (_displayCount + _pageSize).clamp(0, filtered.length);
      _isLoadingMore = false;
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // 검색어로 마라톤 목록 필터링
  List<Marathon> _filterMarathons(List<Marathon> marathons) {
    if (_searchQuery.isEmpty) return marathons;

    final query = _searchQuery.toLowerCase();
    return marathons.where((marathon) {
      // 대회명 검색
      if (marathon.name.toLowerCase().contains(query)) return true;
      // 개최지 검색
      if (marathon.location.toLowerCase().contains(query)) return true;
      // 태그 검색
      if (marathon.tags.any((tag) => tag.toLowerCase().contains(query))) return true;
      return false;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Provider에서 마라톤 목록 가져오기
    final allMarathons = ref.watch(marathonProvider);
    // 검색어로 필터링된 목록
    final marathons = _filterMarathons(allMarathons);
    // 실제 표시할 개수
    final visibleCount = _displayCount.clamp(0, marathons.length);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        // 맨 위로 가기 버튼
        floatingActionButton: AnimatedOpacity(
          opacity: _showScrollToTop ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: FloatingActionButton.small(
            onPressed: () {
              _scrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOut,
              );
            },
            backgroundColor: const Color(0xFF2563EB),
            child: const Icon(Icons.arrow_upward, color: Colors.white),
          ),
        ),
        body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // 상단 앱바 (블러 효과)
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: Colors.white.withValues(alpha: 0.8),
            surfaceTintColor: Colors.transparent,
            flexibleSpace: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(color: Colors.transparent),
              ),
            ),
            title: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.public,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'K-RUN GLOBAL',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            actions: [
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () {},
                  ),
                  Positioned(
                    right: 12,
                    top: 12,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person_outline,
                    size: 20,
                    color: Colors.grey[600],
                  ),
                ),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
            ],
          ),

          // 히어로 섹션 (타이틀 + 검색바 + 통계)
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF2563EB).withValues(alpha: 0.05),
                    Colors.white,
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '세계의 주로를\n달리는 여정',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        height: 1.2,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '전 세계 150+ 마라톤 대회를 한눈에.\n접수 놓치지 마세요.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // 검색 입력창
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: TextField(
                        controller: _searchController,
                        // 검색어 입력시 필터링 + 페이지 초기화
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                            _displayCount = _pageSize;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: '대회명, 도시 또는 키워드 검색',
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontWeight: FontWeight.w500,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.grey[400],
                          ),
                          // 검색어 있을 때 X 버튼 표시
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: Icon(
                                    Icons.clear,
                                    color: Colors.grey[400],
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _searchController.clear();
                                      _searchQuery = '';
                                      _displayCount = _pageSize;
                                    });
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // 통계 정보 (대회 수 / 커뮤니티 규모)
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '150+',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              '분석된 글로벌 대회',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey[400],
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 32),
                        Container(
                          width: 1,
                          height: 32,
                          color: Colors.grey[200],
                        ),
                        const SizedBox(width: 32),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '42.2k',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              '러너 커뮤니티',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey[400],
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 필터 섹션 (가로 스크롤)
          SliverToBoxAdapter(
            child: FilterChipSection(
              selectedFilter: selectedFilter,
              // 필터 선택시 상태 업데이트
              onFilterChanged: (filter) {
                setState(() {
                  selectedFilter = filter;
                });
              },
            ),
          ),

          // 결과 헤더 (개수 표시 + 상세필터 버튼)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            '큐레이션 결과',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${marathons.length}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF2563EB),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '실시간 접수 정보와 한국인 적합도 기준 정렬',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[400],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.tune,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '상세 필터',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 마라톤 카드 목록 (스크롤 최적화된 SliverList)
          if (marathons.isEmpty)
            // 검색 결과 없음 표시
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(48.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 64,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '"$_searchQuery" 검색 결과가 없습니다',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: MarathonCard(marathon: marathons[index]),
                    );
                  },
                  childCount: visibleCount,
                ),
              ),
            ),

          // 로딩 인디케이터
          if (_isLoadingMore)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                ),
              ),
            ),

          // 모두 불러옴 표시
          if (!_isLoadingMore && visibleCount >= marathons.length && marathons.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    '모든 대회를 불러왔습니다',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[400],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),

          // 하단 여백
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
      ),
    );
  }
}
