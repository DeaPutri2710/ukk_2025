import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ukk/beranda.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Supabase.initialize(
    url: "https:fvykohkpduxbsolmohdx.supabase.co",
    anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZ2eWtvaGtwZHV4YnNvbG1vaGR4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzk0MDk5NjgsImV4cCI6MjA1NDk4NTk2OH0.DfUPeEn_L7S8gQbf8g03XKBJi_hYNkAwZDSqtFTcZ4M",
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink.shade100,
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              _InputField(),
            ],
          ),
        ),
      ),
    );
  }
}

class _InputField extends StatefulWidget {
  const _InputField({super.key});

  @override
  State<_InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<_InputField> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  bool _usernameError = false;
  bool _passwordError = false;

  void _validateAndLogin() {
    setState(() {
      _usernameError = _usernameController.text.isEmpty;
      _passwordError = _passwordController.text.isEmpty;

      if (!_usernameError && !_passwordError) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Login berhasil',
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
            backgroundColor: Colors.grey,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(bottom: 20, left: 10, right: 10),
          ),
        );

        Future.delayed(const Duration(seconds: 2), () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          context,
          controller: _usernameController,
          hintText: "Username",
          icon: Icons.person,
          isError: _usernameError,
        ),
        if (_usernameError)
          const Padding(
            padding: EdgeInsets.only(top: 4, left: 12),
            child: Text(
              'Username tidak boleh kosong !',
              style: TextStyle(color: Colors.red, fontSize: 15),
            ),
          ),
        const SizedBox(height: 10),
        _buildTextField(
          context,
          controller: _passwordController,
          hintText: "Password",
          icon: Icons.lock,
          isPassword: true,
          isError: _passwordError,
        ),
        if (_passwordError)
          const Padding(
            padding: EdgeInsets.only(top: 4, left: 12),
            child: Text(
              'Password tidak boleh kosong !',
              style: TextStyle(color: Colors.red, fontSize: 15),
            ),
          ),
        const SizedBox(height: 10),
        Center(
          child: ElevatedButton(
            onPressed: _validateAndLogin,
            style: ElevatedButton.styleFrom(
              maximumSize: const Size(200, 50),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            ),
            child: const Text(
              "Login",
              style: TextStyle(
                fontSize: 20,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    BuildContext context, {
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    bool isError = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? _obscurePassword : false,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.black),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: isError ? Colors.red : Colors.transparent,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: isError ? Colors.red : Colors.transparent,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: isError ? Colors.red : Colors.blue,
          ),
        ),
        fillColor: Colors.white,
        filled: true,
        prefixIcon: Icon(
          icon,
          color: Colors.black,
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  color: Colors.black,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              )
            : null,
      ),
    );
  }
}

