import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../main_wrapper.dart'; // حتما چک کن آدرس درست باشد

class AuthPage extends StatefulWidget {
  final bool isSignUp;
  const AuthPage({super.key, this.isSignUp = false});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isLoading = false;
  late bool _isSignUp;

  // وضعیت اعتبارسنجی رمز عبور
  bool _hasUppercase = false;
  bool _hasDigits = false;
  bool _hasSpecialCharacters = false;
  bool _hasMinLength = false;

  @override
  void initState() {
    super.initState();
    _isSignUp = widget.isSignUp;
    _passwordController.addListener(_validatePassword);
  }

  void _validatePassword() {
    final password = _passwordController.text;
    setState(() {
      _hasUppercase = password.contains(RegExp(r'[A-Z]'));
      _hasDigits = password.contains(RegExp(r'[0-9]'));
      _hasSpecialCharacters = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
      _hasMinLength = password.length >= 8;
    });
  }

  bool get _isRegisterButtonEnabled {
    if (!_isSignUp) return _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty;
    return _hasUppercase && _hasDigits && _hasSpecialCharacters && _hasMinLength &&
           _firstNameController.text.isNotEmpty && _lastNameController.text.isNotEmpty &&
           _emailController.text.isNotEmpty;
  }

  Future<void> _handleAuth() async {
    setState(() => _isLoading = true);
    try {
      if (_isSignUp) {
        // ۱. انجام ثبت نام
        final response = await Supabase.instance.client.auth.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          data: {
            'first_name': _firstNameController.text.trim(),
            'last_name': _lastNameController.text.trim(),
            'phone': _phoneController.text.trim(),
          },
        );
        
        if (mounted && response.user != null) {
          _showSnackBar("Welcome to SafiPay! Redirecting...", Colors.green);
          // هدایت مستقیم به داشبورد
          Navigator.pushAndRemoveUntil(
            context, 
            MaterialPageRoute(builder: (context) => const MainWrapper()),
            (route) => false,
          );
        }
      } else {
        // ۲. انجام ورود
        await Supabase.instance.client.auth.signInWithPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        
        if (mounted) {
          // هدایت مستقیم به داشبورد
          Navigator.pushAndRemoveUntil(
            context, 
            MaterialPageRoute(builder: (context) => const MainWrapper()),
            (route) => false,
          );
        }
      }
    } on AuthException catch (e) {
      _showSnackBar(e.message, Colors.redAccent);
    } catch (e) {
      _showSnackBar("An unexpected error occurred", Colors.redAccent);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color, behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned(
            top: -50,
            left: -50,
            child: Opacity(
              opacity: 0.05,
              child: Image.asset('assets/logo.png', width: 280),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(30),
              child: Column(
                children: [
                  Hero(tag: 'logo', child: Image.asset('assets/logo.png', width: 80)),
                  const SizedBox(height: 20),
                  Text(
                    _isSignUp ? "Join SafiPay" : "Welcome Back",
                    style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 30),

                  if (_isSignUp) ...[
                    Row(
                      children: [
                        Expanded(child: _buildField(_firstNameController, "First Name", Icons.person_outline, false)),
                        const SizedBox(width: 10),
                        Expanded(child: _buildField(_lastNameController, "Last Name", Icons.person_outline, false)),
                      ],
                    ),
                    const SizedBox(height: 15),
                    _buildField(_phoneController, "Phone Number", Icons.phone_android_outlined, false),
                    const SizedBox(height: 15),
                  ],

                  _buildField(_emailController, "Email Address", Icons.alternate_email, false),
                  const SizedBox(height: 15),
                  _buildField(_passwordController, "Password", Icons.lock_outline, true),

                  if (_isSignUp) _buildPasswordRequirements(),

                  const SizedBox(height: 30),

                  _isLoading
                      ? const CircularProgressIndicator(color: Color(0xFFFFD700))
                      : ElevatedButton(
                          onPressed: _isRegisterButtonEnabled ? _handleAuth : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFD700),
                            foregroundColor: Colors.black,
                            disabledBackgroundColor: Colors.white10,
                            minimumSize: const Size(double.infinity, 60),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          child: Text(
                            _isSignUp ? "CREATE ACCOUNT" : "LOG IN",
                            style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
                          ),
                        ),

                  TextButton(
                    onPressed: () => setState(() {
                      _isSignUp = !_isSignUp;
                      _passwordController.clear();
                    }),
                    child: Text(
                      _isSignUp ? "Already have an account? Sign In" : "New to SafiPay? Create Account",
                      style: const TextStyle(color: Color(0xFFFFD700)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordRequirements() {
    return Padding(
      padding: const EdgeInsets.only(top: 15, left: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _reqItem("At least 8 characters", _hasMinLength),
          _reqItem("One uppercase letter (A-Z)", _hasUppercase),
          _reqItem("One number (0-9)", _hasDigits),
          _reqItem("One special character (@#\$...)", _hasSpecialCharacters),
        ],
      ),
    );
  }

  Widget _reqItem(String text, bool isMet) {
    return Row(
      children: [
        Icon(isMet ? Icons.check_circle : Icons.circle_outlined, 
             size: 14, color: isMet ? Colors.green : Colors.white24),
        const SizedBox(width: 8),
        Text(text, style: TextStyle(color: isMet ? Colors.green : Colors.white24, fontSize: 11)),
      ],
    );
  }

  Widget _buildField(TextEditingController controller, String hint, IconData icon, bool isPass) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPass,
        onChanged: (value) => setState(() {}),
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: const Color(0xFFFFD700), size: 20),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        ),
      ),
    );
  }
}