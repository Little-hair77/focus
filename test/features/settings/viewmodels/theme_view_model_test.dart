import 'package:flutter_test/flutter_test.dart';
import 'package:focus/features/settings/viewmodels/theme_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('persiste modo escuro e carrega em uma nova instância', () async {
    final firstViewModel = ThemeViewModel();

    await firstViewModel.setDarkMode(true);

    final secondViewModel = ThemeViewModel();
    await secondViewModel.loadSettings();

    expect(secondViewModel.isDarkMode, isTrue);
  });
}
