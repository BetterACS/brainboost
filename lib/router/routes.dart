// This file contains all the routes used in the app.

class Routes {
  Routes._();
  // Landing Page
  static const String landingPage = '/landing';
  static const String loginPage = 'login';
  static const String signUpPage = 'signup';
  static const String forgotPasswordPage = 'forgot-password';
  static const String resetPasswordPage = 'reset-password';
  static const String nestedLoginPage = '/landing/login';
  static const String nestedSignUpPage = '/landing/signup';
  static const String nestedForgotPasswordPage = '/landing/forgot-password';
  static const String nestedResetPasswordPage = '/landing/reset-password';

  // Home
  static const String homePage = '/home';
  
  // My Games
  static const String gamePage = '/games';

  // Create Game
  static const String createGamePage = 'create-game';
  static const String nestedCreateGamePageFromHome = '/home/create-game';
  static const String nestedCreateGamePageFromGame = '/games/create-game';
  
  // Play Game
  static const String playGamePage = '/play-game';

  // Result
  static const String resultPage = '/result';

  // Create Summary
  static const String createSummaryPage = 'create-summary';
  static const String nestedCreateSummaryPageFromGame = '/home/create-summary';
  static const String viewSummaryPage = 'view-summary';
  static const String nestedViewSummaryPageFromHistory = '/history/view-summary';
  static const String nestedViewSummaryPageFromHome = '/home/view-summary';

  // History
  static const String historyPage = '/history';

  // Profile
  static const String profilePage = '/profile';
  static const String editProfilePage = '/edit-profile';
  static const String nestedEditProfilePageFromProfile = '/profile/edit-profile';

  // Settings
  static const String settingsPage = '/settings';
  // static const String nestedSettingsPageFromProfile = '/profile/settings';
}
