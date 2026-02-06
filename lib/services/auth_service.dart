import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  late final SupabaseClient _supabase;
  late final GoogleSignIn _googleSignIn;

  factory AuthService() {
    return _instance;
  }

  AuthService._internal() {
    _supabase = Supabase.instance.client;
    final googleClientId = dotenv.env['GOOGLE_CLIENT_ID'];
    if (googleClientId == null || googleClientId.isEmpty) {
      throw Exception('GOOGLE_CLIENT_ID not found in .env file');
    }
    _googleSignIn = GoogleSignIn(
      clientId: googleClientId,
    );
  }

  // Check if user is logged in
  bool get isLoggedIn => _supabase.auth.currentSession != null;

  // Get current user
  User? get currentUser => _supabase.auth.currentUser;

  // Get current session
  Session? get currentSession => _supabase.auth.currentSession;

  // Stream of auth state changes
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // Sign up with email and password
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'display_name': displayName},
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Sign in with email and password
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Sign in with Google
  Future<AuthResponse> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signInSilently();
      if (googleUser == null) {
        throw Exception('Google sign in cancelled');
      }

      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null) {
        throw 'No Access Token found.';
      }
      if (idToken == null) {
        throw 'No ID Token found.';
      }

      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Sign up with Google
  Future<AuthResponse> signUpWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signInSilently();
      if (googleUser == null) {
        throw Exception('Google sign in cancelled');
      }

      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null) {
        throw 'No Access Token found.';
      }
      if (idToken == null) {
        throw 'No ID Token found.';
      }

      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _supabase.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  // Reset password
  Future<void> resetPassword({required String email}) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      rethrow;
    }
  }
}
