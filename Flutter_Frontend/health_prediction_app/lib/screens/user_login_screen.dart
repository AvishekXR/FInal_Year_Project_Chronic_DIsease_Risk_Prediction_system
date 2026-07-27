import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../core/constants.dart';
import '../services/user_service.dart';
import 'home_screen.dart';

class UserLoginScreen extends StatefulWidget {
  const UserLoginScreen({super.key});

  @override
  State<UserLoginScreen> createState() => _UserLoginScreenState();
}

class _UserLoginScreenState extends State<UserLoginScreen> {
  bool _isLogin = true;
  bool _loading = false;
  bool _obscurePassword = true;
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailCtrl.text.trim();
    final password = _passCtrl.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Please fill in all required fields');
      return;
    }
    if (!_isLogin && _nameCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Please enter your full name');
      return;
    }

    setState(() { _loading = true; _error = null; });
    try {
      if (_isLogin) {
        await UserService.login(email, password);
      } else {
        await UserService.register(
          _nameCtrl.text.trim(), email, password,
          phone: _phoneCtrl.text.trim(),
        );
      }
      if (mounted) {
        Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const HomeScreen()));
      }
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = !kIsWeb || screenWidth < 600;

    if (isMobile) return _buildMobile(context);
    return _buildWeb(context);
  }

  // ─── MOBILE LAYOUT ────────────────────────────────────────────────────────
  Widget _buildMobile(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Color(0xFF004D40),
      systemNavigationBarIconBrightness: Brightness.light,
    ));
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFF004D40),
      body: SizedBox.expand(
        child: Container(
          decoration: const BoxDecoration(gradient: heroGradient),
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(24, MediaQuery.of(context).padding.top + 24, 24, 48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Logo & Title ─────────────────────────────────────────
                Center(
                  child: Column(children: [
                    Container(
                      width: 70, height: 70,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.35), width: 2),
                      ),
                      child: const Icon(Icons.health_and_safety_rounded,
                          color: Colors.white, size: 38),
                    ),
                    const SizedBox(height: 14),
                    const Text('Health Prediction',
                      style: TextStyle(color: Colors.white, fontSize: 24,
                          fontWeight: FontWeight.bold, letterSpacing: -0.3)),
                    const SizedBox(height: 4),
                    Text('Chronic Disease Risk Prediction System',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 12)),
                  ]),
                ),
                const SizedBox(height: 28),

                // ── White Card ───────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 36),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(
                        color: Colors.black.withValues(alpha: 0.18),
                        blurRadius: 30, offset: const Offset(0, 10))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Toggle
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(children: [
                          Expanded(child: GestureDetector(
                            onTap: () => setState(() {
                              _isLogin = true;
                              _error = null;
                            }),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              decoration: BoxDecoration(
                                color: _isLogin ? primaryColor : Colors.transparent,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Text('Login',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: _isLogin
                                      ? Colors.white : Colors.grey.shade500)),
                            ),
                          )),
                          Expanded(child: GestureDetector(
                            onTap: () => setState(() {
                              _isLogin = false;
                              _error = null;
                            }),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              decoration: BoxDecoration(
                                color: !_isLogin ? primaryColor : Colors.transparent,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Text('Register',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: !_isLogin
                                      ? Colors.white : Colors.grey.shade500)),
                            ),
                          )),
                        ]),
                      ),
                      const SizedBox(height: 22),

                      // Name (register only)
                      if (!_isLogin) ...[
                        _field(
                          controller: _nameCtrl,
                          label: 'Full Name',
                          icon: Icons.person_outline_rounded,
                        ),
                        const SizedBox(height: 14),
                      ],

                      // Email
                      _field(
                        controller: _emailCtrl,
                        label: 'Email',
                        icon: Icons.email_outlined,
                        keyboard: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 14),

                      // Phone (register only)
                      if (!_isLogin) ...[
                        _field(
                          controller: _phoneCtrl,
                          label: 'Phone (optional)',
                          icon: Icons.phone_outlined,
                          keyboard: TextInputType.phone,
                        ),
                        const SizedBox(height: 14),
                      ],

                      // Password
                      TextField(
                        controller: _passCtrl,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _submit(),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock_outline_rounded,
                              color: Colors.grey.shade500, size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: Colors.grey.shade500, size: 20),
                            onPressed: () => setState(() =>
                                _obscurePassword = !_obscurePassword),
                          ),
                        ),
                      ),

                      // Error
                      if (_error != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: dangerColor.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: dangerColor.withValues(alpha: 0.2)),
                          ),
                          child: Row(children: [
                            const Icon(Icons.error_outline,
                                color: dangerColor, size: 16),
                            const SizedBox(width: 8),
                            Expanded(child: Text(_error!,
                              style: const TextStyle(
                                  color: dangerColor, fontSize: 12))),
                          ]),
                        ),
                      ],

                      const SizedBox(height: 22),

                      // Submit Button
                      ElevatedButton(
                        onPressed: _loading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: _loading
                          ? const SizedBox(width: 22, height: 22,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2.5, color: Colors.white))
                          : Text(
                              _isLogin ? 'Login' : 'Create Account',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(height: 4),
                    ],
                  ),
                ),

                // ── Guest Button ─────────────────────────────────────────
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => const HomeScreen())),
                  child: Text('Continue as Guest',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 14,
                        fontWeight: FontWeight.w500)),
                ),
              ],
            ),
        ),
      ),
      ),
    );
  }

  // ─── WEB LAYOUT (unchanged) ───────────────────────────────────────────────
  Widget _buildWeb(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: heroGradient),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3), width: 2),
                    ),
                    child: const Icon(Icons.health_and_safety_rounded,
                        color: Colors.white, size: 44),
                  ),
                  const SizedBox(height: 20),
                  const Text('Health Prediction',
                    style: TextStyle(color: Colors.white, fontSize: 26,
                        fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text('Chronic Disease Risk Prediction System',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 13)),
                  const SizedBox(height: 36),

                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 30, offset: const Offset(0, 10))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(children: [
                            Expanded(child: GestureDetector(
                              onTap: () => setState(() => _isLogin = true),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: _isLogin ? primaryColor : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text('Login', textAlign: TextAlign.center,
                                  style: TextStyle(fontWeight: FontWeight.w600,
                                    color: _isLogin
                                        ? Colors.white : Colors.grey.shade600)),
                              ),
                            )),
                            Expanded(child: GestureDetector(
                              onTap: () => setState(() => _isLogin = false),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: !_isLogin ? primaryColor : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text('Register', textAlign: TextAlign.center,
                                  style: TextStyle(fontWeight: FontWeight.w600,
                                    color: !_isLogin
                                        ? Colors.white : Colors.grey.shade600)),
                              ),
                            )),
                          ]),
                        ),
                        const SizedBox(height: 24),

                        if (!_isLogin) ...[
                          _field(controller: _nameCtrl, label: 'Full Name',
                              icon: Icons.person_outline),
                          const SizedBox(height: 16),
                        ],

                        _field(controller: _emailCtrl, label: 'Email',
                            icon: Icons.email_outlined,
                            keyboard: TextInputType.emailAddress),
                        const SizedBox(height: 16),

                        if (!_isLogin) ...[
                          _field(controller: _phoneCtrl, label: 'Phone (optional)',
                              icon: Icons.phone_outlined,
                              keyboard: TextInputType.phone),
                          const SizedBox(height: 16),
                        ],

                        TextField(
                          controller: _passCtrl,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock_outline,
                                color: Colors.grey.shade500),
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword
                                  ? Icons.visibility_off : Icons.visibility,
                                  color: Colors.grey.shade500),
                              onPressed: () => setState(() =>
                                  _obscurePassword = !_obscurePassword),
                            ),
                          ),
                        ),

                        if (_error != null) ...[
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: dangerColor.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(children: [
                              const Icon(Icons.error_outline,
                                  color: dangerColor, size: 18),
                              const SizedBox(width: 8),
                              Expanded(child: Text(_error!,
                                style: const TextStyle(
                                    color: dangerColor, fontSize: 13))),
                            ]),
                          ),
                        ],

                        const SizedBox(height: 24),

                        SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _submit,
                            child: _loading
                              ? const SizedBox(width: 22, height: 22,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2.5, color: Colors.white))
                              : Text(_isLogin ? 'Login' : 'Create Account',
                                  style: const TextStyle(fontSize: 16)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (_) => const HomeScreen())),
                    child: const Text('Continue as Guest',
                      style: TextStyle(color: Colors.white70, fontSize: 14)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Reusable field ────────────────────────────────────────────────────────
  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey.shade500, size: 20),
      ),
    );
  }
}
