import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// مسار الألوان الخاص بك (تأكد من صحته)
// import '../../utils/app_colors.dart';

class Debouncer {
  final int milliseconds;
  Timer? _timer;
  Debouncer({required this.milliseconds});

  void run(VoidCallback action) {
    if (_timer?.isActive ?? false) _timer!.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Debouncer _debouncer = Debouncer(milliseconds: 500);
  
  // لون الفخامة الأساسي (نفس المستخدم في الهوم)
  final Color luxuryAccentColor = const Color(0xFF6C63FF);
  
  List<String> _results = []; 
  bool _isLoading = false;

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      setState(() {
        _results = [];
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = true);

    _debouncer.run(() {
      // هنا سيتم ربط الـ API أو قاعدة البيانات لاحقاً
      setState(() {
        _isLoading = false;
        _results = [
          'نتيجة بحث 1 عن: $query',
          'نتيجة بحث 2 عن: $query',
          'نتيجة بحث 3 عن: $query',
        ];
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0E), // نفس الأسود العميق للـ Home
      body: SafeArea(
        child: Column(
          children: [
            // 1. شريط البحث العلوي (Luxury Style)
            _buildSearchBar(),
            
            // 2. خط فاصل رفيع جداً بلمسة بنفسجية لإعطاء عمق
            Divider(color: luxuryAccentColor.withOpacity(0.1), height: 1, thickness: 1),

            // 3. عرض النتائج أو الحالة الفارغة
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: luxuryAccentColor,
                        strokeWidth: 2,
                      ),
                    )
                  : _results.isEmpty
                      ? _buildEmptyState()
                      : _buildResultsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
          ),
          Expanded(
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A22).withOpacity(0.6), // زجاج داكن
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: luxuryAccentColor.withOpacity(0.15), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: luxuryAccentColor.withOpacity(0.05),
                    blurRadius: 10,
                    spreadRadius: 1,
                  )
                ],
              ),
              child: Theme(
                data: Theme.of(context).copyWith(
                  textSelectionTheme: TextSelectionThemeData(
                    selectionColor: luxuryAccentColor.withOpacity(0.3),
                    selectionHandleColor: luxuryAccentColor,
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  onChanged: _onSearchChanged,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  cursorColor: luxuryAccentColor,
                  decoration: InputDecoration(
                    hintText: 'Search chats, messages...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 15),
                    prefixIcon: Icon(Icons.search_rounded, color: luxuryAccentColor.withOpacity(0.7), size: 22),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: luxuryAccentColor.withOpacity(0.15),
                              ),
                              child: const Icon(Icons.close_rounded, color: Colors.white, size: 14),
                            ),
                            onPressed: () {
                              HapticFeedback.selectionClick();
                              _searchController.clear();
                              _onSearchChanged('');
                              setState(() {});
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: luxuryAccentColor.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.manage_search_rounded, 
              size: 70, 
              color: luxuryAccentColor.withOpacity(0.3),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'What are you looking for?',
            style: TextStyle(
              fontSize: 16, 
              color: Colors.white.withOpacity(0.5),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList() {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8),
      itemCount: _results.length,
      itemBuilder: (context, index) {
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: luxuryAccentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.chat_bubble_outline_rounded, color: luxuryAccentColor, size: 20),
          ),
          title: Text(
            _results[index],
            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            'Message • Just now',
            style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13),
          ),
          onTap: () {
            HapticFeedback.lightImpact();
            // الانتقال للنتيجة
          },
        );
      },
    );
  }
}
