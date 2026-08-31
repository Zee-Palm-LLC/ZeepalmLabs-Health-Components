import 'package:get/get.dart';

enum GenderOption { male, female, others }

class ProfileSetupController extends GetxController {
  static const totalSteps = 4;

  final step = 0.obs;
  final gender = GenderOption.male.obs;
  final age = 22.obs;
  final weightKg = 48.0.obs;
  final heightCm = 170.0.obs;

  double get progress => (step.value + 1) / totalSteps;

  void next() {
    if (step.value < totalSteps - 1) {
      step.value++;
    } else {
      // Profile complete — stay on last step for now.
    }
  }

  void back() {
    if (step.value > 0) {
      step.value--;
    } else {
      Get.back();
    }
  }

  void setGender(GenderOption value) => gender.value = value;
  void setAge(int value) => age.value = value;
  void setWeight(double value) => weightKg.value = value;
  void setHeight(double value) => heightCm.value = value;
}
