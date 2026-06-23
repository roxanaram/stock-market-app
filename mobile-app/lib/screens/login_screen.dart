import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLogin = true;
  bool _obscurePassword = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  static final Map<String, String> _registeredUsers = {};

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? const Color(0xFFFF5C5C) : const Color(0xFF2ECC71),
      ),
    );
  }

  void _submit() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();

    if (email.isEmpty) {
      _showSnackbar('Please enter your email.', isError: true);
      return;
    }
    if (!_isValidEmail(email)) {
      _showSnackbar('Please enter a valid email address.', isError: true);
      return;
    }
    if (password.isEmpty) {
      _showSnackbar('Please enter your password.', isError: true);
      return;
    }
    if (password.length < 6) {
      _showSnackbar('Password must be at least 6 characters.', isError: true);
      return;
    }

    if (_isLogin) {
      if (!_registeredUsers.containsKey(email)) {
        _showSnackbar('No account found. Please register first.', isError: true);
        return;
      }
      if (_registeredUsers[email] != password) {
        _showSnackbar('Incorrect password. Please try again.', isError: true);
        return;
      }
      _showSnackbar('Welcome back! Logged in successfully.');
    } else {
      if (name.isEmpty) {
        _showSnackbar('Please enter your full name.', isError: true);
        return;
      }
      if (_registeredUsers.containsKey(email)) {
        _showSnackbar('An account with this email already exists.', isError: true);
        return;
      }
      _registeredUsers[email] = password;
      _showSnackbar('Account created! You can now log in.');
      setState(() => _isLogin = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF08111F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF08111F),
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF4CC9F0).withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text('S',
                    style: TextStyle(
                        color: Color(0xFF4CC9F0),
                        fontWeight: FontWeight.bold,
                        fontSize: 18)),
              ),
            ),
            const SizedBox(width: 8),
            Text(_isLogin ? 'Login' : 'Register',
                style: const TextStyle(
                    color: Color(0xFFF8FAFC),
                    fontWeight: FontWeight.bold,
                    fontSize: 20)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // Logo
            Center(
              child: Column(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CC9F0).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: const Color(0xFF4CC9F0).withOpacity(0.3)),
                    ),
                    child: const Center(
                      child: Text('S',
                          style: TextStyle(
                              color: Color(0xFF4CC9F0),
                              fontSize: 36,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('StockScope',
                      style: TextStyle(
                          color: Color(0xFFF8FAFC),
                          fontSize: 24,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    _isLogin ? 'Welcome back!' : 'Create your account',
                    style: const TextStyle(color: Color(0xFFAAB6C8), fontSize: 14),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 36),

            // Toggle
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF142238),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white.withOpacity(0.12)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isLogin = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _isLogin ? const Color(0xFF4CC9F0) : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text('Login',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: _isLogin
                                    ? const Color(0xFF08111F)
                                    : const Color(0xFFAAB6C8),
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isLogin = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: !_isLogin ? const Color(0xFF4CC9F0) : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text('Register',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: !_isLogin
                                    ? const Color(0xFF08111F)
                                    : const Color(0xFFAAB6C8),
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Name field (register only)
            if (!_isLogin) ...[
              const Text('Full Name',
                  style: TextStyle(color: Color(0xFFAAB6C8), fontSize: 13)),
              const SizedBox(height: 6),
              TextField(
                controller: _nameController,
                style: const TextStyle(color: Color(0xFFF8FAFC)),
                decoration: InputDecoration(
                  hintText: 'Enter your name',
                  hintStyle: const TextStyle(color: Color(0xFFAAB6C8)),
                  prefixIcon: const Icon(Icons.person, color: Color(0xFFAAB6C8)),
                  filled: true,
                  fillColor: const Color(0xFF142238),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.12)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF4CC9F0)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Email
            const Text('Email',
                style: TextStyle(color: Color(0xFFAAB6C8), fontSize: 13)),
            const SizedBox(height: 6),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Color(0xFFF8FAFC)),
              decoration: InputDecoration(
                hintText: 'Enter your email',
                hintStyle: const TextStyle(color: Color(0xFFAAB6C8)),
                prefixIcon: const Icon(Icons.email, color: Color(0xFFAAB6C8)),
                filled: true,
                fillColor: const Color(0xFF142238),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.12)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF4CC9F0)),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Password
            const Text('Password',
                style: TextStyle(color: Color(0xFFAAB6C8), fontSize: 13)),
            const SizedBox(height: 6),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              style: const TextStyle(color: Color(0xFFF8FAFC)),
              decoration: InputDecoration(
                hintText: 'Minimum 6 characters',
                hintStyle: const TextStyle(color: Color(0xFFAAB6C8)),
                prefixIcon: const Icon(Icons.lock, color: Color(0xFFAAB6C8)),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: const Color(0xFFAAB6C8),
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
                filled: true,
                fillColor: const Color(0xFF142238),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.12)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF4CC9F0)),
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CC9F0),
                  foregroundColor: const Color(0xFF08111F),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  _isLogin ? 'Login' : 'Create Account',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: 16),

            Center(
              child: GestureDetector(
                onTap: () => setState(() => _isLogin = !_isLogin),
                child: Text(
                  _isLogin
                      ? "Don't have an account? Register"
                      : 'Already have an account? Login',
                  style: const TextStyle(color: Color(0xFF4CC9F0), fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
