import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginAppBar extends StatelessWidget implements PreferredSizeWidget {
  const LoginAppBar({super.key, this.title = 'Login', this.onBack});

  final String title;
  final VoidCallback? onBack;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.white,
      leading: Center(
        child: GestureDetector(
          onTap: onBack ?? () => Navigator.of(context).maybePop(),
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
          ),
        ),
      ),
      centerTitle: true,
      title: Text(
        title,
        style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w400),
      ),
    );
  }
}
