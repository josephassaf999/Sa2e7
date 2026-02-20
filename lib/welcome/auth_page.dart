import 'package:flutter/material.dart';
import 'package:sa2e7/firebase/firebase_logic.dart';
import 'package:sa2e7/core/utils/auth_utils.dart';

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

  // ─── LOGIN ──────────────────────────────────────────────────────────────────
  Future<void> _login() async {
    if (!AuthUIUtils.validateLogin(
      email: emailController.text,
      password: passwordController.text,
    )) {
      return;
    }

    setState(() => loading = true);
    final user = await _authService.login(
      email: emailController.text,
      password: passwordController.text,
    );
    setState(() => loading = false);
    if (user != null && mounted) Navigator.pop(context);
  }

  // ─── REGISTER ───────────────────────────────────────────────────────────────
  Future<void> _register() async {
    if (!AuthUIUtils.validateRegister(
      name: nameController.text,
      email: emailController.text,
      password: passwordController.text,
      confirm: confirmController.text,
    )) {
      return;
    }

    setState(() => loading = true);
    final user = await _authService.register(
      name: nameController.text,
      email: emailController.text,
      password: passwordController.text,
      confirmPassword: confirmController.text,
    );
    setState(() => loading = false);
    if (user != null && mounted) Navigator.pop(context);
  }

  // ─── GOOGLE SIGN IN ─────────────────────────────────────────────────────────
  Future<void> _googleSignIn() async {
    setState(() => loading = true);
    final user = await _authService.signInWithGoogle();
    setState(() => loading = false);
    if (user != null && mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuthUIConstants.primaryBlue,
      appBar: AppBar(
        backgroundColor: AuthUIConstants.primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body:
          loading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
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
              Text(
                AuthUIConstants.loginTitle,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AuthUIConstants.primaryBlue,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: AuthUIUtils.buildInputDecoration(
                  hintText: AuthUIConstants.emailHint,
                  prefixIcon: Icons.email,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: AuthUIUtils.buildInputDecoration(
                  hintText: AuthUIConstants.passwordHint,
                  prefixIcon: Icons.lock,
                  obscure: true,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: AuthUIUtils.primaryButtonStyle(),
                onPressed: _login,
                child: const Text(
                  AuthUIConstants.loginButton,
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                label: const Text(
                  AuthUIConstants.googleSignIn,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: AuthUIUtils.secondaryButtonStyle(),
                onPressed: _googleSignIn,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => setState(() => showLogin = false),
                child: Text(
                  AuthUIConstants.noAccount,
                  style: const TextStyle(color: AuthUIConstants.mintGreen),
                ),
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
              Text(
                AuthUIConstants.registerTitle,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AuthUIConstants.primaryBlue,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: nameController,
                decoration: AuthUIUtils.buildInputDecoration(
                  hintText: AuthUIConstants.nameHint,
                  prefixIcon: Icons.person,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: AuthUIUtils.buildInputDecoration(
                  hintText: AuthUIConstants.emailHint,
                  prefixIcon: Icons.email,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: AuthUIUtils.buildInputDecoration(
                  hintText: AuthUIConstants.passwordHint,
                  prefixIcon: Icons.lock,
                  obscure: true,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmController,
                obscureText: true,
                decoration: AuthUIUtils.buildInputDecoration(
                  hintText: AuthUIConstants.confirmPasswordHint,
                  prefixIcon: Icons.lock_outline,
                  obscure: true,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: AuthUIUtils.primaryButtonStyle(),
                onPressed: _register,
                child: const Text(
                  AuthUIConstants.registerButton,
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                label: const Text(
                  AuthUIConstants.googleRegister,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: AuthUIUtils.secondaryButtonStyle(),
                onPressed: _googleSignIn,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => setState(() => showLogin = true),
                child: Text(
                  AuthUIConstants.haveAccount,
                  style: const TextStyle(color: AuthUIConstants.mintGreen),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
