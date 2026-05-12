import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/models/missao_model.dart';

/// Provider para obter o userId do usuário logado
/// Tenta obter do SharedPreferences ou Firebase Auth
final userIdProvider = FutureProvider<String?>((ref) async {
  try {
    final prefs = await SharedPreferences.getInstance();

    // Tenta obter userId do backend
    final userId = prefs.getString('backend_user_id');
    if (userId != null && userId.isNotEmpty) {
      return userId;
    }

    // Fallback: tenta Firebase UID (se estiver usando Firebase Auth)
    // final user = FirebaseAuth.instance.currentUser;
    // if (user != null) {
    //   return user.uid;
    // }

    return null;
  } catch (e) {
    throw Exception('Erro ao obter userId: $e');
  }
});

/// Provider para obter o token de acesso
final accessTokenProvider = FutureProvider<String?>((ref) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('procel_backend_access_token');
  } catch (e) {
    return null;
  }
});

/// Provider para verificar se o usuário está autenticado
final isAuthenticatedProvider = FutureProvider<bool>((ref) async {
  final userId = await ref.watch(userIdProvider.future);
  final token = await ref.watch(accessTokenProvider.future);
  return userId != null && token != null;
});

/// Dados de autenticação do usuário
class AuthData {
  final String userId;
  final String accessToken;
  final String? displayName;
  final String? email;

  AuthData({
    required this.userId,
    required this.accessToken,
    this.displayName,
    this.email,
  });
}

/// Provider para obter dados completos de autenticação
final authDataProvider = FutureProvider<AuthData?>((ref) async {
  try {
    final prefs = await SharedPreferences.getInstance();

    final userId = prefs.getString('backend_user_id');
    final token = prefs.getString('procel_backend_access_token');
    final displayName = prefs.getString('backend_display_name');
    final email = prefs.getString('backend_email');

    if (userId != null && token != null) {
      return AuthData(
        userId: userId,
        accessToken: token,
        displayName: displayName,
        email: email,
      );
    }

    return null;
  } catch (e) {
    throw Exception('Erro ao obter dados de autenticação: $e');
  }
});
