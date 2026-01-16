import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/auth_repository.dart';
import 'firebase_auth_repository.dart';

part 'auth_provider.g.dart';

@Riverpod(keepAlive: true)
AuthRepository authRepository(AuthRepositoryRef ref) {
  return FirebaseAuthRepository();
}

@Riverpod(keepAlive: true)
Stream<String?> authState(AuthStateRef ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
}

/// Tracks the previous user ID to detect user changes for data isolation
@Riverpod(keepAlive: true)
class PreviousUserId extends _$PreviousUserId {
  @override
  String? build() => null;

  void update(String? userId) => state = userId;
}
