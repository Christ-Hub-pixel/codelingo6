import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../fournisseurs/progression_fournisseur.dart';
import '../../services/cloud_service.dart';
import '../../utils/theme.dart';
import '../../services/audio_service.dart';
import '../../services/traduction_service.dart';

class EcranClassement extends StatefulWidget {
  const EcranClassement({super.key});

  @override
  State<EcranClassement> createState() => _EcranClassementState();
}

class _EcranClassementState extends State<EcranClassement> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _podiumScale;
  Future<List<Map<String, dynamic>>>? _classementFuture;
  String _region = 'US';

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

    try {
      _region = ui.PlatformDispatcher.instance.locale.countryCode ?? 'US';
    } catch (_) {}
    _classementFuture = CloudService.obtenirClassementRegion(_region);
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
    final userAuth = FirebaseAuth.instance.currentUser;
    final myUid = userAuth?.uid;
    final myName = (userAuth?.displayName != null && userAuth!.displayName!.isNotEmpty) 
        ? userAuth.displayName! 
        : 'Vous';

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _classementFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          List<Map<String, dynamic>> apiUsers = snapshot.data ?? [];
          final List<Map<String, dynamic>> utilisateurs = [];
          
          for (int i = 0; i < apiUsers.length; i++) {
            final u = apiUsers[i];
            final prog = u['progression'] ?? {};
            final nom = u['nom'] ?? 'Utilisateur';
            final avatar = (nom.toString().isNotEmpty) ? nom.toString()[0].toUpperCase() : '👤';
            utilisateurs.add({
              'nom': nom,
              'xp': prog['xp_total'] ?? 0,
              'rang': i + 1,
              'estMoi': u['uid'] == myUid,
              'avatar': avatar,
            });
          }

          if (utilisateurs.isEmpty) {
            utilisateurs.add({'nom': myName, 'xp': progression.xpTotal, 'rang': 1, 'estMoi': true, 'avatar': '🚀'});
          }

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 320,
                pinned: true,
                elevation: 0,
                stretch: true,
                backgroundColor: isDark ? const Color(0xFF1E1B4B) : const Color(0xFF4F46E5),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark 
                          ? [const Color(0xFF1E1B4B), const Color(0xFF0F172A)]
                          : [const Color(0xFF6366F1), const Color(0xFF4338CA)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: SafeArea(
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          // Badge Ligue Premium
                          _buildLigueBadge(progression.ligueActuelle),
                          const SizedBox(height: 8),
                          Text(
                            '🌍 Région : $_region',
                            style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 15),
                          // Podium
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: ScaleTransition(
                                scale: _podiumScale,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.bottomCenter,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      if (utilisateurs.length > 1) _buildPodiumItem(utilisateurs[1], '2', const Color(0xFFE2E8F0), 70),
                                      if (utilisateurs.length > 1) const SizedBox(width: 15),
                                      if (utilisateurs.isNotEmpty) _buildPodiumItem(utilisateurs[0], '1', const Color(0xFFFFD700), 110, isFirst: true),
                                      if (utilisateurs.length > 2) const SizedBox(width: 15),
                                      if (utilisateurs.length > 2) _buildPodiumItem(utilisateurs[2], '3', const Color(0xFFFDBA74), 50),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildPlayerRow(utilisateurs[index], isDark),
                    childCount: utilisateurs.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLigueBadge(String ligue) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.amber.withValues(alpha: 0.2), blurRadius: 20, spreadRadius: 2),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.workspace_premium_rounded, color: Color(0xFFFFD700), size: 22),
          const SizedBox(width: 10),
          Text(
            'LIGUE ${ligue.toUpperCase()}',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 2),
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumItem(Map<String, dynamic> user, String rank, Color color, double height, {bool isFirst = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (isFirst) 
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Icon(Icons.military_tech_rounded, color: color, size: 40),
          ),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.2),
            border: Border.all(color: color, width: isFirst ? 3 : 2),
            boxShadow: isFirst ? [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 20, spreadRadius: 5)] : [],
          ),
          child: CircleAvatar(
            radius: isFirst ? 32 : 24,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            child: Text(user['avatar'] as String, style: TextStyle(fontSize: isFirst ? 28 : 20)),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          (user['nom'] as String).split(' ').first,
          style: TextStyle(color: Colors.white, fontSize: isFirst ? 14 : 12, fontWeight: FontWeight.w900),
        ),
        Text(
          '${user['xp']} XP',
          style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          width: isFirst ? 90 : 75,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                color.withValues(alpha: 0.4),
                Colors.white.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, -5)),
            ],
          ),
          child: Center(
            child: Text(
              rank,
              style: TextStyle(color: Colors.white, fontSize: isFirst ? 32 : 26, fontWeight: FontWeight.w900),
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
    final color = estTop3 ? (rang == 1 ? const Color(0xFFFFD700) : (rang == 2 ? const Color(0xFF94A3B8) : const Color(0xFFD97706))) : AppColors.textMuted;

    return GestureDetector(
      onTap: () {
        if (!estMoi) {
          _afficherProfilJoueur(context, user, isDark);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: estMoi ? AppColors.primary.withValues(alpha: 0.1) : (isDark ? AppColors.cardDark : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: estMoi ? AppColors.primary : (isDark ? Colors.white10 : Colors.grey[200]!), width: estMoi ? 2 : 1),
          boxShadow: estMoi 
            ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.2), blurRadius: 15, spreadRadius: 1)]
            : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            SizedBox(
              width: 32,
              child: Text(
                '$rang',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: color),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: estTop3 ? Border.all(color: color, width: 2) : null,
              ),
              child: CircleAvatar(
                radius: 22,
                backgroundColor: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.primaryLight,
                child: Text(user['avatar'] as String, style: const TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user['nom'] as String,
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: isDark ? Colors.white : AppColors.textPrimary),
                  ),
                  if (estMoi)
                    const Text('C\'est vous ! 🚀', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w900)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${user['xp']}',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.primary),
                ),
                const Text('XP', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.textMuted, letterSpacing: 1.2)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _afficherProfilJoueur(BuildContext context, Map<String, dynamic> user, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.primaryLight,
              child: Text(user['avatar'] as String, style: const TextStyle(fontSize: 40)),
            ),
            const SizedBox(height: 16),
            Text(
              user['nom'] as String,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: isDark ? Colors.white : AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              '${user['xp']} XP • Rang ${user['rang']}',
              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('💬 ${TraductionService.t('bientot_disponible')}')));
                    },
                    icon: const Icon(Icons.chat_bubble_rounded),
                    label: Text(TraductionService.t('message')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? Colors.white10 : Colors.grey[200],
                      foregroundColor: isDark ? Colors.white : Colors.black87,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('⚔️ ${TraductionService.t('bientot_disponible')}')));
                    },
                    icon: const Icon(Icons.sports_kabaddi_rounded),
                    label: Text(TraductionService.t('duel')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
