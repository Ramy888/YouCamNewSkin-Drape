// Drape API client and models. The API is same-origin with the app (served from the Worker),
// so every path is relative to the page origin. Errors always come back as the envelope
// {error: {code, message, fix, docs_url, request_id}} and are surfaced as [ApiError].
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

class ApiError implements Exception {
  ApiError(this.code, this.message, this.fix, {this.status = 0, this.requestId});

  final String code;
  final String message;
  final String fix;
  final int status;
  final String? requestId;

  /// Parses the backend error envelope; anything else becomes a generic network error.
  factory ApiError.fromResponse(int status, String body) {
    try {
      final j = jsonDecode(body);
      if (j is Map && j['error'] is Map) {
        final e = j['error'] as Map;
        return ApiError(
          '${e['code'] ?? 'DRAPE_INTERNAL'}',
          '${e['message'] ?? 'Something went wrong.'}',
          '${e['fix'] ?? 'Try again.'}',
          status: status,
          requestId: e['request_id'] as String?,
        );
      }
    } catch (_) {
      // fall through to the generic error below
    }
    return ApiError('DRAPE_NETWORK', 'The server sent an unexpected reply ($status).', 'Check your connection and try again.', status: status);
  }

  @override
  String toString() => '$code: $message';
}

class Swatch {
  Swatch(this.id, this.name, this.hex);
  final String id;
  final String name;
  final String hex;
  factory Swatch.fromJson(Map<String, dynamic> j) => Swatch('${j['id'] ?? ''}', '${j['name']}', '${j['hex']}');
}

class Palette {
  Palette({required this.undertone, required this.contrast, required this.metal, required this.lip, required this.suits, required this.avoid});
  final String undertone; // warm | neutral | cool
  final String contrast; // low | medium | high
  final String metal;
  final Swatch lip;
  final List<Swatch> suits;
  final List<Swatch> avoid;

  factory Palette.fromJson(Map<String, dynamic> j) => Palette(
        undertone: '${j['undertone']}',
        contrast: '${j['contrast']}',
        metal: '${j['metal']}',
        lip: Swatch.fromJson({'id': 'lip', ...(j['lip'] as Map).cast<String, dynamic>()}),
        suits: [for (final s in (j['suits'] as List)) Swatch.fromJson((s as Map).cast<String, dynamic>())],
        avoid: [for (final s in (j['avoid'] as List)) Swatch.fromJson((s as Map).cast<String, dynamic>())],
      );
}

/// Verdict of one colourway against the buyer's palette. `null` before the colour reading.
enum Verdict { yours, neutral, avoid }

Verdict? verdictFrom(Object? v) => switch (v) {
      'yours' => Verdict.yours,
      'neutral' => Verdict.neutral,
      'avoid' => Verdict.avoid,
      _ => null,
    };

class Colorway {
  Colorway({required this.id, required this.name, required this.hex, required this.image, this.verdict, this.closest, this.distance});
  final String id;
  final String name;
  final String hex;
  final String image;
  final Verdict? verdict;
  final Swatch? closest;

  /// Delta-E to [closest]; smaller means a closer palette match.
  final double? distance;

  factory Colorway.fromJson(Map<String, dynamic> j) => Colorway(
        id: '${j['id']}',
        name: '${j['name']}',
        hex: '${j['hex']}',
        image: '${j['image'] ?? ''}',
        verdict: verdictFrom(j['verdict']),
        closest: j['closest'] is Map ? Swatch.fromJson((j['closest'] as Map).cast<String, dynamic>()) : null,
        distance: j['distance'] is num ? (j['distance'] as num).toDouble() : null,
      );
}

/// A colour the store doesn't sell yet, from the buyer's palette: a YouCam AI Fabric template the palette rates "yours".
class FabricSuggestion {
  FabricSuggestion({required this.template, required this.name, required this.hex, required this.closest});
  final String template;
  final String name;
  final String hex;
  final Swatch closest;

  factory FabricSuggestion.fromJson(Map<String, dynamic> j) => FabricSuggestion(
        template: '${j['template']}',
        name: '${j['name']}',
        hex: '${j['hex']}',
        closest: Swatch.fromJson((j['closest'] as Map).cast<String, dynamic>()),
      );
}

/// The store that sells a product; Drape's own catalogue lists several.
class StoreRef {
  const StoreRef({required this.id, required this.name, this.url});
  final String id;
  final String name;
  final String? url;
}

class Product {
  Product({required this.id, required this.name, required this.category, required this.price, required this.currency, required this.colorways, this.links = const [], this.suggestion, this.store, this.buyUrl});
  final String id;
  final String name;
  final String category;
  final num price;
  final String currency;
  final List<Colorway> colorways;

  /// Product page URLs on other stores; the Drape extension matches the page address against these.
  final List<String> links;

  /// Set when none of the colourways suit this buyer.
  final FabricSuggestion? suggestion;

  /// Who sells it, and where to finish checkout (the seller's listing, else the store's home page).
  final StoreRef? store;
  final String? buyUrl;

  factory Product.fromJson(Map<String, dynamic> j) => Product(
        id: '${j['id']}',
        name: '${j['name']}',
        category: '${j['category']}',
        price: (j['price'] as num?) ?? 0,
        currency: '${j['currency'] ?? 'EGP'}',
        colorways: [for (final c in (j['colorways'] as List)) Colorway.fromJson((c as Map).cast<String, dynamic>())],
        links: [for (final l in (j['links'] as List? ?? const [])) '$l'],
        suggestion: j['suggestion'] is Map ? FabricSuggestion.fromJson((j['suggestion'] as Map).cast<String, dynamic>()) : null,
        store: j['store'] is Map ? StoreRef(id: '${j['store']['id']}', name: '${j['store']['name']}', url: j['store']['url'] as String?) : null,
        buyUrl: j['buyUrl'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'price': price,
        'currency': currency,
        'colorways': [for (final c in colorways) {'id': c.id, 'name': c.name, 'hex': c.hex}],
        'links': links,
      };
}

class Job {
  Job({required this.id, required this.type, required this.status, required this.params, this.result, this.error});
  final String id;
  final String type;
  final String status; // queued | running | done | error
  final Map<String, dynamic> params;
  final Map<String, dynamic>? result;
  final Map<String, dynamic>? error;

  bool get finished => status == 'done' || status == 'error';
  bool get ok => status == 'done';
  String? get image => result?['image'] as String?;
  bool get sample => result?['sample'] == true;
  String? get note => result?['note'] as String?;
  String? get errorKind => error?['kind'] as String?;
  String? get errorCode => error?['code'] as String?;
  String get errorMessage => '${error?['message'] ?? 'Something went wrong.'}';
  bool get retryable => error?['retryable'] == true;

  /// Stand-in for a render that can't be shown (its source failed): the panel falls back to the colour itself.
  factory Job.unavailable() => Job(id: '', type: 'recolor', status: 'error', params: const {}, error: const {'kind': 'unavailable', 'retryable': false});

  factory Job.fromJson(Map<String, dynamic> j) => Job(
        id: '${j['id']}',
        type: '${j['type']}',
        status: '${j['status']}',
        params: ((j['params'] as Map?) ?? {}).cast<String, dynamic>(),
        result: (j['result'] as Map?)?.cast<String, dynamic>(),
        error: (j['error'] as Map?)?.cast<String, dynamic>(),
      );
}

class Session {
  Session({
    required this.id,
    required this.persona,
    required this.mode,
    required this.storeOrigin,
    required this.facePhoto,
    required this.bodyPhoto,
    required this.palette,
    required this.override,
    required this.products,
    required this.jobs,
  });
  final String id;
  final bool persona;
  final String mode; // live | replay
  final String storeOrigin;
  final String? facePhoto;
  final String? bodyPhoto;
  final Palette? palette;
  final String? override;
  final List<Product> products;
  final List<Job> jobs;

  factory Session.fromJson(Map<String, dynamic> j) {
    final photos = ((j['photos'] as Map?) ?? {}).cast<String, dynamic>();
    return Session(
      id: '${j['id']}',
      persona: j['persona'] == true,
      mode: '${j['mode']}',
      storeOrigin: '${j['storeOrigin'] ?? ''}',
      facePhoto: photos['face'] as String?,
      bodyPhoto: photos['body'] as String?,
      palette: j['palette'] is Map ? Palette.fromJson((j['palette'] as Map).cast<String, dynamic>()) : null,
      override: j['override'] as String?,
      products: [for (final p in ((j['products'] as List?) ?? [])) Product.fromJson((p as Map).cast<String, dynamic>())],
      jobs: [for (final x in ((j['jobs'] as List?) ?? [])) Job.fromJson((x as Map).cast<String, dynamic>())],
    );
  }
}

class DrapeApi {
  DrapeApi({http.Client? client, Uri? base}) : _client = client ?? http.Client(), _base = base ?? Uri.base;

  final http.Client _client;
  final Uri _base;
  String? token;
  String? sellerKey;

  Uri _u(String path, [Map<String, String>? q]) => _base.replace(path: path, queryParameters: q, fragment: '');

  Map<String, String> _headers({bool json = true, bool seller = false}) => {
        if (json) 'content-type': 'application/json',
        if (!seller && token != null) 'authorization': 'Bearer $token',
        if (seller && sellerKey != null) 'authorization': 'Bearer $sellerKey',
      };

  Future<Map<String, dynamic>> _send(Future<http.Response> req) async {
    final http.Response res;
    try {
      res = await req;
    } catch (_) {
      throw ApiError('DRAPE_NETWORK', 'We couldn’t reach Drape.', 'Check your connection and try again.');
    }
    if (res.statusCode >= 400) throw ApiError.fromResponse(res.statusCode, res.body);
    return (jsonDecode(res.body) as Map).cast<String, dynamic>();
  }

  /// Image URLs from the API are same-origin paths; make them absolute for Image.network.
  String abs(String path) => path.startsWith('http') ? path : _u(path).toString();

  /// Whether live try-on with the buyer's own photo is switched on (false = demo mode, sample person only).
  Future<bool> liveAvailable() async {
    try {
      final r = await _client.get(_u('/health'));
      return (jsonDecode(r.body) as Map)['mode'] == 'live';
    } catch (_) {
      return false;
    }
  }

  Future<Session> createSession({required String key, String? storeOrigin, bool persona = false, String? judgeCode}) async {
    final j = await _send(_client.post(_u('/v1/sessions'),
        headers: _headers(), body: jsonEncode({'key': key, 'storeOrigin': ?storeOrigin, 'persona': persona, 'judgeCode': ?judgeCode})));
    token = j['token'] as String;
    return Session.fromJson((j['session'] as Map).cast<String, dynamic>());
  }

  Future<Session> getSession() async => Session.fromJson(await _send(_client.get(_u('/v1/sessions/me'), headers: _headers())));

  Future<Session> uploadPhoto(String kind, Uint8List jpeg) async {
    final j = await _send(_client.post(_u('/v1/sessions/me/photos', {'kind': kind}),
        headers: {..._headers(json: false), 'content-type': 'image/jpeg'}, body: jpeg));
    return Session.fromJson((j['session'] as Map).cast<String, dynamic>());
  }

  Future<Job> createJob(String type, {String? productId, String? colorwayId, String? template}) async {
    final j = await _send(_client.post(_u('/v1/sessions/me/jobs'),
        headers: _headers(), body: jsonEncode({'type': type, 'productId': ?productId, 'colorwayId': ?colorwayId, 'template': ?template})));
    return Job.fromJson((j['job'] as Map).cast<String, dynamic>());
  }

  Future<(Job, Session)> getJob(String id) async {
    final j = await _send(_client.get(_u('/v1/jobs/$id'), headers: _headers()));
    return (Job.fromJson((j['job'] as Map).cast<String, dynamic>()), Session.fromJson((j['session'] as Map).cast<String, dynamic>()));
  }

  Future<Session> setOverride(String? override) async {
    final j = await _send(_client.post(_u('/v1/sessions/me/palette'), headers: _headers(), body: jsonEncode({'override': override})));
    return Session.fromJson((j['session'] as Map).cast<String, dynamic>());
  }

  Future<void> deleteSession() async {
    await _send(_client.delete(_u('/v1/sessions/me'), headers: _headers()));
    token = null;
  }

  // ---------- seller ----------

  /// Every product of the store, including drafts and disabled ones (seller key required).
  Future<List<Product>> catalog(String key) async {
    final j = await _send(_client.get(_u('/v1/admin/products'), headers: _headers(seller: true)));
    return [for (final p in (j['products'] as List)) Product.fromJson((p as Map).cast<String, dynamic>())];
  }

  Future<Product> upsertProduct(Map<String, dynamic> product) async {
    final j = await _send(_client.post(_u('/v1/products'), headers: _headers(seller: true), body: jsonEncode(product)));
    return Product.fromJson((j['product'] as Map).cast<String, dynamic>());
  }

  Future<Product> uploadColorwayImage(String productId, String colorwayId, Uint8List bytes) async {
    final j = await _send(_client.put(_u('/v1/products/$productId/colorways/$colorwayId/image'),
        headers: {..._headers(json: false, seller: true), 'content-type': 'image/jpeg'}, body: bytes));
    return Product.fromJson((j['product'] as Map).cast<String, dynamic>());
  }

  /// Ask the store to make [productId] in a colour it doesn't sell yet. Free; returns true if this session had already asked.
  Future<bool> requestColour(String productId, String template) async {
    final j = await _send(_client.post(_u('/v1/sessions/me/requests'),
        headers: _headers(), body: jsonEncode({'productId': productId, 'template': template})));
    return j['alreadyAsked'] == true;
  }

  /// Seller: per product, what buyers tried, which colours their palette rejected, and what they asked for.
  Future<List<Map<String, dynamic>>> demand() async {
    final j = await _send(_client.get(_u('/v1/admin/demand'), headers: _headers(seller: true)));
    return [for (final p in (j['products'] as List)) (p as Map).cast<String, dynamic>()];
  }

  Future<Map<String, dynamic>> ledger() => _send(_client.get(_u('/v1/admin/ledger'), headers: _headers(seller: true)));

  /// Settle a timed-out task after checking the YouCam console: charged keeps the units, not_charged frees them.
  Future<Map<String, dynamic>> reconcile(String id, {required bool charged}) => _send(_client.post(_u('/v1/admin/reconcile'),
      headers: _headers(seller: true), body: jsonEncode({'id': id, 'outcome': charged ? 'charged' : 'not_charged'})));
}
