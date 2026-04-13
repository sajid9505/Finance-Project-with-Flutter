import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/expense.dart';
import '../services/category_service.dart';
import 'auth_provider.dart';

final categoryServiceProvider =
    Provider<CategoryService>((ref) => CategoryService());

/// Merged map of category → isEssential.
/// User overrides are layered on top of the app defaults.
final categoryTypesProvider = StreamProvider<Map<String, bool>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(Map.from(kDefaultEssentialMap));
  return ref
      .read(categoryServiceProvider)
      .watchCategoryTypes(user.uid)
      .map((overrides) => {...kDefaultEssentialMap, ...overrides});
});
