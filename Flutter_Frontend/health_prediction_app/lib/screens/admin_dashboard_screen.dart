import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../services/admin_service.dart';
import 'admin_login_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedTab = 0; // 0=overview, 1=kidney, 2=diabetes, 3=users
  Map<String, dynamic>? _stats;
  List<dynamic> _kidneyList = [];
  List<dynamic> _diabetesList = [];
  List<dynamic> _usersList = [];
  int _kidneyTotal = 0;
  int _diabetesTotal = 0;
  int _usersTotal = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final stats = await AdminService.getDashboardStats();
      final kidney = await AdminService.getKidneyPredictions();
      final diabetes = await AdminService.getDiabetesPredictions();
      final users = await AdminService.getUsers();
      setState(() {
        _stats = stats;
        _kidneyList = kidney['predictions'] ?? [];
        _kidneyTotal = kidney['total'] ?? 0;
        _diabetesList = diabetes['predictions'] ?? [];
        _diabetesTotal = diabetes['total'] ?? 0;
        _usersList = users['users'] ?? [];
        _usersTotal = users['total'] ?? 0;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _deletePrediction(String type, int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Prediction'),
        content: const Text('Are you sure you want to delete this record?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      await AdminService.deletePrediction(type, id);
      _loadData();
    }
  }

  void _logout() {
    AdminService.logout();
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (_) => const AdminLoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width > 800;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Row(
        children: [
          // Sidebar
          Container(
            width: isWide ? 240 : 70,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                begin: Alignment.topCenter, end: Alignment.bottomCenter),
            ),
            child: Column(
              children: [
                const SizedBox(height: 24),
                // Logo
                Container(
                  width: isWide ? 56 : 42, height: isWide ? 56 : 42,
                  decoration: BoxDecoration(
                    gradient: heroGradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.health_and_safety_rounded,
                      color: Colors.white, size: isWide ? 30 : 22),
                ),
                if (isWide) ...[
                  const SizedBox(height: 10),
                  const Text('HealthAI', style: TextStyle(color: Colors.white,
                      fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('Admin Panel', style: TextStyle(
                      color: Colors.grey.shade500, fontSize: 11)),
                ],
                const SizedBox(height: 32),
                _sidebarItem(0, Icons.dashboard_rounded, 'Overview', isWide),
                _sidebarItem(1, Icons.water_drop_rounded, 'Kidney', isWide),
                _sidebarItem(2, Icons.bloodtype_rounded, 'Diabetes', isWide),
                _sidebarItem(3, Icons.people_rounded, 'Users', isWide),
                const Spacer(),
                // Admin info
                if (isWide) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(children: [
                        CircleAvatar(radius: 16, backgroundColor: primaryColor,
                          child: Text(AdminService.adminName.isNotEmpty
                              ? AdminService.adminName[0].toUpperCase() : 'A',
                              style: const TextStyle(color: Colors.white,
                                  fontSize: 14, fontWeight: FontWeight.bold))),
                        const SizedBox(width: 10),
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(AdminService.adminName,
                                style: const TextStyle(color: Colors.white,
                                    fontSize: 12, fontWeight: FontWeight.w600),
                                overflow: TextOverflow.ellipsis),
                            Text(AdminService.adminEmail,
                                style: TextStyle(color: Colors.grey.shade500,
                                    fontSize: 10),
                                overflow: TextOverflow.ellipsis),
                          ],
                        )),
                      ]),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                _sidebarItem(-1, Icons.logout_rounded, 'Logout', isWide),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // Main content
          Expanded(
            child: _loading
              ? const Center(child: CircularProgressIndicator(color: primaryColor))
              : _selectedTab == 0
                ? _buildOverview(isWide)
                : _selectedTab == 1
                  ? _buildPredictionTable('kidney', _kidneyList, _kidneyTotal, isWide)
                  : _selectedTab == 2
                    ? _buildPredictionTable('diabetes', _diabetesList, _diabetesTotal, isWide)
                    : _buildUsersTab(isWide),
          ),
        ],
      ),
    );
  }

  Widget _sidebarItem(int index, IconData icon, String label, bool isWide) {
    final isActive = _selectedTab == index;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isWide ? 12 : 8, vertical: 3),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {
            if (index == -1) { _logout(); return; }
            setState(() => _selectedTab = index);
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.symmetric(
                horizontal: isWide ? 14 : 0, vertical: 12),
            decoration: BoxDecoration(
              color: isActive ? primaryColor.withValues(alpha: 0.15) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: isWide ? MainAxisAlignment.start : MainAxisAlignment.center,
              children: [
                Icon(icon, size: 20,
                    color: index == -1 ? Colors.red.shade300
                        : isActive ? primaryLight : Colors.grey.shade500),
                if (isWide) ...[
                  const SizedBox(width: 12),
                  Text(label, style: TextStyle(fontSize: 13,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                      color: index == -1 ? Colors.red.shade300
                          : isActive ? Colors.white : Colors.grey.shade500)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Overview Tab ──────────────────────────────────────────────────────────
  Widget _buildOverview(bool isWide) {
    final stats = _stats;
    if (stats == null) return const Center(child: Text('No data'));

    final kidneyRisk = stats['kidney_risk'] as Map<String, dynamic>;
    final diabetesRisk = stats['diabetes_risk'] as Map<String, dynamic>;
    final weekly = stats['weekly'] as Map<String, dynamic>;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Welcome, ${AdminService.adminName}',
                  style: const TextStyle(color: Colors.white, fontSize: 22,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('Dashboard Overview',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
            ]),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ]),
          const SizedBox(height: 24),

          // Stat Cards
          Wrap(
            spacing: 16, runSpacing: 16,
            children: [
              _statCard('Total Predictions', '${stats['total_predictions']}',
                  Icons.analytics_rounded, const Color(0xFF6366F1), isWide),
              _statCard('Kidney Tests', '${stats['total_kidney']}',
                  Icons.water_drop_rounded, const Color(0xFF3B82F6), isWide),
              _statCard('Diabetes Tests', '${stats['total_diabetes']}',
                  Icons.bloodtype_rounded, const Color(0xFFEF4444), isWide),
              _statCard('This Week', '${weekly['kidney'] + weekly['diabetes']}',
                  Icons.trending_up_rounded, const Color(0xFF10B981), isWide),
            ],
          ),
          const SizedBox(height: 24),

          // Risk Distribution
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _riskCard('Kidney Risk Distribution', kidneyRisk,
                  const Color(0xFF3B82F6))),
              const SizedBox(width: 16),
              Expanded(child: _riskCard('Diabetes Risk Distribution', diabetesRisk,
                  const Color(0xFFEF4444))),
            ],
          ),
          const SizedBox(height: 24),

          // Recent predictions
          _recentPredictionsCard(),
        ],
      ),
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color, bool isWide) {
    final cardWidth = isWide ? 220.0 : 160.0;
    return Container(
      width: cardWidth,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 14),
          Text(value, style: const TextStyle(color: Colors.white,
              fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _riskCard(String title, Map<String, dynamic> risk, Color accent) {
    final total = (risk['low'] ?? 0) + (risk['medium'] ?? 0) + (risk['high'] ?? 0);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white,
              fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),
          _riskBar('Low', risk['low'] ?? 0, total, const Color(0xFF10B981)),
          const SizedBox(height: 12),
          _riskBar('Medium', risk['medium'] ?? 0, total, const Color(0xFFF59E0B)),
          const SizedBox(height: 12),
          _riskBar('High', risk['high'] ?? 0, total, const Color(0xFFEF4444)),
        ],
      ),
    );
  }

  Widget _riskBar(String label, int count, int total, Color color) {
    final pct = total > 0 ? count / total : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Container(width: 8, height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
          const Spacer(),
          Text('$count', style: const TextStyle(color: Colors.white,
              fontSize: 13, fontWeight: FontWeight.w600)),
          Text('  ${(pct * 100).toStringAsFixed(0)}%',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
        ]),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct, minHeight: 6,
            backgroundColor: Colors.grey.shade800,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }

  Widget _recentPredictionsCard() {
    final recent = <Map<String, dynamic>>[];
    for (var p in _kidneyList.take(5)) {
      recent.add({...p as Map<String, dynamic>, 'type': 'Kidney'});
    }
    for (var p in _diabetesList.take(5)) {
      recent.add({...p as Map<String, dynamic>, 'type': 'Diabetes'});
    }
    recent.sort((a, b) => (b['created_at'] ?? '').compareTo(a['created_at'] ?? ''));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Recent Predictions',
              style: TextStyle(color: Colors.white, fontSize: 15,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          ...recent.take(8).map((p) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: p['type'] == 'Kidney'
                      ? const Color(0xFF3B82F6).withValues(alpha: 0.15)
                      : const Color(0xFFEF4444).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  p['type'] == 'Kidney' ? Icons.water_drop_rounded : Icons.bloodtype_rounded,
                  size: 16,
                  color: p['type'] == 'Kidney' ? const Color(0xFF3B82F6) : const Color(0xFFEF4444),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${p['type']} Test #${p['id']}',
                      style: const TextStyle(color: Colors.white, fontSize: 13)),
                  Text('Age: ${p['age']} | ${p['gender']}',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
                ],
              )),
              _riskBadge(p['risk_level'] ?? ''),
              const SizedBox(width: 12),
              Text(p['probability'] ?? '',
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
              const SizedBox(width: 12),
              Text(p['created_at'] ?? '',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
            ]),
          )),
        ],
      ),
    );
  }

  Widget _riskBadge(String level) {
    Color bg, fg;
    switch (level.toLowerCase()) {
      case 'low':
        bg = const Color(0xFF10B981).withValues(alpha: 0.15);
        fg = const Color(0xFF10B981);
        break;
      case 'medium':
        bg = const Color(0xFFF59E0B).withValues(alpha: 0.15);
        fg = const Color(0xFFF59E0B);
        break;
      case 'high':
        bg = const Color(0xFFEF4444).withValues(alpha: 0.15);
        fg = const Color(0xFFEF4444);
        break;
      default:
        bg = Colors.grey.shade800; fg = Colors.grey.shade400;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(level, style: TextStyle(color: fg, fontSize: 11,
          fontWeight: FontWeight.w600)),
    );
  }

  // ─── Prediction Table Tab ──────────────────────────────────────────────────
  Widget _buildPredictionTable(String type, List<dynamic> data, int total, bool isWide) {
    final isKidney = type == 'kidney';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Row(children: [
            Icon(isKidney ? Icons.water_drop_rounded : Icons.bloodtype_rounded,
                color: isKidney ? const Color(0xFF3B82F6) : const Color(0xFFEF4444), size: 24),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${isKidney ? 'Kidney' : 'Diabetes'} Predictions',
                  style: const TextStyle(color: Colors.white, fontSize: 20,
                      fontWeight: FontWeight.bold)),
              Text('$total total records',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
            ]),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ]),
        ),

        // Table
        Expanded(
          child: Container(
            margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(18),
            ),
            child: data.isEmpty
              ? Center(child: Text('No predictions yet',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14)))
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: data.length + 1, // +1 for header
                  itemBuilder: (ctx, i) {
                    if (i == 0) return _tableHeader(isKidney);
                    final p = data[i - 1] as Map<String, dynamic>;
                    return _tableRow(p, isKidney, type);
                  },
                ),
          ),
        ),
      ],
    );
  }

  Widget _tableHeader(bool isKidney) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade800)),
      ),
      child: Row(children: [
        _headerCell('ID', 50),
        _headerCell('Age', 50),
        _headerCell('Gender', 70),
        if (isKidney) ...[
          _headerCell('BP', 60),
          _headerCell('BMI', 60),
          _headerCell('Smoking', 70),
        ] else ...[
          _headerCell('Polyuria', 70),
          _headerCell('Polydipsia', 80),
          _headerCell('Wt Loss', 70),
        ],
        _headerCell('Risk', 80),
        _headerCell('Prob', 70),
        _headerCell('Date', 120),
        const SizedBox(width: 40),
      ]),
    );
  }

  Widget _headerCell(String text, double width) {
    return SizedBox(width: width,
      child: Text(text, style: TextStyle(color: Colors.grey.shade500,
          fontSize: 11, fontWeight: FontWeight.w600)));
  }

  Widget _tableRow(Map<String, dynamic> p, bool isKidney, String type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade800.withValues(alpha: 0.4))),
      ),
      child: Row(children: [
        _dataCell('#${p['id']}', 50),
        _dataCell('${p['age']}', 50),
        _dataCell('${p['gender']}', 70),
        if (isKidney) ...[
          _dataCell('${p['systolic_bp'] ?? '-'}', 60),
          _dataCell('${p['bmi'] ?? '-'}', 60),
          _dataCell('${p['smoking'] ?? '-'}', 70),
        ] else ...[
          _dataCell('${p['polyuria'] ?? '-'}', 70),
          _dataCell('${p['polydipsia'] ?? '-'}', 80),
          _dataCell('${p['weight_loss'] ?? '-'}', 70),
        ],
        SizedBox(width: 80, child: _riskBadge(p['risk_level'] ?? '')),
        _dataCell(p['probability'] ?? '', 70),
        _dataCell(p['created_at'] ?? '', 120),
        SizedBox(width: 40, child: IconButton(
          icon: Icon(Icons.delete_outline, size: 16, color: Colors.red.shade400),
          onPressed: () => _deletePrediction(type, p['id']),
        )),
      ]),
    );
  }

  Widget _dataCell(String text, double width) {
    return SizedBox(width: width,
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 12),
          overflow: TextOverflow.ellipsis));
  }

  // ─── Users Tab ────────────────────────────────────────────────────────────
  Future<void> _deleteUser(int userId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete User'),
        content: const Text('Are you sure? This will delete the user account. Their predictions will remain.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      await AdminService.deleteUser(userId);
      _loadData();
    }
  }

  void _showUserPredictions(Map<String, dynamic> user) async {
    final preds = await AdminService.getUserPredictions(user['id']);
    if (!mounted) return;

    final kidneyPreds = preds['kidney'] as List<dynamic>? ?? [];
    final diabetesPreds = preds['diabetes'] as List<dynamic>? ?? [];

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 500),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  CircleAvatar(radius: 20, backgroundColor: primaryColor,
                    child: Text(
                      (user['full_name'] ?? 'U')[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white,
                          fontSize: 18, fontWeight: FontWeight.bold))),
                  const SizedBox(width: 14),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user['full_name'] ?? '',
                          style: const TextStyle(color: Colors.white,
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(user['email'] ?? '',
                          style: TextStyle(color: Colors.grey.shade500,
                              fontSize: 12)),
                    ],
                  )),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white54),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ]),
                const SizedBox(height: 20),
                // Stats row
                Row(children: [
                  _userStatChip('Kidney', '${kidneyPreds.length}',
                      const Color(0xFF3B82F6)),
                  const SizedBox(width: 12),
                  _userStatChip('Diabetes', '${diabetesPreds.length}',
                      const Color(0xFFEF4444)),
                  const SizedBox(width: 12),
                  _userStatChip('Total',
                      '${kidneyPreds.length + diabetesPreds.length}',
                      const Color(0xFF10B981)),
                ]),
                const SizedBox(height: 20),
                const Text('Prediction History',
                    style: TextStyle(color: Colors.white, fontSize: 14,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Expanded(
                  child: (kidneyPreds.isEmpty && diabetesPreds.isEmpty)
                    ? Center(child: Text('No predictions yet',
                        style: TextStyle(color: Colors.grey.shade600)))
                    : ListView(
                        children: [
                          ...kidneyPreds.map((p) => _userPredRow(p, 'Kidney')),
                          ...diabetesPreds.map((p) => _userPredRow(p, 'Diabetes')),
                        ],
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _userStatChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(value, style: TextStyle(color: color, fontSize: 16,
            fontWeight: FontWeight.bold)),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(color: color.withValues(alpha: 0.8),
            fontSize: 11)),
      ]),
    );
  }

  Widget _userPredRow(Map<String, dynamic> p, String type) {
    final isKidney = type == 'Kidney';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(children: [
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(
            color: (isKidney ? const Color(0xFF3B82F6) : const Color(0xFFEF4444))
                .withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Icon(
            isKidney ? Icons.water_drop_rounded : Icons.bloodtype_rounded,
            size: 14,
            color: isKidney ? const Color(0xFF3B82F6) : const Color(0xFFEF4444),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$type Test #${p['id']}',
                style: const TextStyle(color: Colors.white, fontSize: 12)),
            Text('Age: ${p['age']} | ${p['created_at'] ?? ''}',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 10)),
          ],
        )),
        _riskBadge(p['risk_level'] ?? ''),
        const SizedBox(width: 10),
        Text(p['probability'] ?? '',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
      ]),
    );
  }

  Widget _buildUsersTab(bool isWide) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Row(children: [
            const Icon(Icons.people_rounded, color: Color(0xFF8B5CF6), size: 24),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Registered Users',
                  style: TextStyle(color: Colors.white, fontSize: 20,
                      fontWeight: FontWeight.bold)),
              Text('$_usersTotal total users',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
            ]),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ]),
        ),

        // Users table
        Expanded(
          child: Container(
            margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(18),
            ),
            child: _usersList.isEmpty
              ? Center(child: Text('No users registered yet',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14)))
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: _usersList.length + 1,
                  itemBuilder: (ctx, i) {
                    if (i == 0) return _usersTableHeader();
                    final u = _usersList[i - 1] as Map<String, dynamic>;
                    return _usersTableRow(u);
                  },
                ),
          ),
        ),
      ],
    );
  }

  Widget _usersTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade800)),
      ),
      child: Row(children: [
        _headerCell('ID', 40),
        _headerCell('Name', 120),
        _headerCell('Email', 160),
        _headerCell('Phone', 100),
        _headerCell('Kidney', 60),
        _headerCell('Diabetes', 70),
        _headerCell('Total', 50),
        _headerCell('Joined', 120),
        const SizedBox(width: 80),
      ]),
    );
  }

  Widget _usersTableRow(Map<String, dynamic> u) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(
            color: Colors.grey.shade800.withValues(alpha: 0.4))),
      ),
      child: Row(children: [
        _dataCell('#${u['id']}', 40),
        _dataCell(u['full_name'] ?? '', 120),
        _dataCell(u['email'] ?? '', 160),
        _dataCell(u['phone'] ?? '-', 100),
        _dataCell('${u['kidney_tests'] ?? 0}', 60),
        _dataCell('${u['diabetes_tests'] ?? 0}', 70),
        _dataCell('${u['total_predictions'] ?? 0}', 50),
        _dataCell(u['created_at'] ?? '', 120),
        SizedBox(width: 80, child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.visibility_rounded,
                  size: 16, color: Colors.blue.shade400),
              tooltip: 'View predictions',
              onPressed: () => _showUserPredictions(u),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline,
                  size: 16, color: Colors.red.shade400),
              tooltip: 'Delete user',
              onPressed: () => _deleteUser(u['id']),
            ),
          ],
        )),
      ]),
    );
  }
}
