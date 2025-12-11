// Mock implementation of authentication service
// In a real app, you would use Firebase Auth or another auth provider
class AuthService {
  static String? _currentUserEmail;

  // Get current user email
  String? getCurrentUserEmail() {
    return _currentUserEmail;
  }

  // Check if user is signed in
  bool isSignedIn() {
    return _currentUserEmail != null;
  }

  // Sign in with email and password
  Future<bool> signInWithEmailAndPassword(
      String email, String password) async {
    // In a real implementation, you would validate credentials against a server
    // For demo purposes, we'll allow any valid email/password combination
    if (email.isNotEmpty && password.length >= 6) {
      _currentUserEmail = email;
      return true;
    }
    throw Exception('Invalid email or password - password must be at least 6 characters');
  }

  // Create account with email and password
  Future<bool> createAccountWithEmailAndPassword(
      String email, String password) async {
    // In a real implementation, you would create an account on a server
    // For demo purposes, we'll allow any valid email/password combination
    if (email.isNotEmpty && password.length >= 6) {
      _currentUserEmail = email;
      return true;
    }
    throw Exception('Invalid email or password - password must be at least 6 characters');
  }

  // Sign out
  Future<void> signOut() async {
    _currentUserEmail = null;
  }

  // Send password reset email (mock implementation)
  Future<void> sendPasswordResetEmail(String email) async {
    // In a real implementation, you would send a reset email to the server
    // For demo purposes, we'll just simulate the operation
    if (email.isNotEmpty) {
      // Simulate sending password reset email
      return;
    }
    throw Exception('Please enter a valid email address');
  }
}