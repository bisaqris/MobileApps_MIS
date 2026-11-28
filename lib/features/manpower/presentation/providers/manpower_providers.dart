import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../data/repositories/http_manpower_repository.dart';
import '../../data/repositories/mock_manpower_repository.dart';
import '../../domain/entities/manpower.dart';
import '../../domain/repositories/manpower_repository.dart';

// Set ke 'false' jika URL backend sudah aktif kembali
const bool _useMockData = false;

final manpowerRepositoryProvider = Provider<ManpowerRepository>((ref) {
  if (_useMockData) {
    return MockManpowerRepository();
  }
  final dio = ref.watch(dioProvider);
  return HttpManpowerRepository(dio: dio);
});

final manpowerSearchProvider = StateProvider<String>((ref) => '');

final manpowerAvailabilityFilterProvider =
    StateProvider<ManpowerAvailability?>((ref) => null);

final manpowerListProvider = FutureProvider.autoDispose<List<Manpower>>((ref) {
  final query = ref.watch(manpowerSearchProvider);
  final availability = ref.watch(manpowerAvailabilityFilterProvider);
  return ref
      .watch(manpowerRepositoryProvider)
      .fetchManpower(query: query, availability: availability);
});

final manpowerControllerProvider =
    StateNotifierProvider<ManpowerController, AsyncValue<void>>((ref) {
  return ManpowerController(ref);
});

class ManpowerController extends StateNotifier<AsyncValue<void>> {
  ManpowerController(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;

  Future<bool> createManpower(Manpower manpower) async {
    state = const AsyncValue.loading();
    try {
      await _ref.read(manpowerRepositoryProvider).createManpower(manpower);
      state = const AsyncValue.data(null);
      _ref.invalidate(manpowerListProvider);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> updateManpower(Manpower manpower) async {
    state = const AsyncValue.loading();
    try {
      await _ref.read(manpowerRepositoryProvider).updateManpower(manpower);
      state = const AsyncValue.data(null);
      _ref.invalidate(manpowerListProvider);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> deleteManpower(String id) async {
    state = const AsyncValue.loading();
    try {
      await _ref.read(manpowerRepositoryProvider).deleteManpower(id);
      state = const AsyncValue.data(null);
      _ref.invalidate(manpowerListProvider);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

