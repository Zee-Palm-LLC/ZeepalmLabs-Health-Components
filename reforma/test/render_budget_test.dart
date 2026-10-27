import 'package:flutter_test/flutter_test.dart';
import 'package:reforma/three/figure.dart';
import 'package:reforma/three/figures.dart';
import 'package:reforma/three/renderer.dart';

void main() {
  test('3D body fits the frame budget', () {
    final sw = Stopwatch()..start();
    final mesh = buildFigure(Pose.standing, Palette.woman, breathing: true);
    final build = sw.elapsedMicroseconds;
    final view = BodyView(mesh);
    for (var i = 0; i < 60; i++) {
      view.update(yaw: i * 0.05, scale: 2.36, origin: const Offset(195, 213), breath: 0.5, selected: 35, selAmt: 0.5);
    }
    sw.reset();
    for (var i = 0; i < 300; i++) {
      view.update(yaw: i * 0.05, scale: 2.36, origin: const Offset(195, 213), breath: 0.5, selected: 35, selAmt: 0.5);
    }
    final perFrame = sw.elapsedMicroseconds / 300;
    // ignore: avoid_print
    print('verts ${mesh.vertexCount}, tris ${mesh.triCount}, visible ${view.visible}, '
        'build ${build / 1000} ms, update ${perFrame.toStringAsFixed(0)} us/frame, '
        'hero verts ${Figures.heroLow.vertexCount}=${Figures.heroHigh.vertexCount}');
    expect(Figures.heroLow.vertexCount, Figures.heroHigh.vertexCount);
    expect(perFrame, lessThan(8000));
  });
}
