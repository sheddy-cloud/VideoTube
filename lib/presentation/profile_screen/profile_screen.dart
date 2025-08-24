import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../core/services/auth_service.dart';

import '../../core/app_export.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  String _email = '';
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMe();
  }

  Future<void> _loadMe() async {
    try {
      final me = await AuthService.I.fetchMe();
      setState(() {
        _nameController.text = (me['name'] ?? '').toString();
        _email = (me['email'] ?? '').toString();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load profile';
        _loading = false;
      });
    }
  }

  Future<void> _save() async {
    setState(() { _error = null; _loading = true; });
    try {
      await AuthService.I.updateMe(name: _nameController.text.trim());
      if (!mounted) return;
      setState(() { _loading = false; });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated')));
    } catch (e) {
      setState(() { _loading = false; _error = 'Failed to update profile'; });
    }
  }

  Future<void> _signOut() async {
    await AuthService.I.logout();
    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          TextButton(
            onPressed: _loading ? null : _save,
            child: const Text('Save'),
          )
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_error != null)
                    Padding(
                      padding: EdgeInsets.only(bottom: 2.h),
                      child: Text(_error!, style: TextStyle(color: AppTheme.lightTheme.colorScheme.error)),
                    ),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 8.w,
                        backgroundColor: AppTheme.lightTheme.primaryColor,
                        child: Text(
                          (_nameController.text.isNotEmpty ? _nameController.text[0] : 'U').toUpperCase(),
                          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.onPrimary,
                          ),
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: _nameController,
                              decoration: const InputDecoration(labelText: 'Name'),
                            ),
                            SizedBox(height: 1.h),
                            Text(_email, style: AppTheme.lightTheme.textTheme.bodySmall),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('Sign out'),
                    onTap: _signOut,
                  ),
                ],
              ),
            ),
    );
  }
}


