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
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: isDark ? const Color(0xFF4C1D95) : const Color(0xFF7C3AED),
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark 
                      ? [const Color(0xFF4C1D95), const Color(0xFF2E1065)]
                      : [const Color(0xFF8B5CF6), const Color(0xFF6D28D9)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text(
                          '🛍️ Boutique',
                          style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
                            boxShadow: [
                              BoxShadow(color: const Color(0xFF34D399).withValues(alpha: 0.2), blurRadius: 10, spreadRadius: 1),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('💎', style: TextStyle(fontSize: 20)),
                              const SizedBox(width: 8),
                              Text(
                                '${progression.gemmes} gemmes',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
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
            padding: const EdgeInsets.all(24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildSectionLabel('OBJETS SPÉCIAUX', isDark),
                const SizedBox(height: 16),
                _buildShopItem(
                  context, progression, isDark,
                  icon: '❤️',
                  title: 'Recharge de Vies',
                  desc: 'Remplis instantanément ton cœur à 5 vies.',
                  price: 350,
                  color: const Color(0xFFEF4444),
                  isPossede: progression.vies >= 5,
                  textePossede: '✓ MAX',
                  onTap: () => _acheterVies(context, progression),
                ),
                const SizedBox(height: 16),
                _buildShopItem(
                  context, progression, isDark,
                  icon: '❄️',
                  title: 'Gel de Série',
                  desc: 'Protège ta série si tu oublies de coder demain.',
                  price: 1000,
                  color: const Color(0xFF0EA5E9),
                  isPossede: progression.gelDeSerieActif,
                  textePossede: '✓ ACTIF',
                  onTap: () => _acheterGel(context, progression),
                ),
                const SizedBox(height: 36),
                _buildSectionLabel('TENUES DE CODIE', isDark),
                const SizedBox(height: 16),
                _buildShopItem(
                  context, progression, isDark,
                  icon: '🎩',
                  title: 'Codie Magicien',
                  desc: 'Une tenue mystique pour un pro du code.',
                  price: 2500,
                  color: const Color(0xFF8B5CF6),
                  isPossede: progression.tenuesPossedees.contains('magicien'),
                  textePossede: progression.tenueActuelle == 'magicien' ? 'ÉQUIPÉ' : 'ÉQUIPER',
                  onTap: () {
                    if (progression.tenuesPossedees.contains('magicien')) {
                      _equiperTenue(context, progression, 'magicien');
                    } else {
                      _acheterTenue(context, progression, 'magicien', 2500);
                    }
                  },
                ),
                const SizedBox(height: 16),
                _buildShopItem(
                  context, progression, isDark,
                  icon: '🤖',
                  title: 'Codie Robot',
                  desc: 'Transforme Codie en super-ordinateur.',
                  price: 3000,
                  color: const Color(0xFF3B82F6),
                  isPossede: progression.tenuesPossedees.contains('robot'),
                  textePossede: progression.tenueActuelle == 'robot' ? 'ÉQUIPÉ' : 'ÉQUIPER',
                  onTap: () {
                    if (progression.tenuesPossedees.contains('robot')) {
                      _equiperTenue(context, progression, 'robot');
                    } else {
                      _acheterTenue(context, progression, 'robot', 3000);
                    }
                  },
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
        fontSize: 13,
        fontWeight: FontWeight.w900,
        letterSpacing: 2.0,
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
    String textePossede = '✓ MAX',
    bool indisponible = false,
  }) {
    final bool peutAcheter = !indisponible && progression.gemmes >= price;
    final bool isEquipe = textePossede == 'ÉQUIPÉ';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: (isPossede || isEquipe) ? AppColors.success.withValues(alpha: 0.5) : (isDark ? Colors.white10 : Colors.grey[200]!),
          width: (isPossede || isEquipe) ? 2 : 1.5,
        ),
        boxShadow: isDark ? [] : [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withValues(alpha: 0.2), color.withValues(alpha: 0.05)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.2), width: 2),
            ),
            child: Center(child: Text(icon, style: const TextStyle(fontSize: 32))),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: isDark ? Colors.white : AppColors.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 13, height: 1.3, fontWeight: FontWeight.w500),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isPossede ? AppColors.textMuted.withValues(alpha: 0.1) : color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '💎 $price',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: isPossede ? AppColors.textMuted : (progression.gemmes >= price ? color : AppColors.danger),
                          fontSize: 14,
                        ),
                      ),
                    ),
                    if (progression.gemmes < price && !isPossede && !indisponible)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text(
                            'Il manque ${price - progression.gemmes} 💎',
                            style: const TextStyle(color: AppColors.danger, fontSize: 12, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: (isPossede || peutAcheter) ? onTap : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isEquipe 
                    ? AppColors.success.withValues(alpha: 0.15)
                    : isPossede 
                        ? color.withValues(alpha: 0.15)
                        : (indisponible || !peutAcheter)
                            ? (isDark ? Colors.white10 : Colors.grey[100])
                            : color,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isEquipe ? AppColors.success : (isPossede ? color : Colors.transparent),
                  width: 1.5,
                ),
                boxShadow: (peutAcheter && !isPossede && !indisponible) ? [
                  BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))
                ] : [],
              ),
              child: Text(
                isPossede ? textePossede : (indisponible ? 'BIENTÔT' : 'ACHETER'),
                style: TextStyle(
                  fontSize: 13, 
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                  color: isEquipe 
                      ? AppColors.success 
                      : isPossede 
                          ? color
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
    if (progression.vies >= 5) return;
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
    }
  }

  void _acheterGel(BuildContext context, ProgressionFournisseur progression) {
    if (progression.gelDeSerieActif) return;
    if (progression.gemmes >= 1000) {
      progression.depenserGemmes(1000);
      progression.activerGelDeSerie();
      HapticService.success();
      AudioService.jouerSonGemmes();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❄️ Gel de série activé pour demain !'), backgroundColor: Colors.lightBlue),
      );
    } else {
      HapticService.error();
      AudioService.jouerSonErreur();
    }
  }

  void _acheterTenue(BuildContext context, ProgressionFournisseur progression, String id, int prix) {
    if (progression.tenuesPossedees.contains(id)) return;
    if (progression.gemmes >= prix) {
      progression.depenserGemmes(prix);
      progression.acheterTenue(id);
      HapticService.success();
      AudioService.jouerSonGemmes();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✨ Nouvelle tenue débloquée !'), backgroundColor: Colors.purple),
      );
    } else {
      HapticService.error();
      AudioService.jouerSonErreur();
    }
  }

  void _equiperTenue(BuildContext context, ProgressionFournisseur progression, String id) {
    if (progression.tenueActuelle == id) return;
    progression.equiperTenue(id);
    HapticService.click();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('👗 Tenue équipée !'), backgroundColor: AppColors.primary),
    );
  }
}
