import 'package:flutter/material.dart';

class SafiNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const SafiNavBar({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 25),
      decoration: BoxDecoration(
        color: const Color(0xFF121212).withOpacity(0.95),
        borderRadius: BorderRadius.circular(35),
        border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.2)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.home_filled, "Home", 0),
          _navItem(Icons.credit_card, "Cards", 1),
          _navItem(Icons.payments_outlined, "Payment", 2),
          _navItem(Icons.person_outline, "Profile", 3),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    bool isSel = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isSel ? const Color(0xFFFFD700) : Colors.grey, size: 26),
          if (isSel) Text(label, style: const TextStyle(color: Color(0xFFFFD700), fontSize: 10)),
        ],
      ),
    );
  }
}