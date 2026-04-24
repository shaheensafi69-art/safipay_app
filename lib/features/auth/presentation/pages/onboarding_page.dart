import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'welcome_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _data = [
    {
      "title": "Safi International Capital",
      "desc": "Your gateway to global investment and financial management based in London.",
      "icon": "business_center"
    },
    {
      "title": "Safi TopUp",
      "desc": "Send mobile credit and data bundles to over 150 countries instantly.",
      "icon": "bolt"
    },
    {
      "title": "SafiPro",
      "desc": "Premium lifestyle and modern fashion tailored for your unique style.",
      "icon": "shopping_bag"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: _data.length,
            itemBuilder: (context, index) => _buildSlide(index),
          ),
          
          // Navigation UI
          Positioned(
            bottom: 50,
            left: 30,
            right: 30,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: List.generate(_data.length, (index) => _buildDot(index)),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_currentPage == _data.length - 1) {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const WelcomePage()));
                    } else {
                      _controller.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.ease);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700),
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(20),
                  ),
                  child: Icon(Icons.chevron_right, color: Colors.black),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlide(int index) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/logo.png', width: 80, opacity: const AlwaysStoppedAnimation(0.2)),
          const SizedBox(height: 50),
          Text(
            _data[index]["title"]!,
            textAlign: TextAlign.center,
            style: GoogleFonts.orbitron(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFFFFD700)),
          ),
          const SizedBox(height: 20),
          Text(
            _data[index]["desc"]!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 16, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return Container(
      height: 8,
      width: _currentPage == index ? 24 : 8,
      margin: const EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
        color: _currentPage == index ? const Color(0xFFFFD700) : Colors.white24,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}