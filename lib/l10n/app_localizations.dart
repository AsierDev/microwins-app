import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('pt'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Micro Wins'**
  String get appTitle;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get loginTitle;

  /// No description provided for @createAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccountTitle;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// No description provided for @signUpButton.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUpButton;

  /// No description provided for @googleLoginButton.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get googleLoginButton;

  /// No description provided for @guestLoginButton.
  ///
  /// In en, this message translates to:
  /// **'Continue as Guest'**
  String get guestLoginButton;

  /// No description provided for @guestDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Continue as Guest?'**
  String get guestDialogTitle;

  /// No description provided for @guestDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'Your data will only be saved on this device. Sign up later to backup your habits.'**
  String get guestDialogMessage;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get dontHaveAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPasswordTitle;

  /// No description provided for @backToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get backToLogin;

  /// No description provided for @sendLinkButton.
  ///
  /// In en, this message translates to:
  /// **'Send Link'**
  String get sendLinkButton;

  /// No description provided for @resetPasswordSuccess.
  ///
  /// In en, this message translates to:
  /// **'If an account exists with this email, you will receive a password reset link.'**
  String get resetPasswordSuccess;

  /// No description provided for @resetPasswordPrompt.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address and we\'ll send you a link to reset your password.'**
  String get resetPasswordPrompt;

  /// No description provided for @pleaseEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get pleaseEnterEmail;

  /// No description provided for @invalidEmailFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid email format'**
  String get invalidEmailFormat;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get pleaseEnterPassword;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password too short'**
  String get passwordTooShort;

  /// No description provided for @homeTab.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTab;

  /// No description provided for @habitsTab.
  ///
  /// In en, this message translates to:
  /// **'Habits'**
  String get habitsTab;

  /// No description provided for @progressTab.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progressTab;

  /// No description provided for @profileTab.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTab;

  /// No description provided for @newHabitTitle.
  ///
  /// In en, this message translates to:
  /// **'New Habit'**
  String get newHabitTitle;

  /// No description provided for @editHabitTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Habit'**
  String get editHabitTitle;

  /// No description provided for @habitNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Habit Name'**
  String get habitNameLabel;

  /// No description provided for @habitNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Drink Water'**
  String get habitNameHint;

  /// No description provided for @pleaseEnterName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name'**
  String get pleaseEnterName;

  /// No description provided for @iconLabel.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get iconLabel;

  /// No description provided for @categoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryLabel;

  /// No description provided for @durationLabel.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get durationLabel;

  /// No description provided for @saveChangesButton.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChangesButton;

  /// No description provided for @createHabitButton.
  ///
  /// In en, this message translates to:
  /// **'Create Habit'**
  String get createHabitButton;

  /// No description provided for @categoryHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get categoryHealth;

  /// No description provided for @categoryProductivity.
  ///
  /// In en, this message translates to:
  /// **'Productivity'**
  String get categoryProductivity;

  /// No description provided for @categoryWellness.
  ///
  /// In en, this message translates to:
  /// **'Wellness'**
  String get categoryWellness;

  /// No description provided for @categoryLearning.
  ///
  /// In en, this message translates to:
  /// **'Learning'**
  String get categoryLearning;

  /// No description provided for @categoryFitness.
  ///
  /// In en, this message translates to:
  /// **'Fitness'**
  String get categoryFitness;

  /// No description provided for @habitCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Habit created successfully!'**
  String get habitCreatedSuccess;

  /// No description provided for @habitUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Habit updated successfully!'**
  String get habitUpdatedSuccess;

  /// No description provided for @errorTitle.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorTitle;

  /// No description provided for @failedToCreateHabit.
  ///
  /// In en, this message translates to:
  /// **'Failed to create habit'**
  String get failedToCreateHabit;

  /// No description provided for @okButton.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get okButton;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @darkModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkModeLabel;

  /// No description provided for @notificationsLabel.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsLabel;

  /// No description provided for @reminderTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Reminder Time'**
  String get reminderTimeLabel;

  /// No description provided for @testNotificationLabel.
  ///
  /// In en, this message translates to:
  /// **'Test Notification'**
  String get testNotificationLabel;

  /// No description provided for @privacyPolicyLabel.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicyLabel;

  /// No description provided for @deleteAccountLabel.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccountLabel;

  /// No description provided for @logoutButton.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutButton;

  /// No description provided for @deleteAccountDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Account?'**
  String get deleteAccountDialogTitle;

  /// No description provided for @deleteAccountDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete all your data. This action cannot be undone.'**
  String get deleteAccountDialogMessage;

  /// No description provided for @confirmButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirmButton;

  /// No description provided for @discoverTitle.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get discoverTitle;

  /// No description provided for @discoverSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Discover personalized micro-habits'**
  String get discoverSubtitle;

  /// No description provided for @goalPromptLabel.
  ///
  /// In en, this message translates to:
  /// **'What is your goal?'**
  String get goalPromptLabel;

  /// No description provided for @goalPromptHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Sleep better, Learn Spanish'**
  String get goalPromptHint;

  /// No description provided for @getSuggestionsButton.
  ///
  /// In en, this message translates to:
  /// **'Get Suggestions'**
  String get getSuggestionsButton;

  /// No description provided for @loadingSuggestions.
  ///
  /// In en, this message translates to:
  /// **'Finding perfect habits for you...'**
  String get loadingSuggestions;

  /// No description provided for @errorLoadingSuggestions.
  ///
  /// In en, this message translates to:
  /// **'Failed to load suggestions. Please try again.'**
  String get errorLoadingSuggestions;

  /// No description provided for @progressTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Progress'**
  String get progressTitle;

  /// No description provided for @streaksTitle.
  ///
  /// In en, this message translates to:
  /// **'Streaks'**
  String get streaksTitle;

  /// No description provided for @currentStreakLabel.
  ///
  /// In en, this message translates to:
  /// **'Current Streak'**
  String get currentStreakLabel;

  /// No description provided for @bestStreakLabel.
  ///
  /// In en, this message translates to:
  /// **'Best Streak'**
  String get bestStreakLabel;

  /// No description provided for @totalHabitsLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Habits'**
  String get totalHabitsLabel;

  /// No description provided for @activeTodayLabel.
  ///
  /// In en, this message translates to:
  /// **'Active Today'**
  String get activeTodayLabel;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Build habits in just\n2-5 minutes'**
  String get onboardingTitle1;

  /// No description provided for @onboardingSubtitle1.
  ///
  /// In en, this message translates to:
  /// **'Small actions lead to big results. Start with micro-habits that are easy to stick to.'**
  String get onboardingSubtitle1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Track streaks,\nearn badges'**
  String get onboardingTitle2;

  /// No description provided for @onboardingSubtitle2.
  ///
  /// In en, this message translates to:
  /// **'Stay motivated by keeping your streak alive and unlocking achievements.'**
  String get onboardingSubtitle2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'AI-powered habit\nsuggestions'**
  String get onboardingTitle3;

  /// No description provided for @onboardingSubtitle3.
  ///
  /// In en, this message translates to:
  /// **'Not sure where to start? Let AI generate personalized micro-routines for you.'**
  String get onboardingSubtitle3;

  /// No description provided for @getStartedButton.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStartedButton;

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicyTitle;

  /// No description provided for @privacyPolicyContent.
  ///
  /// In en, this message translates to:
  /// **'We respect your privacy. Your data is stored securely and never shared with third parties.'**
  String get privacyPolicyContent;

  /// No description provided for @notificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Time for your habits!'**
  String get notificationTitle;

  /// No description provided for @notificationBody.
  ///
  /// In en, this message translates to:
  /// **'You have {count} habits waiting for you today.'**
  String notificationBody(Object count);

  /// No description provided for @noHabitsYet.
  ///
  /// In en, this message translates to:
  /// **'No habits yet. Start small!'**
  String get noHabitsYet;

  /// No description provided for @createFirstHabit.
  ///
  /// In en, this message translates to:
  /// **'Create First Habit'**
  String get createFirstHabit;

  /// No description provided for @confirmDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirmDeleteTitle;

  /// No description provided for @confirmDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this habit?'**
  String get confirmDeleteMessage;

  /// No description provided for @totalHabits.
  ///
  /// In en, this message translates to:
  /// **'Total Habits'**
  String get totalHabits;

  /// No description provided for @completedToday.
  ///
  /// In en, this message translates to:
  /// **'Completed Today'**
  String get completedToday;

  /// No description provided for @weeklyCompletion.
  ///
  /// In en, this message translates to:
  /// **'Weekly Completion'**
  String get weeklyCompletion;

  /// No description provided for @discoverHabits.
  ///
  /// In en, this message translates to:
  /// **'Discover Habits'**
  String get discoverHabits;

  /// No description provided for @whatIsYourGoal.
  ///
  /// In en, this message translates to:
  /// **'What is your goal?'**
  String get whatIsYourGoal;

  /// No description provided for @sleepBetter.
  ///
  /// In en, this message translates to:
  /// **'Sleep Better'**
  String get sleepBetter;

  /// No description provided for @reduceStress.
  ///
  /// In en, this message translates to:
  /// **'Reduce Stress'**
  String get reduceStress;

  /// No description provided for @learnSkill.
  ///
  /// In en, this message translates to:
  /// **'Learn a Skill'**
  String get learnSkill;

  /// No description provided for @stayHydrated.
  ///
  /// In en, this message translates to:
  /// **'Stay Hydrated'**
  String get stayHydrated;

  /// No description provided for @enterGoalPrompt.
  ///
  /// In en, this message translates to:
  /// **'Enter a goal to generate micro-habits!'**
  String get enterGoalPrompt;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @bestStreak.
  ///
  /// In en, this message translates to:
  /// **'Best Streak'**
  String get bestStreak;

  /// No description provided for @receiveDailyReminders.
  ///
  /// In en, this message translates to:
  /// **'Receive daily habit reminders'**
  String get receiveDailyReminders;

  /// No description provided for @useDarkTheme.
  ///
  /// In en, this message translates to:
  /// **'Use dark theme'**
  String get useDarkTheme;

  /// No description provided for @optimizeNotifications.
  ///
  /// In en, this message translates to:
  /// **'Optimize Notifications'**
  String get optimizeNotifications;

  /// No description provided for @disableBatteryRestrictions.
  ///
  /// In en, this message translates to:
  /// **'Disable battery restrictions for accurate reminders'**
  String get disableBatteryRestrictions;

  /// No description provided for @enableUnrestrictedBattery.
  ///
  /// In en, this message translates to:
  /// **'Enable Unrestricted Battery'**
  String get enableUnrestrictedBattery;

  /// No description provided for @batteryDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'To ensure reminders arrive on time, please disable battery restrictions for MicroWins.'**
  String get batteryDialogMessage;

  /// No description provided for @batteryStep1.
  ///
  /// In en, this message translates to:
  /// **'1. Tap \'Go to Settings\''**
  String get batteryStep1;

  /// No description provided for @batteryStep2.
  ///
  /// In en, this message translates to:
  /// **'2. Tap \'App battery usage\' or \'Battery\''**
  String get batteryStep2;

  /// No description provided for @batteryStep3.
  ///
  /// In en, this message translates to:
  /// **'3. Select \'Unrestricted\' or \'No restrictions\''**
  String get batteryStep3;

  /// No description provided for @goToSettings.
  ///
  /// In en, this message translates to:
  /// **'Go to Settings'**
  String get goToSettings;

  /// No description provided for @gamificationBadgesAndLevels.
  ///
  /// In en, this message translates to:
  /// **'Badges and Levels'**
  String get gamificationBadgesAndLevels;

  /// No description provided for @gamificationExperience.
  ///
  /// In en, this message translates to:
  /// **'Experience: {exp} EXP'**
  String gamificationExperience(Object exp);

  /// No description provided for @gamificationExpToNextLevel.
  ///
  /// In en, this message translates to:
  /// **'{exp} EXP to next level'**
  String gamificationExpToNextLevel(Object exp);

  /// No description provided for @gamificationStatistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get gamificationStatistics;

  /// No description provided for @gamificationCurrentStreak.
  ///
  /// In en, this message translates to:
  /// **'Current Streak'**
  String get gamificationCurrentStreak;

  /// No description provided for @gamificationBestStreak.
  ///
  /// In en, this message translates to:
  /// **'Best Streak'**
  String get gamificationBestStreak;

  /// No description provided for @gamificationTotalCompleted.
  ///
  /// In en, this message translates to:
  /// **'Total Completed'**
  String get gamificationTotalCompleted;

  /// No description provided for @gamificationAchievementCollection.
  ///
  /// In en, this message translates to:
  /// **'Achievement Collection'**
  String get gamificationAchievementCollection;

  /// No description provided for @gamificationUnlockedCount.
  ///
  /// In en, this message translates to:
  /// **'{total}/{unlocked} unlocked'**
  String gamificationUnlockedCount(Object total, Object unlocked);

  /// No description provided for @gamificationLoadingAchievements.
  ///
  /// In en, this message translates to:
  /// **'Loading your achievements...'**
  String get gamificationLoadingAchievements;

  /// No description provided for @gamificationErrorLoadingAchievements.
  ///
  /// In en, this message translates to:
  /// **'Error loading achievements'**
  String get gamificationErrorLoadingAchievements;

  /// No description provided for @gamificationRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get gamificationRetry;

  /// No description provided for @gamificationAchievementUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Achievement Unlocked!'**
  String get gamificationAchievementUnlocked;

  /// No description provided for @gamificationNewAchievementUnlocked.
  ///
  /// In en, this message translates to:
  /// **'New Achievement Unlocked!'**
  String get gamificationNewAchievementUnlocked;

  /// No description provided for @gamificationViewAchievements.
  ///
  /// In en, this message translates to:
  /// **'View Achievements'**
  String get gamificationViewAchievements;

  /// No description provided for @gamificationActiveHabits.
  ///
  /// In en, this message translates to:
  /// **'Active habits'**
  String get gamificationActiveHabits;

  /// No description provided for @gamificationWeeklyProgress.
  ///
  /// In en, this message translates to:
  /// **'Weekly progress'**
  String get gamificationWeeklyProgress;

  /// No description provided for @gamificationMonday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get gamificationMonday;

  /// No description provided for @gamificationTuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get gamificationTuesday;

  /// No description provided for @gamificationWednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get gamificationWednesday;

  /// No description provided for @gamificationThursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get gamificationThursday;

  /// No description provided for @gamificationFriday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get gamificationFriday;

  /// No description provided for @gamificationSaturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get gamificationSaturday;

  /// No description provided for @gamificationSunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get gamificationSunday;

  /// No description provided for @gamificationCompletedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} completed'**
  String gamificationCompletedCount(Object count, Object s);

  /// No description provided for @gamificationNoChangeFromLastWeek.
  ///
  /// In en, this message translates to:
  /// **'No change from last week'**
  String get gamificationNoChangeFromLastWeek;

  /// No description provided for @gamificationBetterThanLastWeek.
  ///
  /// In en, this message translates to:
  /// **'{progress}% better vs same period last week'**
  String gamificationBetterThanLastWeek(Object progress);

  /// No description provided for @gamificationWorseThanLastWeek.
  ///
  /// In en, this message translates to:
  /// **'{progress}% worse vs same period last week'**
  String gamificationWorseThanLastWeek(Object progress);

  /// No description provided for @gamificationStartJourney.
  ///
  /// In en, this message translates to:
  /// **'Start your journey! You have {habits} habits to complete today.'**
  String gamificationStartJourney(Object habits);

  /// No description provided for @gamificationDoingWell.
  ///
  /// In en, this message translates to:
  /// **'You\'re doing well! Only {habits} habit{s} more to your goal.'**
  String gamificationDoingWell(Object habits, Object s);

  /// No description provided for @gamificationPerfectDay.
  ///
  /// In en, this message translates to:
  /// **'Perfect! You\'ve completed all your habits today. Keep it up!'**
  String get gamificationPerfectDay;

  /// No description provided for @gamificationCreateFirstHabit.
  ///
  /// In en, this message translates to:
  /// **'Create your first habit to start your progress journey.'**
  String get gamificationCreateFirstHabit;

  /// No description provided for @gamificationLoadingProgress.
  ///
  /// In en, this message translates to:
  /// **'Loading your progress...'**
  String get gamificationLoadingProgress;

  /// No description provided for @gamificationErrorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get gamificationErrorOccurred;

  /// No description provided for @gamificationBadgeTypeStreakMaster.
  ///
  /// In en, this message translates to:
  /// **'Streak Master'**
  String get gamificationBadgeTypeStreakMaster;

  /// No description provided for @gamificationBadgeTypeConsistencyChampion.
  ///
  /// In en, this message translates to:
  /// **'Consistency Champion'**
  String get gamificationBadgeTypeConsistencyChampion;

  /// No description provided for @gamificationBadgeTypeWeeklyWarrior.
  ///
  /// In en, this message translates to:
  /// **'Weekly Warrior'**
  String get gamificationBadgeTypeWeeklyWarrior;

  /// No description provided for @gamificationBadgeTypeMilestoneMaster.
  ///
  /// In en, this message translates to:
  /// **'Milestone Master'**
  String get gamificationBadgeTypeMilestoneMaster;

  /// No description provided for @gamificationBadgeTypePerfectWeek.
  ///
  /// In en, this message translates to:
  /// **'Perfect Week'**
  String get gamificationBadgeTypePerfectWeek;

  /// No description provided for @gamificationBadgeRarityCommon.
  ///
  /// In en, this message translates to:
  /// **'Common'**
  String get gamificationBadgeRarityCommon;

  /// No description provided for @gamificationBadgeRarityUncommon.
  ///
  /// In en, this message translates to:
  /// **'Uncommon'**
  String get gamificationBadgeRarityUncommon;

  /// No description provided for @gamificationBadgeRarityRare.
  ///
  /// In en, this message translates to:
  /// **'Rare'**
  String get gamificationBadgeRarityRare;

  /// No description provided for @gamificationBadgeRarityEpic.
  ///
  /// In en, this message translates to:
  /// **'Epic'**
  String get gamificationBadgeRarityEpic;

  /// No description provided for @gamificationBadgeRarityLegendary.
  ///
  /// In en, this message translates to:
  /// **'Legendary'**
  String get gamificationBadgeRarityLegendary;

  /// No description provided for @gamificationLevelTitle1.
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get gamificationLevelTitle1;

  /// No description provided for @gamificationLevelTitle2.
  ///
  /// In en, this message translates to:
  /// **'Novice'**
  String get gamificationLevelTitle2;

  /// No description provided for @gamificationLevelTitle3.
  ///
  /// In en, this message translates to:
  /// **'Apprentice'**
  String get gamificationLevelTitle3;

  /// No description provided for @gamificationLevelTitle4.
  ///
  /// In en, this message translates to:
  /// **'Practitioner'**
  String get gamificationLevelTitle4;

  /// No description provided for @gamificationLevelTitle5.
  ///
  /// In en, this message translates to:
  /// **'Dedicated'**
  String get gamificationLevelTitle5;

  /// No description provided for @gamificationLevelTitle6.
  ///
  /// In en, this message translates to:
  /// **'Committed'**
  String get gamificationLevelTitle6;

  /// No description provided for @gamificationLevelTitle7.
  ///
  /// In en, this message translates to:
  /// **'Expert'**
  String get gamificationLevelTitle7;

  /// No description provided for @gamificationLevelTitle8.
  ///
  /// In en, this message translates to:
  /// **'Master'**
  String get gamificationLevelTitle8;

  /// No description provided for @gamificationLevelTitle9.
  ///
  /// In en, this message translates to:
  /// **'Grand Master'**
  String get gamificationLevelTitle9;

  /// No description provided for @gamificationLevelTitle10.
  ///
  /// In en, this message translates to:
  /// **'Legend'**
  String get gamificationLevelTitle10;

  /// No description provided for @gamificationBadgeNameGettingHot.
  ///
  /// In en, this message translates to:
  /// **'Getting Hot'**
  String get gamificationBadgeNameGettingHot;

  /// No description provided for @gamificationBadgeNamePerfectWeek.
  ///
  /// In en, this message translates to:
  /// **'Perfect Week'**
  String get gamificationBadgeNamePerfectWeek;

  /// No description provided for @gamificationBadgeNameLegendMonth.
  ///
  /// In en, this message translates to:
  /// **'Legend Month'**
  String get gamificationBadgeNameLegendMonth;

  /// No description provided for @gamificationBadgeNameCentury.
  ///
  /// In en, this message translates to:
  /// **'Century'**
  String get gamificationBadgeNameCentury;

  /// No description provided for @gamificationBadgeNameConsistent.
  ///
  /// In en, this message translates to:
  /// **'Consistent'**
  String get gamificationBadgeNameConsistent;

  /// No description provided for @gamificationBadgeNameVeryConsistent.
  ///
  /// In en, this message translates to:
  /// **'Very Consistent'**
  String get gamificationBadgeNameVeryConsistent;

  /// No description provided for @gamificationBadgeNameUnbreakable.
  ///
  /// In en, this message translates to:
  /// **'Unbreakable'**
  String get gamificationBadgeNameUnbreakable;

  /// No description provided for @gamificationBadgeNameProductiveWeek.
  ///
  /// In en, this message translates to:
  /// **'Productive Week'**
  String get gamificationBadgeNameProductiveWeek;

  /// No description provided for @gamificationBadgeNameIntenseWeek.
  ///
  /// In en, this message translates to:
  /// **'Intense Week'**
  String get gamificationBadgeNameIntenseWeek;

  /// No description provided for @gamificationBadgeNameEpicWeek.
  ///
  /// In en, this message translates to:
  /// **'Epic Week'**
  String get gamificationBadgeNameEpicWeek;

  /// No description provided for @gamificationBadgeNameFirstSteps.
  ///
  /// In en, this message translates to:
  /// **'First Steps'**
  String get gamificationBadgeNameFirstSteps;

  /// No description provided for @gamificationBadgeNameHalfway.
  ///
  /// In en, this message translates to:
  /// **'Halfway'**
  String get gamificationBadgeNameHalfway;

  /// No description provided for @gamificationBadgeNameCenturion.
  ///
  /// In en, this message translates to:
  /// **'Centurion'**
  String get gamificationBadgeNameCenturion;

  /// No description provided for @gamificationBadgeNameHabitMaster.
  ///
  /// In en, this message translates to:
  /// **'Habit Master'**
  String get gamificationBadgeNameHabitMaster;

  /// No description provided for @gamificationBadgeNamePerfectWeek3.
  ///
  /// In en, this message translates to:
  /// **'Perfect Week (3)'**
  String get gamificationBadgeNamePerfectWeek3;

  /// No description provided for @gamificationBadgeNamePerfectWeek5.
  ///
  /// In en, this message translates to:
  /// **'Perfect Week (5)'**
  String get gamificationBadgeNamePerfectWeek5;

  /// No description provided for @gamificationBadgeDescriptionGettingHot.
  ///
  /// In en, this message translates to:
  /// **'Complete habits 3 days in a row'**
  String get gamificationBadgeDescriptionGettingHot;

  /// No description provided for @gamificationBadgeDescriptionPerfectWeek.
  ///
  /// In en, this message translates to:
  /// **'Complete habits 7 days in a row'**
  String get gamificationBadgeDescriptionPerfectWeek;

  /// No description provided for @gamificationBadgeDescriptionLegendMonth.
  ///
  /// In en, this message translates to:
  /// **'Complete habits 30 days in a row'**
  String get gamificationBadgeDescriptionLegendMonth;

  /// No description provided for @gamificationBadgeDescriptionCentury.
  ///
  /// In en, this message translates to:
  /// **'Complete habits 100 days in a row'**
  String get gamificationBadgeDescriptionCentury;

  /// No description provided for @gamificationBadgeDescriptionConsistent.
  ///
  /// In en, this message translates to:
  /// **'Complete habits at least 7 days in a month'**
  String get gamificationBadgeDescriptionConsistent;

  /// No description provided for @gamificationBadgeDescriptionVeryConsistent.
  ///
  /// In en, this message translates to:
  /// **'Complete habits at least 20 days in a month'**
  String get gamificationBadgeDescriptionVeryConsistent;

  /// No description provided for @gamificationBadgeDescriptionUnbreakable.
  ///
  /// In en, this message translates to:
  /// **'Complete habits every day of a month'**
  String get gamificationBadgeDescriptionUnbreakable;

  /// No description provided for @gamificationBadgeDescriptionProductiveWeek.
  ///
  /// In en, this message translates to:
  /// **'Complete 5 habits in a week'**
  String get gamificationBadgeDescriptionProductiveWeek;

  /// No description provided for @gamificationBadgeDescriptionIntenseWeek.
  ///
  /// In en, this message translates to:
  /// **'Complete 10 habits in a week'**
  String get gamificationBadgeDescriptionIntenseWeek;

  /// No description provided for @gamificationBadgeDescriptionEpicWeek.
  ///
  /// In en, this message translates to:
  /// **'Complete 20 habits in a week'**
  String get gamificationBadgeDescriptionEpicWeek;

  /// No description provided for @gamificationBadgeDescriptionFirstSteps.
  ///
  /// In en, this message translates to:
  /// **'Complete 10 habits in total'**
  String get gamificationBadgeDescriptionFirstSteps;

  /// No description provided for @gamificationBadgeDescriptionHalfway.
  ///
  /// In en, this message translates to:
  /// **'Complete 50 habits in total'**
  String get gamificationBadgeDescriptionHalfway;

  /// No description provided for @gamificationBadgeDescriptionCenturion.
  ///
  /// In en, this message translates to:
  /// **'Complete 100 habits in total'**
  String get gamificationBadgeDescriptionCenturion;

  /// No description provided for @gamificationBadgeDescriptionHabitMaster.
  ///
  /// In en, this message translates to:
  /// **'Complete 500 habits in total'**
  String get gamificationBadgeDescriptionHabitMaster;

  /// No description provided for @gamificationBadgeDescriptionPerfectWeek3.
  ///
  /// In en, this message translates to:
  /// **'Complete all your habits during a week (3+ habits)'**
  String get gamificationBadgeDescriptionPerfectWeek3;

  /// No description provided for @gamificationBadgeDescriptionPerfectWeek5.
  ///
  /// In en, this message translates to:
  /// **'Complete all your habits during a week (5+ habits)'**
  String get gamificationBadgeDescriptionPerfectWeek5;

  /// No description provided for @gamificationSupremeLegend.
  ///
  /// In en, this message translates to:
  /// **'Supreme Legend'**
  String get gamificationSupremeLegend;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'es', 'fr', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
