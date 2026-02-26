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
              : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 24,
                ),
                child: Column(
                  children: [
                    // Tab Buttons with animated indicator
                    _buildTabButtons(),
                    const SizedBox(height: 32),
                    // Form Container
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      switchInCurve: Curves.fastOutSlowIn,
                      switchOutCurve: Curves.fastOutSlowIn,
                      transitionBuilder: (child, animation) {
                        final fadeAnimation = CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeInOut,
                        );

                        final slideAnimation = Tween<Offset>(
                          begin: Offset(0, showLogin ? 0.3 : -0.3),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.fastOutSlowIn,
                          ),
                        );

                        final scaleAnimation = Tween<double>(
                          begin: 0.92,
                          end: 1.0,
                        ).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.fastOutSlowIn,
                          ),
                        );

                        return FadeTransition(
                          opacity: fadeAnimation,
                          child: SlideTransition(
                            position: slideAnimation,
                            child: ScaleTransition(
                              scale: scaleAnimation,
                              child: child,
                            ),
                          ),
                        );
                      },
                      child:
                          showLogin
                              ? _buildLoginPanel()
                              : _buildRegisterPanel(),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildTabButtons() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton(
              label: 'Login',
              isActive: showLogin,
              onTap: () => setState(() => showLogin = true),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildTabButton(
              label: 'Sign Up',
              isActive: !showLogin,
              onTap: () => setState(() => showLogin = false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow:
              isActive
                  ? [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                  : [],
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isActive ? AuthUIConstants.primaryBlue : Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginPanel() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
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
            const SizedBox(height: 8),
            Text(
              'Welcome back!',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 28),
            _buildAnimatedTextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: AuthUIUtils.buildInputDecoration(
                hintText: AuthUIConstants.emailHint,
                prefixIcon: Icons.email,
              ),
              delay: 0,
            ),
            const SizedBox(height: 16),
            _buildAnimatedTextField(
              controller: passwordController,
              obscureText: true,
              decoration: AuthUIUtils.buildInputDecoration(
                hintText: AuthUIConstants.passwordHint,
                prefixIcon: Icons.lock,
                obscure: true,
              ),
              delay: 50,
            ),
            const SizedBox(height: 28),
            _buildAnimatedButton(
              label: AuthUIConstants.loginButton,
              onPressed: _login,
              isPrimary: true,
              delay: 100,
            ),
            const SizedBox(height: 16),
            _buildAnimatedButton(
              label: AuthUIConstants.googleSignIn,
              onPressed: _googleSignIn,
              isPrimary: false,
              isGoogle: true,
              delay: 150,
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => setState(() => showLogin = false),
              child: RichText(
                text: TextSpan(
                  text: 'Don\'t have an account? ',
                  style: TextStyle(color: Colors.grey[700]),
                  children: [
                    TextSpan(
                      text: 'Sign up',
                      style: const TextStyle(
                        color: AuthUIConstants.mintGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterPanel() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
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
            const SizedBox(height: 8),
            Text(
              'Join our community!',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 28),
            _buildAnimatedTextField(
              controller: nameController,
              decoration: AuthUIUtils.buildInputDecoration(
                hintText: AuthUIConstants.nameHint,
                prefixIcon: Icons.person,
              ),
              delay: 0,
            ),
            const SizedBox(height: 16),
            _buildAnimatedTextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: AuthUIUtils.buildInputDecoration(
                hintText: AuthUIConstants.emailHint,
                prefixIcon: Icons.email,
              ),
              delay: 50,
            ),
            const SizedBox(height: 16),
            _buildAnimatedTextField(
              controller: passwordController,
              obscureText: true,
              decoration: AuthUIUtils.buildInputDecoration(
                hintText: AuthUIConstants.passwordHint,
                prefixIcon: Icons.lock,
                obscure: true,
              ),
              delay: 100,
            ),
            const SizedBox(height: 16),
            _buildAnimatedTextField(
              controller: confirmController,
              obscureText: true,
              decoration: AuthUIUtils.buildInputDecoration(
                hintText: AuthUIConstants.confirmPasswordHint,
                prefixIcon: Icons.lock_outline,
                obscure: true,
              ),
              delay: 150,
            ),
            const SizedBox(height: 28),
            _buildAnimatedButton(
              label: AuthUIConstants.registerButton,
              onPressed: _register,
              isPrimary: true,
              delay: 200,
            ),
            const SizedBox(height: 16),
            _buildAnimatedButton(
              label: AuthUIConstants.googleRegister,
              onPressed: _googleSignIn,
              isPrimary: false,
              isGoogle: true,
              delay: 250,
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => setState(() => showLogin = true),
              child: RichText(
                text: TextSpan(
                  text: 'Already have an account? ',
                  style: TextStyle(color: Colors.grey[700]),
                  children: [
                    TextSpan(
                      text: 'Login',
                      style: const TextStyle(
                        color: AuthUIConstants.mintGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedTextField({
    required TextEditingController controller,
    required InputDecoration decoration,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    required int delay,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 500 + delay),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        decoration: decoration,
      ),
    );
  }

  Widget _buildAnimatedButton({
    required String label,
    required VoidCallback onPressed,
    required bool isPrimary,
    bool isGoogle = false,
    required int delay,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 500 + delay),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child:
          isGoogle
              ? ElevatedButton.icon(
                label: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: AuthUIUtils.secondaryButtonStyle(),
                onPressed: onPressed,
              )
              : ElevatedButton(
                style: AuthUIUtils.primaryButtonStyle(),
                onPressed: onPressed,
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
    );
  }
}
