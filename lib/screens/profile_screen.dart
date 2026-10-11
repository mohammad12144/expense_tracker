import 'package:flutter/material.dart';
import '../models/auth_user.dart';
import '../services/api_client.dart';
import '../services/app_services.dart';
import '../utils/constants.dart';
import '../utils/jwt_utils.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  AuthUser? _user;
  DateTime? _tokenExpiry;
  String? _error;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await authedApi.get('https://dummyjson.com/auth/me')
          as Map<String, dynamic>;
      final expiry = JwtUtils.expiry(await tokenStorage.accessToken);
      if (!mounted) return;
      setState(() {
        _user = AuthUser.fromJson(data);
        _tokenExpiry = expiry;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Something went wrong.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ---- أدوات تجربة (Debug) ----

  Future<void> _breakAccessToken() async {
    await tokenStorage.saveAccessToken('invalid.expired.token');
    _hint('Access token broken. Tap "Reload profile" and watch the terminal.');
  }

  Future<void> _breakSession() async {
    await tokenStorage.saveTokens(
        accessToken: 'invalid', refreshToken: 'invalid');
    _hint('Both tokens broken. Tap "Reload profile".');
  }

  void _hint(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _logout() async {
    await authService.logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  String _time(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.hour)}:${two(d.minute)}:${two(d.second)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSizes.formMaxWidth),
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 12),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _load,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final user = _user;
    if (user == null) return const SizedBox.shrink();

    return ListView(
      padding: const EdgeInsets.all(AppSizes.pagePadding),
      children: [
        Center(
          child: CircleAvatar(
            radius: 48,
            backgroundImage:
                user.image.isEmpty ? null : NetworkImage(user.image),
            child: user.image.isEmpty ? const Icon(Icons.person, size: 48) : null,
          ),
        ),
        const SizedBox(height: 16),
        Text(user.fullName,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall),
        Text('@${user.username}', textAlign: TextAlign.center),
        const SizedBox(height: 24),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.email_outlined),
                title: const Text('Email'),
                subtitle: Text(user.email),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.timer_outlined),
                title: const Text('Access token expires at'),
                subtitle: Text(
                    _tokenExpiry == null ? 'unknown' : _time(_tokenExpiry!)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: _load,
          icon: const Icon(Icons.refresh),
          label: const Text('Reload profile'),
        ),
        const SizedBox(height: 24),
        Text('Debug tools', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: _breakAccessToken,
          child: const Text('Simulate expired access token'),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: _breakSession,
          child: const Text('Simulate expired session (both tokens)'),
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: _logout,
          icon: const Icon(Icons.logout),
          label: const Text('Logout'),
        ),
      ],
    );
  }
}