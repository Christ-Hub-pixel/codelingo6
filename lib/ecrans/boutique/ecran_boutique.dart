import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../fournisseurs/progression_fournisseur.dart';
import '../../services/haptic_service.dart';
import '../../services/audio_service.dart';
import '../../utils/theme.dart';

class EcranBoutique extends StatelessWidget {
  const EcranBoutique({super.key});

  @override
  Widget build(BuildContext context) {
    final progression = Provider.of<ProgressionFournisseur>(context);
    final isDark = progression.estModeSombre;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: AppColors.primaryDark,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF7C3AED), Color(0xFF4F46E5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text(
                          '🛍️ Boutique',
                          style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('💎', style: TextStyle(fontSize: 18)),
                              const SizedBox(width: 8),
                              Text(
                                '${progression.gemmes} gemmes disponibles',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildSectionLabel('OBJETS SPÉCIAUX', isDark),
                const SizedBox(height: 12),
                _buildShopItem(
                  context, progression, isDark,
                  icon: '❤️',
                  title: 'Recharge de Vies',
                  desc: 'Remplis instantanément ton cœur à 5 vies.',
                  price: 350,
                  color: AppColors.danger,
                  isPossede: progression.vies >= 5,
                  onTap: () => _acheterVies(context, progression),
                ),
                const SizedBox(height: 12),
                _buildShopItem(
                  context, progression, isDark,
                  icon: '❄️',
                  title: 'Gel de Série',
                  desc: 'Protège ta série si tu oublies de coder demain.',
                  price: 1000,
                  color: Colors.lightBlue,
                  isPossede: false,
                  onTap: () => _acheterGel(context),
                ),
                const SizedBox(height: 28),
                _buildSectionLabel('TENUES DE CODIE', isDark),
                const SizedBox(height: 12),
                _buildShopItem(
                  context, progression, isDark,
                  icon: '🎩',
                  title: 'Codie Magicien',
                  desc: 'Une tenue mystique pour un pro du code.',
                  price: 2500,
                  color: Colors.purple,
                  isPossede: false,
                  indisponible: true,
                  onTap: () {},
                ),
                const SizedBox(height: 12),
                _buildShopItem(
                  context, progression, isDark,
                  icon: '🤖',
                  title: 'Codie Robot',
                  desc: 'Transforme Codie en super-ordinateur.',
                  price: 3000,
                  color: AppColors.primary,
                  isPossede: false,
                  indisponible: true,
                  onTap: () {},
                ),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text, bool isDark) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.5,
        color: isDark ? AppColors.textDarkSecondary : AppColors.textMuted,
      ),
    );
  }

  Widget _buildShopItem(
    BuildContext context,
    ProgressionFournisseur progression,
    bool isDark, {
    required String icon,
    required String title,
    required String desc,
    required int price,
    required Color color,
    required bool isPossede,
    required VoidCallback onTap,
    bool indisponible = false,
  }) {
    final bool peutAcheter = !isPossede && !indisponible && progression.gemmes >= price;

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPossede ? AppColors.success.withValues(alpha: 0.4) : Colors.transparent,
          width: isPossede ? 1.5 : 0,
        ),
        boxShadow: isDark ? [] : [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(child: Text(icon, style: const TextStyle(fontSize: 28))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: isDark ? Colors.white : AppColors.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  desc,
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 12, height: 1.2),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '💎 $price',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: isPossede ? AppColors.textMuted : (progression.gemmes >= price ? color : AppColors.danger),
                        fontSize: 14,
                      ),
                    ),
                    if (progression.gemmes < price && !isPossede)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Text(
                            '(-${price - progression.gemmes})',
                            style: const TextStyle(color: AppColors.danger, fontSize: 10, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: (peutAcheter && !isPossede) ? onTap : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isPossede
                    ? AppColors.success.withValues(alpha: 0.15)
                    : (indisponible || !peutAcheter)
                        ? (isDark ? Colors.white10 : Colors.grey.shade100)
                        : color,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                isPossede ? '✓ Max' : (indisponible ? 'Bientôt' : 'Acheter'),
                style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w800,
                  color: isPossede
                      ? AppColors.success
                      : (indisponible || !peutAcheter) ? AppColors.textMuted : Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _acheterVies(BuildContext context, ProgressionFournisseur progression) {
    if (progression.gemmes >= 350) {
      progression.depenserGemmes(350);
      progression.rechargerVies();
      HapticService.success();
      AudioService.jouerSonGemmes();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❤️ Vies rechargées !'), backgroundColor: AppColors.success),
      );
    } else {
      HapticService.error();
      AudioService.jouerSonErreur();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('💎 Pas assez de gemmes !'), backgroundColor: AppColors.danger),
      );
    }
  }

  void _acheterGel(BuildContext context) {
    HapticService.click();
    AudioService.jouerSonGemmes();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('❄️ Gel de série activé pour demain !'), backgroundColor: Colors.lightBlue),
    );
  }
}
