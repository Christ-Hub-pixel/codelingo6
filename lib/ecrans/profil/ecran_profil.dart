import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../fournisseurs/progression_fournisseur.dart';
import '../../composants/index.dart';
import '../../services/cloud_service.dart';
import '../../utils/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../inscription/ecran_inscription.dart';

class EcranProfil extends StatelessWidget {
  const EcranProfil({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProgressionFournisseur>(
      builder: (context, progression, child) {
        final isDark = progression.estModeSombre;
        int totalXP = (progression.serieJours * 150) + 750;
        double niveauProgres = (totalXP % 1000) / 1000;
        int niveau = (totalXP / 1000).floor() + 1;

        return Scaffold(
          backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
          body: CustomScrollView(
            slivers: [
              // Header Premium
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                stretch: true,
                backgroundColor: isDark ? AppColors.backgroundDark : AppColors.primary,
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [StretchMode.zoomBackground],
                  background: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDark 
                              ? [const Color(0xFF1E1E2E), AppColors.backgroundDark]
                              : [const Color(0xFF6366F1), const Color(0xFF4F46E5)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                      // Motif de fond (discret)
                      Opacity(
                        opacity: 0.1,
                        child: Icon(Icons.code_rounded, size: 300, color: Colors.white),
                      ),
                      SafeArea(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 20),
                            _buildAvatarPicker(context, progression),
                            const SizedBox(height: 16),
                            const Text(
                              'Codie Master',
                              style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: Text(
                                'Niveau $niveau • Développeur Junior',
                                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Progression du Niveau
                      _buildLevelCard(niveauProgres, isDark, niveau),
                      const SizedBox(height: 24),
                      
                      // Dashboard de Statistiques Détaillé
                      _buildSectionHeader('STATISTIQUES DE CODE', isDark),
                      const SizedBox(height: 12),
                      _buildDetailedCodeStats(progression, isDark),
                      
                      const SizedBox(height: 24),
                      // Répartition par Langage
                      _buildLanguageBreakdown(isDark),
                      
                      const SizedBox(height: 32),
                      // Nouvelle Section : Progression de Ligue
                      _buildSectionHeader('CLASSEMENT DE LIGUE', isDark),
                      const SizedBox(height: 12),
                      _buildLeagueProgressCard(progression, isDark),

                      const SizedBox(height: 32),
                      // Nouvelle Section : Maîtrise Technique
                      _buildSectionHeader('MAÎTRISE TECHNIQUE', isDark),
                      const SizedBox(height: 12),
                      _buildMasteryCard(isDark),

                      const SizedBox(height: 32),
                      // Nouvelle Section : Activité (Grille style GitHub)
                      _buildSectionHeader('CONTRIBUTIONS AU CODE', isDark),
                      const SizedBox(height: 12),
                      _buildActivityHeatmap(isDark),
                      
                      const SizedBox(height: 32),
                      _buildSectionHeader('BADGES DÉBLOQUÉS', isDark),
                      const SizedBox(height: 12),
                      _buildBadgesRow(progression, isDark),

                      const SizedBox(height: 32),
                      _buildSectionHeader('CLOUD SYNC', isDark),
                      const SizedBox(height: 12),
                      _buildCloudCard(progression, context, isDark),
                      
                      const SizedBox(height: 32),
                      _buildSectionHeader('PARAMÈTRES', isDark),
                      const SizedBox(height: 12),
                      _buildSettingsGroup(progression, isDark),
                      
                      const SizedBox(height: 40),
                      BoutonDuo(
                        texte: 'SE DÉCONNECTER',
                        couleur: AppColors.danger,
                        onPressed: () => _handleLogout(context),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAvatarPicker(BuildContext context, ProgressionFournisseur progression) {
    return GestureDetector(
      onTap: () => _choisirAvatar(context, progression),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              child: MascotteAnimee(imagePath: progression.avatarPath, height: 75, width: 75),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: const Icon(Icons.camera_alt_rounded, color: AppColors.primary, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelCard(double progress, bool isDark, int niveau) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Niveau actuel', style: TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.bold)),
                  Text('Niveau $niveau', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: isDark ? Colors.white : AppColors.textPrimary)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: Text('${(progress * 100).toInt()}%', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 12,
                  backgroundColor: isDark ? Colors.white10 : AppColors.primaryLight,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
              if (progress > 0.05)
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Container(
                      width: 2,
                      height: 12,
                      color: Colors.white24,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Plus que ${(1000 - (progress * 1000)).toInt()} XP pour le niveau ${niveau + 1}',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 11, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildLeagueProgressCard(ProgressionFournisseur progression, bool isDark) {
    int xp = progression.xpTotal;
    int nextThreshold = 400;
    String nextLeague = 'Argent';
    if (xp >= 3000) { nextThreshold = 10000; nextLeague = 'Légende'; }
    else if (xp >= 1200) { nextThreshold = 3000; nextLeague = 'Diamant'; }
    else if (xp >= 400) { nextThreshold = 1200; nextLeague = 'Or'; }

    double progress = (xp / nextThreshold).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.card(dark: isDark),
      child: Row(
        children: [
          _buildLeagueBadge(progression.ligueActuelle),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Vers la ligue $nextLeague', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary)),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: isDark ? Colors.white10 : Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityHeatmap(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.card(dark: isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Assiduité (30 derniers jours)', style: TextStyle(fontWeight: FontWeight.bold)),
              Icon(Icons.terminal_rounded, size: 16, color: AppColors.primary),
            ],
          ),
          const SizedBox(height: 16),
          // Grille 7x5 pour simuler un mois
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: List.generate(35, (index) {
              int activity = (index * 13) % 6; 
              final Color color = switch (activity) {
                1 => AppColors.primary.withValues(alpha: 0.15),
                2 => AppColors.primary.withValues(alpha: 0.3),
                3 => AppColors.primary.withValues(alpha: 0.5),
                4 => AppColors.primary.withValues(alpha: 0.8),
                5 => AppColors.primary,
                _ => isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[200]!,
              };

              return Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
              );
            }),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text('Moins', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
              const SizedBox(width: 4),
              ...List.generate(5, (i) => Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(left: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: (i + 1) * 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              )),
              const SizedBox(width: 4),
              const Text('Plus', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMasteryCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.card(dark: isDark),
      child: Column(
        children: [
          _buildMasteryRow('Logique', 0.85, Colors.blue),
          const SizedBox(height: 12),
          _buildMasteryRow('Syntaxe', 0.70, Colors.purple),
          const SizedBox(height: 12),
          _buildMasteryRow('Algorithmes', 0.45, Colors.orange),
        ],
      ),
    );
  }

  Widget _buildMasteryRow(String label, double val, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            Text('${(val * 100).toInt()}%', style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: val,
            minHeight: 6,
            backgroundColor: color.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildBadgesRow(ProgressionFournisseur progression, bool isDark) {
    final badges = [
      {'icon': '🔥', 'name': 'Série 7j', 'unlocked': progression.serieJours >= 7},
      {'icon': '💎', 'name': 'Riche', 'unlocked': progression.gemmes >= 500},
      {'icon': '⚔️', 'name': 'Guerrier', 'unlocked': progression.victoiresDuels >= 1},
      {'icon': '🦉', 'name': 'Sage', 'unlocked': progression.xpTotal >= 1000},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: badges.map((badge) {
          bool unlocked = badge['unlocked'] as bool;
          return Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: unlocked ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: unlocked ? AppColors.primary.withValues(alpha: 0.3) : (isDark ? Colors.white12 : Colors.grey[300]!)),
            ),
            child: Column(
              children: [
                Opacity(
                  opacity: unlocked ? 1.0 : 0.3,
                  child: Text(badge['icon'] as String, style: const TextStyle(fontSize: 32)),
                ),
                const SizedBox(height: 8),
                Text(
                  badge['name'] as String,
                  style: TextStyle(
                    fontSize: 10, 
                    fontWeight: FontWeight.bold,
                    color: unlocked ? AppColors.primary : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDetailedCodeStats(ProgressionFournisseur progression, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.card(dark: isDark),
      child: Column(
        children: [
          Row(
            children: [
              _buildSimpleMetric('LIGNES', '1,240', Icons.segment_rounded, Colors.blue),
              _buildDivider(isDark),
              _buildSimpleMetric('FONCTIONS', '84', Icons.functions_rounded, Colors.purple),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1),
          ),
          Row(
            children: [
              _buildSimpleMetric('FOCUS', '12h 45m', Icons.timer_rounded, Colors.orange),
              _buildDivider(isDark),
              _buildSimpleMetric('STABILITÉ', '98%', Icons.verified_user_rounded, Colors.green),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleMetric(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color.withValues(alpha: 0.7), size: 20),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.bold, letterSpacing: 1)),
        ],
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Container(height: 40, width: 1, color: isDark ? Colors.white10 : Colors.black12);
  }

  Widget _buildLanguageBreakdown(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.card(dark: isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('RÉPARTITION PAR LANGAGE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.textMuted)),
          const SizedBox(height: 16),
          // Barre multi-couleurs
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 12,
              child: Row(
                children: [
                  Expanded(flex: 75, child: Container(color: Colors.blue)), // Python
                  Expanded(flex: 15, child: Container(color: Colors.yellow)), // JS
                  Expanded(flex: 10, child: Container(color: Colors.orange)), // HTML/CSS
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildLanguageLegend('Python', '75%', Colors.blue),
          _buildLanguageLegend('Javascript', '15%', Colors.yellow),
          _buildLanguageLegend('HTML/CSS', '10%', Colors.orange),
        ],
      ),
    );
  }

  Widget _buildLanguageLegend(String name, String percent, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          const Spacer(),
          Text(percent, style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildLeagueBadge(String ligue) {
    Color color;
    String icon;
    switch (ligue) {
      case 'Argent': color = Colors.grey[400]!; icon = '🥈'; break;
      case 'Or': color = Colors.amber; icon = '🥇'; break;
      case 'Diamant': color = Colors.cyanAccent; icon = '💎'; break;
      default: color = Colors.brown[300]!; icon = '🥉';
    }

    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
      ),
      child: Center(child: Text(icon, style: const TextStyle(fontSize: 28))),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.5,
        color: isDark ? AppColors.textDarkSecondary : AppColors.textMuted,
      ),
    );
  }

  Widget _buildCloudCard(ProgressionFournisseur progression, BuildContext context, bool isDark) {
    final user = FirebaseAuth.instance.currentUser;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.cardBordered(
        borderColor: user != null ? AppColors.success : AppColors.warning,
        dark: isDark,
      ),
      child: Row(
        children: [
          Icon(
            user != null ? Icons.cloud_done_rounded : Icons.cloud_off_rounded,
            color: user != null ? AppColors.success : AppColors.warning,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user != null ? 'Cloud Sync Actif' : 'Mode Local Uniquement',
                  style: TextStyle(fontWeight: FontWeight.w800, color: isDark ? Colors.white : AppColors.textPrimary),
                ),
                Text(
                  user != null ? user.email! : 'Connectez-vous pour sauvegarder',
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          if (user != null)
            IconButton(
              icon: const Icon(Icons.cloud_sync_rounded, color: AppColors.primary),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Synchronisation en temps réel active !')));
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSettingsGroup(ProgressionFournisseur progression, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 8, bottom: 12),
          child: Text(
            'RÉGLAGES',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.primary, letterSpacing: 1.5),
          ),
        ),
        Container(
          decoration: AppDecorations.card(dark: isDark),
          child: Column(
            children: [
              _buildSettingsTile(Icons.dark_mode_rounded, 'Mode Sombre', isDark, 
                trailing: Switch(
                  value: progression.estModeSombre,
                  onChanged: (val) => progression.toggleModeSombre(),
                  activeThumbColor: AppColors.primary,
                )
              ),
              const Divider(height: 1, indent: 50, endIndent: 20, color: Colors.black12),
              _buildSettingsTile(Icons.language_rounded, 'Langue d\'apprentissage', isDark, value: progression.langueApprise),
              const Divider(height: 1, indent: 50, endIndent: 20, color: Colors.black12),
              _buildSettingsTile(Icons.notifications_active_rounded, 'Notifications', isDark),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTile(IconData icon, String title, bool isDark, {Widget? trailing, String? value}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: isDark ? Colors.white : AppColors.textPrimary)),
      trailing: trailing ?? Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (value != null) Text(value, style: const TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
        ],
      ),
    );
  }

  void _choisirAvatar(BuildContext context, ProgressionFournisseur progression) {
    final avatars = [
      {'path': 'assets/images/joyeuse.png', 'name': 'Codie Content'},
      {'path': 'assets/images/idee.png', 'name': 'Codie Pensif'},
      {'path': 'assets/images/encouragement.png', 'name': 'Codie Zen'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: progression.estModeSombre ? AppColors.cardDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Choisir ton avatar', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: avatars.map((avatar) {
                bool isSel = progression.avatarPath == avatar['path'];
                return GestureDetector(
                  onTap: () {
                    progression.setAvatar(avatar['path']!);
                    Navigator.pop(context);
                  },
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: isSel ? AppColors.primary : Colors.transparent, width: 3),
                        ),
                        child: CircleAvatar(
                          radius: 35,
                          backgroundColor: AppColors.primaryLight,
                          child: Image.asset(avatar['path']!, height: 45),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(avatar['name']!, style: TextStyle(fontSize: 12, fontWeight: isSel ? FontWeight.w800 : FontWeight.w500)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _handleLogout(BuildContext context) async {
    await CloudService.seDeconnecter();
    if (!context.mounted) return;
    
    // Rediriger vers l'écran d'inscription et effacer l'historique de navigation
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const EcranInscription()),
      (Route<dynamic> route) => false,
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Déconnexion réussie')),
    );
  }
}
