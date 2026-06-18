import 'package:flutter/material.dart';
import 'mascotte_animee.dart';
import '../utils/theme.dart';

class BulleTuto extends StatelessWidget {
  final String message;
  final String imagePath;
  final bool mascotteAGauche;

  const BulleTuto({
    super.key,
    required this.message,
    this.imagePath = 'assets/images/joyeuse.png',
    this.mascotteAGauche = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (mascotteAGauche) _buildMascotte(),
          if (mascotteAGauche) const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(24),
                  topRight: const Radius.circular(24),
                  bottomLeft: Radius.circular(mascotteAGauche ? 4 : 24),
                  bottomRight: Radius.circular(mascotteAGauche ? 24 : 4),
                ),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.4,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          if (!mascotteAGauche) const SizedBox(width: 12),
          if (!mascotteAGauche) _buildMascotte(),
        ],
      ),
    );
  }

  Widget _buildMascotte() {
    return MascotteAnimee(
      imagePath: imagePath,
      height: 70,
      width: 70,
    );
  }
}
