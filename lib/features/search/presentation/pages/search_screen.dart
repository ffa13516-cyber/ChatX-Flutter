import 'dart:async';
import 'package:flutter/material.dart';

// الـ Debouncer لمنع الضغط الزائد على السيرفر (تحسين الأداء)
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
  List<String> _results = []; // نتائج وهمية للتجربة مؤقتاً

  void _onSearchChanged(String query) {
    _debouncer.run(() {
      setState(() {
        if (query.isNotEmpty) {
          // هنا مستقبلاً هنربط مع الـ API أو الـ State Management
          _results = ['نتيجة بحث 1 عن: $query', 'نتيجة بحث 2 عن: $query', 'نتيجة بحث 3 عن: $query'];
        } else {
          _results = [];
        }
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // شريط البحث العلوي
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 22),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TextField(
                        controller: _searchController,
                        autofocus: true, // يفتح الكيبورد تلقائياً لـ UX أفضل
                        onChanged: _onSearchChanged,
                        decoration: InputDecoration(
                          hintText: 'ابحث عن أي شيء...',
                          hintStyle: TextStyle(color: Colors.grey.shade500),
                          prefixIcon: const Icon(Icons.search, color: Colors.grey),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // عرض النتائج
            Expanded(
              child: _results.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_rounded, size: 80, color: Colors.grey.withOpacity(0.3)),
                          const SizedBox(height: 16),
                          Text('اكتب شيئاً للبحث...', style: TextStyle(color: Colors.grey.shade600)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _results.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: const Icon(Icons.subdirectory_arrow_right_rounded, color: Colors.grey),
                          title: Text(_results[index]),
                          onTap: () {},
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
