import 'package:drape_app/api.dart';
import 'package:drape_app/logic.dart';
import 'package:flutter_test/flutter_test.dart';

Colorway cw(String id, Verdict? v) => Colorway(id: id, name: id, hex: '#112233', image: '/x.jpg', verdict: v);
Product product(String id, List<Colorway> cws) => Product(id: id, name: id, category: 'full_body', price: 1, currency: 'EGP', colorways: cws);

void main() {
  group('sortColorways', () {
    test('puts palette matches first, keeps every colourway, keeps order inside groups', () {
      final input = [cw('pink', Verdict.avoid), cw('teal', Verdict.neutral), cw('emerald', Verdict.yours), cw('fuchsia', Verdict.avoid), cw('olive', Verdict.yours)];
      final out = sortColorways(input).map((c) => c.id).toList();
      expect(out, ['emerald', 'olive', 'teal', 'pink', 'fuchsia']);
      expect(out.length, input.length);
    });

    test('without a reading (no verdicts) the original order is unchanged', () {
      final input = [cw('a', null), cw('b', null), cw('c', null)];
      expect(sortColorways(input).map((c) => c.id), ['a', 'b', 'c']);
    });
  });

  group('sortProducts', () {
    test('products with a palette match come first and none are hidden', () {
      final ps = [
        product('p1', [cw('x', Verdict.avoid)]),
        product('p2', [cw('y', Verdict.yours)]),
        product('p3', [cw('z', Verdict.neutral)]),
      ];
      expect(sortProducts(ps).map((p) => p.id), ['p2', 'p3', 'p1']);
    });
  });

  group('pickCompare', () {
    test('approved side is the closest palette match, not the first one', () {
      final p = product('abaya', [
        Colorway(id: 'black', name: 'Black', hex: '#1c1c1e', image: '', verdict: Verdict.yours, distance: 12.4),
        Colorway(id: 'emerald', name: 'Emerald', hex: '#1f7a55', image: '', verdict: Verdict.yours, distance: 0),
        Colorway(id: 'lavender', name: 'Lavender', hex: '#b7a6d8', image: '', verdict: Verdict.avoid, distance: 0),
      ]);
      final pair = pickCompare(p, chosenId: 'lavender');
      expect(pair.pick.id, 'emerald');
      expect(pair.off?.id, 'lavender');
    });

    final abaya = product('abaya', [cw('black', Verdict.yours), cw('pink', Verdict.avoid), cw('emerald', Verdict.yours), cw('grey', Verdict.neutral)]);

    test('chosen off-palette colourway is shown against the first palette match', () {
      final pair = pickCompare(abaya, chosenId: 'pink');
      expect(pair.pick.id, 'black');
      expect(pair.off?.id, 'pink');
    });

    test('chosen palette colourway is the pick; the product\'s off-palette colourway is the comparison', () {
      final pair = pickCompare(abaya, chosenId: 'emerald');
      expect(pair.pick.id, 'emerald');
      expect(pair.off?.id, 'pink');
    });

    test('no choice: first match vs first off-palette', () {
      final pair = pickCompare(abaya);
      expect((pair.pick.id, pair.off?.id), ('black', 'pink'));
    });

    test('no off-palette colourway: off is null', () {
      final pair = pickCompare(product('p', [cw('a', Verdict.yours), cw('b', Verdict.neutral)]), chosenId: 'b');
      expect(pair.pick.id, 'a');
      expect(pair.off, isNull);
    });

    test('only neutral colourways: pick the first neutral, nothing to compare against', () {
      final pair = pickCompare(product('p', [cw('a', Verdict.neutral), cw('b', Verdict.neutral)]));
      expect(pair.pick.id, 'a');
      expect(pair.off, isNull);
    });

    test('a single off-palette colourway is never compared with itself', () {
      final pair = pickCompare(product('p', [cw('a', Verdict.avoid)]));
      expect(pair.pick.id, 'a');
      expect(pair.off, isNull);
    });
  });

  group('ApiError.fromResponse', () {
    test('parses the backend envelope', () {
      final e = ApiError.fromResponse(403,
          '{"error":{"code":"DRAPE_DOMAIN_NOT_ALLOWED","message":"https://x is not on the list.","fix":"Add your origin.","docs_url":"d","request_id":"req_1"}}');
      expect(e.code, 'DRAPE_DOMAIN_NOT_ALLOWED');
      expect(e.message, contains('not on the list'));
      expect(e.fix, 'Add your origin.');
      expect(e.requestId, 'req_1');
      expect(e.status, 403);
    });

    test('non-JSON or unexpected bodies become a generic network error', () {
      expect(ApiError.fromResponse(502, '<html>Bad gateway</html>').code, 'DRAPE_NETWORK');
      expect(ApiError.fromResponse(500, '{"oops":1}').code, 'DRAPE_NETWORK');
    });
  });

  group('Session.fromJson', () {
    test('reads palette, verdicts and photos from the session view', () {
      final s = Session.fromJson({
        'id': 'ses_1',
        'persona': true,
        'mode': 'replay',
        'storeOrigin': 'http://localhost:8787',
        'photos': {'face': '/persona/face.jpg', 'body': '/persona/body.jpg'},
        'palette': {
          'undertone': 'warm',
          'contrast': 'high',
          'metal': 'gold',
          'lip': {'name': 'Brick coral', 'hex': '#b5523b'},
          'suits': [{'id': 'emerald', 'name': 'Emerald', 'hex': '#1f7a55'}],
          'avoid': [{'id': 'icy-pink', 'name': 'Icy pink', 'hex': '#f2c8d8'}],
        },
        'products': [
          {
            'id': 'abaya-classic', 'name': 'Classic satin abaya', 'category': 'full_body', 'price': 890, 'currency': 'EGP',
            'colorways': [{'id': 'emerald', 'name': 'Emerald', 'hex': '#1f7a55', 'image': '/catalog/a.jpg', 'verdict': 'yours', 'closest': {'id': 'emerald', 'name': 'Emerald', 'hex': '#1f7a55'}}],
          }
        ],
        'jobs': [],
      });
      expect(s.palette!.metal, 'gold');
      expect(s.products.single.colorways.single.verdict, Verdict.yours);
      expect(s.facePhoto, '/persona/face.jpg');
    });
  });
}
