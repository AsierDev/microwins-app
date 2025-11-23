import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/ai_repository.dart';
import 'ai_repository_impl.dart';
import 'open_router_service.dart';

part 'ai_provider.g.dart';

@riverpod
OpenRouterService openRouterService(OpenRouterServiceRef ref) {
  return OpenRouterService();
}

@riverpod
AiRepository aiRepository(AiRepositoryRef ref) {
  final service = ref.watch(openRouterServiceProvider);
  return AiRepositoryImpl(service);
}
