import 'package:flutter/material.dart';

import '../../core/glyphs.dart';
import '../../core/palette.dart';
import '../../core/type.dart';
import '../../core/widgets.dart';
import '../../scene/orb.dart';
import '../../sound/mixer.dart';
import '../../sound/sounds.dart';

Future<T?> showNightSheet<T>(
  BuildContext context, {
  required String title,
  String? caption,
  required Widget Function(BuildContext) body,
}) {
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: const Color(0x99050712),
    isScrollControlled: true,
    elevation: 0,
    builder: (context) =>
        _SheetFrame(title: title, caption: caption, child: body(context)),
  );
}

class _SheetFrame extends StatelessWidget {
  const _SheetFrame({required this.title, required this.child, this.caption});

  final String title;
  final String? caption;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final s = mq.size.width / 393;
    return Padding(
      padding: EdgeInsets.fromLTRB(8 * s, 0, 8 * s, 8 * s),
      child: Blurred(
        radius: BorderRadius.circular(34 * s),
        sigma: 26,
        child: Container(
          padding: EdgeInsets.fromLTRB(
            22 * s,
            12 * s,
            22 * s,
            18 * s + mq.padding.bottom * 0.6,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(34 * s),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xE6221F40), Color(0xF2141630)],
            ),
            border: Border.all(color: const Color(0x26C9C0FF)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38 * s,
                  height: 4 * s,
                  decoration: BoxDecoration(
                    color: const Color(0x40FFFFFF),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: 18 * s),
              Text(title, style: Typo.serifText(22 * s, weight: 430)),
              if (caption != null) ...[
                SizedBox(height: 4 * s),
                Text(caption!, style: Typo.ui(13 * s, color: Night.textDim)),
              ],
              SizedBox(height: 18 * s),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

Future<Sound?> showSoundPicker(BuildContext context) {
  final mixer = MixerScope.read(context);
  final options = Sound.values.where((s) => !mixer.contains(s)).toList();
  return showNightSheet<Sound>(
    context,
    title: 'Add to your mix',
    caption: 'Choose a sound to pour into the vessel',
    body: (context) {
      final s = MediaQuery.of(context).size.width / 393;
      return Wrap(
        alignment: WrapAlignment.center,
        spacing: 8 * s,
        runSpacing: 14 * s,
        children: [
          for (final sound in options)
            Pressable(
              onTap: () => Navigator.of(context).pop(sound),
              child: SizedBox(
                width: 76 * s,
                child: Column(
                  children: [
                    Orb(sound: sound, diameter: 54 * s, glow: 0.9),
                    SizedBox(height: 8 * s),
                    Text(sound.label, style: Typo.ui(12.5 * s, weight: 500)),
                  ],
                ),
              ),
            ),
        ],
      );
    },
  );
}

Future<Duration?> showTimerSheet(BuildContext context, Duration current) {
  const options = [15, 30, 45, 60, 90, 120];
  return showNightSheet<Duration>(
    context,
    title: 'Sleep timer',
    caption: 'Nocturne fades out gently when it ends',
    body: (context) {
      final s = MediaQuery.of(context).size.width / 393;
      return Wrap(
        spacing: 10 * s,
        runSpacing: 10 * s,
        children: [
          for (final m in options)
            Pressable(
              onTap: () => Navigator.of(context).pop(Duration(minutes: m)),
              child: Container(
                width: (393 * s - 16 * s - 44 * s - 20 * s) / 3,
                height: 64 * s,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20 * s),
                  gradient: current.inMinutes == m
                      ? const LinearGradient(
                          colors: [Color(0xFFC6B8FF), Color(0xFFAE9CF6)],
                        )
                      : const LinearGradient(
                          colors: [Color(0x0FFFFFFF), Color(0x08FFFFFF)],
                        ),
                  border: Border.all(
                    color: current.inMinutes == m
                        ? const Color(0x66FFFFFF)
                        : const Color(0x1FFFFFFF),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      m >= 60 && m % 60 == 0 ? '${m ~/ 60}' : '$m',
                      style: Typo.serifText(
                        22 * s,
                        color: current.inMinutes == m ? Night.ink : Night.text,
                        height: 1.1,
                      ),
                    ),
                    Text(
                      m >= 60 && m % 60 == 0
                          ? (m == 60 ? 'hour' : 'hours')
                          : 'min',
                      style: Typo.ui(
                        11.5 * s,
                        color: current.inMinutes == m
                            ? Night.ink
                            : Night.textDim,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
    },
  );
}

Future<void> showLevelsSheet(BuildContext context) {
  return showNightSheet<void>(
    context,
    title: 'Your blend',
    caption: 'Shape each layer of tonight’s soundscape',
    body: (context) => const _Levels(),
  );
}

class _Levels extends StatelessWidget {
  const _Levels();

  @override
  Widget build(BuildContext context) {
    final mixer = MixerScope.of(context);
    final s = MediaQuery.of(context).size.width / 393;
    if (mixer.sounds.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 20 * s),
        child: Text(
          'Your mix is empty. Add sounds from Home.',
          style: Typo.ui(14 * s, color: Night.textDim),
        ),
      );
    }
    return Column(
      children: [
        for (final sound in mixer.sounds)
          Padding(
            padding: EdgeInsets.only(bottom: 10 * s),
            child: Row(
              children: [
                Orb(sound: sound, diameter: 34 * s, glow: 0.7),
                SizedBox(width: 12 * s),
                SizedBox(
                  width: 62 * s,
                  child: Text(
                    sound.label,
                    style: Typo.ui(13.5 * s, weight: 500),
                  ),
                ),
                Expanded(
                  child: NightSlider(
                    value: mixer.volume(sound),
                    colors: [
                      Color.lerp(sound.mid, sound.glow, 0.3)!,
                      Color.lerp(sound.glow, Colors.white, 0.45)!,
                    ],
                    onChanged: (v) => mixer.setVolume(sound, v),
                  ),
                ),
              ],
            ),
          ),
        Padding(
          padding: EdgeInsets.only(top: 4 * s),
          child: Row(
            children: [
              SizedBox(
                width: 34 * s,
                child: Center(
                  child: Glyph(G.speaker, size: 22 * s, color: Night.text),
                ),
              ),
              SizedBox(width: 12 * s),
              SizedBox(
                width: 62 * s,
                child: Text('Master', style: Typo.ui(13.5 * s, weight: 500)),
              ),
              Expanded(
                child: NightSlider(
                  value: mixer.master,
                  onChanged: mixer.setMaster,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
