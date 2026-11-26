import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../data/repositories/http_client_repository.dart';
import '../../data/repositories/mock_client_repository.dart';
import '../../domain/entities/client.dart';
import '../../domain/repositories/client_repository.dart';

// Set ke 'false' jika URL backend sudah aktif kembali
const bool _useMockData = false;

final clientRepositoryProvider = Provider<ClientRepository>((ref) {
  if (_useMockData) {
    return MockClientRepository();
  }
  final dio = ref.watch(dioProvider);
  return HttpClientRepository(dio: dio);
});

final clientSearchProvider = StateProvider<String>((ref) => '');

final clientsProvider = FutureProvider.autoDispose<List<Client>>((ref) {
  final query = ref.watch(clientSearchProvider);
  return ref.watch(clientRepositoryProvider).fetchClients(query: query);
});

final clientControllerProvider =
    StateNotifierProvider<ClientController, AsyncValue<void>>((ref) {
  return ClientController(ref);
});

class ClientController extends StateNotifier<AsyncValue<void>> {
  ClientController(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;

  Future<bool> createClient(Client client) async {
    state = const AsyncValue.loading();
    try {
      await _ref.read(clientRepositoryProvider).createClient(client);
      state = const AsyncValue.data(null);
      _ref.invalidate(clientsProvider);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> updateClient(Client client) async {
    state = const AsyncValue.loading();
    try {
      await _ref.read(clientRepositoryProvider).updateClient(client);
      state = const AsyncValue.data(null);
      _ref.invalidate(clientsProvider);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> deleteClient(String id) async {
    state = const AsyncValue.loading();
    try {
      await _ref.read(clientRepositoryProvider).deleteClient(id);
      state = const AsyncValue.data(null);
      _ref.invalidate(clientsProvider);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

