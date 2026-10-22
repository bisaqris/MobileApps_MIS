import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('WELCOME BACK!', style: textTheme.headlineMedium),
                    const SizedBox(height: 8),
                    Text(
                      'Please sign in to access your dashboard and manage everything in one place.',
                      style: textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    const TextField(decoration: InputDecoration(labelText: 'Email')),
                    const SizedBox(height: 16),
                    const TextField(obscureText: true, decoration: InputDecoration(labelText: 'Password')),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(onPressed: () {}, child: const Text('Forgot Password?')),
                    ),
                    const SizedBox(height: 8),
                    FilledButton(onPressed: () => context.go(AppRoutes.dashboard), child: const Text('Login')),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
