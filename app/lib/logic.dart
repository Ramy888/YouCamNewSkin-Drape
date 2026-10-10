// Pure decisions the screens share, kept free of Flutter so they are easy to test.
import 'api.dart';

int _rank(Verdict? v) => switch (v) {
      Verdict.yours => 0,
      Verdict.neutral => 1,
      null => 1,
      Verdict.avoid => 2,
    };

/// Store order: palette matches first, then neutral, then off-palette. Nothing is ever removed,
/// and the original order is kept inside each group.
List<Colorway> sortColorways(List<Colorway> colorways) {
  final indexed = [for (var i = 0; i < colorways.length; i++) (i, colorways[i])];
  indexed.sort((a, b) {
    final r = _rank(a.$2.verdict).compareTo(_rank(b.$2.verdict));
    return r != 0 ? r : a.$1.compareTo(b.$1);
  });
  return [for (final e in indexed) e.$2];
}

/// Products with at least one palette match come first; every product stays in the list.
List<Product> sortProducts(List<Product> products) {
  int best(Product p) => p.colorways.map((c) => _rank(c.verdict)).fold(9, (a, b) => a < b ? a : b);
  final indexed = [for (var i = 0; i < products.length; i++) (i, products[i])];
  indexed.sort((a, b) {
    final r = best(a.$2).compareTo(best(b.$2));
    return r != 0 ? r : a.$1.compareTo(b.$1);
  });
  return [for (final e in indexed) e.$2];
}

class ComparePair {
  ComparePair(this.pick, this.off);

  /// The colourway that works with the buyer's colouring.
  final Colorway pick;

  /// The colourway that fights it, or null when the product has none.
  final Colorway? off;
}

/// Decide what the Compare screen shows for [product]:
/// - pick: the chosen colourway when it is "yours", else the closest "yours" match, else the first neutral, else the first.
/// - off: the chosen colourway when it is "avoid", else the first "avoid" in the product, else none.
ComparePair pickCompare(Product product, {String? chosenId}) {
  final cws = product.colorways;
  if (cws.isEmpty) throw ArgumentError('product ${product.id} has no colourways');
  Colorway? chosen;
  for (final c in cws) {
    if (c.id == chosenId) chosen = c;
  }
  Colorway? firstWhere(Verdict v) {
    for (final c in cws) {
      if (c.verdict == v) return c;
    }
    return null;
  }

  Colorway? bestYours() {
    Colorway? best;
    for (final c in cws) {
      if (c.verdict != Verdict.yours) continue;
      if (best == null || (c.distance ?? double.infinity) < (best.distance ?? double.infinity)) best = c;
    }
    return best;
  }

  final pick = (chosen?.verdict == Verdict.yours ? chosen : null) ?? bestYours() ?? firstWhere(Verdict.neutral) ?? cws.first;
  var off = (chosen?.verdict == Verdict.avoid ? chosen : null) ?? firstWhere(Verdict.avoid);
  if (off?.id == pick.id) off = null;
  return ComparePair(pick, off);
}
