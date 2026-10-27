import 'package:flutter/material.dart';

import '../home.dart';

/// An iPhone-style bezel around the app at the exact 390 × 844 design size.
class PhoneFrame extends StatelessWidget {
  const PhoneFrame({super.key, this.homeKey});

  final GlobalKey<LullHomeState>? homeKey;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: const Color(0xFF111214),
        borderRadius: BorderRadius.circular(64),
        boxShadow: const [
          BoxShadow(color: Color(0x33000000), blurRadius: 40, offset: Offset(0, 24)),
          BoxShadow(color: Color(0x1A000000), blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(53),
        child: Stack(
          children: [
            MediaQuery(
              data: MediaQuery.of(context).copyWith(
                size: const Size(390, 844),
                padding: const EdgeInsets.only(top: 47, bottom: 34),
                viewPadding: const EdgeInsets.only(top: 47, bottom: 34),
              ),
              child: SizedBox(width: 390, height: 844, child: LullHome(key: homeKey, framed: true)),
            ),
            Positioned(
              top: 11,
              left: (390 - 124) / 2,
              child: Container(
                width: 124,
                height: 36,
                decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(20)),
              ),
            ),
            Positioned(
              bottom: 8,
              left: (390 - 134) / 2,
              child: Container(
                width: 134,
                height: 5,
                decoration: BoxDecoration(color: const Color(0x99000000), borderRadius: BorderRadius.circular(3)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
