import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'auth_view_model.dart';
import '../utils/auth_error_handler.dart';
import '../../../l10n/app_localizations.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true; // Toggle between Login and Sign Up
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (ref.read(authViewModelProvider).isLoading) return;
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      if (_isLogin) {
        await ref.read(authViewModelProvider.notifier).signIn(email, password);
      } else {
        await ref.read(authViewModelProvider.notifier).signUp(email, password);
      }

      if (mounted && !ref.read(authViewModelProvider).hasError) {
        context.go('/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final isLoading = authState.isLoading;

    ref.listen(authViewModelProvider, (previous, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AuthErrorHandler.getErrorMessage(next.error!)),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 32),
                  Text(
                    _isLogin
                        ? AppLocalizations.of(context)!.loginTitle
                        : AppLocalizations.of(context)!.createAccountTitle,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.emailLabel,
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.email_outlined),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (value) =>
                        setState(() {}), // Trigger rebuild for validation icon
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.pleaseEnterEmail;
                      }
                      final emailRegex = RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      );
                      if (!emailRegex.hasMatch(value)) {
                        return AppLocalizations.of(context)!.invalidEmailFormat;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.passwordLabel,
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    obscureText: _obscurePassword,
                    onChanged: (value) =>
                        setState(() {}), // Trigger rebuild for validation icon
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(
                          context,
                        )!.pleaseEnterPassword;
                      }
                      if (value.length < 6) {
                        return AppLocalizations.of(context)!.passwordTooShort;
                      }
                      return null;
                    },
                  ),
                  if (_isLogin) ...[
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => context.push('/forgot-password'),
                        child: Text(
                          AppLocalizations.of(context)!.forgotPassword,
                        ),
                      ),
                    ),
                  ] else
                    const SizedBox(height: 24),

                  FilledButton(
                    onPressed: isLoading ? null : _submit,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              _isLogin
                                  ? AppLocalizations.of(context)!.loginButton
                                  : AppLocalizations.of(context)!.signUpButton,
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: isLoading
                        ? null
                        : () async {
                            await ref
                                .read(authViewModelProvider.notifier)
                                .signInWithGoogle();
                            if (mounted &&
                                context.mounted &&
                                !ref.read(authViewModelProvider).hasError) {
                              context.go('/home');
                            }
                          },
                    icon: const Icon(Icons.g_mobiledata, size: 28),
                    label: Text(
                      AppLocalizations.of(context)!.googleLoginButton,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.guestDialogTitle,
                                ),
                                content: Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.guestDialogMessage,
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: Text(
                                      AppLocalizations.of(
                                        context,
                                      )!.cancelButton,
                                    ),
                                  ),
                                  FilledButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: Text(
                                      AppLocalizations.of(
                                        context,
                                      )!.continueButton,
                                    ),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true && mounted) {
                              try {
                                // Add timeout to prevent infinite loading
                                await ref
                                    .read(authViewModelProvider.notifier)
                                    .signInAnonymously()
                                    .timeout(
                                      const Duration(seconds: 10),
                                      onTimeout: () {
                                        // Check if auth succeeded despite timeout
                                        if (mounted) {
                                          final authState = ref.read(
                                            authViewModelProvider,
                                          );
                                          if (!authState.hasError) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Signed in successfully (slow connection)',
                                                ),
                                                duration: Duration(seconds: 2),
                                              ),
                                            );
                                          } else {
                                            throw TimeoutException(
                                              'Guest login timed out',
                                            );
                                          }
                                        }
                                      },
                                    );

                                if (mounted && context.mounted) {
                                  final authState = ref.read(
                                    authViewModelProvider,
                                  );
                                  if (!authState.hasError) {
                                    context.go('/home');
                                  }
                                }
                              } on TimeoutException {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Connection is slow. Please try again.',
                                      ),
                                      backgroundColor: Colors.orange,
                                      duration: Duration(seconds: 3),
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error: ${e.toString()}'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            }
                          },
                    child: Text(AppLocalizations.of(context)!.guestLoginButton),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isLogin
                            ? AppLocalizations.of(context)!.dontHaveAccount
                            : AppLocalizations.of(context)!.alreadyHaveAccount,
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isLogin = !_isLogin;
                            _formKey.currentState?.reset();
                            _emailController.clear();
                            _passwordController.clear();
                          });
                        },
                        child: Text(
                          _isLogin
                              ? AppLocalizations.of(context)!.signUpButton
                              : AppLocalizations.of(context)!.loginButton,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
