import 'package:flutter_test/flutter_test.dart';
import 'package:coach/providers/user_provider.dart';
import 'package:coach/providers/auth_provider.dart';

class MockAuthProvider extends AuthProvider {
  String? _mockAccessToken = 'expired_token';
  int refreshCount = 0;
  bool refreshSucceeds = true;

  @override
  String? get accessToken => _mockAccessToken;

  @override
  Future<bool> refresh() async {
    refreshCount++;
    if (refreshSucceeds) {
      _mockAccessToken = 'valid_token';
      return true;
    }
    _mockAccessToken = null;
    return false;
  }
}

void main() {
  testWidgets('UserProvider can be initialized with MockAuthProvider', (tester) async {
    final auth = MockAuthProvider();
    final userProvider = UserProvider(auth);
    expect(userProvider, isNotNull);
  });
}
