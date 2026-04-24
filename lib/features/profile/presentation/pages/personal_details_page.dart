import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:country_picker/country_picker.dart'; // برای لیست مکمل کشورها

class PersonalDetailsPage extends StatefulWidget {
  const PersonalDetailsPage({super.key});

  @override
  State<PersonalDetailsPage> createState() => _PersonalDetailsPageState();
}

class _PersonalDetailsPageState extends State<PersonalDetailsPage> {
  final supabase = Supabase.instance.client;
  
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  
  String _selectedCountry = "Select Country";
  DateTime? _selectedDate;
  String? _avatarUrl;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // ۱. دریافت اطلاعات
  Future<void> _loadUserData() async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      try {
        final data = await supabase
            .from('profiles')
            .select()
            .eq('id', user.id)
            .single();
        
        setState(() {
          _firstNameController.text = data['first_name'] ?? '';
          _lastNameController.text = data['last_name'] ?? '';
          _phoneController.text = data['phone'] ?? '';
          _selectedCountry = data['country'] ?? "Select Country";
          _avatarUrl = data['avatar_url'];
          if (data['dob'] != null) {
            _selectedDate = DateTime.tryParse(data['dob']);
          }
        });
      } catch (e) {
        debugPrint("Error loading profile: $e");
      }
    }
  }

  // ۲. اصلاح دکمه عکس (با مدیریت خطا)
  Future<void> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery, 
        imageQuality: 50
      );

      if (image == null) return;

      setState(() => _isUpdating = true);

      final userId = supabase.auth.currentUser!.id;
      final file = File(image.path);
      final fileExt = image.path.split('.').last;
      final fileName = '$userId-${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath = 'avatars/$fileName';

      // آپلود در استوریج سابابیس
      await supabase.storage.from('avatars').upload(filePath, file);

      // دریافت URL عمومی
      final String publicUrl = supabase.storage.from('avatars').getPublicUrl(filePath);

      // آپدیت دیتابیس
      await supabase.from('profiles').update({'avatar_url': publicUrl}).eq('id', userId);

      setState(() => _avatarUrl = publicUrl);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Profile Photo Updated"), backgroundColor: Colors.green),
      );
    } catch (e) {
      debugPrint("Photo Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Failed to upload image: $e"), backgroundColor: Colors.redAccent),
      );
    } finally {
      setState(() => _isUpdating = false);
    }
  }

  // ۳. انتخاب کشور (لیست مکمل با قابلیت جستجو)
  void _showCountryPicker() {
    showCountryPicker(
      context: context,
      showPhoneCode: false,
      countryListTheme: CountryListThemeData(
        backgroundColor: const Color(0xFF1A1A2E),
        textStyle: const TextStyle(color: Colors.white),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        searchTextStyle: const TextStyle(color: Colors.white),
        inputDecoration: InputDecoration(
          hintText: 'Search country...',
          hintStyle: const TextStyle(color: Colors.white24),
          prefixIcon: const Icon(Icons.search, color: Color(0xFFFFD700)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ),
      onSelect: (Country country) {
        setState(() {
          _selectedCountry = "${country.flagEmoji} ${country.name}";
        });
      },
    );
  }

  // ۴. ذخیره نهایی
  Future<void> _updateProfile() async {
    setState(() => _isUpdating = true);
    try {
      final userId = supabase.auth.currentUser!.id;

      await supabase.from('profiles').update({
        'first_name': _firstNameController.text.trim(),
        'last_name': _lastNameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'country': _selectedCountry,
        'dob': _selectedDate?.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ SafiPay Records Synced"), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Sync Failed: $e"), backgroundColor: Colors.redAccent),
      );
    } finally {
      setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity, height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1A2E), Colors.black],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      _buildAvatarPicker(),
                      const SizedBox(height: 30),
                      _buildEditField(_firstNameController, "First Name", Icons.person_outline),
                      const SizedBox(height: 15),
                      _buildEditField(_lastNameController, "Last Name", Icons.person_outline),
                      const SizedBox(height: 15),
                      _buildEditField(_phoneController, "Phone Number", Icons.phone_android_outlined),
                      const SizedBox(height: 15),
                      _buildCustomPicker(
                        label: "Country", value: _selectedCountry, icon: Icons.public,
                        onTap: _showCountryPicker,
                      ),
                      const SizedBox(height: 15),
                      _buildCustomPicker(
                        label: "Date of Birth",
                        value: _selectedDate == null ? "Not Set" : DateFormat('yyyy-MM-dd').format(_selectedDate!),
                        icon: Icons.calendar_month, onTap: () => _selectDate(context),
                      ),
                      const SizedBox(height: 40),
                      _buildSaveButton(),
                      const SizedBox(height: 20),
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

  // ویجت دکمه عکس پروفایل
  Widget _buildAvatarPicker() {
    return GestureDetector(
      onTap: _pickAndUploadImage,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircleAvatar(
            radius: 55,
            backgroundColor: const Color(0xFFFFD700).withOpacity(0.1),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white10,
              backgroundImage: _avatarUrl != null ? NetworkImage(_avatarUrl!) : null,
              child: _avatarUrl == null ? const Icon(Icons.camera_alt, color: Color(0xFFFFD700), size: 30) : null,
            ),
          ),
          Positioned(
            bottom: 0, right: 4,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(color: Color(0xFFFFD700), shape: BoxShape.circle),
              child: const Icon(Icons.edit, size: 14, color: Colors.black),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20), onPressed: () => Navigator.pop(context)),
          Text("Personal Details", style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildEditField(TextEditingController controller, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white10)),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label, labelStyle: const TextStyle(color: Colors.white38, fontSize: 12),
          prefixIcon: Icon(icon, color: const Color(0xFFFFD700), size: 20),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildCustomPicker({required String label, required String value, required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white10)),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFFFD700), size: 20),
            const SizedBox(width: 15),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10)),
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 15)),
            ]),
            const Spacer(),
            const Icon(Icons.keyboard_arrow_down, color: Colors.white24),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context, initialDate: DateTime(2000),
      firstDate: DateTime(1920), lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Widget _buildSaveButton() {
    return _isUpdating 
      ? const CircularProgressIndicator(color: Color(0xFFFFD700))
      : ElevatedButton(
          onPressed: _updateProfile,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFD700), foregroundColor: Colors.black,
            minimumSize: const Size(double.infinity, 60), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          ),
          child: const Text("UPDATE DATABASE", style: TextStyle(fontWeight: FontWeight.bold)),
        );
  }
}