import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../core/app_provider.dart';
import '../core/constants.dart';
import '../services/api_service.dart';
import '../models/diabetes_input.dart';
import '../widgets/loading_indicator.dart';
import '../services/user_service.dart';
import 'result_screen.dart';

class DiabetesFormScreen extends StatefulWidget {
  const DiabetesFormScreen({super.key});

  @override
  State<DiabetesFormScreen> createState() => _DiabetesFormScreenState();
}

class _DiabetesFormScreenState extends State<DiabetesFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  int age = 30;
  int gender = 1;
  int polyuria = 0;
  int polydipsia = 0;
  int weightLoss = 0;
  int weakness = 0;
  int polyphagia = 0;
  int genitalThrush = 0;
  int visualBlurring = 0;
  int itching = 0;
  int irritability = 0;
  int delayedHealing = 0;
  int partialParesis = 0;
  int muscleStiffness = 0;
  int alopecia = 0;
  int obesity = 0;

  // ─── VALIDATOR ─────────────────────────────────────────────────────────────
  String? _validateAge(String? v) {
    if (v == null || v.isEmpty) return 'Age is required';
    final n = int.tryParse(v);
    if (n == null) return 'Please enter a valid number';
    if (n < 20 || n > 90) return 'Age must be between 20 and 90 years';
    return null;
  }

  // ─── PREDICT ───────────────────────────────────────────────────────────────
  Future<void> _predict() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final provider = Provider.of<AppProvider>(context, listen: false);

      final data = DiabetesInput(
        userId: UserService.userId,
        age: age,
        gender: gender,
        polyuria: polyuria,
        polydipsia: polydipsia,
        weightLoss: weightLoss,
        weakness: weakness,
        polyphagia: polyphagia,
        genitalThrush: genitalThrush,
        visualBlurring: visualBlurring,
        itching: itching,
        irritability: irritability,
        delayedHealing: delayedHealing,
        partialParesis: partialParesis,
        muscleStiffness: muscleStiffness,
        alopecia: alopecia,
        obesity: obesity,
        language: provider.language,
      ).toJson();

      final result = await ApiService.predictDiabetes(data);

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            title: provider.getText(
              'Diabetes Risk Result',
              'मधुमेह जोखिम परिणाम',
            ),
            riskLevel: result['risk_level'],
            probability: result['probability'],
            guidance: List<String>.from(result['guidance']),
            probabilityDriven: true,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ─── UI HELPERS ────────────────────────────────────────────────────────────

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSymptomTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: value
            ? primaryColor.withValues(alpha: 0.06)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value
              ? primaryColor.withValues(alpha: 0.35)
              : Colors.grey.shade200,
          width: 1.5,
        ),
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade800,
            fontWeight: value ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: primaryColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        dense: true,
      ),
    );
  }

  Widget _buildPredictButton(AppProvider provider) {
    return Container(
      width: double.infinity,
      height: 58,
      decoration: BoxDecoration(
        gradient: heroGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.4),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: _predict,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.analytics_rounded,
                    color: Colors.white, size: 22),
                const SizedBox(width: 10),
                Text(
                  provider.getText(
                    'Analyze My Health',
                    'मेरो स्वास्थ्य विश्लेषण',
                  ),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── BUILD ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = !kIsWeb || screenWidth < 600;
    final maxWidth = isMobile ? double.infinity : 560.0;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          provider.getText(
            'Diabetes Risk Assessment',
            'मधुमेह जोखिम मूल्यांकन',
          ),
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: diabetesGradient),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const LoadingIndicator()
          : SingleChildScrollView(
              padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Section 1: Basic Information ──────────────
                        _buildSectionCard(
                          icon: Icons.person_rounded,
                          title: provider.getText(
                            'Basic Information',
                            'आधारभूत जानकारी',
                          ),
                          color: secondaryColor,
                          children: [
                            TextFormField(
                              initialValue: age.toString(),
                              decoration: InputDecoration(
                                labelText: provider.getText(
                                  'Age (years)',
                                  'उमेर (वर्ष)',
                                ),
                                hintText: '20 – 90',
                                helperText: provider.getText(
                                  'Enter age between 20 and 90',
                                  'उमेर २० देखि ९० बीचमा प्रविष्ट गर्नुहोस्',
                                ),
                                prefixIcon: const Icon(Icons.cake_rounded,
                                    color: secondaryColor),
                              ),
                              keyboardType: TextInputType.number,
                              validator: _validateAge,
                              onChanged: (v) => age = int.tryParse(v) ?? 30,
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<int>(
                              value: gender,
                              decoration: InputDecoration(
                                labelText: provider.getText(
                                  'Your Gender',
                                  'तपाईंको लिङ्ग',
                                ),
                                prefixIcon: const Icon(Icons.wc_rounded,
                                    color: secondaryColor),
                              ),
                              items: [
                                DropdownMenuItem(
                                  value: 0,
                                  child: Text(
                                    provider.getText('Female', 'महिला'),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 1,
                                  child: Text(
                                    provider.getText('Male', 'पुरुष'),
                                  ),
                                ),
                              ],
                              onChanged: (v) => setState(() => gender = v!),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // ── Section 2: Common Symptoms ─────────────────
                        _buildSectionCard(
                          icon: Icons.medical_information_rounded,
                          title: provider.getText(
                            'Common Symptoms',
                            'सामान्य लक्षणहरू',
                          ),
                          color: const Color(0xFF6A1B9A),
                          children: [
                            _buildSymptomTile(
                              title: provider.getText(
                                'Do you urinate more frequently than usual?',
                                'के तपाईं सामान्य भन्दा धेरै पटक पिसाब गर्नुहुन्छ?',
                              ),
                              value: polyuria == 1,
                              onChanged: (v) =>
                                  setState(() => polyuria = v ? 1 : 0),
                            ),
                            _buildSymptomTile(
                              title: provider.getText(
                                'Do you feel very thirsty often?',
                                'के तपाईंलाई बारम्बार धेरै तिर्खा लाग्छ?',
                              ),
                              value: polydipsia == 1,
                              onChanged: (v) =>
                                  setState(() => polydipsia = v ? 1 : 0),
                            ),
                            _buildSymptomTile(
                              title: provider.getText(
                                'Have you lost weight suddenly without trying?',
                                'के तपाईंले प्रयास नगरीकन अचानक तौल घटाउनुभएको छ?',
                              ),
                              value: weightLoss == 1,
                              onChanged: (v) =>
                                  setState(() => weightLoss = v ? 1 : 0),
                            ),
                            _buildSymptomTile(
                              title: provider.getText(
                                'Do you feel weak or tired most of the time?',
                                'के तपाईंलाई प्रायः कमजोर वा थकित महसुस हुन्छ?',
                              ),
                              value: weakness == 1,
                              onChanged: (v) =>
                                  setState(() => weakness = v ? 1 : 0),
                            ),
                            _buildSymptomTile(
                              title: provider.getText(
                                'Do you feel hungry more often than usual?',
                                'के तपाईंलाई सामान्य भन्दा धेरै भोक लाग्छ?',
                              ),
                              value: polyphagia == 1,
                              onChanged: (v) =>
                                  setState(() => polyphagia = v ? 1 : 0),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // ── Section 3: Other Symptoms ──────────────────
                        _buildSectionCard(
                          icon: Icons.health_and_safety_rounded,
                          title: provider.getText(
                            'Other Symptoms',
                            'अन्य लक्षणहरू',
                          ),
                          color: warningColor,
                          children: [
                            _buildSymptomTile(
                              title: provider.getText(
                                'Have you had genital infections recently?',
                                'के हालै तपाईंलाई जननांग संक्रमण भएको छ?',
                              ),
                              value: genitalThrush == 1,
                              onChanged: (v) =>
                                  setState(() => genitalThrush = v ? 1 : 0),
                            ),
                            _buildSymptomTile(
                              title: provider.getText(
                                'Has your vision been blurry lately?',
                                'के हालै तपाईंको दृष्टि धमिलो भएको छ?',
                              ),
                              value: visualBlurring == 1,
                              onChanged: (v) =>
                                  setState(() => visualBlurring = v ? 1 : 0),
                            ),
                            _buildSymptomTile(
                              title: provider.getText(
                                'Do you have itching on skin?',
                                'के तपाईंको छालामा चिलाउने समस्या छ?',
                              ),
                              value: itching == 1,
                              onChanged: (v) =>
                                  setState(() => itching = v ? 1 : 0),
                            ),
                            _buildSymptomTile(
                              title: provider.getText(
                                'Do you feel irritable or moody often?',
                                'के तपाईं प्रायः चिडचिडे वा मूड परिवर्तन हुन्छ?',
                              ),
                              value: irritability == 1,
                              onChanged: (v) =>
                                  setState(() => irritability = v ? 1 : 0),
                            ),
                            _buildSymptomTile(
                              title: provider.getText(
                                'Do wounds or cuts take longer to heal?',
                                'के घाउ वा काटिएको ठाउँ निको हुन समय लाग्छ?',
                              ),
                              value: delayedHealing == 1,
                              onChanged: (v) =>
                                  setState(() => delayedHealing = v ? 1 : 0),
                            ),
                            _buildSymptomTile(
                              title: provider.getText(
                                'Do you feel partial paralysis or muscle weakness?',
                                'के तपाईंलाई आंशिक पक्षाघात वा मांसपेशी कमजोरी महसुस हुन्छ?',
                              ),
                              value: partialParesis == 1,
                              onChanged: (v) =>
                                  setState(() => partialParesis = v ? 1 : 0),
                            ),
                            _buildSymptomTile(
                              title: provider.getText(
                                'Do you have muscle stiffness?',
                                'के तपाईंको मांसपेशी कडा हुन्छ?',
                              ),
                              value: muscleStiffness == 1,
                              onChanged: (v) =>
                                  setState(() => muscleStiffness = v ? 1 : 0),
                            ),
                            _buildSymptomTile(
                              title: provider.getText(
                                'Have you noticed hair loss?',
                                'के तपाईंले कपाल झर्ने समस्या देख्नुभएको छ?',
                              ),
                              value: alopecia == 1,
                              onChanged: (v) =>
                                  setState(() => alopecia = v ? 1 : 0),
                            ),
                            _buildSymptomTile(
                              title: provider.getText(
                                'Are you obese or overweight?',
                                'के तपाईं मोटोपन वा बढी तौल भएको हुनुहुन्छ?',
                              ),
                              value: obesity == 1,
                              onChanged: (v) =>
                                  setState(() => obesity = v ? 1 : 0),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),

                        // ── Predict Button ─────────────────────────────
                        _buildPredictButton(provider),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
