import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'auth_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Seal Logo
          Positioned(
            bottom: -60,
            right: -60,
            child: Opacity(
              opacity: 0.08,
              child: Image.asset(
                'assets/logo.png',
                width: 350,
                errorBuilder: (context, error, stackTrace) => 
                    const Icon(Icons.bolt, size: 300, color: Colors.white10),
              ),
            ),
          ),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  const SizedBox(height: 100),
                  Hero(
                    tag: 'logo',
                    child: Image.asset(
                      'assets/logo.png',
                      width: 120,
                      errorBuilder: (c, e, s) => const Icon(Icons.auto_awesome, color: Color(0xFFFFD700), size: 100),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    "SafiPay",
                    style: GoogleFonts.orbitron(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFFFD700),
                      letterSpacing: 8,
                    ),
                  ),
                  Text(
                    "NEXT-GEN DIGITAL ASSETS",
                    style: GoogleFonts.poppins(
                      color: Colors.white30,
                      letterSpacing: 3,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  _buildButton(
                    context,
                    "SIGN IN",
                    const Color(0xFFFFD700),
                    Colors.black,
                    () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AuthPage(isSignUp: false))),
                  ),
                  const SizedBox(height: 20),
                  _buildButton(
                    context,
                    "GET STARTED",
                    Colors.transparent,
                    const Color(0xFFFFD700),
                    () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AuthPage(isSignUp: true))),
                    isOutlined: true,
                  ),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(BuildContext context, String text, Color bgColor, Color textColor, VoidCallback onTap, {bool isOutlined = false}) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: textColor,
          side: isOutlined ? const BorderSide(color: Color(0xFFFFD700), width: 1.5) : BorderSide.none,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: isOutlined ? 0 : 15,
        ),
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2),
        ),
      ),
    );
  }
}