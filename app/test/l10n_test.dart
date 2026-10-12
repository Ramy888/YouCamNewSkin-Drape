import 'package:drape_app/l10n.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Arabic replaces known server and YouCam messages, English keeps the server text', () {
    final ar = S(Lang.ar), en = S(Lang.en);
    expect(ar.jobError('error_multi_person', 'Only one person should be in the photo.'), contains('لوحدك'));
    expect(en.jobError('error_multi_person', 'Only one person should be in the photo.'), 'Only one person should be in the photo.');
    expect(ar.apiError('DRAPE_PHOTO_MISSING', 'We need your face photo first.'), contains('صورتك'));
  });
  test('Arabic never shows an unknown English server message', () {
    final ar = S(Lang.ar);
    expect(ar.jobError('error_brand_new', 'Some English text'), ar.somethingWrong);
    expect(ar.apiError('DRAPE_SOMETHING_NEW', 'Some English text'), ar.somethingWrong);
  });
}
