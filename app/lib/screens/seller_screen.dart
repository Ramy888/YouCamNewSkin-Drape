// Seller console: one dense page. Sign in with the secret key, see products and their colourways,
// add or edit a product, upload a colourway photo, and watch the unit ledger.
import 'package:flutter/material.dart';

import '../api.dart';
import '../imaging.dart';
import '../platform/platform.dart';
import '../theme.dart';
import '../widgets/colour_picker.dart';
import '../widgets/common.dart';

const _keyStore = 'drape.sellerKey';
const _categories = ['upper_body', 'lower_body', 'full_body', 'outer'];

class SellerScreen extends StatefulWidget {
  const SellerScreen({super.key, required this.api, this.publishableKey = 'pk_demo_drape'});
  final DrapeApi api;
  final String publishableKey;

  @override
  State<SellerScreen> createState() => _SellerScreenState();
}

class _SellerScreenState extends State<SellerScreen> {
  final _key = TextEditingController();
  List<Product> _products = [];
  Map<String, dynamic>? _ledger;
  Product? _selected;
  ApiError? _error;
  String? _status;
  bool _busy = false;
  bool get _signedIn => widget.api.sellerKey != null && _ledger != null;

  @override
  void initState() {
    super.initState();
    final saved = Platform.readStore(_keyStore);
    if (saved != null) {
      widget.api.sellerKey = saved;
      _refresh();
    }
  }

  Future<void> _reconcile(String id, bool charged) => _act(() async {
        await widget.api.reconcile(id, charged: charged);
        _ledger = await widget.api.ledger();
      }, done: charged ? 'Recorded as charged.' : 'Units released.');

  Future<void> _act(Future<void> Function() f, {String? done}) async {
    setState(() {
      _busy = true;
      _error = null;
      _status = null;
    });
    try {
      await f();
      _status = done;
    } on ApiError catch (e) {
      _error = e;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _refresh() => _act(() async {
        _ledger = await widget.api.ledger();
        _products = await widget.api.catalog(widget.publishableKey);
        if (_selected != null) _selected = _products.where((p) => p.id == _selected!.id).firstOrNull ?? _selected;
      });

  Future<void> _signIn() async {
    widget.api.sellerKey = _key.text.trim();
    await _refresh();
    if (_error == null) {
      Platform.writeStore(_keyStore, widget.api.sellerKey);
    } else {
      widget.api.sellerKey = null;
    }
  }

  void _signOut() {
    Platform.writeStore(_keyStore, null);
    setState(() {
      widget.api.sellerKey = null;
      _ledger = null;
      _products = [];
      _selected = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: Tone.paper,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 64,
        backgroundColor: Tone.ink,
        foregroundColor: Colors.white,
        title: const BrandMark(suffix: 'Seller console', onDark: true),
        actions: [
          if (_signedIn) ...[
            if (_busy) const Padding(padding: EdgeInsets.all(20), child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))),
            IconButton(tooltip: 'Refresh', onPressed: _busy ? null : _refresh, icon: const Icon(Icons.refresh_rounded)),
            TextButton.icon(
              style: TextButton.styleFrom(foregroundColor: Colors.white),
              onPressed: _signOut,
              icon: const Icon(Icons.logout_rounded, size: 18),
              label: const Text('Sign out'),
            ),
            const SizedBox(width: 12),
          ],
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              if (_error != null) _ErrorStrip(error: _error!),
              if (_status != null)
                Padding(padding: const EdgeInsets.only(bottom: 16), child: Notice(text: _status!)),
              if (!_signedIn) _signInForm(t) else _console(t),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _signInForm(TextTheme t) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Padding(
            padding: const EdgeInsets.only(top: 40),
            child: DrapeCard(
              padding: const EdgeInsets.all(28),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                const Align(alignment: AlignmentDirectional.centerStart, child: BrandMark()),
                const SizedBox(height: 24),
                Text('Sign in to your store', style: t.headlineSmall),
                const SizedBox(height: 8),
                Text('Use the secret seller key you were issued. It stays in this browser only.', style: t.bodyMedium),
                const SizedBox(height: 20),
                TextField(
                  controller: _key,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Secret key', prefixIcon: Icon(Icons.key_rounded)),
                  onSubmitted: (_) => _signIn(),
                ),
                const SizedBox(height: 16),
                FilledButton(onPressed: _busy ? null : _signIn, child: const Text('Sign in')),
              ]),
            ),
          ),
        ),
      );

  Widget _console(TextTheme t) {
    final l = _ledger!;
    num n(String k) => (l[k] as num?) ?? 0;
    final budget = n('budget');
    final used = n('used');
    final stuck = ((l['stuckEntries'] as List?) ?? const []).cast<Map>();
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [
        Expanded(child: Text('Overview', style: t.headlineSmall)),
        Tag(
          text: budget > 0 ? 'Live try-on on' : 'Demo mode',
          icon: budget > 0 ? Icons.circle : Icons.circle_outlined,
          color: budget > 0 ? Tone.yours : Tone.brass,
          bg: budget > 0 ? Tone.yoursSoft : const Color(0xFFF4ECDC),
        ),
      ]),
      const SizedBox(height: 16),
      LayoutBuilder(builder: (context, c) {
        final tiles = [
          _Kpi(label: 'Live budget', value: '$budget', hint: 'YouCam units'),
          _Kpi(label: 'Used', value: '$used', hint: budget > 0 ? '${(used / budget * 100).round()}% of budget' : null, progress: budget > 0 ? (used / budget).clamp(0, 1).toDouble() : null),
          _Kpi(label: 'Remaining', value: '${n('remaining')}'),
          _Kpi(label: 'Used today', value: '${n('usedToday')}'),
          _Kpi(label: 'To reconcile', value: '${n('stuck')}', warn: n('stuck') > 0),
        ];
        final perRow = c.maxWidth > 900 ? 5 : (c.maxWidth > 560 ? 3 : 2);
        final w = (c.maxWidth - 12 * (perRow - 1)) / perRow;
        return Wrap(spacing: 12, runSpacing: 12, children: [for (final k in tiles) SizedBox(width: w, height: 124, child: k)]);
      }),
      if (stuck.isNotEmpty) ...[
        const SizedBox(height: 16),
        DrapeCard(
          color: Tone.avoidSoft,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.warning_amber_rounded, color: Tone.avoid),
              const SizedBox(width: 8),
              Text('Tasks to reconcile', style: t.titleMedium),
            ]),
            const SizedBox(height: 4),
            Text('These timed out. Check each task in the YouCam console, then record what happened.', style: t.bodyMedium),
            for (final e in stuck)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Wrap(crossAxisAlignment: WrapCrossAlignment.center, spacing: 12, runSpacing: 8, children: [
                  Text('${e['jobType']} · ${e['units']} units', style: t.titleMedium?.copyWith(fontSize: 16)),
                  Text('${e['id']}', style: t.bodySmall),
                  OutlinedButton(onPressed: _busy ? null : () => _reconcile('${e['id']}', true), child: const Text('It was charged')),
                  OutlinedButton(onPressed: _busy ? null : () => _reconcile('${e['id']}', false), child: const Text('Not charged')),
                ]),
              ),
          ]),
        ),
      ],
      const SizedBox(height: 32),
      Text('Catalogue', style: t.headlineSmall),
      const SizedBox(height: 16),
      LayoutBuilder(builder: (context, c) {
        final list = _productList(t);
        final editor = DrapeCard(
          padding: const EdgeInsets.all(24),
          child: _ProductEditor(
            key: ValueKey(_selected?.id ?? 'new'),
            product: _selected,
            busy: _busy,
            onSave: (json) => _act(() async {
              final p = await widget.api.upsertProduct(json);
              _products = await widget.api.catalog(widget.publishableKey);
              _selected = p;
            }, done: 'Saved ${json['id']}.'),
            onUpload: (pid, cid) => _act(() async {
              final raw = await Platform.pickImage();
              if (raw == null) return;
              final jpeg = prepareJpeg(raw);
              if (jpeg == null) throw ApiError('DRAPE_IMAGE_INVALID', 'That file isn’t a readable image.', 'Upload a JPEG or PNG product photo.');
              _selected = await widget.api.uploadColorwayImage(pid, cid, jpeg);
              _products = await widget.api.catalog(widget.publishableKey);
            }, done: 'Photo uploaded for $cid.'),
            api: widget.api,
          ),
        );
        return c.maxWidth > 860
            ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [SizedBox(width: 320, child: list), const SizedBox(width: 16), Expanded(child: editor)])
            : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [list, const SizedBox(height: 16), editor]);
      }),
    ]);
  }

  Widget _productList(TextTheme t) => DrapeCard(
        padding: const EdgeInsets.all(8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: Row(children: [
              Expanded(child: Text('Products', style: t.titleMedium)),
              Text('${_products.length}', style: t.labelMedium),
            ]),
          ),
          for (final p in _products)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: ListTile(
                selected: _selected?.id == p.id,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 40,
                    height: 50,
                    color: Tone.paperDeep,
                    child: p.colorways.isEmpty || p.colorways.first.image.isEmpty
                        ? const Icon(Icons.checkroom_outlined, color: Tone.inkSoft)
                        : Image.network(widget.api.abs(p.colorways.first.image), fit: BoxFit.contain, color: Tone.paperDeep, colorBlendMode: BlendMode.multiply, errorBuilder: (_, _, _) => const SizedBox()),
                  ),
                ),
                title: Text(p.name, style: t.titleMedium?.copyWith(fontSize: 16)),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(children: [
                    for (final cw in p.colorways.take(6))
                      Padding(
                        padding: const EdgeInsetsDirectional.only(end: 4),
                        child: Container(width: 14, height: 14, decoration: BoxDecoration(color: hexColor(cw.hex), shape: BoxShape.circle, border: Border.all(color: Colors.black12))),
                      ),
                    const SizedBox(width: 6),
                    Flexible(child: Text(p.category, style: t.bodySmall, overflow: TextOverflow.ellipsis)),
                  ]),
                ),
                onTap: () => setState(() => _selected = p),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: OutlinedButton.icon(onPressed: () => setState(() => _selected = null), icon: const Icon(Icons.add_rounded), label: const Text('New product')),
          ),
        ]),
      );
}

class _Kpi extends StatelessWidget {
  const _Kpi({required this.label, required this.value, this.hint, this.progress, this.warn = false});
  final String label;
  final String value;
  final String? hint;
  final double? progress;
  final bool warn;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return DrapeCard(
      padding: const EdgeInsets.all(16),
      color: warn ? Tone.avoidSoft : Tone.surface,
      expand: true,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label.toUpperCase(), style: t.labelMedium?.copyWith(fontSize: 12)),
        const SizedBox(height: 6),
        Text(value, style: t.headlineSmall?.copyWith(fontFamily: 'Plex Arabic', fontWeight: FontWeight.w600, color: warn ? Tone.avoid : Tone.ink, fontFeatures: const [FontFeature.tabularFigures()])),
        if (progress != null) ...[
          const SizedBox(height: 8),
          ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: progress, minHeight: 6)),
        ],
        if (hint != null) ...[const SizedBox(height: 6), Text(hint!, style: t.bodySmall)],
      ]),
    );
  }
}

class _ErrorStrip extends StatelessWidget {
  const _ErrorStrip({required this.error});
  final ApiError error;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Tone.avoidSoft, borderRadius: BorderRadius.circular(12), border: Border.all(color: Tone.avoid.withValues(alpha: 0.25))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(error.message, style: t.bodyLarge),
        Text(error.fix, style: t.bodyMedium),
        Text('${error.code}${error.requestId == null ? '' : ' · ${error.requestId}'}', style: t.labelMedium?.copyWith(color: Tone.inkSoft)),
      ]),
    );
  }
}

class _CwRow {
  _CwRow(this.id, this.name, this.hex, this.image);
  final TextEditingController id;
  final TextEditingController name;
  final TextEditingController hex;
  final String image;
}

class _ProductEditor extends StatefulWidget {
  const _ProductEditor({super.key, required this.product, required this.busy, required this.onSave, required this.onUpload, required this.api});
  final Product? product;
  final bool busy;
  final Future<void> Function(Map<String, dynamic>) onSave;
  final Future<void> Function(String productId, String colorwayId) onUpload;
  final DrapeApi api;

  @override
  State<_ProductEditor> createState() => _ProductEditorState();
}

class _ProductEditorState extends State<_ProductEditor> {
  late final _id = TextEditingController(text: widget.product?.id ?? '');
  late final _name = TextEditingController(text: widget.product?.name ?? '');
  late final _price = TextEditingController(text: '${widget.product?.price ?? ''}');
  late final _links = TextEditingController(text: (widget.product?.links ?? const []).join('\n'));

  @override
  void dispose() {
    for (final c in [_id, _name, _price, _links, for (final r in _rows) ...[r.id, r.name, r.hex]]) {
      c.dispose();
    }
    super.dispose();
  }
  late String _category = widget.product?.category ?? 'full_body';
  late final List<_CwRow> _rows = [
    for (final c in widget.product?.colorways ?? <Colorway>[])
      _CwRow(TextEditingController(text: c.id), TextEditingController(text: c.name), TextEditingController(text: c.hex), c.image),
  ];

  Future<void> _pick(_CwRow r) async {
    final picked = await pickColour(context, initialHex: r.hex.text);
    if (picked == null) return;
    setState(() {
      r.hex.text = picked.$1;
      final name = picked.$2;
      if (name != null && r.name.text.trim().isEmpty) r.name.text = name;
      if (r.id.text.trim().isEmpty && r.name.text.trim().isNotEmpty) {
        r.id.text = r.name.text.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-').replaceAll(RegExp(r'^-|-$'), '');
      }
    });
  }

  void _addRow() => setState(() => _rows.add(_CwRow(TextEditingController(), TextEditingController(), TextEditingController(text: '#'), '')));

  Map<String, dynamic> _json() => {
        'id': _id.text.trim(),
        'name': _name.text.trim(),
        'category': _category,
        'price': num.tryParse(_price.text.trim()) ?? 0,
        'colorways': [
          for (final r in _rows) {'id': r.id.text.trim(), 'name': r.name.text.trim(), 'hex': r.hex.text.trim()},
        ],
        'links': [for (final l in _links.text.split('\n')) if (l.trim().isNotEmpty) l.trim()],
      };

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final editing = widget.product != null;
    Widget section(String title, String? hint) => Padding(
          padding: const EdgeInsets.only(top: 24, bottom: 12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: t.titleMedium),
            if (hint != null) Text(hint, style: t.bodySmall),
          ]),
        );
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [
        Expanded(child: Text(editing ? widget.product!.name : 'New product', style: t.titleLarge)),
        if (editing) Tag(text: widget.product!.id, color: Tone.inkSoft, bg: Tone.paperDeep),
      ]),
      section('Details', null),
      Wrap(spacing: 12, runSpacing: 12, children: [
        SizedBox(width: 220, child: TextField(controller: _id, enabled: !editing, decoration: const InputDecoration(labelText: 'Product id', hintText: 'abaya-classic'))),
        SizedBox(width: 280, child: TextField(controller: _name, decoration: const InputDecoration(labelText: 'Name'))),
        SizedBox(width: 130, child: TextField(controller: _price, decoration: const InputDecoration(labelText: 'Price'))),
        SizedBox(
          width: 200,
          child: DropdownButtonFormField<String>(
            initialValue: _category,
            decoration: const InputDecoration(labelText: 'Garment category'),
            items: [for (final c in _categories) DropdownMenuItem(value: c, child: Text(c))],
            onChanged: (v) => setState(() => _category = v ?? _category),
          ),
        ),
      ]),
      section('Where you sell it', 'Shoppers using the Drape extension on these pages land straight on this product.'),
      TextField(
        controller: _links,
        minLines: 2,
        maxLines: 5,
        decoration: const InputDecoration(labelText: 'Product page links, one per line'),
      ),
      section('Colourways', 'One clean, front-facing photo per colour on a plain background.'),
      for (final r in _rows)
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Tone.paper, borderRadius: BorderRadius.circular(12), border: Border.all(color: Tone.line)),
          child: Wrap(spacing: 12, runSpacing: 10, crossAxisAlignment: WrapCrossAlignment.center, children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 52,
                height: 66,
                color: Tone.surface,
                child: r.image.isEmpty
                    ? const Icon(Icons.image_outlined, color: Tone.inkSoft)
                    : Image.network(widget.api.abs(r.image), fit: BoxFit.contain, errorBuilder: (_, _, _) => const SizedBox()),
              ),
            ),
            SizedBox(width: 130, child: TextField(controller: r.id, decoration: const InputDecoration(labelText: 'Id'))),
            SizedBox(width: 160, child: TextField(controller: r.name, decoration: const InputDecoration(labelText: 'Name'))),
            SizedBox(
              width: 150,
              child: TextField(
                controller: r.hex,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: 'Colour',
                  hintText: '#rrggbb',
                  prefixIcon: IconButton(
                    tooltip: 'Pick from palette',
                    onPressed: () => _pick(r),
                    icon: RegExp(r'^#[0-9a-fA-F]{6}$').hasMatch(r.hex.text)
                        ? Container(width: 20, height: 20, decoration: BoxDecoration(color: hexColor(r.hex.text), shape: BoxShape.circle, border: Border.all(color: Colors.black12)))
                        : const Icon(Icons.palette_outlined, size: 20),
                  ),
                ),
              ),
            ),
            IconButton.outlined(
              tooltip: 'Pick from palette',
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              style: IconButton.styleFrom(side: const BorderSide(color: Tone.line), backgroundColor: Tone.surface),
              onPressed: () => _pick(r),
              icon: const Icon(Icons.palette_outlined, color: Tone.mulberry),
            ),
            if (editing)
              OutlinedButton.icon(
                onPressed: widget.busy || r.id.text.isEmpty ? null : () => widget.onUpload(widget.product!.id, r.id.text.trim()),
                icon: const Icon(Icons.upload_rounded, size: 18),
                label: Text(r.image.isEmpty ? 'Upload photo' : 'Replace photo'),
              ),
          ]),
        ),
      Align(alignment: AlignmentDirectional.centerStart, child: TextButton.icon(onPressed: _addRow, icon: const Icon(Icons.add_rounded), label: const Text('Add colourway'))),
      if (!editing) Text('Save the product first, then upload a photo for each colourway.', style: t.bodySmall),
      const SizedBox(height: 20),
      const Divider(),
      const SizedBox(height: 16),
      Align(
        alignment: AlignmentDirectional.centerEnd,
        child: FilledButton(onPressed: widget.busy ? null : () => widget.onSave(_json()), child: Text(editing ? 'Save changes' : 'Create product')),
      ),
    ]);
  }
}
