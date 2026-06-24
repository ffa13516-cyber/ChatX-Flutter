import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// استيراد الموديلز والـ Repo الخاص بك
import '../../models/models.dart'; // تأكد من مسار الـ UserModel الصحيح
import '../../repositories/firebase_repo.dart';
import 'chat_screen.dart'; // تأكد من مسار صفحة الشات

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
  // ✅ تمرير بيانات المستخدم الحالي لتمريرها لاحقاً لصفحة الشات
  final String myUid;
  final String myName;

  const SearchScreen({
    Key? key, 
    required this.myUid, 
    required this.myName,
  }) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Debouncer _debouncer = Debouncer(milliseconds: 500); // 500ms ممتاز جداً للـ UX
  
  // لون الفخامة الأساسي
  final Color luxuryAccentColor = const Color(0xFF6C63FF);
  
  // ✅ تحويل القائمة لتستقبل UserModel بدلاً من السلسلة النصية التقليدية
  List<UserModel> _results = [];
  bool _isLoading = false;

  void _onSearchChanged(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = true);

    // ✅ تشغيل الـ Debouncer لمنع الضغط الزائد على السيرفر
    _debouncer.run(() async {
      try {
        // جلب المستخدم من الـ Firebase Repo بناءً على الـ username
        final user = await FirebaseRepo.getUserByUsername(query.trim());
        
        if (!mounted) return; // حماية ضد أخطاء الـ Async Gaps

        setState(() {
          _isLoading = false;
          if (user != null) {
            _results = [user]; // الـ Repo حالياً يعيد مستخدم واحد مطرابق
          } else {
            _results = [];
          }
        });
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _results = [];
        });
        // 💡 تلميح للمستقبل: يمكنك إظهار SnackBar هنا في حالة حدوث خطأ شبكة
      }
    });
  }

  // ✅ دالة معالجة فتح الشات والانتقال المباشر
  Future<void> _openChat(UserModel user) async {
    setState(() => _isLoading = true); // إشعار المستخدم بالتحميل أثناء إنشاء الغرفة
    
    try {
      final chat = await FirebaseRepo.getOrCreateChat(
        widget.myUid,
        user.uid,
      );
      
      if (!mounted) return;

      // الانتقال لشاشة الشات وتمرير البيانات المطلوبة
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            chatId: chat.chatId,
            myUid: widget.myUid,
            myName: widget.myName,
          ),
        ),
      ).then((_) {
        // إعادة حالة المؤشر لوضعه الطبيعي بعد العودة من الشات
        if (mounted) setState(() => _isLoading = false);
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      // التعامل مع الأخطاء هنا إن وجدت
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0E),
      body: SafeArea(
        child: Column(
          children: [
            // 1. شريط البحث العلوي (Luxury Style)
            _buildSearchBar(),
            
            // 2. خط فاصل رفيع جداً بلمسة بنفسجية لإعطاء عمق
            Divider(color: luxuryAccentColor.withOpacity(0.1), height: 1, thickness: 1),

            // 3. عرض النتائج أو الحالة الفارغة أو التحميل
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
                color: const Color(0xFF1A1A22).withOpacity(0.6), 
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
                    hintText: 'Search by username...',
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
            _searchController.text.isEmpty 
                ? 'Type a username to start chatting' 
                : 'No user found with this username',
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
        final user = _results[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
          leading: CircleAvatar(
            radius: 24,
            backgroundColor: luxuryAccentColor.withOpacity(0.1),
            backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
            child: user.avatarUrl == null
                ? Icon(Icons.person, color: luxuryAccentColor, size: 22)
                : null,
          ),
          title: Text(
            user.displayName,
            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            '@${user.username}',
            style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13),
          ),
          trailing: Icon(Icons.arrow_forward_ios_rounded, color: Colors.white.withOpacity(0.2), size: 14),
          onTap: () {
            HapticFeedback.lightImpact();
            _openChat(user); // تفعيل بدء الشات فوراً عند الضغط
          },
        );
      },
    );
  }
}
