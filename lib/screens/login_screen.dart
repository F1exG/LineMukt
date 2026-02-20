import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isPatient = true;
  bool _obscureText = true;
  bool _isLoading = false;
  String? _errorMessage;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isRegister = false;

  // Optimized Theme Colors
  static const Color primaryBlue = Color(0xFF0066FF);
  static const Color backgroundGrey = Color(0xFFF8FAFC);
  static const Color inputBackground = Color(0xFFF1F5F9);
  static const Color textDark = Color(0xFF1E293B);
  static const Color textLight = Color(0xFF64748B);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _handleAuth() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      Map<String, dynamic> result;

      if (_isRegister) {
        result = await ApiService.register(
          fullName: _nameController.text,
          email: _emailController.text,
          phone: _phoneController.text,
          password: _passwordController.text,
        );
      } else {
        result = await ApiService.login(
          email: _emailController.text,
          password: _passwordController.text,
        );
      }

      setState(() => _isLoading = false);

      if (result['success']) {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Authentication failed';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGrey,
      body: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: Colors.white.withOpacity(0.5)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 40,
                    offset: const Offset(0, 20),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 48),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildBranding(),
                    const SizedBox(height: 32),
                    _buildRoleToggle(),
                    const SizedBox(height: 40),
                    _buildWelcomeHeader(),
                    const SizedBox(height: 32),

                    // Error Message
                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Color(0xFFC62828),
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Tabs
                    _buildTabs(),
                    const SizedBox(height: 24),

                    // Name Field (Register only)
                    if (_isRegister) ...[
                      _buildFieldLabel('FULL NAME'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _nameController,
                        hint: 'John Doe',
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Phone Field (Register only)
                    if (_isRegister) ...[
                      _buildFieldLabel('PHONE NUMBER'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _phoneController,
                        hint: '+1 (555) 000-0000',
                        icon: Icons.phone_outlined,
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Email Field
                    _buildFieldLabel('EMAIL ADDRESS'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _emailController,
                      hint: 'name@example.com',
                      icon: Icons.email_outlined,
                      autofill: AutofillHints.email,
                    ),
                    const SizedBox(height: 24),

                    // Password Field
                    _buildFieldLabel('PASSWORD'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _passwordController,
                      hint: '••••••••',
                      icon: Icons.lock_outline,
                      isPassword: true,
                      autofill: AutofillHints.password,
                    ),

                    if (!_isRegister) _buildForgotPassword(),
                    const SizedBox(height: 24),
                    _buildSignInButton(),
                    const SizedBox(height: 32),
                    _buildFooter(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- UI Components ---

  Widget _buildBranding() {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [primaryBlue, Color(0xFF0052CC)]),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: primaryBlue.withOpacity(0.2), blurRadius: 12)],
          ),
          child: const Icon(Icons.add_box_rounded, color: Colors.white, size: 32),
        ),
        const SizedBox(height: 16),
        const Text('LineMukt', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: textDark)),
      ],
    );
  }

  Widget _buildRoleToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: inputBackground, borderRadius: BorderRadius.circular(100)),
      child: Row(
        children: [
          _toggleBtn('Patient', isPatient, () => _handleToggle(true)),
          _toggleBtn('Staff', !isPatient, () => _handleToggle(false)),
        ],
      ),
    );
  }

  void _handleToggle(bool val) {
    HapticFeedback.lightImpact();
    setState(() => isPatient = val);
  }

  Widget _toggleBtn(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(100),
            boxShadow: active ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)] : [],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                color: active ? textDark : textLight,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Column(
      children: [
        Text(
          _isRegister ? 'Create Account' : 'Welcome Back',
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: textDark),
        ),
        const SizedBox(height: 8),
        Text(
          _isRegister
              ? (isPatient ? 'Register as a patient' : 'Register as staff')
              : (isPatient ? 'Access your medical queue' : 'Hospital management portal'),
          style: const TextStyle(fontSize: 14, color: textLight),
        ),
      ],
    );
  }

  Widget _buildTabs() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _isRegister = false),
            child: Column(
              children: [
                Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: !_isRegister ? textDark : textLight,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 2,
                  color: !_isRegister ? primaryBlue : Colors.transparent,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _isRegister = true),
            child: Column(
              children: [
                Text(
                  'Register',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _isRegister ? textDark : textLight,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 2,
                  color: _isRegister ? primaryBlue : Colors.transparent,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFieldLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: Color(0xFF94A3B8),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    String? autofill,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: inputBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && _obscureText,
        autofillHints: autofill != null ? [autofill] : null,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: textLight, size: 20),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: textLight,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscureText = !_obscureText),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {},
        child: const Text(
          'Forgot Password?',
          style: TextStyle(
            color: primaryBlue,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildSignInButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton(
        onPressed: _isLoading ? null : _handleAuth,
        style: FilledButton.styleFrom(
          backgroundColor: primaryBlue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
          disabledBackgroundColor: Colors.grey,
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                _isRegister ? 'Register' : 'Sign In',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _isRegister ? "Already have an account? " : "New to LineMukt? ",
          style: const TextStyle(color: textLight, fontSize: 14),
        ),
        GestureDetector(
          onTap: () => setState(() => _isRegister = !_isRegister),
          child: Text(
            _isRegister ? 'Sign In' : 'Sign Up',
            style: const TextStyle(
              color: primaryBlue,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}