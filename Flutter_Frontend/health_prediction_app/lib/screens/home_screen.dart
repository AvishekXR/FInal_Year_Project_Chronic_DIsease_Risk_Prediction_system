import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../core/app_provider.dart';
import '../core/constants.dart';
import 'kidney_form_screen.dart';
import 'diabetes_form_screen.dart';
import 'admin_login_screen.dart';
import 'user_login_screen.dart';
import '../services/user_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _floatCtrl;
  late Animation<double> _floatAnim;
  late AnimationController _pulse1Ctrl;
  late Animation<double> _pulse1Scale, _pulse1Opacity;
  late AnimationController _pulse2Ctrl;
  late Animation<double> _pulse2Scale, _pulse2Opacity;

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2200))
      ..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: -8, end: 8).animate(
        CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));

    _pulse1Ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat();
    _pulse1Scale = Tween<double>(begin: 1.0, end: 2.8).animate(
        CurvedAnimation(parent: _pulse1Ctrl, curve: Curves.easeOut));
    _pulse1Opacity = Tween<double>(begin: 0.75, end: 0.0).animate(
        CurvedAnimation(parent: _pulse1Ctrl, curve: Curves.easeOut));

    _pulse2Ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat();
    _pulse2Scale = Tween<double>(begin: 1.0, end: 2.8).animate(
        CurvedAnimation(parent: _pulse2Ctrl, curve: Curves.easeOut));
    _pulse2Opacity = Tween<double>(begin: 0.75, end: 0.0).animate(
        CurvedAnimation(parent: _pulse2Ctrl, curve: Curves.easeOut));
    _pulse2Ctrl.forward(from: 0.5);
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    _pulse1Ctrl.dispose();
    _pulse2Ctrl.dispose();
    super.dispose();
  }

  void _showLanguagePicker(BuildContext context, AppProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(24)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4))),
          const SizedBox(height: 20),
          Text('Select Language / भाषा छान्नुहोस्',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700)),
          const SizedBox(height: 16),
          _langOption(context, provider, 'en', 'English', '🇬🇧'),
          _langOption(context, provider, 'np', 'नेपाली', '🇳🇵'),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }

  Widget _langOption(BuildContext context, AppProvider provider,
      String code, String label, String flag) {
    final isActive = provider.language == code;
    return GestureDetector(
      onTap: () { provider.setLanguage(code); Navigator.pop(context); },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isActive ? primaryColor.withValues(alpha: 0.08) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: isActive ? primaryColor : Colors.grey.shade200,
              width: isActive ? 1.5 : 1),
        ),
        child: Row(children: [
          Text(flag, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 16),
          Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,
              color: isActive ? primaryColor : Colors.grey.shade700)),
          const Spacer(),
          if (isActive)
            const Icon(Icons.check_circle_rounded, color: primaryColor, size: 22),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;

    // Web = Chrome browser; mobile = physical phone
    if (kIsWeb) {
      return _buildWebLayout(context, provider, screenWidth);
    } else {
      return _buildMobileLayout(context, provider);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // WEB LAYOUT — original, unchanged, exactly as before
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildWebLayout(BuildContext context, AppProvider provider, double screenWidth) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 44,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(gradient: heroGradient),
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(children: [
                          const Icon(Icons.health_and_safety_rounded,
                              color: Colors.white54, size: 18),
                          const SizedBox(width: 6),
                          Text(provider.getText('HealthAI', 'स्वास्थ्यAI'),
                              style: const TextStyle(color: Colors.white70,
                                  fontSize: 13, fontWeight: FontWeight.w600)),
                        ]),
                        Row(children: [
                          if (UserService.isLoggedIn)
                            GestureDetector(
                              onTap: () {
                                UserService.logout();
                                Navigator.pushReplacement(context,
                                  MaterialPageRoute(builder: (_) => const UserLoginScreen()));
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                                ),
                                child: const Icon(Icons.logout_rounded,
                                    color: Colors.white, size: 18),
                              ),
                            ),
                          if (UserService.isLoggedIn) const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const AdminLoginScreen())),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                              ),
                              child: const Icon(Icons.admin_panel_settings_rounded,
                                  color: Colors.white, size: 18),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => _showLanguagePicker(context, provider),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                              ),
                              child: Row(mainAxisSize: MainAxisSize.min, children: [
                                const Icon(Icons.language_rounded, color: Colors.white, size: 18),
                                const SizedBox(width: 5),
                                Text(provider.language == 'en' ? 'EN' : 'ने',
                                    style: const TextStyle(color: Colors.white,
                                        fontSize: 12, fontWeight: FontWeight.bold)),
                              ]),
                            ),
                          ),
                        ]),
                      ],
                    ),
                    const Spacer(),
                    Center(
                      child: AnimatedBuilder(
                        animation: Listenable.merge(
                            [_floatCtrl, _pulse1Ctrl, _pulse2Ctrl]),
                        builder: (_, __) {
                          const box = 80.0;
                          return Transform.translate(
                            offset: Offset(0, _floatAnim.value),
                            child: SizedBox(
                              width: box,
                              height: box,
                              child: OverflowBox(
                                maxWidth: box * 3.5,
                                maxHeight: box * 3.5,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Transform.scale(scale: _pulse1Scale.value,
                                      child: Opacity(opacity: _pulse1Opacity.value,
                                        child: Container(width: box, height: box,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: Colors.white, width: 2.5))))),
                                    Transform.scale(scale: _pulse2Scale.value,
                                      child: Opacity(opacity: _pulse2Opacity.value,
                                        child: Container(width: box, height: box,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: Colors.white, width: 2.5))))),
                                    Container(
                                      width: box, height: box,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(22),
                                        border: Border.all(
                                            color: Colors.white.withValues(alpha: 0.5),
                                            width: 2),
                                        boxShadow: [
                                          BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.2),
                                              blurRadius: 20,
                                              offset: const Offset(0, 8)),
                                          BoxShadow(
                                              color: Colors.white.withValues(alpha: 0.15),
                                              blurRadius: 12, spreadRadius: 2),
                                        ],
                                      ),
                                      child: const Icon(Icons.health_and_safety_rounded,
                                          color: Colors.white, size: 44),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          provider.getText('Chronic Disease Risk Prediction System',
                              'दीर्घरोग जोखिम पूर्वानुमान प्रणाली'),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          style: const TextStyle(color: Colors.white, fontSize: 22,
                              fontWeight: FontWeight.bold, letterSpacing: -0.3),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: Text(
                        provider.getText('AI-powered early disease detection',
                            'एआई-आधारित प्रारम्भिक रोग पहिचान'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white54, fontSize: 13),
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 56,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(36),
                    topRight: Radius.circular(36),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 28, 22, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                        Container(width: 4, height: 20,
                            decoration: BoxDecoration(color: primaryColor,
                                borderRadius: BorderRadius.circular(4))),
                        const SizedBox(width: 10),
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(provider.getText('Choose Assessment', 'जाँच छान्नुहोस्'),
                              style: TextStyle(fontSize: screenWidth < 600 ? 17 : 19,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade800)),
                          Text(provider.getText('Select a health check to begin',
                              'सुरु गर्न स्वास्थ्य जाँच छान्नुहोस्'),
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                        ]),
                      ]),
                      const SizedBox(height: 18),
                      Expanded(
                        child: _buildWebCard(
                          context: context,
                          title: provider.getText('Kidney Health Check', 'मिर्गौला स्वास्थ्य जाँच'),
                          subtitle: provider.getText('Assess your risk of kidney disease',
                              'मिर्गौला रोगको जोखिम मूल्यांकन'),
                          tag: provider.getText('17 questions', '१७ प्रश्न'),
                          icon: Icons.water_drop_rounded,
                          gradient: kidneyGradient,
                          onTap: () => Navigator.push(context, MaterialPageRoute(
                              builder: (_) => const KidneyFormScreen())),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: _buildWebCard(
                          context: context,
                          title: provider.getText('Diabetes Risk Check', 'मधुमेह جوخيم جانچ'),
                          subtitle: provider.getText('Assess your risk of diabetes',
                              'मधुमेहको जोखिम मूल्यांकन'),
                          tag: provider.getText('16 questions', '१६ प्रश्न'),
                          icon: Icons.bloodtype_rounded,
                          gradient: diabetesGradient,
                          onTap: () => Navigator.push(context, MaterialPageRoute(
                              builder: (_) => const DiabetesFormScreen())),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFDE7),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFFE082)),
                        ),
                        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Icon(Icons.info_outline_rounded,
                              color: Color(0xFFF57F17), size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              provider.getText(
                                'For screening only. Always consult a doctor.',
                                'केवल जाँचको लागि। योग्य डाक्टरसँग परामर्श गर्नुहोस्।'),
                              style: const TextStyle(fontSize: 11,
                                  color: Color(0xFFE65100), height: 1.4),
                            ),
                          ),
                        ]),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String tag,
    required IconData icon,
    required LinearGradient gradient,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18, offset: const Offset(0, 4))],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(children: [
              Container(width: 64, height: 64,
                decoration: BoxDecoration(gradient: gradient,
                    borderRadius: BorderRadius.circular(18)),
                child: Icon(icon, color: Colors.white, size: 32)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(title, style: TextStyle(fontSize: 15,
                        fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: TextStyle(fontSize: 12,
                        color: Colors.grey.shade500)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(color: backgroundColor,
                          borderRadius: BorderRadius.circular(20)),
                      child: Text(tag, style: TextStyle(fontSize: 11,
                          color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(width: 34, height: 34,
                decoration: BoxDecoration(color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.arrow_forward_ios_rounded,
                    size: 14, color: Colors.grey.shade500)),
            ]),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // MOBILE LAYOUT — responsive, animated, fits on one screen
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildMobileLayout(BuildContext context, AppProvider provider) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
      child: Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final totalH = constraints.maxHeight;
            final heroH  = totalH * 0.43;
            final bottomH = totalH * 0.57;
            return Column(
              children: [
                // ── Hero ──────────────────────────────────────────────────
                SizedBox(
                  height: heroH,
                  width: double.infinity,
                  child: Stack(
                    children: [
                      Container(decoration: const BoxDecoration(gradient: heroGradient)),
                      Positioned(right: -50, top: -50,
                        child: Container(width: 220, height: 220,
                          decoration: BoxDecoration(shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.08)))),
                      Positioned(left: -40, bottom: -20,
                        child: Container(width: 150, height: 150,
                          decoration: BoxDecoration(shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.06)))),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(children: [
                                  const Icon(Icons.health_and_safety_rounded,
                                      color: Colors.white54, size: 16),
                                  const SizedBox(width: 5),
                                  Text(provider.getText('HealthAI', 'स्वास्थ्यAI'),
                                      style: const TextStyle(color: Colors.white70,
                                          fontSize: 13, fontWeight: FontWeight.w600)),
                                ]),
                                Row(children: [
                                  if (UserService.isLoggedIn)
                                    GestureDetector(
                                      onTap: () {
                                        UserService.logout();
                                        Navigator.pushReplacement(context,
                                          MaterialPageRoute(builder: (_) => const UserLoginScreen()));
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                              color: Colors.white.withValues(alpha: 0.3)),
                                        ),
                                        child: const Icon(Icons.logout_rounded,
                                            color: Colors.white, size: 15),
                                      ),
                                    ),
                                  if (UserService.isLoggedIn) const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () => _showLanguagePicker(context, provider),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                            color: Colors.white.withValues(alpha: 0.3)),
                                      ),
                                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                                        const Icon(Icons.language_rounded,
                                            color: Colors.white, size: 15),
                                        const SizedBox(width: 4),
                                        Text(provider.language == 'en' ? 'EN' : 'ने',
                                            style: const TextStyle(color: Colors.white,
                                                fontSize: 12, fontWeight: FontWeight.bold)),
                                      ]),
                                    ),
                                  ),
                                ]),
                              ],
                            ),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  AnimatedBuilder(
                                    animation: Listenable.merge(
                                        [_floatCtrl, _pulse1Ctrl, _pulse2Ctrl]),
                                    builder: (_, __) {
                                      const box = 64.0;
                                      return Transform.translate(
                                        offset: Offset(0, _floatAnim.value),
                                        child: SizedBox(
                                          width: box, height: box,
                                          child: OverflowBox(
                                            maxWidth: box * 3.5,
                                            maxHeight: box * 3.5,
                                            child: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                Transform.scale(scale: _pulse1Scale.value,
                                                  child: Opacity(opacity: _pulse1Opacity.value,
                                                    child: Container(width: box, height: box,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        border: Border.all(color: Colors.white, width: 2.5))))),
                                                Transform.scale(scale: _pulse2Scale.value,
                                                  child: Opacity(opacity: _pulse2Opacity.value,
                                                    child: Container(width: box, height: box,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        border: Border.all(color: Colors.white, width: 2.5))))),
                                                Container(
                                                  width: box, height: box,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white.withValues(alpha: 0.2),
                                                    borderRadius: BorderRadius.circular(20),
                                                    border: Border.all(
                                                        color: Colors.white.withValues(alpha: 0.5), width: 2),
                                                    boxShadow: [
                                                      BoxShadow(color: Colors.black.withValues(alpha: 0.2),
                                                          blurRadius: 20, offset: const Offset(0, 8)),
                                                      BoxShadow(color: Colors.white.withValues(alpha: 0.15),
                                                          blurRadius: 12, spreadRadius: 2),
                                                    ],
                                                  ),
                                                  child: const Icon(Icons.health_and_safety_rounded,
                                                      color: Colors.white, size: 34),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 10),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        provider.getText(
                                          'Chronic Disease Risk Prediction System',
                                          'दीर्घरोग जोखिम पूर्वानुमान प्रणाली'),
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(color: Colors.white,
                                            fontSize: 20, fontWeight: FontWeight.bold,
                                            letterSpacing: -0.3),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    provider.getText('AI-powered early disease detection',
                                        'एआई-आधारित प्रारम्भिक रोग पहिचान'),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: Colors.white60, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Bottom ─────────────────────────────────────────────────
                SizedBox(
                  height: bottomH,
                  width: double.infinity,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(28),
                        topRight: Radius.circular(28),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Container(width: 4, height: 20,
                                decoration: BoxDecoration(color: primaryColor,
                                    borderRadius: BorderRadius.circular(4))),
                            const SizedBox(width: 10),
                            Column(crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(provider.getText('Choose Assessment', 'जाँच छान्नुहोस्'),
                                    style: const TextStyle(fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2D3748))),
                                Text(provider.getText('Select a health check to begin',
                                    'सुरु गर्न स्वास्थ्य जाँच छान्नुहोस्'),
                                    style: TextStyle(fontSize: 12,
                                        color: Colors.grey.shade500)),
                              ]),
                          ]),
                          const SizedBox(height: 10),
                          _buildMobileCard(
                            title: provider.getText('Kidney Health Check', 'मिर्गौला स्वास्थ्य जाँच'),
                            subtitle: provider.getText('Assess your risk of kidney disease',
                                'मिर्गौला रोगको जोखिम मूल्यांकन'),
                            tag: provider.getText('17 questions', '१७ प्रश्न'),
                            icon: Icons.water_drop_rounded,
                            gradient: kidneyGradient,
                            accentColor: secondaryColor,
                            onTap: () => Navigator.push(context, MaterialPageRoute(
                                builder: (_) => const KidneyFormScreen())),
                          ),
                          const SizedBox(height: 8),
                          _buildMobileCard(
                            title: provider.getText('Diabetes Risk Check', 'मधुमेह जोखिम जाँच'),
                            subtitle: provider.getText('Assess your risk of diabetes disease',
                                'मधुमेहको जोखिम मूल्यांकन गर्नुहोस्'),
                            tag: provider.getText('16 questions', '१६ प्रश्न'),
                            icon: Icons.bloodtype_rounded,
                            gradient: diabetesGradient,
                            accentColor: warningColor,
                            onTap: () => Navigator.push(context, MaterialPageRoute(
                                builder: (_) => const DiabetesFormScreen())),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFDE7),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFFFFE082)),
                            ),
                            child: Row(children: [
                              const Icon(Icons.info_outline_rounded,
                                  color: Color(0xFFF57F17), size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  provider.getText(
                                    'For screening only. Always consult a doctor.',
                                    'केवल जाँचको लागि। योग्य डाक्टरसँग परामर्श गर्नुहोस्।'),
                                  style: const TextStyle(fontSize: 12,
                                      color: Color(0xFFE65100), height: 1.4),
                                ),
                              ),
                            ]),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    ),
  );
  }

  Widget _buildMobileCard({
    required String title,
    required String subtitle,
    required String tag,
    required IconData icon,
    required LinearGradient gradient,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 14, offset: const Offset(0, 4))],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          splashColor: accentColor.withValues(alpha: 0.08),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              Container(width: 48, height: 48,
                decoration: BoxDecoration(gradient: gradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: accentColor.withValues(alpha: 0.35),
                      blurRadius: 10, offset: const Offset(0, 4))]),
                child: Icon(icon, color: Colors.white, size: 26)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 15,
                        fontWeight: FontWeight.bold, color: Color(0xFF2D3748))),
                    const SizedBox(height: 3),
                    Text(subtitle, style: TextStyle(fontSize: 12,
                        color: Colors.grey.shade500, height: 1.3)),
                    const SizedBox(height: 7),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: accentColor.withValues(alpha: 0.25)),
                      ),
                      child: Text(tag, style: TextStyle(fontSize: 11,
                          color: accentColor, fontWeight: FontWeight.w600)),
                    ),
                  ]),
              ),
              const SizedBox(width: 6),
              Container(width: 30, height: 30,
                decoration: BoxDecoration(color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(9)),
                child: Icon(Icons.arrow_forward_ios_rounded,
                    size: 12, color: Colors.grey.shade500)),
            ]),
          ),
        ),
      ),
    );
  }
}
