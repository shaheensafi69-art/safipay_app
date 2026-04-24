import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  // لیست مخاطبین برگزیده با نام اصلاح شده Feroz
  final List<Map<String, String>> favorites = [
    {'name': 'Hamed', 'relation': 'Brother', 'image': 'H'},
    {'name': 'Feroz', 'relation': 'Brother', 'image': 'F'},
    {'name': 'Mujtaba', 'relation': 'Partner', 'image': 'M'},
    {'name': 'Sahel', 'relation': 'Partner', 'image': 'S'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(-0.5, -0.5),
            radius: 1.5,
            colors: [Color(0xFF1A1A2E), Color(0xFF000000)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _buildHeader(),
                const SizedBox(height: 30),
                _buildSectionTitle("Friends & Family"),
                _buildFavoritesList(),
                const SizedBox(height: 30),
                _buildSectionTitle("Quick Actions"),
                _buildQuickActions(),
                const SizedBox(height: 30),
                _buildSectionTitle("Global Services"),
                _buildServiceGrid(),
                const SizedBox(height: 30),
                _buildSectionTitle("Recent Activity"),
                _buildRecentActivity(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Payments", style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
        Text("Global transfers & local payments", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13)),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white70)),
    );
  }

  // لیست مخاطبین با قابلیت اسکرول افقی
  Widget _buildFavoritesList() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: favorites.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildAddFavorite();
          }
          final person = favorites[index - 1];
          return GestureDetector(
            onTap: () => _showTransferSheet(person['name']!),
            child: Container(
              margin: const EdgeInsets.only(right: 20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: const Color(0xFFFFD700).withOpacity(0.1),
                    child: Text(person['image']!, style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 8),
                  Text(person['name']!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAddFavorite() {
    return Container(
      margin: const EdgeInsets.only(right: 20),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white.withOpacity(0.05),
            child: const Icon(Icons.add, color: Colors.white54),
          ),
          const SizedBox(height: 8),
          const Text("Add", style: TextStyle(fontSize: 12, color: Colors.white54)),
        ],
      ),
    );
  }

  // پنل انتقال وجه با باز شدن خودکار کیبورد عددی
  void _showTransferSheet(String name) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20, 
          top: 20, 
          left: 20, 
          right: 20
        ),
        decoration: const BoxDecoration(
          color: Color(0xFF121212),
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          border: Border(top: BorderSide(color: Colors.white10)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 25),
            Text("Send to $name", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
            const SizedBox(height: 15),
            
            TextField(
              autofocus: true, // باز شدن خودکار کیبورد
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.center,
              style: GoogleFonts.orbitron(fontSize: 40, color: const Color(0xFFFFD700), fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: "0.00",
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.05)),
                prefixText: "\$ ",
                prefixStyle: GoogleFonts.poppins(fontSize: 25, color: const Color(0xFFFFD700)),
                border: InputBorder.none,
              ),
            ),
            
            const SizedBox(height: 30),
            
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showLuxuryMessage();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                elevation: 0,
              ),
              child: const Text("Confirm & Send", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  void _showLuxuryMessage() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(30),
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          border: Border(top: BorderSide(color: Color(0xFFFFD700), width: 0.5)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.verified_user_outlined, color: Color(0xFFFFD700), size: 50),
            const SizedBox(height: 20),
            Text("SafiPay Coming Soon", style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 10),
            const Text(
              "Our secure payment gateway is undergoing final audits. This feature will be available to all members in the upcoming global update.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white60),
            ),
            const SizedBox(height: 30),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Got it!", style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        _quickActionItem(Icons.send_rounded, "Send", () => _showTransferSheet("Contact")),
        const SizedBox(width: 15),
        _quickActionItem(Icons.call_received_rounded, "Request", _showLuxuryMessage),
        const SizedBox(width: 15),
        _quickActionItem(Icons.qr_code_scanner_rounded, "Scan", _showLuxuryMessage),
      ],
    );
  }

  Widget _quickActionItem(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: const Color(0xFFFFD700).withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.1)),
          ),
          child: Column(
            children: [
              Icon(icon, color: const Color(0xFFFFD700)),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceGrid() {
    final services = [
      {'icon': Icons.phone_android, 'name': 'Top-Up'},
      {'icon': Icons.wifi, 'name': 'Internet'},
      {'icon': Icons.bolt, 'name': 'Utility'},
      {'icon': Icons.games, 'name': 'Gaming'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.6,
      ),
      itemCount: 4,
      itemBuilder: (context, index) => GestureDetector(
        onTap: _showLuxuryMessage,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(services[index]['icon'] as IconData, color: const Color(0xFFFFD700)),
              const SizedBox(height: 8),
              Text(services[index]['name'] as String, style: const TextStyle(fontSize: 12, color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03), 
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: const ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(backgroundColor: Colors.white10, child: Icon(Icons.history, color: Colors.white54)),
        title: Text("No Recent Transactions", style: TextStyle(fontSize: 14, color: Colors.white70)),
        trailing: Text("\$0.00", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }
}