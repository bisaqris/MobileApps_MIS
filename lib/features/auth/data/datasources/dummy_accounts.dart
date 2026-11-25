import '../../domain/entities/user.dart';

abstract final class DummyAccounts {
  static const _password = 'password123';

  static const _accounts = <_DummyUser>[
    _DummyUser(
      user: User(
        id: '1',
        name: 'Direktur',
        email: 'director@makromedia.com',
        role: UserRole.director,
      ),
      password: _password,
    ),
    _DummyUser(
      user: User(
        id: '2',
        name: 'Budi Finance',
        email: 'finance@makromedia.com',
        role: UserRole.finance,
      ),
      password: _password,
    ),
    _DummyUser(
      user: User(
        id: '3',
        name: 'Sales',
        email: 'sales@makromedia.com',
        role: UserRole.sales,
      ),
      password: _password,
    ),
    _DummyUser(
      user: User(
        id: '4',
        name: 'Projek Manager',
        email: 'pm@makromedia.com',
        role: UserRole.projectManager,
      ),
      password: _password,
    ),
    _DummyUser(
      user: User(
        id: '5',
        name: 'Tim Produksi',
        email: 'production@makromedia.com',
        role: UserRole.production,
      ),
      password: _password,
    ),
  ];

  static User? authenticate(String email, String password) {
    for (final account in _accounts) {
      if (account.user.email == email && account.password == password) {
        return account.user;
      }
    }
    return null;
  }
}

class _DummyUser {
  const _DummyUser({required this.user, required this.password});
  final User user;
  final String password;
}
