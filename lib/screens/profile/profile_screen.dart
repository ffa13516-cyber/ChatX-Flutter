import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../repositories/firebase_repo.dart';
import '../../utils/app_colors.dart';
import '../../utils/session_manager.dart';
import '../../widgets/widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  String _myUid = '';
  String _phone = '';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final uid = await SessionManager.instance.getUid();
    final phone = await SessionManager.instance.getPhone();
    final user = await FirebaseRepo.getUserById(uid);
    setState(() {
      _myUid = uid;
      _phone = phone;
      _nameController.text = user?.displayName ?? '';
      _usernameController.text = user?.username ?? '';
    });
  }

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();
    final username = _usernameController.text.trim().toLowerCase();

    if (name.isEmpty) {
      _showSnack('Name cannot be empty');
      return;
    }
    if (username.isEmpty) {
      _showSnack('Username cannot be empty');
      return;
    }
    if (!RegExp(r'^[a-z0-9_.]+$').hasMatch(username)) {
      _showSnack('Username can only contain letters, numbers, _ and .');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final currentUser = await FirebaseRepo.getUserById(_myUid);
      if (currentUser?.username != username) {
        final existing = await FirebaseRepo.getUserByUsername(username);
        if (existing != null) {
          _showSnack('Username @$username is already taken!');
          return;
        }
      }

      if (currentUser != null) {
        await FirebaseRepo.saveUser(
          currentUser.copyWith(displayName: name, username: username),
        );
        await SessionManager.instance.saveSession(
          uid: _myUid,
          phone: _phone,
          name: name,
        );
        _showSnack('Profile saved! @$username');
      } else {
        _showSnack('User not found!');
      }
    } catch (e) {
      _showSnack('Error: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.bgCard,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppColors.bgDark,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 16),

            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  _nameController.text.isNotEmpty
                      ? _nameController.text[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            Text(
              _nameController.text,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              _phone,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),

            const SizedBox(height: 32),

            CustomTextField(
              hint: 'Display Name',
              controller: _nameController,
              prefixIcon: Icons.person_rounded,
            ),
            const SizedBox(height: 14),
            CustomTextField(
              hint: 'Username (e.g. ahmed123)',
              controller: _usernameController,
              prefixIcon: Icons.alternate_email_rounded,
            ),
            const SizedBox(height: 8),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Letters, numbers, _ and . only',
                style: TextStyle(color: AppColors.textHint, fontSize: 12),
              ),
            ),
            const SizedBox(height: 24),

            GradientButton(
              text: 'Save Profile',
              onPressed: _saveProfile,
              isLoading: _isSaving,
            ),
          ],
        ),
      ),
    );
  }
}
