import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'personal_details_page.dart';
import 'security_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final supabase = Supabase.instance.client;
  Stream<List<Map<String, dynamic>>>? _profileStream;

  @override
  void initState() {
    super.initState();
    _initStream();
  }

  void _initStream() {
    final user = supabase.auth.currentUser;
    if (user != null) {
      // گوش دادن به تغییرات جدول profiles به صورت زنده
      _profileStream = supabase
          .from('profiles')
          .stream(primaryKey: ['id'])
          .eq('id', user.id);
    }
  }

  Future<void> _launchExternal(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint("Could not launch $url");
    }
  }

  void _showSupportOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("SafiPay Support", style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _menuTile(Icons.chat_bubble_outline, "WhatsApp Support", () => _launchExternal("https://wa.me/447476620282")),
            _menuTile(Icons.mail_outline, "Email Support", () => _launchExternal("mailto:safipay@hotmail.com")),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1A2E), Colors.black],
          ),
        ),
       // ... کدهای قبل ثابت است

        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: _profileStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFFFFD700)));
            }

            Map<String, dynamic> data = {};
            String displayName = "Safi Member";

            if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              data = snapshot.data!.first;
              
              // ترکیب هوشمندانه نام و تخلص
              String firstName = data['first_name'] ?? "";
              String lastName = data['last_name'] ?? "";
              
              if (firstName.isNotEmpty || lastName.isNotEmpty) {
                displayName = "$firstName $lastName".trim();
              } else if (data['full_name'] != null) {
                displayName = data['full_name'];
              }
            } else {
              // استفاده از متادیتای پیش‌فرض اگر دیتابیس خالی بود
              displayName = user?.userMetadata?['full_name'] ?? 
                            user?.userMetadata?['first_name'] ?? 
                            "Safi Member";
              
              data = {
                'avatar_url': user?.userMetadata?['avatar_url'],
                'tier': "Standard",
                'status': "Verified",
                'member_id': "SF-${user?.id.substring(0, 4).toUpperCase() ?? "0000"}",
              };
            }

            return SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    // ارسال نام کامل به هدر
                    _buildProfileHeader(displayName, data['avatar_url'], user?.email),
                    const SizedBox(height: 30),
                    _buildStatsRow(data['status'] ?? "Verified", data['tier'] ?? "Standard", data['member_id'] ?? "SF-0000"),
                    
                    // ... باقی منوها
                    
                    _sectionLabel("ACCOUNT MANAGEMENT"),
                    _buildMenuBox([
                      _menuTile(Icons.person_outline, "Personal Details", () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const PersonalDetailsPage()));
                      }),
                      _menuTile(Icons.shield_outlined, "Security & Biometrics", () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const SecurityPage()));
                      }),
                    ]),

                    const SizedBox(height: 25),
                    _sectionLabel("SAFI ECOSYSTEM"),
                    _buildMenuBox([
                      _menuTile(Icons.language, "Official Website", () => _launchExternal("https://safipay.net")),
                      _menuTile(Icons.bolt_outlined, "Safi TopUp", () => _launchExternal("https://safitopup.site")),
                      _menuTile(Icons.shopping_bag_outlined, "SafiPro Store", () => _launchExternal("https://safipro.site")),
                    ]),

                    const SizedBox(height: 25),
                    _sectionLabel("HELP & LEGAL"),
                    _buildMenuBox([
                      _menuTile(Icons.headset_mic_outlined, "Support Center", _showSupportOptions),
                      _menuTile(Icons.description_outlined, "Terms & Conditions", () {}),
                    ]),

                    const SizedBox(height: 40),
                    _buildLogoutButton(),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileHeader(String name, String? avatar, String? email) {
    return Column(
      children: [
        CircleAvatar(
          radius: 55,
          backgroundColor: const Color(0xFFFFD700),
          child: CircleAvatar(
            radius: 52,
            backgroundColor: const Color(0xFF1A1A2E),
            backgroundImage: avatar != null ? NetworkImage(avatar) : null,
            child: avatar == null ? const Icon(Icons.person, size: 50, color: Colors.white10) : null,
          ),
        ),
        const SizedBox(height: 15),
        Text(name, 
          textAlign: TextAlign.center,
          style: GoogleFonts.orbitron(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1)),
        const SizedBox(height: 5),
        Text(email ?? "", style: GoogleFonts.poppins(color: Colors.white38, fontSize: 13)),
      ],
    );
  }

  Widget _buildStatsRow(String status, String tier, String id) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        border: Border.symmetric(horizontal: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _statItem("Status", status),
          _statItem("Tier", tier),
          _statItem("ID", id),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 13)),
        Text(label, style: const TextStyle(color: Colors.white24, fontSize: 10)),
      ],
    );
  }

  Widget _sectionLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 15, bottom: 10),
        child: Text(text, style: GoogleFonts.poppins(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
      ),
    );
  }

  Widget _buildMenuBox(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(children: children),
    );
  }

  Widget _menuTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: const Color(0xFFFFD700), size: 18),
      ),
      title: Text(title, style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white10, size: 10),
    );
  }

  Widget _buildLogoutButton() {
    return InkWell(
      onTap: () async => await supabase.auth.signOut(),
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.logout, color: Colors.redAccent, size: 18),
            SizedBox(width: 10),
            Text("Sign Out", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}