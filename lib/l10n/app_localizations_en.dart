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

  @override
  String get gamificationBadgesAndLevels => 'Badges and Levels';

  @override
  String gamificationExperience(Object exp) {
    return 'Experience: $exp EXP';
  }

  @override
  String gamificationExpToNextLevel(Object exp) {
    return '$exp EXP to next level';
  }

  @override
  String get gamificationStatistics => 'Statistics';

  @override
  String get gamificationCurrentStreak => 'Current Streak';

  @override
  String get gamificationBestStreak => 'Best Streak';

  @override
  String get gamificationTotalCompleted => 'Total Completed';

  @override
  String get gamificationAchievementCollection => 'Achievement Collection';

  @override
  String gamificationUnlockedCount(Object total, Object unlocked) {
    return '$total/$unlocked unlocked';
  }

  @override
  String get gamificationLoadingAchievements => 'Loading your achievements...';

  @override
  String get gamificationErrorLoadingAchievements =>
      'Error loading achievements';

  @override
  String get gamificationRetry => 'Retry';

  @override
  String get gamificationAchievementUnlocked => 'Achievement Unlocked!';

  @override
  String get gamificationNewAchievementUnlocked => 'New Achievement Unlocked!';

  @override
  String get gamificationViewAchievements => 'View Achievements';

  @override
  String get gamificationActiveHabits => 'Active habits';

  @override
  String get gamificationWeeklyProgress => 'Weekly progress';

  @override
  String get gamificationMonday => 'Monday';

  @override
  String get gamificationTuesday => 'Tuesday';

  @override
  String get gamificationWednesday => 'Wednesday';

  @override
  String get gamificationThursday => 'Thursday';

  @override
  String get gamificationFriday => 'Friday';

  @override
  String get gamificationSaturday => 'Saturday';

  @override
  String get gamificationSunday => 'Sunday';

  @override
  String gamificationCompletedCount(Object count, Object s) {
    return '$count completed';
  }

  @override
  String get gamificationNoChangeFromLastWeek => 'No change from last week';

  @override
  String gamificationBetterThanLastWeek(Object progress) {
    return '$progress% better vs same period last week';
  }

  @override
  String gamificationWorseThanLastWeek(Object progress) {
    return '$progress% worse vs same period last week';
  }

  @override
  String gamificationStartJourney(Object habits) {
    return 'Start your journey! You have $habits habits to complete today.';
  }

  @override
  String gamificationDoingWell(Object habits, Object s) {
    return 'You\'re doing well! Only $habits habit$s more to your goal.';
  }

  @override
  String get gamificationPerfectDay =>
      'Perfect! You\'ve completed all your habits today. Keep it up!';

  @override
  String get gamificationCreateFirstHabit =>
      'Create your first habit to start your progress journey.';

  @override
  String get gamificationLoadingProgress => 'Loading your progress...';

  @override
  String get gamificationErrorOccurred => 'An error occurred';

  @override
  String get gamificationBadgeTypeStreakMaster => 'Streak Master';

  @override
  String get gamificationBadgeTypeConsistencyChampion => 'Consistency Champion';

  @override
  String get gamificationBadgeTypeWeeklyWarrior => 'Weekly Warrior';

  @override
  String get gamificationBadgeTypeMilestoneMaster => 'Milestone Master';

  @override
  String get gamificationBadgeTypePerfectWeek => 'Perfect Week';

  @override
  String get gamificationBadgeRarityCommon => 'Common';

  @override
  String get gamificationBadgeRarityUncommon => 'Uncommon';

  @override
  String get gamificationBadgeRarityRare => 'Rare';

  @override
  String get gamificationBadgeRarityEpic => 'Epic';

  @override
  String get gamificationBadgeRarityLegendary => 'Legendary';

  @override
  String get gamificationLevelTitle1 => 'Beginner';

  @override
  String get gamificationLevelTitle2 => 'Novice';

  @override
  String get gamificationLevelTitle3 => 'Apprentice';

  @override
  String get gamificationLevelTitle4 => 'Practitioner';

  @override
  String get gamificationLevelTitle5 => 'Dedicated';

  @override
  String get gamificationLevelTitle6 => 'Committed';

  @override
  String get gamificationLevelTitle7 => 'Expert';

  @override
  String get gamificationLevelTitle8 => 'Master';

  @override
  String get gamificationLevelTitle9 => 'Grand Master';

  @override
  String get gamificationLevelTitle10 => 'Legend';

  @override
  String get gamificationBadgeNameGettingHot => 'Getting Hot';

  @override
  String get gamificationBadgeNamePerfectWeek => 'Perfect Week';

  @override
  String get gamificationBadgeNameLegendMonth => 'Legend Month';

  @override
  String get gamificationBadgeNameCentury => 'Century';

  @override
  String get gamificationBadgeNameConsistent => 'Consistent';

  @override
  String get gamificationBadgeNameVeryConsistent => 'Very Consistent';

  @override
  String get gamificationBadgeNameUnbreakable => 'Unbreakable';

  @override
  String get gamificationBadgeNameProductiveWeek => 'Productive Week';

  @override
  String get gamificationBadgeNameIntenseWeek => 'Intense Week';

  @override
  String get gamificationBadgeNameEpicWeek => 'Epic Week';

  @override
  String get gamificationBadgeNameFirstSteps => 'First Steps';

  @override
  String get gamificationBadgeNameHalfway => 'Halfway';

  @override
  String get gamificationBadgeNameCenturion => 'Centurion';

  @override
  String get gamificationBadgeNameHabitMaster => 'Habit Master';

  @override
  String get gamificationBadgeNamePerfectWeek3 => 'Perfect Week (3)';

  @override
  String get gamificationBadgeNamePerfectWeek5 => 'Perfect Week (5)';

  @override
  String get gamificationBadgeDescriptionGettingHot =>
      'Complete habits 3 days in a row';

  @override
  String get gamificationBadgeDescriptionPerfectWeek =>
      'Complete habits 7 days in a row';

  @override
  String get gamificationBadgeDescriptionLegendMonth =>
      'Complete habits 30 days in a row';

  @override
  String get gamificationBadgeDescriptionCentury =>
      'Complete habits 100 days in a row';

  @override
  String get gamificationBadgeDescriptionConsistent =>
      'Complete habits at least 7 days in a month';

  @override
  String get gamificationBadgeDescriptionVeryConsistent =>
      'Complete habits at least 20 days in a month';

  @override
  String get gamificationBadgeDescriptionUnbreakable =>
      'Complete habits every day of a month';

  @override
  String get gamificationBadgeDescriptionProductiveWeek =>
      'Complete 5 habits in a week';

  @override
  String get gamificationBadgeDescriptionIntenseWeek =>
      'Complete 10 habits in a week';

  @override
  String get gamificationBadgeDescriptionEpicWeek =>
      'Complete 20 habits in a week';

  @override
  String get gamificationBadgeDescriptionFirstSteps =>
      'Complete 10 habits in total';

  @override
  String get gamificationBadgeDescriptionHalfway =>
      'Complete 50 habits in total';

  @override
  String get gamificationBadgeDescriptionCenturion =>
      'Complete 100 habits in total';

  @override
  String get gamificationBadgeDescriptionHabitMaster =>
      'Complete 500 habits in total';

  @override
  String get gamificationBadgeDescriptionPerfectWeek3 =>
      'Complete all your habits during a week (3+ habits)';

  @override
  String get gamificationBadgeDescriptionPerfectWeek5 =>
      'Complete all your habits during a week (5+ habits)';

  @override
  String get gamificationSupremeLegend => 'Supreme Legend';

  @override
  String get themeLabel => 'App Theme';

  @override
  String get themeSystem => 'System Default';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystemSubtitle => 'Follows device settings';

  @override
  String get sendFeedbackLabel => 'Send Feedback';

  @override
  String get sendFeedbackSubtitle => 'Report issues or suggest features';

  @override
  String get skipButton => 'Skip';

  @override
  String get viewTutorialLabel => 'View Tutorial';

  @override
  String get viewTutorialSubtitle => 'Revisit the onboarding guide';

  @override
  String get nextButton => 'Next';

  @override
  String get deleteAccountSubtitle =>
      'Permanently delete your account and data';
}
