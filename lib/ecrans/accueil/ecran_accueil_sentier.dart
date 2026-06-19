import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../composants/index.dart';
import '../lecon/ecran_tutoriel.dart';
import '../../modeles/index.dart';
import '../../fournisseurs/progression_fournisseur.dart';
import '../../services/contenu_service.dart';
import '../../fournisseurs/notification_fournisseur.dart';
import '../playground/ecran_playground.dart';
import '../../services/haptic_service.dart';
import '../../services/audio_service.dart';
import '../../utils/theme.dart';

class EcranAccueilSentier extends StatelessWidget {
  const EcranAccueilSentier({super.key});

  @override
  Widget build(BuildContext context) {
    final progression = Provider.of<ProgressionFournisseur>(context);
    final notifications = Provider.of<NotificationFournisseur>(context);
    
    final isDark = progression.estModeSombre;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
        elevation: 0,
        toolbarHeight: 75,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    children: [
                      _buildStatItem('🔥', '${progression.serieJours}', Colors.orange),
                      const SizedBox(width: 8),
                      _buildStatItem('💎', '${progression.gemmes}', AppColors.info),
                      const SizedBox(width: 8),
                      _buildStatItem('❤️', '${progression.vies}', AppColors.danger),
                      const SizedBox(width: 8),
                      _buildLeagueBadge(progression),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Bouton Playground
            IconButton(
              icon: Icon(Icons.code_rounded, color: isDark ? Colors.white70 : AppColors.primary),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EcranPlayground()),
              ),
            ),
            // Bouton Notifications Restauré
            Stack(
              children: [
                IconButton(
                  icon: Icon(Icons.notifications_none_rounded, color: isDark ? Colors.white70 : AppColors.textSecondary),
                  onPressed: () => _ouvrirNotifications(context, notifications),
                ),
                if (notifications.nbNonLus > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: AppColors.danger, shape: BoxShape.circle),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        '${notifications.nbNonLus}',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<Unite>>(
        future: ContenuService.chargerContenu(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Erreur de chargement de l\'aventure'));
          }

          final unites = snapshot.data!;
          return Stack(
            children: [
              Positioned.fill(
                child: isDark 
                  ? const FondAnimeCode(child: SizedBox.expand())
                  : Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [AppColors.background, const Color(0xFFEEF2FF)],
                        ),
                      ),
                    ),
              ),
              
              // Le Sentier d'Aventure
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    _buildDailyQuest(context, progression),
                    const SizedBox(height: 40),
                    ...unites.asMap().entries.map((entry) {
                      int uIdx = entry.key;
                      Unite unite = entry.value;
                      return _buildAdventureSection(uIdx, unite, context, progression.estModeSombre);
                    }),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAdventureSection(int uIdx, Unite unite, BuildContext context, bool isDark) {
    return Column(
      children: [
        _buildSectionTitle('Unité ${uIdx + 1}', unite.titre, isDark),
        const SizedBox(height: 24),
        _buildCodieEncouragement(context, unite.description, isDark),
        const SizedBox(height: 16),
        
        Stack(
          children: [
            // Peintre du chemin (Ligne pointillée)
            Positioned.fill(
              child: CustomPaint(
                painter: _AdventurePathPainter(
                  nbLecons: unite.lecons.length,
                  isDark: isDark,
                ),
              ),
            ),
            
            // Les Nœuds de Leçon
            Column(
              children: unite.lecons.asMap().entries.map((lEntry) {
                int lIdx = lEntry.key;
                Lecon lecon = lEntry.value;
                double offset = 0;
                if (lIdx % 4 == 1) offset = 1;
                if (lIdx % 4 == 3) offset = -1;
                
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: Duration(milliseconds: 600 + (lIdx * 100)),
                  curve: Curves.easeOutBack,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value.clamp(0.0, 1.0),
                      child: Transform.scale(
                        scale: value,
                        child: _buildAdventureNode(offset, lecon, context, isDark),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ],
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildAdventureNode(double offset, Lecon lecon, BuildContext context, bool isDark) {
    final progression = Provider.of<ProgressionFournisseur>(context, listen: false);
    bool estDebloquee = lecon.ordre <= (progression.leconActuelleIndex + 1);
    bool estSuivante = lecon.ordre == (progression.leconActuelleIndex + 1);
    
    Color color = AppColors.primary;
    IconData icon = Icons.code_rounded;
    bool isSpecial = lecon.id.contains('exam') || lecon.id.contains('final') || lecon.id.contains('class');
    
    if (isSpecial) {
      color = Colors.amber;
      icon = Icons.workspace_premium;
    } else if (lecon.ordre > 5) {
      color = Colors.deepPurple;
      icon = Icons.psychology;
    }

    if (!estDebloquee) {
      color = AppColors.textMuted;
      icon = Icons.lock_rounded;
    }

    double padding = 60.0;
    Alignment alignment = offset == 0 
        ? Alignment.center 
        : (offset > 0 ? Alignment.centerRight : Alignment.centerLeft);

    Widget node = GestureDetector(
      onTap: estDebloquee ? () => _ouvrirDetailLecon(context, lecon) : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: isSpecial ? 90 : 80,
            height: isSpecial ? 90 : 80,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [
                if (estDebloquee)
                  BoxShadow(
                    color: color.withValues(alpha: 0.5),
                    blurRadius: estSuivante ? 25 : 15,
                    spreadRadius: estSuivante ? 5 : 0,
                    offset: const Offset(0, 8),
                  ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: isSpecial ? 40 : 35),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? Colors.black26 : Colors.white70,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              lecon.titre,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 14,
                color: estDebloquee 
                    ? (isDark ? Colors.white : AppColors.textPrimary) 
                    : AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );

    if (estSuivante) {
      return Container(
        width: double.infinity,
        height: 160,
        padding: EdgeInsets.symmetric(horizontal: padding),
        child: Align(
          alignment: alignment,
          child: _FloatingNode(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 1.0, end: 1.1),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOutSine,
              builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
              onEnd: () {}, 
              child: node,
            ),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: 160,
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: Align(
        alignment: alignment,
        child: _FloatingNode(child: node),
      ),
    );
  }

  Widget _buildDailyQuest(BuildContext context, ProgressionFournisseur progression) {
    final isDark = progression.estModeSombre;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF9E6D), Color(0xFFF59E0B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: AppColors.warning.withValues(alpha: 0.35), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Row(
        children: [
          const Text('🎒', style: TextStyle(fontSize: 40)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Quête du Jour', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 16)),
                const Text('Termine 2 leçons pour ton bonus 💎', style: TextStyle(fontSize: 13, color: Colors.white70)),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    height: 12,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                      boxShadow: [
                        if (progression.xpTotal > 0)
                          BoxShadow(color: AppColors.primary.withValues(alpha: 0.2), blurRadius: 10, spreadRadius: 2),
                      ],
                    ),
                    child: LinearProgressIndicator(
                      value: (progression.xpTotal % 500) / 500,
                      backgroundColor: Colors.transparent,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                const Text('1 / 2 leçons', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodieEncouragement(BuildContext context, String message, bool isDark) {
    final mascotteKey = GlobalKey<MascotteAnimeeState>();
    final tips = [
      "Savais-tu que Python a été nommé d'après les Monty Python ?",
      "Pense à bien indenter ton code, c'est crucial en Python !",
      "Besoin d'aide ? Tapote l'éditeur de code pour des indices.",
      "N'oublie pas de faire des pauses, ton cerveau code mieux reposé !",
      "Le 'snake_case' est la norme pour nommer tes variables en Python.",
    ];

    return GestureDetector(
      onTap: () {
        mascotteKey.currentState?.sauter();
        HapticService.click();
        AudioService.jouerSonBouton();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🦉 Codie : ${(tips..shuffle()).first}'),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : AppColors.primaryLight,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isDark ? AppColors.primary.withValues(alpha: 0.3) : AppColors.primary.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            MascotteAnimee(key: mascotteKey, imagePath: 'assets/images/idee.png', height: 50, width: 50),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.primary : AppColors.primaryDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeagueBadge(ProgressionFournisseur progression) {
    String ligue = progression.ligueActuelle;
    int xp = progression.xpTotal;
    Color color;
    String icon;
    int prevThreshold = 0;
    int nextThreshold = 400;

    switch (ligue) {
      case 'Diamant': 
        color = Colors.cyanAccent; icon = '💎'; 
        prevThreshold = 3000; nextThreshold = 10000;
        break;
      case 'Or': 
        color = Colors.amber; icon = '🥇'; 
        prevThreshold = 1200; nextThreshold = 3000;
        break;
      case 'Argent': 
        color = Colors.grey[400]!; icon = '🥈'; 
        prevThreshold = 400; nextThreshold = 1200;
        break;
      default: 
        color = Colors.brown[300]!; icon = '🥉';
        prevThreshold = 0; nextThreshold = 400;
    }

    double progress = (xp >= 3000) ? 1.0 : (xp - prevThreshold) / (nextThreshold - prevThreshold);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 22,
            height: 22,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 2.5,
                  backgroundColor: color.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
                Text(icon, style: const TextStyle(fontSize: 10)),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '$xp XP',
            style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 11),
          ),
          const SizedBox(width: 2),
        ],
      ),
    );
  }

  Widget _buildStatItem(String icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String unite, String description, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 10)),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.terrain_rounded, color: Colors.white, size: 40),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(unite.toUpperCase(), style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 12)),
                Text(description, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _ouvrirDetailLecon(BuildContext context, Lecon lecon) {
    final isDark = Provider.of<ProgressionFournisseur>(context, listen: false).estModeSombre;
    AudioService.jouerSonBouton();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
              child: const Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 50),
            ),
            const SizedBox(height: 24),
            Text(
              lecon.titre,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            Text(
              'Prêt pour ton prochain défi de code ?',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 40),
            if (Provider.of<ProgressionFournisseur>(context, listen: false).vies > 0)
              BoutonDuo(
                texte: 'C\'EST PARTI !',
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EcranTutoriel(lecon: lecon)),
                  );
                },
              )
            else
              Column(
                children: [
                  const Text(
                    '💔 Oups ! Tu n\'as plus de vies.',
                    style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  BoutonDuo(
                    texte: 'RECHARGER DANS LA BOUTIQUE',
                    couleur: AppColors.info,
                    onPressed: () {
                      Navigator.pop(context);
                      // On pourrait naviguer vers l'onglet boutique ici 
                      // mais pour simplifier on informe l'utilisateur
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void _ouvrirNotifications(BuildContext context, NotificationFournisseur provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Notifications', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                    TextButton(
                      onPressed: () => provider.toutMarquerCommeLu(),
                      child: const Text('Tout lire'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: provider.notifications.isEmpty
                    ? const Center(child: Text('Aucune notification pour le moment'))
                    : ListView.builder(
                        controller: controller,
                        itemCount: provider.notifications.length,
                        itemBuilder: (context, index) {
                          final notif = provider.notifications[index];
                          return _buildNotificationTile(context, provider, notif);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationTile(BuildContext context, NotificationFournisseur provider, NotificationModele notif) {
    IconData icon;
    Color color;
    switch (notif.type) {
      case 'succes':
        icon = Icons.emoji_events_rounded;
        color = Colors.amber;
        break;
      case 'rappel':
        icon = Icons.alarm_rounded;
        color = Colors.orange;
        break;
      default:
        icon = Icons.info_rounded;
        color = Colors.blue;
    }

    return Dismissible(
      key: Key(notif.id),
      onDismissed: (_) => provider.supprimerNotification(notif.id),
      background: Container(
        color: Colors.red, 
        alignment: Alignment.centerRight, 
        padding: const EdgeInsets.only(right: 20), 
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color),
        ),
        title: Text(notif.titre, style: TextStyle(fontWeight: notif.estLu ? FontWeight.normal : FontWeight.w900)),
        subtitle: Text(notif.message, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        onTap: () {
          provider.marquerCommeLu(notif.id);
          // Optionnel : fermer le bottom sheet ? Non, laisser l'utilisateur lire
        },
        trailing: notif.estLu ? null : const CircleAvatar(radius: 4, backgroundColor: Colors.blue),
      ),
    );
  }
}

class _AdventurePathPainter extends CustomPainter {
  final int nbLecons;
  final bool isDark;
  _AdventurePathPainter({required this.nbLecons, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    if (nbLecons <= 1) return;

    final paint = Paint()
      ..color = isDark ? Colors.white10 : Colors.blue.withValues(alpha: 0.1)
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final dotPaint = Paint()
      ..color = isDark ? Colors.blue.withValues(alpha: 0.3) : Colors.blue.withValues(alpha: 0.3)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final path = Path();
    double itemHeight = 160.0;
    double centerY = 80.0; // Milieu du premier item
    double width = size.width;

    for (int i = 0; i < nbLecons - 1; i++) {
      double x1 = width / 2 + (i % 4 == 1 ? 60 : (i % 4 == 3 ? -60 : 0));
      double y1 = centerY + (i * itemHeight);
      
      int nextI = i + 1;
      double x2 = width / 2 + (nextI % 4 == 1 ? 60 : (nextI % 4 == 3 ? -60 : 0));
      double y2 = centerY + (nextI * itemHeight);

      path.moveTo(x1, y1);
      
      // Courbe de Bézier pour un effet "chemin naturel"
      double controlX = width / 2;
      double controlY = (y1 + y2) / 2;
      
      path.quadraticBezierTo(controlX, controlY, x2, y2);
    }

    // Dessiner le chemin principal
    canvas.drawPath(path, paint);

    // Dessiner des points pointillés par-dessus
    var dashPath = Path();
    double dashWidth = 8.0;
    double dashSpace = 12.0;
    double distance = 0.0;

    for (var pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        dashPath.addPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }
    canvas.drawPath(dashPath, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FloatingNode extends StatefulWidget {
  final Widget child;
  const _FloatingNode({required this.child});

  @override
  State<_FloatingNode> createState() => _FloatingNodeState();
}

class _FloatingNodeState extends State<_FloatingNode> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    _animation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: widget.child,
        );
      },
    );
  }
}
