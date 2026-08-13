import 'package:get/get.dart';

import '../data/organs_data.dart';
import '../models/organ.dart';

class OrganController extends GetxController {
  static const List<String> organIds = [
    'heart',
    'brain',
    'lungs',
    'liver',
    'kidneys',
    'eyeball',
    'intestine',
    'pancreas',
    'skin',
  ];

  /// Kept for OrganPanel compatibility.
  static List<String> get organs => organIds;

  final RxString _selected = 'heart'.obs;
  final RxInt _navIndex = 0.obs;
  final RxnString _activeSystem = RxnString();

  String get selected => _selected.value;
  int get navIndex => _navIndex.value;
  String? get activeSystem => _activeSystem.value;

  Organ get selectedOrgan => organById(selected);

  List<Organ> get visibleOrgans {
    final system = _activeSystem.value;
    if (system == null) return organsList;
    final match = bodySystems.where((s) => s.name == system);
    if (match.isEmpty) return organsList;
    final ids = match.first.organIds.toSet();
    return organsList.where((o) => ids.contains(o.id)).toList();
  }

  void select(String organ) {
    if (organ == _selected.value) return;
    _selected.value = organ;
    update();
  }

  void setNavIndex(int index) {
    if (index == _navIndex.value) return;
    _navIndex.value = index;
    update();
  }

  void toggleSystem(String systemName) {
    if (_activeSystem.value == systemName) {
      _activeSystem.value = null;
    } else {
      _activeSystem.value = systemName;
      final match = bodySystems.where((s) => s.name == systemName);
      if (match.isNotEmpty && match.first.organIds.isNotEmpty) {
        _selected.value = match.first.organIds.first;
      }
    }
    update();
  }

  void clearSystemFilter() {
    _activeSystem.value = null;
    update();
  }
}

List<Organ> get organsList => organs;
