import 'package:flutter/material.dart';
import '../../utils/theme.dart';

import 'package:flutter/services.dart';
class BoutonDuo extends StatefulWidget {
  final String texte;
  final VoidCallback onPressed;
  final Color? couleur;
  final bool estActif;
  final double? width;

  const BoutonDuo({
    super.key,
    required this.texte,
    required this.onPressed,
    this.couleur,
    this.estActif = true,
    this.width,
  });

  @override
  State<BoutonDuo> createState() => _BoutonDuoState();
}

class _BoutonDuoState extends State<BoutonDuo> {
  bool _estAppuye = false;

  @override
  Widget build(BuildContext context) {
    final Color baseColor = widget.couleur ?? AppColors.primary;
    final Color shadowColor = HSLColor.fromColor(baseColor).withLightness(
      (HSLColor.fromColor(baseColor).lightness - 0.15).clamp(0.0, 1.0)
    ).toColor();

    return SizedBox(
      width: widget.width,
      child: GestureDetector(
        onTapDown: widget.estActif ? (_) {
          HapticFeedback.lightImpact();
          setState(() => _estAppuye = true);
        } : null,
        onTapUp: widget.estActif ? (_) {
          setState(() => _estAppuye = false);
          widget.onPressed();
        } : null,
        onTapCancel: widget.estActif ? () => setState(() => _estAppuye = false) : null,
        child: AnimatedScale(
          scale: _estAppuye ? 0.96 : 1.0,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            margin: EdgeInsets.only(top: _estAppuye ? 4.0 : 0.0),
            padding: EdgeInsets.only(bottom: _estAppuye ? 0.0 : 4.0),
            decoration: BoxDecoration(
              color: widget.estActif ? shadowColor : Colors.grey[400],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: widget.estActif ? baseColor : Colors.grey[300],
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              alignment: Alignment.center,
              child: Text(
                widget.texte.toUpperCase(),
                style: TextStyle(
                  color: widget.estActif ? Colors.white : Colors.grey[500],
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
