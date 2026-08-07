import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:job_finder_app/services/app_store.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AppStore.instance.init();
  });

  test('sendOtp generates a 6-digit OTP and verifyOtp accepts it', () {
    final store = AppStore.instance;
    store.setPhone('9845112233');

    String? sentOtp;
    store.sendOtp(
      (_) => fail('sendOtp should not error for a valid phone'),
      (otp) => sentOtp = otp,
    );

    expect(sentOtp, isNotNull);
    expect(sentOtp!.length, 6);
    expect(RegExp(r'^\d{6}$').hasMatch(sentOtp!), isTrue);

    bool? verified;
    store.verifyOtp(
      sentOtp!,
      (_) => fail('Correct OTP should verify'),
      (w, e) => verified = true,
    );
    expect(verified, isTrue);
  });

  test('verifyOtp rejects a wrong OTP', () {
    final store = AppStore.instance;
    store.setPhone('9845112233');

    String? sentOtp;
    store.sendOtp((_) => fail('should not error'), (otp) => sentOtp = otp);

    String? error;
    store.verifyOtp(
      '000000',
      (msg) => error = msg,
      (w, e) => fail('Wrong OTP should not verify'),
    );
    expect(error, isNotNull);

    // The valid OTP still works afterwards.
    bool? verified;
    store.verifyOtp(sentOtp!, (_) => fail('should not error'), (w, e) => verified = true);
    expect(verified, isTrue);
  });

  test('sendOtp produces different codes across requests', () {
    final store = AppStore.instance;
    store.setPhone('9845112233');

    String? first;
    String? second;
    store.sendOtp((_) => fail('should not error'), (otp) => first = otp);
    store.sendOtp((_) => fail('should not error'), (otp) => second = otp);

    // Extremely unlikely (1 in 900000) that two consecutive codes are equal.
    expect(first, isNot(second));
  });
}
