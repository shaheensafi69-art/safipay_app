import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// اصلاح مسیرها بر اساس اسکرین‌شات شما:
import 'main_wrapper.dart'; 
import 'features/auth/presentation/pages/onboarding_page.dart';
import 'features/home/presentation/pages/transaction_history.dart'; // مسیر درست اینجاست

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await dotenv.load(fileName: ".env");
    
    final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
    final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      throw Exception("❌ خطا: کلیدهای Supabase یافت نشدند!");
    }

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(authFlowType: AuthFlowType.pkce),
    );

    debugPrint("✅ SafiPay Engine: Connected");
    
  } catch (e) {
    debugPrint("🚨 CRITICAL ERROR: $e");
  }

  runApp(const SafiPayApp());
}

class SafiPayApp extends StatelessWidget {
  const SafiPayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafiPay',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        primaryColor: const Color(0xFFFFD700),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFFD700),
          secondary: Color(0xFFFFD700),
        ),
        fontFamily: 'Poppins',
        useMaterial3: true,
      ),

      // ثبت مسیر صفحه تاریخچه برای استفاده در Navigator
      routes: {
        '/history': (context) => const TransactionHistory(),
      },

      home: StreamBuilder<AuthState>(
        stream: Supabase.instance.client.auth.onAuthStateChange,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator(color: Color(0xFFFFD700))));
          }

          final session = snapshot.data?.session;
          if (session != null) {
            return const MainWrapper();
          } else {
            return const OnboardingPage();
          }
        },
      ),
    );
  }
}