// Buyer-flow state: one session, the current step, and the jobs each screen is waiting on.
//
//   start ─▶ face ─▶ reveal ─▶ shop ─▶ compare ─(body photo first time, live only)─▶ look
//     └ "try with the sample person" skips the photos (persona session, replay results, 0 units)
import 'dart:async';
import 'package:flutter/foundation.dart';

import 'api.dart';
import 'imaging.dart';
import 'l10n.dart';
import 'logic.dart';
import 'platform/platform.dart';

enum FlowStep { start, face, reveal, shop, compare, body, look }

class EntryParams {
  const EntryParams({this.pk = 'pk_demo_drape', this.productId, this.colorwayId, this.storeOrigin, this.judgeCode});
  final String pk;
  final String? productId;
  final String? colorwayId;
  final String? storeOrigin;
  final String? judgeCode;

  factory EntryParams.fromQuery(Map<String, String> q) => EntryParams(
        pk: q['pk'] ?? 'pk_demo_drape',
        productId: q['product'],
        colorwayId: q['colorway'],
        storeOrigin: q['origin'],
        judgeCode: q['code'],
      );
}

class AppState extends ChangeNotifier {
  AppState({DrapeApi? api, this.entry = const EntryParams(), Lang lang = Lang.en, this.pollEvery = const Duration(milliseconds: 1500)})
      : api = api ?? DrapeApi(),
        _lang = lang;

  final DrapeApi api;
  final EntryParams entry;
  final Duration pollEvery;

  Lang _lang;
  Lang get lang => _lang;
  S get s => S(_lang);
  void toggleLang() {
    _lang = _lang == Lang.en ? Lang.ar : Lang.en;
    notifyListeners();
  }

  FlowStep step = FlowStep.start;

  /// null until /health answers. When false, "Use my photo" is switched off so nobody uploads a photo
  /// and then sees the sample person's result.
  bool? live;
  Future<void> checkLive() async {
    live = await api.liveAvailable();
    notifyListeners();
  }
  Session? session;
  String? busy; // progress copy shown while waiting
  String? error; // buyer-facing message (never a raw error)
  String? errorFix;

  Job? readingJob;
  Job? makeupJob;
  Job? jewelryJob;
  final Map<String, Job> tryons = {};
  String? productId;
  String? chosenColorwayId;
  bool addedAtStore = false;
  bool demoOrderPlaced = false;
  bool deleted = false;

  static const _tokenKey = 'drape.token';

  void go(FlowStep next) {
    step = next;
    error = null;
    errorFix = null;
    notifyListeners();
  }

  void back() {
    const order = [FlowStep.start, FlowStep.face, FlowStep.reveal, FlowStep.shop, FlowStep.compare, FlowStep.look];
    final i = order.indexOf(step == FlowStep.body ? FlowStep.compare : step);
    go(i <= 0 ? FlowStep.start : order[i - 1]);
  }

  Future<T?> _guard<T>(String? progress, Future<T> Function() action) async {
    busy = progress;
    error = null;
    errorFix = null;
    notifyListeners();
    try {
      return await action();
    } on ApiError catch (e) {
      error = s.apiError(e.code, e.message);
      errorFix = s.rtl ? null : e.fix;
      return null;
    } catch (_) {
      error = s.somethingWrong;
      return null;
    } finally {
      busy = null;
      notifyListeners();
    }
  }

  /// Resume a session from sessionStorage (e.g. after a reload).
  Future<void> restore() async {
    final t = Platform.readStore(_tokenKey);
    if (t == null) return;
    api.token = t;
    try {
      session = await api.getSession();
      step = session!.palette != null ? FlowStep.shop : FlowStep.face;
      notifyListeners();
    } catch (_) {
      api.token = null;
      Platform.writeStore(_tokenKey, null);
    }
  }

  Future<void> start({required bool persona}) async {
    deleted = false;
    final ses = await _guard(null, () => api.createSession(key: entry.pk, storeOrigin: entry.storeOrigin, persona: persona, judgeCode: entry.judgeCode));
    if (ses == null) return;
    session = ses;
    Platform.writeStore(_tokenKey, api.token);
    productId = entry.productId;
    chosenColorwayId = entry.colorwayId;
    if (persona) {
      go(FlowStep.reveal);
      await readColours();
    } else {
      go(FlowStep.face);
    }
  }

  /// Picks, prepares (resize + re-encode, strips metadata) and uploads one photo.
  Future<bool> addPhoto(String kind, {Uint8List? bytes}) async {
    final raw = bytes ?? await Platform.pickImage(selfie: kind == 'face');
    if (raw == null) return false;
    final ok = await _guard(s.uploading, () async {
      final jpeg = prepareJpeg(raw);
      if (jpeg == null) throw ApiError('DRAPE_IMAGE_INVALID', s.photoReadFail, s.takePhoto);
      session = await api.uploadPhoto(kind, jpeg);
      return true;
    });
    return ok == true;
  }

  Future<Job?> _run(String type, String progress, {String? productId, String? colorwayId}) {
    return _guard(progress, () async {
      var job = await api.createJob(type, productId: productId, colorwayId: colorwayId);
      while (!job.finished) {
        await Future<void>.delayed(pollEvery);
        final (j, ses) = await api.getJob(job.id);
        job = j;
        session = ses;
      }
      if (job.finished) session = await api.getSession();
      return job;
    });
  }

  Future<void> readColours() async {
    readingJob = await _run('color_reading', s.reading);
    if (readingJob != null && !readingJob!.ok) {
      error = s.jobError(readingJob!.errorCode, readingJob!.errorMessage);
      notifyListeners();
    }
  }

  Future<void> setOverride(String? o) async {
    final ses = await _guard(null, () => api.setOverride(o));
    if (ses != null) session = ses;
    notifyListeners();
  }

  Product? get product {
    final ses = session;
    if (ses == null || ses.products.isEmpty) return null;
    for (final p in ses.products) {
      if (p.id == productId) return p;
    }
    return null;
  }

  ComparePair? get comparePair {
    final p = product;
    return p == null ? null : pickCompare(p, chosenId: chosenColorwayId);
  }

  Future<void> openCompare(Product p, {String? colorwayId}) async {
    productId = p.id;
    chosenColorwayId = colorwayId;
    tryons.clear();
    final ses = session!;
    if (ses.mode == 'live' && !ses.persona && ses.bodyPhoto == null) {
      go(FlowStep.body);
      return;
    }
    go(FlowStep.compare);
    await renderCompare();
  }

  Future<void> renderCompare() async {
    final pair = comparePair;
    if (pair == null) return;
    await Future.wait([
      renderTryon(pair.pick),
      if (pair.off != null) renderTryon(pair.off!),
    ]);
  }

  Future<void> renderTryon(Colorway c) async {
    final job = await _run('tryon', s.dressing(c.name), productId: productId, colorwayId: c.id);
    if (job != null) {
      tryons[c.id] = job;
      notifyListeners();
    }
  }

  Future<void> completeLook() async {
    go(FlowStep.look);
    makeupJob = await _run('makeup', s.matchingMakeup);
    jewelryJob = await _run('jewelry', s.earringsInMetal);
    // A failed makeup or earring render is a partial result: the look card still shows the outfit,
    // the lip swatch and the metal.
    error = null;
    notifyListeners();
  }

  /// Hands the bundle to the store that opened Drape (exact origin only), or runs the labelled demo checkout.
  void addToCart() {
    final ses = session!;
    final pair = comparePair;
    final items = [
      if (pair != null) {'productId': productId, 'colorwayId': pair.pick.id},
    ];
    final target = ses.storeOrigin;
    final fromStore = entry.storeOrigin != null && target.isNotEmpty && Platform.hasOpener;
    if (fromStore &&
        Platform.postToOpener({
          'type': 'drape:add-to-cart',
          'sessionId': ses.id,
          'items': items,
          'lip': {'name': ses.palette?.lip.name, 'hex': ses.palette?.lip.hex},
          'metal': ses.palette?.metal,
        }, target)) {
      addedAtStore = true;
    } else {
      demoOrderPlaced = true;
    }
    notifyListeners();
  }

  Future<void> deletePhotos() async {
    await _guard(null, () => api.deleteSession());
    Platform.writeStore(_tokenKey, null);
    session = null;
    readingJob = null;
    makeupJob = null;
    jewelryJob = null;
    tryons.clear();
    deleted = true;
    go(FlowStep.start);
  }
}
