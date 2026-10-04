import '../mock/mock_account.dart';
import '../models/account_profile.dart';
import '../models/account_settings.dart';

class AccountService {
  static AccountProfile? _currentUser = AccountProfile.fromJson(
    mockSignedInAccount,
  );
  static String _currencyCode = 'MYR';
  static NotificationPreferences _notifications =
      const NotificationPreferences();
  static ComfortTravelSettings _comfortSettings = const ComfortTravelSettings();

  Future<AccountProfile?> getCurrentUser() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return _currentUser;
  }

  Future<void> signOut() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    _currentUser = null;
  }

  Future<AccountProfile> updateProfile(AccountProfile profile) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    _currentUser = profile;
    return profile;
  }

  Future<String> getCurrency() async => _currencyCode;

  Future<String> setCurrency(String currencyCode) async {
    _currencyCode = currencyCode;
    return _currencyCode;
  }

  Future<NotificationPreferences> getNotifications() async => _notifications;

  Future<NotificationPreferences> setNotifications(
    NotificationPreferences preferences,
  ) async {
    _notifications = preferences;
    return preferences;
  }

  Future<ComfortTravelSettings> getComfortSettings() async => _comfortSettings;

  Future<ComfortTravelSettings> setComfortSettings(
    ComfortTravelSettings settings,
  ) async {
    _comfortSettings = settings;
    return settings;
  }

  Future<AccountProfile> signIn({
    required String email,
    required String password,
  }) async {
    if (email.trim().isEmpty || password.isEmpty) {
      throw ArgumentError('Enter both an email address and password.');
    }

    await Future<void>.delayed(const Duration(milliseconds: 250));
    _currentUser = AccountProfile.fromJson({
      ...mockSignedInAccount,
      'name': email.trim().split('@').first,
    });
    return _currentUser!;
  }
}
