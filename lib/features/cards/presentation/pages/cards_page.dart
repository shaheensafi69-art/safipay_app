import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CardsPage extends StatefulWidget {
  const CardsPage({super.key});

  @override
  State<CardsPage> createState() => _CardsPageState();
}

class _CardsPageState extends State<CardsPage> {
  bool isFrozen = false;
  final PageController _pageController = PageController(viewportFraction: 0.9);
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildHeader(),
                ),
                const SizedBox(height: 30),
                
                // بخش کارت‌ها با قابلیت اسلاید
                SizedBox(
                  height: 230,
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) => setState(() => _currentPage = index),
                    children: [
                      _buildCard("VIRTUAL CARD", const Color(0xFFFFD700)),
                      _buildCard("PHYSICAL CARD", Colors.white),
                    ],
                  ),
                ),
                
                // نشانگر صفحه (Dots)
                Center(child: _buildPageIndicator()),
                
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildCardActions(),
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildSettingsSection(),
                ),
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
        Text("My Safi Cards", style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(_currentPage == 0 ? "Digital instant card" : "Premium physical card", 
          style: TextStyle(color: const Color(0xFFFFD700).withOpacity(0.7), fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildCard(String title, Color accentColor) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 300),
      scale: isFrozen ? 0.95 : 1.0,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: accentColor.withOpacity(0.2)),
          gradient: LinearGradient(
            colors: [Colors.white.withOpacity(0.05), Colors.black],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -30, bottom: -30,
              child: Opacity(
                opacity: 0.1,
                child: Image.asset('assets/logo.png', width: 220, errorBuilder: (c,e,s) => const Icon(Icons.account_balance, size: 200)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(title, style: GoogleFonts.orbitron(color: accentColor, fontSize: 12, fontWeight: FontWeight.bold)),
                      Icon(Icons.contactless, color: accentColor.withOpacity(0.5)),
                    ],
                  ),
                  Text("COMING SOON", style: GoogleFonts.orbitron(fontSize: 22, letterSpacing: 5, color: Colors.white.withOpacity(0.9))),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset('assets/logo.png', width: 35, errorBuilder: (c,e,s) => const Icon(Icons.bolt, color: Colors.amber)),
                      Text("SAFI PAY", style: GoogleFonts.poppins(color: Colors.white38, fontWeight: FontWeight.bold)),
                    ],
                  )
                ],
              ),
            ),
            if (isFrozen) 
              Container(
                decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(25)),
                child: Center(
  child: Icon(
    Icons.ac_unit, 
    color: _currentPage == 0 ? Colors.lightBlueAccent : const Color(0xFFFFD700), 
    size: 50
  )
),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(2, (index) => AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.all(4),
        width: _currentPage == index ? 20 : 8,
        height: 8,
        decoration: BoxDecoration(
          color: _currentPage == index ? const Color(0xFFFFD700) : Colors.white24,
          borderRadius: BorderRadius.circular(4),
        ),
      )),
    );
  }

  // نمایش پیام لوکس به جای اسنک‌بار
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
            const Icon(Icons.stars, color: Color(0xFFFFD700), size: 50),
            const SizedBox(height: 20),
            Text("Coming Soon", style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text(
              "Card details and sensitive information will be visible immediately after the official launch of SafiPay services.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white60),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text("Understood", style: TextStyle(fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCardActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _actionItem(isFrozen ? Icons.ac_unit : Icons.lock_open, isFrozen ? "Unfreeze" : "Freeze", () => setState(() => isFrozen = !isFrozen)),
        _actionItem(Icons.visibility, "Details", _showLuxuryMessage),
        _actionItem(Icons.add_card, "Limits", _showLuxuryMessage),
        _actionItem(Icons.settings, "Manage", _showLuxuryMessage),
      ],
    );
  }

  Widget _actionItem(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.1)),
            ),
            child: Icon(icon, color: const Color(0xFFFFD700)),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          _settingsTile(Icons.wifi, "Contactless Payments", true),
          const Divider(color: Colors.white10),
          _settingsTile(Icons.shopping_cart_outlined, "Online Transactions", true),
        ],
      ),
    );
  }

  Widget _settingsTile(IconData icon, String title, bool val) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: const Color(0xFFFFD700)),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      trailing: Switch(value: val, onChanged: (v) {}, activeColor: const Color(0xFFFFD700)),
    );
  }
}