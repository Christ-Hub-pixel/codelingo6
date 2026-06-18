import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../fournisseurs/progression_fournisseur.dart';
import '../../utils/theme.dart';
import '../../services/audio_service.dart';

class EcranClassement extends StatefulWidget {
  const EcranClassement({super.key});

  @override
  State<EcranClassement> createState() => _EcranClassementState();
}

class _EcranClassementState extends State<EcranClassement> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _podiumScale;

  @override
  void initState() {
    super.initState();
    AudioService.jouerSonLigue();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _podiumScale = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progression = Provider.of<ProgressionFournisseur>(context);
    final isDark = progression.estModeSombre;

    final utilisateurs = [
      {'nom': 'Alice Codeuse', 'xp': 2850, 'rang': 1, 'estMoi': false, 'avatar': '👩‍💻'},
      {'nom': 'Vous', 'xp': progression.serieJours * 100 + 750, 'rang': 2, 'estMoi': true, 'avatar': '🚀'},
      {'nom': 'Bob Builder', 'xp': 1200, 'rang': 3, 'estMoi': false, 'avatar': '👨‍🔧'},
      {'nom': 'Charlie Dev', 'xp': 950, 'rang': 4, 'estMoi': false, 'avatar': '🧑‍💻'},
      {'nom': 'Diana Script', 'xp': 820, 'rang': 5, 'estMoi': false, 'avatar': '👩‍🔬'},
      {'nom': 'Evan Java', 'xp': 600, 'rang': 6, 'estMoi': false, 'avatar': '☕'},
      {'nom': 'Fiona CSS', 'xp': 450, 'rang': 7, 'estMoi': false, 'avatar': '🎨'},
    ];

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            elevation: 0,
            stretch: true,
            backgroundColor: AppColors.primaryDark,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      // Badge Ligue Premium
                      _buildLigueBadge(progression.ligueActuelle),
                      const SizedBox(height: 20),
                      // Podium
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: ScaleTransition(
                            scale: _podiumScale,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.bottomCenter,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  _buildPodiumItem(utilisateurs[1], '2', const Color(0xFFE2E8F0), 60),
                                  const SizedBox(width: 10),
                                  _buildPodiumItem(utilisateurs[0], '1', const Color(0xFFFDE047), 85),
                                  const SizedBox(width: 10),
                                  _buildPodiumItem(utilisateurs[2], '3', const Color(0xFFFDBA74), 45),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildPlayerRow(utilisateurs[index], isDark),
                childCount: utilisateurs.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLigueBadge(String ligue) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.shield_rounded, color: Color(0xFFFDE047), size: 20),
          const SizedBox(width: 8),
          Text(
            'LIGUE ${ligue.toUpperCase()}',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1.2),
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumItem(Map<String, dynamic> user, String rank, Color color, double height) {
    final isFirst = rank == '1';
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (isFirst) 
          const Padding(
            padding: EdgeInsets.only(bottom: 2),
            child: Icon(Icons.workspace_premium_rounded, color: Color(0xFFFDE047), size: 24),
          ),
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.5), width: 2),
          ),
          child: CircleAvatar(
            radius: isFirst ? 28 : 22,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            child: Text(user['avatar'] as String, style: TextStyle(fontSize: isFirst ? 24 : 18)),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          (user['nom'] as String).split(' ').first,
          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800),
        ),
        Text(
          '${user['xp']} XP',
          style: TextStyle(color: color.withValues(alpha: 0.9), fontSize: 10, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        Container(
          width: isFirst ? 80 : 70,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withValues(alpha: 0.3),
                Colors.white.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: Center(
            child: Text(
              rank,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 24, fontWeight: FontWeight.w900),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerRow(Map<String, dynamic> user, bool isDark) {
    final rang = user['rang'] as int;
    final estMoi = user['estMoi'] == true;
    final estTop3 = rang <= 3;
    final color = estTop3 ? (rang == 1 ? const Color(0xFFFDE047) : (rang == 2 ? const Color(0xFF94A3B8) : const Color(0xFFD97706))) : AppColors.textMuted;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: estMoi ? AppColors.primary.withValues(alpha: 0.1) : (isDark ? AppColors.cardDark : Colors.white),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: estMoi ? AppColors.primary.withValues(alpha: 0.3) : Colors.transparent, width: 1.5),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '$rang',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: color),
            ),
          ),
          CircleAvatar(
            radius: 20,
            backgroundColor: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.primaryLight,
            child: Text(user['avatar'] as String, style: const TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['nom'] as String,
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: isDark ? Colors.white : AppColors.textPrimary),
                ),
                if (estMoi)
                  const Text('C\'est vous ! 🚀', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${user['xp']}',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.primary),
              ),
              const Text('XP', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: AppColors.textMuted, letterSpacing: 1)),
            ],
          ),
        ],
      ),
    );
  }
}
