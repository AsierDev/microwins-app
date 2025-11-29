// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Micro Wins';

  @override
  String get loginTitle => 'Welcome Back';

  @override
  String get createAccountTitle => 'Create Account';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get loginButton => 'Login';

  @override
  String get signUpButton => 'Sign Up';

  @override
  String get googleLoginButton => 'Continue with Google';

  @override
  String get guestLoginButton => 'Continue as Guest';

  @override
  String get guestDialogTitle => 'Continue as Guest?';

  @override
  String get guestDialogMessage =>
      'Your data will only be saved on this device. Sign up later to backup your habits.';

  @override
  String get dontHaveAccount => 'Don\'t have an account? ';

  @override
  String get alreadyHaveAccount => 'Already have an account? ';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get continueButton => 'Continue';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get resetPasswordTitle => 'Reset Password';

  @override
  String get backToLogin => 'Back to Login';

  @override
  String get sendLinkButton => 'Send Link';

  @override
  String get resetPasswordSuccess =>
      'If an account exists with this email, you will receive a password reset link.';

  @override
  String get resetPasswordPrompt =>
      'Enter your email address and we\'ll send you a link to reset your password.';

  @override
  String get pleaseEnterEmail => 'Please enter your email';

  @override
  String get invalidEmailFormat => 'Invalid email format';

  @override
  String get pleaseEnterPassword => 'Please enter your password';

  @override
  String get passwordTooShort => 'Password too short';

  @override
  String get homeTab => 'Home';

  @override
  String get habitsTab => 'Habits';

  @override
  String get progressTab => 'Progress';

  @override
  String get profileTab => 'Profile';

  @override
  String get newHabitTitle => 'New Habit';

  @override
  String get editHabitTitle => 'Edit Habit';

  @override
  String get habitNameLabel => 'Habit Name';

  @override
  String get habitNameHint => 'e.g., Drink Water';

  @override
  String get pleaseEnterName => 'Please enter a name';

  @override
  String get iconLabel => 'Icon';

  @override
  String get categoryLabel => 'Category';

  @override
  String get durationLabel => 'Duration';

  @override
  String get saveChangesButton => 'Save Changes';

  @override
  String get createHabitButton => 'Create Habit';

  @override
  String get categoryHealth => 'Health';

  @override
  String get categoryProductivity => 'Productivity';

  @override
  String get categoryWellness => 'Wellness';

  @override
  String get categoryLearning => 'Learning';

  @override
  String get categoryFitness => 'Fitness';

  @override
  String get habitCreatedSuccess => 'Habit created successfully!';

  @override
  String get habitUpdatedSuccess => 'Habit updated successfully!';

  @override
  String get errorTitle => 'Error';

  @override
  String get failedToCreateHabit => 'Failed to create habit';

  @override
  String get okButton => 'OK';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get darkModeLabel => 'Dark Mode';

  @override
  String get notificationsLabel => 'Notifications';

  @override
  String get reminderTimeLabel => 'Reminder Time';

  @override
  String get testNotificationLabel => 'Test Notification';

  @override
  String get privacyPolicyLabel => 'Privacy Policy';

  @override
  String get deleteAccountLabel => 'Delete Account';

  @override
  String get logoutButton => 'Logout';

  @override
  String get deleteAccountDialogTitle => 'Delete Account?';

  @override
  String get deleteAccountDialogMessage =>
      'This will permanently delete all your data. This action cannot be undone.';

  @override
  String get confirmButton => 'Confirm';

  @override
  String get discoverTitle => 'Discover';

  @override
  String get discoverSubtitle => 'Discover personalized micro-habits';

  @override
  String get goalPromptLabel => 'What is your goal?';

  @override
  String get goalPromptHint => 'e.g., Sleep better, Learn Spanish';

  @override
  String get getSuggestionsButton => 'Get Suggestions';

  @override
  String get loadingSuggestions => 'Finding perfect habits for you...';

  @override
  String get errorLoadingSuggestions =>
      'Failed to load suggestions. Please try again.';

  @override
  String get progressTitle => 'Your Progress';

  @override
  String get streaksTitle => 'Streaks';

  @override
  String get currentStreakLabel => 'Current Streak';

  @override
  String get bestStreakLabel => 'Best Streak';

  @override
  String get totalHabitsLabel => 'Total Habits';

  @override
  String get activeTodayLabel => 'Active Today';

  @override
  String get onboardingTitle1 => 'Build habits in just\n2-5 minutes';

  @override
  String get onboardingSubtitle1 =>
      'Small actions lead to big results. Start with micro-habits that are easy to stick to.';

  @override
  String get onboardingTitle2 => 'Track streaks,\nearn badges';

  @override
  String get onboardingSubtitle2 =>
      'Stay motivated by keeping your streak alive and unlocking achievements.';

  @override
  String get onboardingTitle3 => 'AI-powered habit\nsuggestions';

  @override
  String get onboardingSubtitle3 =>
      'Not sure where to start? Let AI generate personalized micro-routines for you.';

  @override
  String get getStartedButton => 'Get Started';

  @override
  String get privacyPolicyTitle => 'Privacy Policy';

  @override
  String get privacyPolicyContent =>
      'We respect your privacy. Your data is stored securely and never shared with third parties.';

  @override
  String get notificationTitle => 'Time for your habits!';

  @override
  String notificationBody(Object count) {
    return 'You have $count habits waiting for you today.';
  }

  @override
  String get noHabitsYet => 'No habits yet. Start small!';

  @override
  String get createFirstHabit => 'Create First Habit';

  @override
  String get confirmDeleteTitle => 'Confirm';

  @override
  String get confirmDeleteMessage =>
      'Are you sure you want to delete this habit?';

  @override
  String get totalHabits => 'Total Habits';

  @override
  String get completedToday => 'Completed Today';

  @override
  String get weeklyCompletion => 'Weekly Completion';

  @override
  String get discoverHabits => 'Discover Habits';

  @override
  String get whatIsYourGoal => 'What is your goal?';

  @override
  String get sleepBetter => 'Sleep Better';

  @override
  String get reduceStress => 'Reduce Stress';

  @override
  String get learnSkill => 'Learn a Skill';

  @override
  String get stayHydrated => 'Stay Hydrated';

  @override
  String get enterGoalPrompt => 'Enter a goal to generate micro-habits!';

  @override
  String get statistics => 'Statistics';

  @override
  String get bestStreak => 'Best Streak';

  @override
  String get receiveDailyReminders => 'Receive daily habit reminders';

  @override
  String get useDarkTheme => 'Use dark theme';

  @override
  String get optimizeNotifications => 'Optimize Notifications';

  @override
  String get disableBatteryRestrictions =>
      'Disable battery restrictions for accurate reminders';

  @override
  String get enableUnrestrictedBattery => 'Enable Unrestricted Battery';

  @override
  String get batteryDialogMessage =>
      'To ensure reminders arrive on time, please disable battery restrictions for MicroWins.';

  @override
  String get batteryStep1 => '1. Tap \'Go to Settings\'';

  @override
  String get batteryStep2 => '2. Tap \'App battery usage\' or \'Battery\'';

  @override
  String get batteryStep3 =>
      '3. Select \'Unrestricted\' or \'No restrictions\'';

  @override
  String get goToSettings => 'Go to Settings';
}
