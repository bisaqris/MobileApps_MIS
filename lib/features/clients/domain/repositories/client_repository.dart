import '../entities/client.dart';

abstract interface class ClientRepository {
  Future<List<Client>> fetchClients({String query = ''});
  Future<void> createClient(Client client);
  Future<void> updateClient(Client client);
  Future<void> deleteClient(String id);
}

