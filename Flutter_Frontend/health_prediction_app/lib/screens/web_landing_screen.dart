import 'package:flutter/material.dart';
import '../core/constants.dart';
import 'user_login_screen.dart';
import 'admin_login_screen.dart';

class WebLandingScreen extends StatelessWidget {
  const WebLandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: heroGradient),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 860),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo + title
                  Container(
                    width: 90, height: 90,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.35), width: 2),
                    ),
                    child: const Icon(Icons.health_and_safety_rounded,
                        color: Colors.white, size: 50),
                  ),
                  const SizedBox(height: 20),
                  const Text('Chronic Disease Risk Prediction System',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 28,
                        fontWeight: FontWeight.bold, letterSpacing: -0.3)),
                  const SizedBox(height: 8),
                  Text('AI-powered early detection for kidney disease & diabetes',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.65), fontSize: 14)),
                  const SizedBox(height: 52),

                  // Two cards side by side
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User card
                      Expanded(
                        child: _PortalCard(
                          icon: Icons.person_rounded,
                          title: 'User Portal',
                          subtitle: 'Register or login to take kidney\nand diabetes risk assessments',
                          buttonLabel: 'Enter as User',
                          buttonIcon: Icons.login_rounded,
                          accentColor: const Color(0xFF10B981),
                          features: const [
                            'Kidney risk assessment',
                            'Diabetes risk assessment',
                            'Instant AI-powered results',
                            'Personalized health guidance',
                          ],
                          onTap: () => Navigator.push(context,
                            MaterialPageRoute(
                                builder: (_) => const UserLoginScreen())),
                        ),
                      ),
                      const SizedBox(width: 24),
                      // Admin card
                      Expanded(
                        child: _PortalCard(
                          icon: Icons.admin_panel_settings_rounded,
                          title: 'Admin Portal',
                          subtitle: 'Access the dashboard to manage\nusers and prediction history',
                          buttonLabel: 'Enter as Admin',
                          buttonIcon: Icons.dashboard_rounded,
                          accentColor: const Color(0xFF6366F1),
                          features: const [
                            'View all predictions',
                            'User management',
                            'Risk distribution stats',
                            'Delete records',
                          ],
                          onTap: () => Navigator.push(context,
                            MaterialPageRoute(
                                builder: (_) => const AdminLoginScreen())),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Text('© 2026 HealthAI — For screening purposes only',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.35), fontSize: 12)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PortalCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final IconData buttonIcon;
  final Color accentColor;
  final List<String> features;
  final VoidCallback onTap;

  const _PortalCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.buttonIcon,
    required this.accentColor,
    required this.features,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 30, offset: const Offset(0, 12))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon badge
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: accentColor, size: 30),
          ),
          const SizedBox(height: 18),
          Text(title, style: const TextStyle(fontSize: 20,
              fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          const SizedBox(height: 8),
          Text(subtitle, style: TextStyle(fontSize: 13,
              color: Colors.grey.shade600, height: 1.5)),
          const SizedBox(height: 22),
          // Feature list
          ...features.map((f) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(children: [
              Container(width: 20, height: 20,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_rounded, size: 13, color: accentColor)),
              const SizedBox(width: 10),
              Text(f, style: TextStyle(fontSize: 13,
                  color: Colors.grey.shade700)),
            ]),
          )),
          const SizedBox(height: 24),
          // Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: onTap,
              icon: Icon(buttonIcon, size: 18),
              label: Text(buttonLabel),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
                textStyle: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
