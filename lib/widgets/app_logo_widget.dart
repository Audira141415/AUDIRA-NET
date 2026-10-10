import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double? width;
  final double? height;
  final BoxFit fit;

  const AppLogo({
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo.png',
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        // Fallback jika logo tidak ditemukan
        return Container(
          width: width ?? 100,
          height: height ?? 100,
          decoration: BoxDecoration(
            color: Colors.blue[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.business, color: Colors.blue),
        );
      },
    );
  }
}

class AppLogoWithText extends StatelessWidget {
  final double logoSize;
  final double fontSize;
  final MainAxisAlignment alignment;

  const AppLogoWithText({
    super.key,
    this.logoSize = 120,
    this.fontSize = 24,
    this.alignment = MainAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: alignment,
      children: [
        AppLogo(width: logoSize, height: logoSize),
        const SizedBox(height: 12),
        const Text(
          'Audira Digital Network',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          'Connecting Your Digital Future',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w300,
            letterSpacing: 0.8,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
