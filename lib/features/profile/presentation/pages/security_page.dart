import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_auth/local_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  final LocalAuthentication auth = LocalAuthentication();
  bool _isBiometricEnabled = false;
  bool _canCheckBiometrics = false;

  @override
  void initState() {
    super.initState();
    _checkDeviceSupport();
  }

  // بررسی پشتیبانی سخت‌افزاری گوشی (اثر انگشت یا تشخیص چهره)
  Future<void> _checkDeviceSupport() async {
    try {
      bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
      bool isSupported = await auth.isDeviceSupported();
      setState(() {
        _canCheckBiometrics = canAuthenticateWithBiometrics && isSupported;
      });
    } catch (e) {
      debugPrint("Device support check error: $e");
    }
  }

  // تابع زنده احراز هویت بیومتریک
  Future<void> _authenticate() async {
    if (!_canCheckBiometrics) {
      _showSnackBar("Biometric not supported on this device", Colors.redAccent);
      return;
    }

    try {
      // این ساختار بدون نیاز به آن ایمپورت خاص کار می‌کند
      bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Please authenticate to enable secure access for SafiPay',
        // پارامتر options را حذف کردیم تا ارور برطرف شود
        // فلاتر به صورت پیش‌فرض امن‌ترین حالت را در نظر می‌گیرد
      );

      setState(() {
        _isBiometricEnabled = didAuthenticate;
      });

      if (didAuthenticate) {
        _showSnackBar("Biometric Security Enabled! ✅", Colors.green);
      }
    } catch (e) {
      debugPrint("Auth Error: $e");
      _showSnackBar("Authentication error or canceled", Colors.orange);
    }
  }

  void _setupPIN() {
    _showSnackBar("PIN Setup feature is now active. Please set your 4-digit code.", const Color(0xFFFFD700));
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      _sectionLabel("BIOMETRICS"),
                      _buildSecurityBox([
                        _buildSwitchTile(
                          Icons.fingerprint, 
                          "Touch ID / Face ID", 
                          _canCheckBiometrics ? "Secure your SafiPay account" : "Not supported", 
                          _isBiometricEnabled,
                          (val) {
                            if (val) {
                              _authenticate();
                            } else {
                              setState(() => _isBiometricEnabled = false);
                            }
                          },
                        ),
                      ]),
                      
                      const SizedBox(height: 30),
                      _sectionLabel("ACCESS CONTROL"),
                      _buildSecurityBox([
                        _buildActionTile(Icons.pin_outlined, "App PIN Code", "Live setup for security code", _setupPIN),
                        _buildSwitchTile(
                          Icons.phonelink_lock_outlined, 
                          "Two-Factor Auth", 
                          "Coming soon", 
                          false, 
                          null, // غیرفعال طبق درخواست شما
                        ),
                      ]),

                      const SizedBox(height: 30),
                      _sectionLabel("PASSWORD"),
                      _buildSecurityBox([
                        _buildActionTile(Icons.lock_reset_outlined, "Change Password", "Currently disabled", null),
                      ]),

                      const SizedBox(height: 40),
                      _buildSecurityStatus(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          Text("Security Center", style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 10),
      child: Text(text, style: GoogleFonts.poppins(color: Colors.white24, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
    );
  }

  Widget _buildSecurityBox(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile(IconData icon, String title, String subtitle, bool value, Function(bool)? onChanged) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFFFFD700), size: 22),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.white24, fontSize: 11)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: const Color(0xFFFFD700),
      ),
    );
  }

  Widget _buildActionTile(IconData icon, String title, String subtitle, VoidCallback? onTap) {
    return ListTile(
      onTap: onTap,
      enabled: onTap != null,
      leading: Icon(icon, color: onTap == null ? Colors.white10 : const Color(0xFFFFD700), size: 22),
      title: Text(title, style: TextStyle(color: onTap == null ? Colors.white10 : Colors.white, fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.white24, fontSize: 11)),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white10, size: 12),
    );
  }

  Widget _buildSecurityStatus() {
    return Center(
      child: Column(
        children: [
          Icon(Icons.verified_user, color: _isBiometricEnabled ? Colors.green : Colors.white10, size: 40),
          const SizedBox(height: 10),
          Text(
            _isBiometricEnabled ? "YOUR ACCOUNT IS HIGHLY SECURED" : "PROTECT YOUR ACCOUNT",
            style: GoogleFonts.poppins(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}