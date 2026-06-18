import 'package:flutter/material.dart';
import '../utils/theme.dart';

class BarreStatutDuo extends StatelessWidget implements PreferredSizeWidget {
  final int vies;
  final int serieJours;
  final int gemmes;
  final bool isDark;

  const BarreStatutDuo({
    super.key,
    required this.vies,
    required this.serieJours,
    required this.gemmes,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isDark ? const Color(0xFF1F2937) : Colors.white;
    final borderColor = isDark ? Colors.white10 : Colors.grey[200]!;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(bottom: BorderSide(color: borderColor, width: 1.5)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildItem('🔥', '$serieJours', Colors.orange),
              _buildItem('💎', '$gemmes', AppColors.info),
              _buildItem('❤️', '$vies', AppColors.danger),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItem(String icon, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}
