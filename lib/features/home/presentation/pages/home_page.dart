import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

// وارد کردن صفحه هیستوری (مطمئن شو مسیر درست است)
// import 'package:your_project_name/screens/transaction_history.dart';

class GalaxyDashboard extends StatefulWidget {
  final VoidCallback onHistoryClick;

  const GalaxyDashboard({super.key, required this.onHistoryClick});

  @override
  State<GalaxyDashboard> createState() => _GalaxyDashboardState();
}

class _GalaxyDashboardState extends State<GalaxyDashboard> {
  final supabase = Supabase.instance.client;
  
  String userName = "Safi Member"; // مقدار پیش‌فرض بهتر
  String? avatarUrl;
  
  final TextEditingController _amountController = TextEditingController(text: "1");
  double _exchangeRate = 0.92;

  final List<Map<String, dynamic>> currencies = [
    {'name': 'US Dollar', 'code': 'USD', 'symbol': '\$', 'flag': '🇺🇸', 'balance': 0.0},
    {'name': 'Euro', 'code': 'EUR', 'symbol': '€', 'flag': '🇪🇺', 'balance': 0.0},
    {'name': 'British Pound', 'code': 'GBP', 'symbol': '£', 'flag': '🇬🇧', 'balance': 0.0},
    {'name': 'Polish Zloty', 'code': 'PLN', 'symbol': 'zł', 'flag': '🇵🇱', 'balance': 0.0},
    {'name': 'Swedish Krona', 'code': 'SEK', 'symbol': 'kr', 'flag': '🇸🇪', 'balance': 0.0},
    {'name': 'Norwegian Krone', 'code': 'NOK', 'symbol': 'kr', 'flag': '🇳🇴', 'balance': 0.0},
    {'name': 'Romanian Leu', 'code': 'RON', 'symbol': 'lei', 'flag': '🇷🇴', 'balance': 0.0},
    {'name': 'Hungarian Forint', 'code': 'HUF', 'symbol': 'Ft', 'flag': '🇭🇺', 'balance': 0.0},
    {'name': 'Czech Koruna', 'code': 'CZK', 'symbol': 'Kč', 'flag': '🇨🇿', 'balance': 0.0},
    {'name': 'Danish Krone', 'code': 'DKK', 'symbol': 'kr', 'flag': '🇩🇰', 'balance': 0.0},
  ];

  late Map<String, dynamic> selectedCurrency;
  late Map<String, dynamic> fromEx;
  late Map<String, dynamic> toEx;

  @override
  void initState() {
    super.initState();
    selectedCurrency = currencies[0];
    fromEx = currencies[0];
    toEx = currencies[1];
    _initializeDashboard();
  }

  // متد جدید برای گرفتن سریع داده‌ها
  Future<void> _fetchUserData() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final data = await supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();
      
      if (mounted) {
        setState(() {
          String fName = data['first_name'] ?? "";
          String lName = data['last_name'] ?? "";
          String combined = "$fName $lName".trim();
          userName = combined.isNotEmpty ? combined : (data['full_name'] ?? "Safi Member");
          avatarUrl = data['avatar_url'];
        });
      }
    } catch (e) {
      debugPrint("Error fetching user: $e");
    }
  }

  void _initializeDashboard() {
    _fetchUserData(); // فراخوانی سریع

    final user = supabase.auth.currentUser;
    if (user == null) return;

    // استریم برای آپدیت‌های لحظه‌ای
    supabase
        .from('profiles')
        .stream(primaryKey: ['id'])
        .eq('id', user.id)
        .listen((data) {
          if (data.isNotEmpty && mounted) {
            final p = data.first;
            setState(() {
              String fName = p['first_name'] ?? "";
              String lName = p['last_name'] ?? "";
              String combined = "$fName $lName".trim();
              userName = combined.isNotEmpty ? combined : (p['full_name'] ?? "Safi Member");
              avatarUrl = p['avatar_url'];
            });
          }
        });

    supabase
        .from('wallets')
        .stream(primaryKey: ['id'])
        .eq('user_id', user.id)
        .listen((data) {
          if (data.isNotEmpty && mounted) {
            final w = data.first;
            setState(() {
              for (var cur in currencies) {
                cur['balance'] = (w[cur['code']] ?? 0.0).toDouble();
              }
            });
          }
        });
  }

  // بقیه متدهای UI (بدون تغییر) ...
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.8, -0.5),
            radius: 1.5,
            colors: [Color(0xFF1A1A2E), Color(0xFF000000)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _buildHeader(),
                const SizedBox(height: 35),
                _buildMainBalanceCard(),
                const SizedBox(height: 40),
                _buildModernSectionTitle("Global Assets"),
                const SizedBox(height: 15),
                _buildCurrencyList(),
                const SizedBox(height: 40),
                _buildModernSectionTitle("Quick Conversion"),
                const SizedBox(height: 15),
                _buildExchangeSection(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("PREMIUM ACCOUNT", style: GoogleFonts.poppins(color: Colors.white38, fontSize: 10, letterSpacing: 2)),
            Text(userName, style: GoogleFonts.orbitron(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
          ],
        ),
        // بخش آواتار...
        _buildAvatar(),
      ],
    );
  }

  Widget _buildAvatar() {
    return Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.5)),
          ),
          child: CircleAvatar(
            radius: 24,
            backgroundColor: Colors.white10,
            backgroundImage: (avatarUrl != null && avatarUrl!.isNotEmpty) ? NetworkImage(avatarUrl!) : null,
            child: (avatarUrl == null || avatarUrl!.isEmpty) ? const Icon(Icons.person, color: Color(0xFFFFD700)) : null,
          ),
        );
  }

  Widget _buildMainBalanceCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(35),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(35),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            children: [
              Text("AVAILABLE BALANCE (${selectedCurrency['code']})", 
                style: GoogleFonts.poppins(color: const Color(0xFFFFD700).withOpacity(0.7), fontSize: 10, letterSpacing: 3, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              Text("${selectedCurrency['symbol']}${selectedCurrency['balance'].toStringAsFixed(2)}", 
                style: GoogleFonts.orbitron(fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: _cardActionButton(Icons.account_balance_outlined, "BANK INFO", _showBankDetailsMessage),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _cardActionButton(
                      Icons.history_rounded, 
                      "HISTORY", 
                      () {
                        print("History button clicked"); // برای تست در کنسول
                        widget.onHistoryClick();
                      }, 
                      isPrimary: true
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  // سایر متدهای کمکی UI مثل _cardActionButton, _buildExchangeSection و غیره...
  // (کدهای قبلی را اینجا قرار بده)

  Widget _cardActionButton(IconData icon, String label, VoidCallback onTap, {bool isPrimary = false}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque, // اضافه شده برای حساسیت بیشتر دکمه
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isPrimary ? const Color(0xFFFFD700) : Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: isPrimary ? Colors.black : Colors.white),
            const SizedBox(width: 8),
            Text(label, style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w900, color: isPrimary ? Colors.black : Colors.white)),
          ],
        ),
      ),
    );
  }

  void _showBankDetailsMessage() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.account_balance, color: Color(0xFFFFD700), size: 50),
            const SizedBox(height: 20),
            Text("Bank Details", style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 15),
            const Text(
              "International bank details (IBAN/SWIFT) are currently being set up for your account.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white60, height: 1.5),
            ),
            const SizedBox(height: 30),
            _cardActionButton(Icons.check, "I UNDERSTAND", () => Navigator.pop(context), isPrimary: true),
          ],
        ),
      ),
    );
  }

  Widget _buildExchangeSection() {
    double inputVal = double.tryParse(_amountController.text) ?? 0.0;
    double result = inputVal * _exchangeRate;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          _buildExRow("From", fromEx, _amountController, true),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Icon(Icons.swap_vert_circle_outlined, color: Color(0xFFFFD700), size: 30),
          ),
          _buildExRow("To", toEx, TextEditingController(text: result.toStringAsFixed(2)), false),
          const SizedBox(height: 15),
          Text("Exchange Rate: 1 ${fromEx['code']} = $_exchangeRate ${toEx['code']}", 
            style: const TextStyle(color: Colors.white38, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildExRow(String label, Map<String, dynamic> cur, TextEditingController ctrl, bool enabled) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: ctrl,
            enabled: enabled,
            onChanged: (v) => setState(() {}),
            keyboardType: TextInputType.number,
            style: GoogleFonts.orbitron(color: Colors.white, fontSize: 18),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: const TextStyle(color: Colors.white24, fontSize: 12),
              border: InputBorder.none,
            ),
          ),
        ),
        _buildExPicker(cur, (v) => setState(() {
          if (label == "From") fromEx = v!; else toEx = v!;
        })),
      ],
    );
  }

  Widget _buildExPicker(Map<String, dynamic> current, Function(Map<String, dynamic>?) onSet) {
    return PopupMenuButton<Map<String, dynamic>>(
      onSelected: onSet,
      color: const Color(0xFF1A1A2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Text(current['flag']),
            const SizedBox(width: 8),
            Text(current['code'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      itemBuilder: (context) => currencies.map((c) => PopupMenuItem(value: c, child: Text("${c['flag']} ${c['code']}", style: const TextStyle(color: Colors.white)))).toList(),
    );
  }

  Widget _buildCurrencyList() {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: currencies.length,
        itemBuilder: (context, index) {
          final cur = currencies[index];
          bool isSelected = selectedCurrency['code'] == cur['code'];
          return GestureDetector(
            onTap: () => setState(() => selectedCurrency = cur),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 80,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFFFD700) : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(cur['flag'], style: const TextStyle(fontSize: 20)),
                  const SizedBox(height: 5),
                  Text(cur['code'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: isSelected ? Colors.black : Colors.white)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildModernSectionTitle(String title) {
    return Text(title, style: GoogleFonts.poppins(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5));
  }
}