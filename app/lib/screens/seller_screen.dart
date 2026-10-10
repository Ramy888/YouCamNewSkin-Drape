// Seller console: one dense page. Sign in with the secret key, see products and their colourways,
// add or edit a product, upload a colourway photo, and watch the unit ledger.
import 'package:flutter/material.dart';

import '../api.dart';
import '../imaging.dart';
import '../platform/platform.dart';
import '../theme.dart';

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
      appBar: AppBar(
        title: Text('Drape · Seller console', style: t.titleMedium),
        actions: [if (_signedIn) TextButton(onPressed: _signOut, child: const Text('Sign out'))],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          if (_error != null) _ErrorStrip(error: _error!),
          if (_status != null) Padding(padding: const EdgeInsets.only(bottom: 12), child: Text(_status!, style: t.bodyLarge?.copyWith(color: Tone.yours))),
          if (!_signedIn) _signInForm(t) else _console(t),
        ]),
      ),
    );
  }

  Widget _signInForm(TextTheme t) => ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Sign in', style: t.headlineSmall),
          const SizedBox(height: 8),
          Text('Use the secret seller key you were issued. It stays in this browser tab only.', style: t.bodyMedium),
          const SizedBox(height: 12),
          TextField(controller: _key, obscureText: true, decoration: const InputDecoration(labelText: 'Secret key'), onSubmitted: (_) => _signIn()),
          const SizedBox(height: 12),
          FilledButton(onPressed: _busy ? null : _signIn, child: const Text('Sign in')),
        ]),
      );

  Widget _console(TextTheme t) {
    final l = _ledger!;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Wrap(spacing: 24, runSpacing: 8, children: [
        for (final (k, label) in [('budget', 'Live budget'), ('used', 'Units used'), ('remaining', 'Remaining'), ('usedToday', 'Used today'), ('stuck', 'Stuck (to reconcile)')])
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: t.labelMedium),
            Text('${l[k] ?? 0}', style: t.titleMedium?.copyWith(fontFeatures: const [FontFeature.tabularFigures()])),
          ]),
      ]),
      for (final e in ((l['stuckEntries'] as List?) ?? const []).cast<Map>())
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Wrap(crossAxisAlignment: WrapCrossAlignment.center, spacing: 12, runSpacing: 6, children: [
            Text('${e['jobType']} · ${e['units']} units · ${e['id']}', style: t.bodyMedium),
            Text('Check this task in the YouCam console, then:', style: t.bodySmall),
            OutlinedButton(onPressed: _busy ? null : () => _reconcile('${e['id']}', true), child: const Text('It was charged')),
            OutlinedButton(onPressed: _busy ? null : () => _reconcile('${e['id']}', false), child: const Text('Not charged')),
          ]),
        ),
      const SizedBox(height: 16),
      const Divider(),
      LayoutBuilder(builder: (context, c) {
        final list = _productList(t);
        final editor = _ProductEditor(
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
        );
        return c.maxWidth > 760
            ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [SizedBox(width: 260, child: list), const VerticalDivider(), Expanded(child: editor)])
            : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [list, const Divider(), editor]);
      }),
    ]);
  }

  Widget _productList(TextTheme t) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text('Products', style: t.titleMedium)),
        for (final p in _products)
          ListTile(
            selected: _selected?.id == p.id,
            title: Text(p.name),
            subtitle: Text('${p.id} · ${p.category} · ${p.colorways.length} colourways'),
            onTap: () => setState(() => _selected = p),
          ),
        TextButton.icon(onPressed: () => setState(() => _selected = null), icon: const Icon(Icons.add), label: const Text('New product')),
      ]);
}

class _ErrorStrip extends StatelessWidget {
  const _ErrorStrip({required this.error});
  final ApiError error;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(color: Tone.paperDeep, border: BorderDirectional(start: BorderSide(color: Tone.avoid, width: 3))),
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
  late String _category = widget.product?.category ?? 'full_body';
  late final List<_CwRow> _rows = [
    for (final c in widget.product?.colorways ?? <Colorway>[])
      _CwRow(TextEditingController(text: c.id), TextEditingController(text: c.name), TextEditingController(text: c.hex), c.image),
  ];

  void _addRow() => setState(() => _rows.add(_CwRow(TextEditingController(), TextEditingController(), TextEditingController(text: '#'), '')));

  Map<String, dynamic> _json() => {
        'id': _id.text.trim(),
        'name': _name.text.trim(),
        'category': _category,
        'price': num.tryParse(_price.text.trim()) ?? 0,
        'colorways': [
          for (final r in _rows) {'id': r.id.text.trim(), 'name': r.name.text.trim(), 'hex': r.hex.text.trim()},
        ],
      };

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final editing = widget.product != null;
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 12, top: 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(editing ? 'Edit ${widget.product!.name}' : 'New product', style: t.titleMedium),
        const SizedBox(height: 12),
        Wrap(spacing: 12, runSpacing: 12, children: [
          SizedBox(width: 200, child: TextField(controller: _id, enabled: !editing, decoration: const InputDecoration(labelText: 'Product id (e.g. abaya-classic)'))),
          SizedBox(width: 260, child: TextField(controller: _name, decoration: const InputDecoration(labelText: 'Name'))),
          SizedBox(width: 120, child: TextField(controller: _price, decoration: const InputDecoration(labelText: 'Price'))),
          SizedBox(
            width: 180,
            child: DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(labelText: 'Garment category'),
              items: [for (final c in _categories) DropdownMenuItem(value: c, child: Text(c))],
              onChanged: (v) => setState(() => _category = v ?? _category),
            ),
          ),
        ]),
        const SizedBox(height: 16),
        Text('Colourways', style: t.titleMedium),
        const SizedBox(height: 4),
        Text('One clean, front-facing photo per colour on a plain background.', style: t.bodyMedium),
        const SizedBox(height: 8),
        for (final r in _rows)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Wrap(spacing: 10, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
              SizedBox(width: 120, child: TextField(controller: r.id, decoration: const InputDecoration(labelText: 'Id'))),
              SizedBox(width: 150, child: TextField(controller: r.name, decoration: const InputDecoration(labelText: 'Name'))),
              SizedBox(width: 110, child: TextField(controller: r.hex, decoration: const InputDecoration(labelText: '#rrggbb'))),
              if (RegExp(r'^#[0-9a-fA-F]{6}$').hasMatch(r.hex.text))
                Container(width: 28, height: 28, decoration: BoxDecoration(color: hexColor(r.hex.text), shape: BoxShape.circle, border: Border.all(color: Tone.line))),
              if (r.image.isNotEmpty) SizedBox(width: 48, height: 64, child: Image.network(widget.api.abs(r.image), fit: BoxFit.contain, errorBuilder: (_, _, _) => const SizedBox())),
              if (editing)
                OutlinedButton(
                  onPressed: widget.busy || r.id.text.isEmpty ? null : () => widget.onUpload(widget.product!.id, r.id.text.trim()),
                  child: Text(r.image.isEmpty ? 'Upload photo' : 'Replace photo'),
                ),
            ]),
          ),
        Align(alignment: AlignmentDirectional.centerStart, child: TextButton.icon(onPressed: _addRow, icon: const Icon(Icons.add), label: const Text('Add colourway'))),
        if (!editing) Text('Save the product first, then upload a photo for each colourway.', style: t.bodyMedium),
        const SizedBox(height: 12),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: FilledButton(onPressed: widget.busy ? null : () => widget.onSave(_json()), child: Text(editing ? 'Save changes' : 'Create product')),
        ),
      ]),
    );
  }
}
