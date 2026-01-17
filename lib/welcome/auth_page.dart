import 'package:flutter/material.dart';
import '../firebase/firebase_logic.dart'; // Your AuthService

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});
  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool showLogin = true;
  bool loading = false;

  final AuthService _authService = AuthService();

  // Controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  // Colors
  final Color primaryBlue = const Color(0xFFFF0000);
  final Color mintGreen = const Color(0xFFD86767);

  // Validators
  bool isValidEmail(String email) {
    final regex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
    return regex.hasMatch(email);
  }

  bool isValidPassword(String password) => password.length >= 6;

  // Login
  Future<void> _login() async {
    if (!isValidEmail(emailController.text) || !isValidPassword(passwordController.text)) return;
    setState(() => loading = true);
    final user = await _authService.login(
      email: emailController.text,
      password: passwordController.text,
    );
    setState(() => loading = false);
    if (user != null) Navigator.pop(context);
  }

  // Register
  Future<void> _register() async {
    final email = emailController.text;
    final password = passwordController.text;
    final confirm = confirmController.text;
    final name = nameController.text;

    if (name.isEmpty || !isValidEmail(email) || !isValidPassword(password) || password != confirm) return;

    setState(() => loading = true);
    final user = await _authService.register(
      name: name,
      email: email,
      password: password,
      confirmPassword: confirm,
    );
    setState(() => loading = false);
    if (user != null) Navigator.pop(context);
  }

  // Google login
  Future<void> _googleSignIn() async {
    setState(() => loading = true);
    final user = await _authService.signInWithGoogle();
    setState(() => loading = false);
    if (user != null) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBlue,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : AnimatedSwitcher(
        duration: const Duration(milliseconds: 700),
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        transitionBuilder: (child, animation) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: Offset(0, showLogin ? 1.0 : -1.0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        },
        child: showLogin ? _buildLoginPanel() : _buildRegisterPanel(),
      ),
    );
  }

  Widget _buildLoginPanel() {
    return SingleChildScrollView(
      key: const ValueKey("login"),
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Login",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: primaryBlue)),
              const SizedBox(height: 24),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.email, color: mintGreen),
                  hintText: "Email",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  filled: true,
                  fillColor: mintGreen.withOpacity(0.1),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.lock, color: mintGreen),
                  hintText: "Password",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  filled: true,
                  fillColor: mintGreen.withOpacity(0.1),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _login,
                child: const Text("Login", style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
              const SizedBox(height: 16),
              // Google button
              ElevatedButton.icon(
                label: const Text("Sign in with Google", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _googleSignIn,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => setState(() => showLogin = false),
                child: Text("Don't have an account? Register", style: TextStyle(color: mintGreen)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterPanel() {
    return SingleChildScrollView(
      key: const ValueKey("register"),
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Register",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: primaryBlue)),
              const SizedBox(height: 24),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.person, color: mintGreen),
                  hintText: "Name",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  filled: true,
                  fillColor: mintGreen.withOpacity(0.1),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.email, color: mintGreen),
                  hintText: "Email",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  filled: true,
                  fillColor: mintGreen.withOpacity(0.1),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.lock, color: mintGreen),
                  hintText: "Password",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  filled: true,
                  fillColor: mintGreen.withOpacity(0.1),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmController,
                obscureText: true,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.lock_outline, color: mintGreen),
                  hintText: "Confirm Password",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  filled: true,
                  fillColor: mintGreen.withOpacity(0.1),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _register,
                child: const Text("Register", style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                label: const Text("Register with Google", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _googleSignIn,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => setState(() => showLogin = true),
                child: Text("Already have an account? Login", style: TextStyle(color: mintGreen)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
