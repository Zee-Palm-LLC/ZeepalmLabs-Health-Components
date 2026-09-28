import 'package:flutter/widgets.dart';

import 'art.dart';

class Recipe {
  const Recipe({
    required this.id,
    required this.title,
    required this.photo,
    required this.minutes,
    required this.rating,
    required this.reviews,
  });

  final String id;
  final String title;
  final Sprite photo;
  final int minutes;
  final String rating;
  final String reviews;
}

const recipes = [
  Recipe(id: 'pasta', title: 'Creamy Pasta', photo: Art.photoPasta, minutes: 20, rating: '4.8', reviews: '(2.4k)'),
  Recipe(id: 'pancakes', title: 'Fluffy Pancakes', photo: Art.photoPancakes, minutes: 15, rating: '4.7', reviews: '(1.8k)'),
];

class Kitchen extends ChangeNotifier {
  final Set<String> _liked = {'pasta'};

  bool liked(String id) => _liked.contains(id);

  List<Recipe> get favorites => [
    for (final r in recipes)
      if (_liked.contains(r.id)) r,
  ];

  void toggle(String id) {
    if (!_liked.remove(id)) _liked.add(id);
    notifyListeners();
  }
}

class KitchenScope extends InheritedNotifier<Kitchen> {
  const KitchenScope({super.key, required Kitchen kitchen, required super.child}) : super(notifier: kitchen);

  static Kitchen of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<KitchenScope>()!.notifier!;
}
