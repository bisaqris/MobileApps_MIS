import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/auth_notifier.dart';
import '../providers/auth_state.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    ref.read(authProvider.notifier).login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // Tampilkan error feedback via SnackBar.
    ref.listen<AuthState>(authProvider, (prev, next) {
      if (next.errorMessage != null &&
          next.errorMessage != prev?.errorMessage) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Iconsax.warning_2, color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                  Expanded(child: Text(next.errorMessage!)),
                ],
              ),
              backgroundColor: AppColors.danger,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Stack(
        children: [
          // ---- Decorative blurred circles ----
          _buildGlowCircle(
            top: -60,
            left: -60,
            size: 320,
            color: const Color(0xFF3B7DFF).withValues(alpha: 0.5),
          ),
          _buildGlowCircle(
            bottom: -80,
            left: 100,
            size: 250,
            color: const Color(0xFF004BCA).withValues(alpha: 0.6),
          ),
          _buildGlowCircle(
            bottom: -40,
            right: -40,
            size: 200,
            color: const Color(0xFF3B7DFF).withValues(alpha: 0.3),
          ),

          // ---- Main content ----
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 920),
                child: _buildResponsiveLayout(context, authState),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveLayout(BuildContext context, AuthState authState) {
    final isWide = MediaQuery.sizeOf(context).width >= Breakpoints.tablet;

    if (isWide) {
      // ---- Desktop / Tablet: side-by-side ----
      return Container(
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.all(48),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left column: branding
            Expanded(child: _buildBrandingColumn()),
            const SizedBox(width: 48),
            // Right column: form
            Expanded(child: _buildFormColumn(authState)),
          ],
        ),
      );
    }

    // ---- Mobile: stacked ----
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBrandingColumn(),
        const SizedBox(height: 32),
        _buildFormColumn(authState),
      ],
    );
  }

  // ---- Branding column (left side) ----
  Widget _buildBrandingColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: const Text(
                'M',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Makromedia',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 48),
        const Text(
          'WELCOME BACK!',
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Please sign in to access your\ndashboard and manage everything in\none place.',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w400,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  // ---- Form column (right side) ----
  Widget _buildFormColumn(AuthState authState) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Email field
          const Text(
            'Email',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            style: const TextStyle(color: Colors.white),
            decoration: _loginInputDecoration(hintText: 'Enter your email'),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Email wajib diisi';
              }
              final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
              if (!emailRegex.hasMatch(value.trim())) {
                return 'Format email tidak valid';
              }
              return null;
            },
          ),

          const SizedBox(height: 24),

          // Password field
          const Text(
            'Password',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submit(),
            style: const TextStyle(color: Colors.white),
            decoration: _loginInputDecoration(
              hintText: 'Enter your password',
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Iconsax.eye_slash : Iconsax.eye,
                  color: Colors.white70,
                  size: 20,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Password wajib diisi';
              }
              if (value.length < 6) {
                return 'Password minimal 6 karakter';
              }
              return null;
            },
          ),

          const SizedBox(height: 8),

          // Forgot password
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                // TODO: navigasi ke halaman forgot password.
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white70,
                textStyle: const TextStyle(fontSize: 13),
              ),
              child: const Text('Forgot Password?'),
            ),
          ),

          const SizedBox(height: 16),

          // Login button
          SizedBox(
            height: 52,
            child: FilledButton(
              onPressed: authState.isLoading ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                disabledBackgroundColor: Colors.white60,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: authState.isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    )
                  : const Text('Login'),
            ),
          ),
        ],
      ),
    );
  }

  // ---- Shared input decoration for login fields ----
  InputDecoration _loginInputDecoration({
    String? hintText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
      suffixIcon: suffixIcon,
      filled: false,
      contentPadding: const EdgeInsets.symmetric(vertical: 14),
      border: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.white38),
      ),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.white38),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.white, width: 2),
      ),
      errorBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.dangerLight),
      ),
      focusedErrorBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.dangerLight, width: 2),
      ),
      errorStyle: const TextStyle(color: AppColors.dangerLight),
    );
  }

  // ---- Decorative glow circle ----
  Widget _buildGlowCircle({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required double size,
    required Color color,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color,
              blurRadius: 120,
              spreadRadius: 40,
            ),
          ],
        ),
      ),
    );
  }
}
