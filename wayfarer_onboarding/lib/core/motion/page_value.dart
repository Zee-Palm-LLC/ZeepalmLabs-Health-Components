import 'package:flutter/widgets.dart';

extension PageControllerValue on PageController {
  double get pageValue {
    if (!hasClients || !position.haveDimensions) return initialPage.toDouble();
    return page ?? initialPage.toDouble();
  }
}
