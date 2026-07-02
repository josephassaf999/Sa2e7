/// Provider-based Auth State Management Guide
///
/// The app now uses Provider to manage authentication state globally.
/// This eliminates the need to repeatedly call FirebaseAuth.instance throughout the app.
///
/// To access the current user in any widget:
///
/// ```dart
/// import 'package:firebase_auth/firebase_auth.dart';
/// import 'package:provider/provider.dart';
///
/// class MyPage extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     // Watch for auth state changes - rebuilds when user logs in/out
///     final user = context.watch<User?>();
///
///     if (user == null) {
///       return const LoginPage();
///     }
///
///     return HomePage(user: user);
///   }
/// }
/// ```
///
/// Key methods:
/// - `context.watch<User?>()` - Watches for changes, rebuilds widget
/// - `context.read<User?>()` - Reads current value without watching (use in callbacks)
///
/// Examples:
///
/// 1. Conditional rendering based on auth state:
/// ```dart
/// final user = context.watch<User?>();
/// return user != null ? HomePage() : LoginPage();
/// ```
///
/// 2. Getting user data in a callback (non-rebuild context):
/// ```dart
/// onPressed: () {
///   final user = context.read<User?>();
///   if (user != null) {
///     print('User: ${user.email}');
///   }
/// }
/// ```
///
/// 3. Getting user UID for database queries:
/// ```dart
/// final user = context.watch<User?>();
/// final uid = user?.uid ?? 'anonymous';
/// ```
///
/// Benefits:
/// - Single source of truth for auth state
/// - Automatic rebuilds when auth state changes
/// - No need for manual listeners
/// - Cleaner code with less boilerplate
/// - Easier testing and debugging
class AuthStateProvider {
  // This is just a marker class for documentation.
  // Actual provider is set up in main.dart with StreamProvider<User?>
}
