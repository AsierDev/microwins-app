import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'auth_view_model.dart';
import '../utils/auth_error_handler.dart';
import '../../../l10n/app_localizations.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();

      await ref.read(authViewModelProvider.notifier).resetPassword(email);

      if (mounted && !ref.read(authViewModelProvider).hasError) {
        setState(() {
          _emailSent = true;
        });
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
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.resetPasswordTitle),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: _emailSent
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.mark_email_read_outlined,
                        size: 80,
                        color: Colors.green,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        AppLocalizations.of(context)!.resetPasswordSuccess,
                        style: Theme.of(context).textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      FilledButton(
                        onPressed: () => context.pop(),
                        child: Text(AppLocalizations.of(context)!.backToLogin),
                      ),
                    ],
                  )
                : Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Icon(
                          Icons.lock_reset,
                          size: 80,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          AppLocalizations.of(context)!.resetPasswordTitle,
                          style: Theme.of(context).textTheme.headlineMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppLocalizations.of(context)!.resetPasswordPrompt,
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
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppLocalizations.of(
                                context,
                              )!.pleaseEnterEmail;
                            }
                            final emailRegex = RegExp(
                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                            );
                            if (!emailRegex.hasMatch(value)) {
                              return AppLocalizations.of(
                                context,
                              )!.invalidEmailFormat;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        FilledButton(
                          onPressed: isLoading ? null : _submit,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.sendLinkButton,
                                  ),
                          ),
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
