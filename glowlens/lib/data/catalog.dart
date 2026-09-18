import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

enum Routine { morning, evening }

enum Filter { all, morning, evening }

class Product {
  const Product({
    required this.id,
    required this.brand,
    required this.name,
    required this.target,
    required this.price,
    required this.image,
    required this.routine,
    required this.rating,
    required this.reviews,
    required this.about,
    required this.ingredients,
    required this.tint,
  });

  final String id;
  final String brand;
  final String name;
  final String target;
  final int price;
  final String image;
  final Routine routine;
  final double rating;
  final int reviews;
  final String about;
  final List<String> ingredients;
  final Color tint;

  bool matches(Filter filter) {
    return switch (filter) {
      Filter.all => true,
      Filter.morning => routine == Routine.morning,
      Filter.evening => routine == Routine.evening,
    };
  }
}

abstract final class Catalog {
  static const products = [
    Product(
      id: 'retinol',
      brand: 'SKINCEUTICALS',
      name: 'Advanced Retinol Cream',
      target: 'Targeting Forehead Lines',
      price: 88,
      image: 'assets/products/retinol.webp',
      routine: Routine.morning,
      rating: 4.8,
      reviews: 1240,
      about:
          'A slow-release 0.3% retinol cream that smooths horizontal forehead lines while ceramides keep the barrier calm.',
      ingredients: ['Retinol 0.3%', 'Ceramides', 'Squalane', 'Bisabolol'],
      tint: Color(0xFFE6DAF6),
    ),
    Product(
      id: 'peptide',
      brand: 'THE ORDINARY',
      name: 'Peptide Power Serum',
      target: 'Targeting Forehead Lines',
      price: 28,
      image: 'assets/products/peptide.webp',
      routine: Routine.evening,
      rating: 4.6,
      reviews: 3180,
      about: 'Matrixyl and Argireline peptides relax expression lines and firm the skin overnight.',
      ingredients: ['Matrixyl 3000', 'Argireline', 'Hyaluronic Acid', 'Green Tea'],
      tint: Color(0xFFDDEFD4),
    ),
    Product(
      id: 'hydrating',
      brand: 'CeraVe',
      name: 'Hydrating Booster 89',
      target: 'Targeting Crows Feet',
      price: 34,
      image: 'assets/products/hydrating.webp',
      routine: Routine.evening,
      rating: 4.7,
      reviews: 2045,
      about: 'Mineral water and hyaluronic acid plump the thin skin around the eyes where crows feet start.',
      ingredients: ['Mineral Water', 'Hyaluronic Acid', 'Niacinamide'],
      tint: Color(0xFFD5E6F4),
    ),
    Product(
      id: 'inkey',
      brand: 'The INKEY List',
      name: 'Collagen Glow Balm',
      target: 'Targeting Frown Lines',
      price: 19,
      image: 'assets/products/inkey.webp',
      routine: Routine.morning,
      rating: 4.5,
      reviews: 860,
      about: 'A cushiony balm with collagen peptides and rose extract that softens the lines between the brows.',
      ingredients: ['Collagen Peptides', 'Rose Extract', 'Shea Butter'],
      tint: Color(0xFFF8D9DE),
    ),
    Product(
      id: 'barrier',
      brand: "T'AIME",
      name: 'Pretty Pure Cleansing Balm',
      target: 'Prepares Skin for Actives',
      price: 24,
      image: 'assets/products/barrier.webp',
      routine: Routine.evening,
      rating: 4.4,
      reviews: 512,
      about: 'Melts sunscreen and makeup without stripping, so your evening treatments absorb evenly.',
      ingredients: ['Sunflower Oil', 'Vitamin E', 'Chamomile'],
      tint: Color(0xFFDCEBF8),
    ),
    Product(
      id: 'spf',
      brand: 'SUPERGOOP',
      name: 'Unseen Lilac SPF 40',
      target: 'Prevents New Lines',
      price: 36,
      image: 'assets/products/spf.webp',
      routine: Routine.morning,
      rating: 4.9,
      reviews: 4302,
      about: 'An invisible, weightless sunscreen. Daily UV protection is the single best way to slow new wrinkles.',
      ingredients: ['Avobenzone', 'Red Algae', 'Meadowfoam Seed'],
      tint: Color(0xFFEBD8F6),
    ),
  ];

  static Product byId(String id) => products.firstWhere((p) => p.id == id);
}

enum Severity { mild, moderate, deep }

class Area {
  const Area({
    required this.name,
    required this.severity,
    required this.focus,
    required this.radius,
    required this.score,
    required this.tip,
    required this.productId,
  });

  final String name;
  final Severity severity;
  final Offset focus;
  final double radius;
  final int score;
  final String tip;
  final String productId;

  String get severityLabel => switch (severity) {
    Severity.mild => 'Mild',
    Severity.moderate => 'Moderate',
    Severity.deep => 'Deep',
  };
}

abstract final class Analysis {
  static const areas = [
    Area(
      name: 'Forehead Lines',
      severity: Severity.moderate,
      focus: Offset(0.555, 0.262),
      radius: 0.16,
      score: 62,
      tip: 'Use retinol three nights a week and keep your brows relaxed when you concentrate.',
      productId: 'retinol',
    ),
    Area(
      name: 'Frown Lines',
      severity: Severity.mild,
      focus: Offset(0.552, 0.35),
      radius: 0.075,
      score: 81,
      tip: 'Peptides soften the "11" lines. Screen time breaks help you stop squinting.',
      productId: 'peptide',
    ),
    Area(
      name: 'Crows Feet',
      severity: Severity.moderate,
      focus: Offset(0.335, 0.405),
      radius: 0.07,
      score: 66,
      tip: 'Hydrate the eye area morning and night and wear sunglasses outdoors.',
      productId: 'hydrating',
    ),
    Area(
      name: 'Smile Lines',
      severity: Severity.mild,
      focus: Offset(0.43, 0.54),
      radius: 0.07,
      score: 84,
      tip: 'A light collagen balm and daily SPF keep nasolabial folds shallow.',
      productId: 'inkey',
    ),
  ];

  static const score = 78;
}

class Bag extends ChangeNotifier {
  Bag._();

  static final Bag instance = Bag._();

  final Map<String, int> _items = {};

  Map<String, int> get items => Map.unmodifiable(_items);

  int get count => _items.values.fold(0, (a, b) => a + b);

  int get total => _items.entries.fold(0, (sum, e) => sum + Catalog.byId(e.key).price * e.value);

  void add(String id) {
    _items[id] = (_items[id] ?? 0) + 1;
    notifyListeners();
  }

  void remove(String id) {
    final left = (_items[id] ?? 0) - 1;
    if (left <= 0) {
      _items.remove(id);
    } else {
      _items[id] = left;
    }
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  @visibleForTesting
  void reset() => _items.clear();
}

class ScanResults extends ChangeNotifier {
  ScanResults._();

  static final ScanResults instance = ScanResults._();

  int generation = 0;
  bool scanned = false;

  void publish() {
    scanned = true;
    generation++;
    notifyListeners();
  }
}

const meshPoints = [
  Offset(0.555, 0.187),
  Offset(0.460, 0.194),
  Offset(0.650, 0.194),
  Offset(0.378, 0.218),
  Offset(0.735, 0.218),
  Offset(0.322, 0.264),
  Offset(0.790, 0.264),
  Offset(0.292, 0.335),
  Offset(0.800, 0.335),
  Offset(0.285, 0.407),
  Offset(0.805, 0.403),
  Offset(0.282, 0.478),
  Offset(0.800, 0.471),
  Offset(0.300, 0.550),
  Offset(0.785, 0.542),
  Offset(0.335, 0.614),
  Offset(0.755, 0.610),
  Offset(0.390, 0.664),
  Offset(0.705, 0.660),
  Offset(0.470, 0.696),
  Offset(0.640, 0.694),
  Offset(0.558, 0.703),
  Offset(0.445, 0.257),
  Offset(0.555, 0.246),
  Offset(0.665, 0.257),
  Offset(0.390, 0.300),
  Offset(0.500, 0.296),
  Offset(0.610, 0.296),
  Offset(0.720, 0.300),
  Offset(0.318, 0.335),
  Offset(0.400, 0.325),
  Offset(0.485, 0.335),
  Offset(0.625, 0.335),
  Offset(0.705, 0.325),
  Offset(0.770, 0.334),
  Offset(0.365, 0.393),
  Offset(0.422, 0.378),
  Offset(0.478, 0.394),
  Offset(0.422, 0.408),
  Offset(0.610, 0.396),
  Offset(0.665, 0.382),
  Offset(0.722, 0.393),
  Offset(0.665, 0.411),
  Offset(0.550, 0.375),
  Offset(0.548, 0.428),
  Offset(0.505, 0.471),
  Offset(0.598, 0.471),
  Offset(0.552, 0.508),
  Offset(0.505, 0.512),
  Offset(0.605, 0.514),
  Offset(0.370, 0.471),
  Offset(0.740, 0.468),
  Offset(0.420, 0.542),
  Offset(0.690, 0.539),
  Offset(0.448, 0.577),
  Offset(0.505, 0.562),
  Offset(0.555, 0.565),
  Offset(0.608, 0.562),
  Offset(0.665, 0.575),
  Offset(0.555, 0.614),
  Offset(0.495, 0.604),
  Offset(0.618, 0.604),
  Offset(0.470, 0.646),
  Offset(0.640, 0.646),
  Offset(0.555, 0.660),
];

const meshEdges = [
  (0, 1),
  (0, 2),
  (0, 23),
  (1, 3),
  (1, 22),
  (1, 23),
  (2, 4),
  (2, 23),
  (2, 24),
  (3, 5),
  (3, 22),
  (3, 25),
  (4, 6),
  (4, 24),
  (4, 28),
  (5, 7),
  (5, 25),
  (5, 29),
  (6, 8),
  (6, 28),
  (6, 34),
  (7, 9),
  (7, 29),
  (8, 10),
  (8, 34),
  (9, 11),
  (9, 29),
  (9, 35),
  (9, 50),
  (10, 12),
  (10, 34),
  (10, 41),
  (10, 51),
  (11, 13),
  (11, 50),
  (12, 14),
  (12, 51),
  (13, 15),
  (13, 50),
  (13, 52),
  (14, 16),
  (14, 51),
  (14, 53),
  (15, 17),
  (15, 52),
  (15, 54),
  (16, 18),
  (16, 53),
  (16, 58),
  (17, 19),
  (17, 54),
  (17, 62),
  (18, 20),
  (18, 58),
  (18, 63),
  (19, 21),
  (19, 62),
  (19, 64),
  (20, 21),
  (20, 63),
  (20, 64),
  (21, 64),
  (22, 23),
  (22, 25),
  (22, 26),
  (23, 24),
  (23, 26),
  (23, 27),
  (24, 27),
  (24, 28),
  (25, 26),
  (25, 29),
  (25, 30),
  (26, 27),
  (26, 30),
  (26, 31),
  (26, 43),
  (27, 28),
  (27, 32),
  (27, 33),
  (27, 43),
  (28, 33),
  (28, 34),
  (29, 30),
  (29, 35),
  (30, 31),
  (30, 35),
  (30, 36),
  (31, 36),
  (31, 37),
  (31, 43),
  (32, 33),
  (32, 39),
  (32, 40),
  (32, 43),
  (33, 34),
  (33, 40),
  (33, 41),
  (34, 41),
  (35, 36),
  (35, 38),
  (35, 50),
  (36, 37),
  (36, 38),
  (37, 38),
  (37, 43),
  (37, 44),
  (37, 45),
  (38, 45),
  (38, 50),
  (39, 40),
  (39, 42),
  (39, 43),
  (39, 44),
  (39, 46),
  (40, 41),
  (40, 42),
  (41, 42),
  (41, 51),
  (42, 46),
  (42, 51),
  (43, 44),
  (44, 45),
  (44, 46),
  (45, 46),
  (45, 47),
  (45, 48),
  (45, 50),
  (45, 52),
  (46, 47),
  (46, 49),
  (46, 51),
  (47, 48),
  (47, 49),
  (47, 56),
  (48, 52),
  (48, 55),
  (48, 56),
  (49, 51),
  (49, 53),
  (49, 56),
  (49, 57),
  (50, 52),
  (51, 53),
  (52, 54),
  (52, 55),
  (53, 57),
  (53, 58),
  (54, 55),
  (54, 60),
  (54, 62),
  (55, 56),
  (55, 60),
  (56, 57),
  (56, 59),
  (56, 60),
  (56, 61),
  (57, 58),
  (57, 61),
  (58, 61),
  (58, 63),
  (59, 60),
  (59, 61),
  (59, 62),
  (59, 63),
  (59, 64),
  (60, 62),
  (61, 63),
  (62, 64),
  (63, 64),
];

const meshCentre = Offset(0.553, 0.44);

const faceBounds = Rect.fromLTRB(0.25, 0.16, 0.84, 0.72);
