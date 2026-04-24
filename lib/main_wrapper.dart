import 'package:flutter/material.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/cards/presentation/pages/cards_page.dart';
// فرض بر این است که مسیر فایل پرداخت و پروفایل طبق ساختار شما این‌گونه است:
import 'features/payment/presentation/pages/payment_page.dart';
import 'features/profile/presentation/pages/profile_page.dart';
import 'widgets/safi_nav_bar.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    
    // مقداردهی صفحات در initState برای دسترسی به context و تعریف اکشن دکمه‌ها
    _pages = [
      GalaxyDashboard(
        onHistoryClick: () {
          // استفاده از نام مسیری که در main.dart تعریف کردیم
          Navigator.pushNamed(context, '/history');
        },
      ),
      const CardsPage(),
      const PaymentPage(),
      const ProfilePage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // اجازه می‌دهد محتوا پشت نویگیشن‌بار (برای حالت Blur/Glass) دیده شود
      extendBody: true,
      
      // استفاده از IndexedStack برای حفظ وضعیت صفحات هنگام جابجایی
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),

      // نویگیشن‌بار اختصاصی SafiPay
      bottomNavigationBar: SafiNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}