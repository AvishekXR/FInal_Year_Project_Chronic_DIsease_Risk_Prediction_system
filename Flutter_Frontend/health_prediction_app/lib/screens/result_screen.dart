import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../core/app_provider.dart';
import '../core/constants.dart';

class ResultScreen extends StatelessWidget {
  final String title;
  final String riskLevel;
  final String probability;
  final List<String> guidance;
  final Map<String, String>? extra;

  // ignored — kept so existing callers don't break
  final bool probabilityDriven;

  const ResultScreen({
    super.key,
    required this.title,
    required this.riskLevel,
    required this.probability,
    required this.guidance,
    this.extra,
    this.probabilityDriven = false,
  });

  double _parsePercent(String prob) {
    final clean = prob.replaceAll('%', '').trim();
    final val = double.tryParse(clean) ?? 0;
    return (val > 1 ? val / 100 : val).clamp(0.0, 1.0);
  }

  Color _getRiskColor(String level) {
    switch (level.toLowerCase()) {
      case 'low':    return lowRiskColor;
      case 'medium': return warningColor;
      case 'high':   return dangerColor;
      default:       return primaryColor;
    }
  }

  LinearGradient _getRiskGradient(String level) {
    switch (level.toLowerCase()) {
      case 'low':    return lowRiskGradient;
      case 'medium': return mediumRiskGradient;
      case 'high':   return highRiskGradient;
      default:       return heroGradient;
    }
  }

  IconData _getRiskIcon(String level) {
    switch (level.toLowerCase()) {
      case 'low':    return Icons.verified_rounded;
      case 'medium': return Icons.warning_rounded;
      case 'high':   return Icons.dangerous_rounded;
      default:       return Icons.health_and_safety_rounded;
    }
  }

  String _getTranslatedRiskLevel(String level, AppProvider provider) {
    switch (level.toLowerCase()) {
      case 'low':    return provider.getText('LOW', 'निम्न');
      case 'medium': return provider.getText('MEDIUM', 'मध्यम');
      case 'high':   return provider.getText('HIGH', 'उच्च');
      default:       return level.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider   = Provider.of<AppProvider>(context);
    final color      = _getRiskColor(riskLevel);
    final gradient   = _getRiskGradient(riskLevel);
    final percent    = _parsePercent(probability);
    final translated = _getTranslatedRiskLevel(riskLevel, provider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile   = !kIsWeb || screenWidth < 600;
    final maxWidth   = isMobile ? double.infinity : 560.0;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: gradient),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 20.0 : 28.0),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Risk Banner ────────────────────────────────────────
                Container(
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.35),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 36, horizontal: 24),
                    child: Column(
                      children: [
                        // Circular progress
                        // Kidney LOW: backend returns confidence (95%) →
                        // invert to show actual disease risk (5%)
                        CircularPercentIndicator(
                          radius: isMobile ? 72.0 : 88.0,
                          lineWidth: 11.0,
                          percent: (!probabilityDriven && riskLevel.toLowerCase() == 'low')
                              ? (1.0 - percent)
                              : percent,
                          backgroundColor: Colors.white.withValues(alpha: 0.25),
                          progressColor: Colors.white,
                          circularStrokeCap: CircularStrokeCap.round,
                          center: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${((!probabilityDriven && riskLevel.toLowerCase() == "low") ? (1.0 - percent) : percent) * 100 ~/ 1}%',
                                style: TextStyle(
                                  fontSize: isMobile ? 26 : 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                provider.getText('Risk', 'जोखिम'),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        Icon(_getRiskIcon(riskLevel),
                            color: Colors.white, size: 32),
                        const SizedBox(height: 8),

                        Text(
                          provider.getText(
                              'Your Risk Level', 'तपाईंको जोखिम स्तर'),
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(height: 4),

                        Text(
                          translated,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isMobile ? 34 : 40,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),

                        if (extra != null && extra!.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 10,
                            children: extra!.entries.map((e) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 7),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color:
                                          Colors.white.withValues(alpha: 0.3)),
                                ),
                                child: Text(
                                  '${e.key}: ${e.value}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // ── Guidance Header ────────────────────────────────────
                Row(children: [
                  Container(
                    width: 4, height: 24,
                    decoration: BoxDecoration(
                        color: color, borderRadius: BorderRadius.circular(4)),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    provider.getText(
                        'Personalized Guidance', 'व्यक्तिगत सुझावहरू'),
                    style: TextStyle(
                      fontSize: isMobile ? 18 : 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ]),
                const SizedBox(height: 16),

                // ── Guidance Items ─────────────────────────────────────
                ...guidance.asMap().entries.map((entry) {
                  final idx  = entry.key;
                  final item = entry.value;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 32, height: 32,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text('${idx + 1}',
                                  style: TextStyle(
                                      color: color,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(item,
                                style: TextStyle(
                                    fontSize: isMobile ? 14 : 15,
                                    color: Colors.grey.shade700,
                                    height: 1.55)),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 16),

                // ── Disclaimer ─────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFDE7),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFFFE082)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          color: Color(0xFFF57F17), size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          provider.getText(
                            'This is an AI-based screening tool. Please consult a qualified doctor for a proper diagnosis.',
                            'यो एआई-आधारित जाँच उपकरण हो। उचित निदानको लागि योग्य डाक्टरसँग परामर्श गर्नुहोस्।',
                          ),
                          style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFFE65100),
                              height: 1.5),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
