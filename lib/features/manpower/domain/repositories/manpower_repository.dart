import '../entities/manpower.dart';

abstract interface class ManpowerRepository {
  Future<List<Manpower>> fetchManpower({
    String query = '',
    ManpowerAvailability? availability,
  });
  Future<Manpower> getManpowerById(String id);
  Future<void> createManpower(Manpower manpower);
  Future<void> updateManpower(Manpower manpower);
  Future<void> deleteManpower(String id);
}

