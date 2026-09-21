import 'package:flutter/material.dart';

class CopyrightWatermark extends StatelessWidget {
  const CopyrightWatermark({
    super.key,
    this.dark = false,
  });

  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 16,
        right: 16,
        top: 8,
        bottom: 10,
      ),
      child: Center(
        child: Text(
          '© 2026 Sistem pengaduan sarana sekolah. '
          'All rights reserved by Aan Risky Ramadhanni SMK N 1 Sanden.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: dark ? Colors.white.withOpacity(0.60) : Colors.grey.shade500,
            fontSize: 8.5,
            fontWeight: FontWeight.w500,
            height: 1.3,
          ),
        ),
      ),
    );
  }
}
