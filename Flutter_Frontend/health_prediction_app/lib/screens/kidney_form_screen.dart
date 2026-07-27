import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../core/app_provider.dart';
import '../core/constants.dart';
import '../services/api_service.dart';
import '../widgets/loading_indicator.dart';
import '../services/user_service.dart';
import 'result_screen.dart';

class KidneyFormScreen extends StatefulWidget {
  const KidneyFormScreen({super.key});

  @override
  State<KidneyFormScreen> createState() => _KidneyFormScreenState();
}

class _KidneyFormScreenState extends State<KidneyFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  int age = 30;
  int gender = 1;
  double systolicBp = 120;
  double heightCm = 170;
  double weightKg = 70;
  int smoking = 0;
  double alcohol = 0;
  double physicalActivity = 5;
  int diabetes = 0;
  int edema = 0;
  int urineChanges = 0;
  int appetiteChange = 0;
  int familyHistory = 0;
  double? creatinine;
  double? bun;
  double? hemoglobin;
  double? sodium;

  // ─── VALIDATORS ────────────────────────────────────────────────────────────
  String? _validateAge(String? v) {
    if (v == null || v.isEmpty) return 'Age is required';
    final n = int.tryParse(v);
    if (n == null) return 'Please enter a valid number';
    if (n < 20 || n > 90) return 'Age must be between 20 and 90 years';
    return null;
  }

  String? _validateSystolicBp(String? v) {
    if (v == null || v.isEmpty) return 'Blood pressure is required';
    final n = double.tryParse(v);
    if (n == null) return 'Please enter a valid number';
    if (n < 70 || n > 200) return 'Blood pressure must be between 70 and 200 mmHg';
    return null;
  }

  String? _validateHeight(String? v) {
    if (v == null || v.isEmpty) return 'Height is required';
    final n = double.tryParse(v);
    if (n == null) return 'Please enter a valid number';
    if (n < 100 || n > 250) return 'Height must be between 100 and 250 cm';
    return null;
  }

  String? _validateWeight(String? v) {
    if (v == null || v.isEmpty) return 'Weight is required';
    final n = double.tryParse(v);
    if (n == null) return 'Please enter a valid number';
    if (n < 20 || n > 200) return 'Weight must be between 20 and 200 kg';
    return null;
  }

  String? _validateAlcohol(String? v) {
    if (v == null || v.isEmpty) return null;
    final n = double.tryParse(v);
    if (n == null) return 'Please enter a valid number';
    if (n < 0 || n > 50) return 'Alcohol units must be between 0 and 50 per week';
    return null;
  }

  String? _validatePhysicalActivity(String? v) {
    if (v == null || v.isEmpty) return 'Physical activity is required';
    final n = double.tryParse(v);
    if (n == null) return 'Please enter a valid number';
    if (n < 0 || n > 14) return 'Physical activity must be between 0 and 14 hours/day';
    return null;
  }

  String? _validateCreatinine(String? v) {
    if (v == null || v.isEmpty) return null;
    final n = double.tryParse(v);
    if (n == null) return 'Please enter a valid number';
    if (n < 0.1 || n > 20) return 'Creatinine must be between 0.1 and 20 mg/dL';
    return null;
  }

  String? _validateBun(String? v) {
    if (v == null || v.isEmpty) return null;
    final n = double.tryParse(v);
    if (n == null) return 'Please enter a valid number';
    if (n < 1 || n > 150) return 'BUN must be between 1 and 150 mg/dL';
    return null;
  }

  String? _validateHemoglobin(String? v) {
    if (v == null || v.isEmpty) return null;
    final n = double.tryParse(v);
    if (n == null) return 'Please enter a valid number';
    if (n < 3 || n > 20) return 'Hemoglobin must be between 3 and 20 g/dL';
    return null;
  }

  String? _validateSodium(String? v) {
    if (v == null || v.isEmpty) return null;
    final n = double.tryParse(v);
    if (n == null) return 'Please enter a valid number';
    if (n < 100 || n > 170) return 'Sodium must be between 100 and 170 mEq/L';
    return null;
  }

  // ─── PREDICT ───────────────────────────────────────────────────────────────
  Future<void> _predict() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final provider = Provider.of<AppProvider>(context, listen: false);

      final heightInMeters = heightCm / 100;
      final bmi = weightKg / (heightInMeters * heightInMeters);

      final Map<String, dynamic> data = {
        if (UserService.userId != null) 'user_id': UserService.userId,
        'age': age,
        'gender': gender,
        'systolic_bp': systolicBp,
        'height_cm': heightCm,
        'weight_kg': weightKg,
        'smoking': smoking,
        'alcohol_consumption': alcohol,
        'physical_activity': physicalActivity,
        'diabetes': diabetes,
        'edema': edema,
        'urine_changes': urineChanges,
        'appetite_change': appetiteChange,
        'family_history': familyHistory,
        'serum_creatinine': creatinine,
        'bun_levels': bun,
        'hemoglobin_levels': hemoglobin,
        'sodium_levels': sodium,
        'language': provider.language,
      };

      final result = await ApiService.predictKidney(data);

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            title: provider.getText(
              'Kidney Risk Result',
              'मिर्गौला जोखिम परिणाम',
            ),
            riskLevel: result['risk_level'],
            probability: result['probability'],
            guidance: List<String>.from(result['guidance']),
            extra: {'BMI': bmi.toStringAsFixed(2)},
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
            'Kidney Risk Assessment',
            'मिर्गौला जोखिम मूल्यांकन',
          ),
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: kidneyGradient),
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
                                      provider.getText('Female', 'महिला')),
                                ),
                                DropdownMenuItem(
                                  value: 1,
                                  child: Text(
                                      provider.getText('Male', 'पुरुष')),
                                ),
                              ],
                              onChanged: (v) => setState(() => gender = v!),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              initialValue: systolicBp.toString(),
                              decoration: InputDecoration(
                                labelText: provider.getText(
                                  'Systolic Blood Pressure (mmHg)',
                                  'सिस्टोलिक रक्तचाप (mmHg)',
                                ),
                                hintText: '70 – 200',
                                helperText: provider.getText(
                                  'Enter value between 70 and 200',
                                  '७० देखि २०० बीचको मान प्रविष्ट गर्नुहोस्',
                                ),
                                prefixIcon: const Icon(
                                    Icons.monitor_heart_rounded,
                                    color: secondaryColor),
                              ),
                              keyboardType: TextInputType.number,
                              validator: _validateSystolicBp,
                              onChanged: (v) =>
                                  systolicBp = double.tryParse(v) ?? 120,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              initialValue: heightCm.toString(),
                              decoration: InputDecoration(
                                labelText: provider.getText(
                                  'Height (cm)',
                                  'उचाइ (सेन्टिमिटर)',
                                ),
                                hintText: '100 – 250',
                                helperText: provider.getText(
                                  'Enter height between 100 and 250 cm',
                                  'उचाइ १०० देखि २५० सेमी बीचमा प्रविष्ट गर्नुहोस्',
                                ),
                                prefixIcon: const Icon(Icons.height_rounded,
                                    color: secondaryColor),
                              ),
                              keyboardType: TextInputType.number,
                              validator: _validateHeight,
                              onChanged: (v) =>
                                  heightCm = double.tryParse(v) ?? 170,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              initialValue: weightKg.toString(),
                              decoration: InputDecoration(
                                labelText: provider.getText(
                                  'Weight (kg)',
                                  'तौल (किलोग्राम)',
                                ),
                                hintText: '20 – 200',
                                helperText: provider.getText(
                                  'Enter weight between 20 and 200 kg',
                                  'तौल २० देखि २०० किलो बीचमा प्रविष्ट गर्नुहोस्',
                                ),
                                prefixIcon: const Icon(
                                    Icons.monitor_weight_rounded,
                                    color: secondaryColor),
                              ),
                              keyboardType: TextInputType.number,
                              validator: _validateWeight,
                              onChanged: (v) =>
                                  weightKg = double.tryParse(v) ?? 70,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // ── Section 2: Lifestyle & History ─────────────
                        _buildSectionCard(
                          icon: Icons.self_improvement_rounded,
                          title: provider.getText(
                            'Lifestyle & History',
                            'जीवनशैली र इतिहास',
                          ),
                          color: primaryColor,
                          children: [
                            _buildSymptomTile(
                              title: provider.getText(
                                'Do you smoke?',
                                'के तपाईं धूम्रपान गर्नुहुन्छ?',
                              ),
                              value: smoking == 1,
                              onChanged: (v) =>
                                  setState(() => smoking = v ? 1 : 0),
                            ),
                            TextFormField(
                              initialValue: alcohol.toString(),
                              decoration: InputDecoration(
                                labelText: provider.getText(
                                  'Alcohol units per week',
                                  'हप्तामा मदिरा युनिट',
                                ),
                                hintText: '0 – 50',
                                helperText: provider.getText(
                                  'Enter 0 if you do not drink (max 50)',
                                  'नपिउनुभएमा ० राख्नुहोस् (अधिकतम ५०)',
                                ),
                                prefixIcon: const Icon(
                                    Icons.local_bar_rounded,
                                    color: primaryColor),
                              ),
                              keyboardType: TextInputType.number,
                              validator: _validateAlcohol,
                              onChanged: (v) =>
                                  alcohol = double.tryParse(v) ?? 0,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              initialValue: physicalActivity.toString(),
                              decoration: InputDecoration(
                                labelText: provider.getText(
                                  'Physical activity (hours per day)',
                                  'शारीरिक गतिविधि (प्रतिदिन घण्टा)',
                                ),
                                hintText: '0 – 14',
                                helperText: provider.getText(
                                  'Enter hours between 0 and 14 per day',
                                  'प्रतिदिन ० देखि १४ घण्टा बीचमा प्रविष्ट गर्नुहोस्',
                                ),
                                prefixIcon: const Icon(
                                    Icons.directions_run_rounded,
                                    color: primaryColor),
                              ),
                              keyboardType: TextInputType.number,
                              validator: _validatePhysicalActivity,
                              onChanged: (v) =>
                                  physicalActivity = double.tryParse(v) ?? 5,
                            ),
                            const SizedBox(height: 10),
                            _buildSymptomTile(
                              title: provider.getText(
                                'Do you have diabetes?',
                                'के तपाईंलाई मधुमेह छ?',
                              ),
                              value: diabetes == 1,
                              onChanged: (v) =>
                                  setState(() => diabetes = v ? 1 : 0),
                            ),
                            _buildSymptomTile(
                              title: provider.getText(
                                'Any family history of kidney, high BP, or diabetes?',
                                'मिर्गौला, उच्च रक्तचाप वा मधुमेहको पारिवारिक इतिहास छ?',
                              ),
                              value: familyHistory == 1,
                              onChanged: (v) =>
                                  setState(() => familyHistory = v ? 1 : 0),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // ── Section 3: Symptoms ────────────────────────
                        _buildSectionCard(
                          icon: Icons.medical_information_rounded,
                          title: provider.getText('Symptoms', 'लक्षणहरू'),
                          color: const Color(0xFF6A1B9A),
                          children: [
                            _buildSymptomTile(
                              title: provider.getText(
                                'Do you have swelling in legs or feet?',
                                'के तपाईंको खुट्टा वा खुट्टामा सुन्निएको छ?',
                              ),
                              value: edema == 1,
                              onChanged: (v) =>
                                  setState(() => edema = v ? 1 : 0),
                            ),
                            _buildSymptomTile(
                              title: provider.getText(
                                'Have you noticed changes in urine (color, frequency)?',
                                'के तपाईंले पिसाबमा परिवर्तन (रंग, बारम्बारता) देख्नुभएको छ?',
                              ),
                              value: urineChanges == 1,
                              onChanged: (v) =>
                                  setState(() => urineChanges = v ? 1 : 0),
                            ),
                            _buildSymptomTile(
                              title: provider.getText(
                                'Have you had changes in appetite or nausea?',
                                'के तपाईंको भोकमा परिवर्तन वा वाकवाकी भएको छ?',
                              ),
                              value: appetiteChange == 1,
                              onChanged: (v) =>
                                  setState(() => appetiteChange = v ? 1 : 0),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // ── Section 4: Optional Lab Results ───────────
                        _buildSectionCard(
                          icon: Icons.biotech_rounded,
                          title: provider.getText(
                            'Lab Results (Optional)',
                            'प्रयोगशाला नतिजा (वैकल्पिक)',
                          ),
                          color: warningColor,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: warningColor.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color:
                                        warningColor.withValues(alpha: 0.25)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.info_outline_rounded,
                                      color: warningColor, size: 16),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      provider.getText(
                                        'Leave blank if you do not have lab results',
                                        'प्रयोगशाला नतिजा नभएमा खाली छोड्नुहोस्',
                                      ),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: warningColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: provider.getText(
                                  'Serum Creatinine (mg/dL)',
                                  'सिरम क्रिएटिनिन (mg/dL)',
                                ),
                                hintText: '0.1 – 20',
                                helperText: provider.getText(
                                  'Normal: 0.6–1.2 mg/dL',
                                  'सामान्य: ०.६–१.२ mg/dL',
                                ),
                                prefixIcon: const Icon(Icons.science_rounded,
                                    color: warningColor),
                              ),
                              keyboardType: TextInputType.number,
                              validator: _validateCreatinine,
                              onChanged: (v) =>
                                  creatinine = double.tryParse(v),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: provider.getText(
                                  'BUN Levels (mg/dL)',
                                  'बीयूएन स्तर (mg/dL)',
                                ),
                                hintText: '1 – 150',
                                helperText: provider.getText(
                                  'Normal: 7–20 mg/dL',
                                  'सामान्य: ७–२० mg/dL',
                                ),
                                prefixIcon: const Icon(Icons.science_rounded,
                                    color: warningColor),
                              ),
                              keyboardType: TextInputType.number,
                              validator: _validateBun,
                              onChanged: (v) => bun = double.tryParse(v),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: provider.getText(
                                  'Hemoglobin (g/dL)',
                                  'हेमोग्लोबिन (g/dL)',
                                ),
                                hintText: '3 – 20',
                                helperText: provider.getText(
                                  'Normal: 12–17 g/dL',
                                  'सामान्य: १२–१७ g/dL',
                                ),
                                prefixIcon: const Icon(Icons.bloodtype_rounded,
                                    color: warningColor),
                              ),
                              keyboardType: TextInputType.number,
                              validator: _validateHemoglobin,
                              onChanged: (v) => hemoglobin = double.tryParse(v),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: provider.getText(
                                  'Sodium Levels (mEq/L)',
                                  'सोडियम स्तर (mEq/L)',
                                ),
                                hintText: '100 – 170',
                                helperText: provider.getText(
                                  'Normal: 135–145 mEq/L',
                                  'सामान्य: १३५–१४५ mEq/L',
                                ),
                                prefixIcon: const Icon(Icons.water_rounded,
                                    color: warningColor),
                              ),
                              keyboardType: TextInputType.number,
                              validator: _validateSodium,
                              onChanged: (v) => sodium = double.tryParse(v),
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
