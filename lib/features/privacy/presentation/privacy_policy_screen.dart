import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Button to view online version
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.open_in_new),
                label: const Text('View Online Version'),
                onPressed: () async {
                  final uri = Uri.parse(
                    'https://asierdev.github.io/microwins-app/privacy-policy.html',
                  );
                  try {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Could not open URL: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Privacy Policy',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Last updated: ${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              'Introduction',
              'MicroWins ("we", "our", or "us") respects your privacy and is committed to protecting your personal data. This privacy policy will inform you about how we look after your personal data when you use our mobile application and tell you about your privacy rights.',
            ),
            _buildSection(
              context,
              'Information We Collect',
              'We collect and process the following types of information:\n\n'
                  '• Account Information: When you sign in with Google, we collect your name, email address, and profile picture.\n\n'
                  '• Habit Data: We store your habits, including names, categories, completion history, and streaks.\n\n'
                  '• Device Information: We may collect device identifiers for analytics and crash reporting purposes.',
            ),
            _buildSection(
              context,
              'How We Use Your Information',
              'We use your information to:\n\n'
                  '• Provide and maintain our service\n\n'
                  '• Sync your habit data across your devices\n\n'
                  '• Send you notifications about your habits (if enabled)\n\n'
                  '• Improve our app and develop new features\n\n'
                  '• Communicate with you about updates and support',
            ),
            _buildSection(
              context,
              'Data Storage and Security',
              'Your habit data is stored locally on your device using Hive (local database) and synced to Firebase Firestore for cross-device access. We implement appropriate security measures to protect your data, but no method of transmission over the internet is 100% secure.',
            ),
            _buildSection(
              context,
              'Third-Party Services',
              'We use the following third-party services:\n\n'
                  '• Firebase (Google): For authentication and cloud storage\n\n'
                  '• Google Sign-In: For user authentication\n\n'
                  '• Google Mobile Ads: For displaying advertisements (if applicable)',
            ),
            _buildSection(
              context,
              'Your Rights',
              'You have the right to:\n\n'
                  '• Access your personal data\n\n'
                  '• Request correction of your personal data\n\n'
                  '• Request deletion of your personal data\n\n'
                  '• Object to processing of your personal data\n\n'
                  '• Request transfer of your personal data',
            ),
            _buildSection(
              context,
              'Data Retention',
              'We retain your personal data only for as long as necessary to provide you with our services and for legitimate business purposes. If you delete your account, we will delete your personal data within 30 days, except where we are required to retain it by law.',
            ),
            _buildSection(
              context,
              'Children\'s Privacy',
              'Our service is not directed to children under 13 years of age. We do not knowingly collect personal information from children under 13. If you are a parent or guardian and believe your child has provided us with personal information, please contact us.',
            ),
            _buildSection(
              context,
              'Changes to This Policy',
              'We may update this privacy policy from time to time. We will notify you of any changes by posting the new privacy policy on this page and updating the "Last updated" date.',
            ),
            _buildSection(
              context,
              'Contact Us',
              'If you have any questions about this privacy policy or our data practices, please contact us at:\n\n'
                  'Email: app.microwins@gmail.com',
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(height: 1.5),
          ),
        ],
      ),
    );
  }
}
