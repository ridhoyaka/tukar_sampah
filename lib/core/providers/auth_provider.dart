import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Notifier yang listen ke auth state changes dan notify GoRouter untuk redirect
class AuthNotifier extends ChangeNotifier {
  AuthNotifier() {
    _subscription = Supabase.instance.client.auth.onAuthStateChange.listen((
      event,
    ) {
      notifyListeners();
    });
  }

  late final StreamSubscription<AuthState> _subscription;

  bool get isLoggedIn => Supabase.instance.client.auth.currentSession != null;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final authNotifierProvider = ChangeNotifierProvider<AuthNotifier>((ref) {
  return AuthNotifier();
});

final currentUserProvider = Provider<User?>((ref) {
  // Watch authNotifier agar provider ini refresh saat auth berubah
  ref.watch(authNotifierProvider);
  return Supabase.instance.client.auth.currentUser;
});

// Provider untuk mengambil role user dari tabel profiles
final userRoleProvider = FutureProvider<String?>((ref) async {
  ref.watch(authNotifierProvider);
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return null;

  try {
    final data = await Supabase.instance.client
        .from('profiles')
        .select('role')
        .eq('id', user.id)
        .maybeSingle();

    return data?['role'] as String? ?? 'user';
  } catch (e) {
    debugPrint('Error fetching user role: $e');
    return 'user';
  }
});
