import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../composants/index.dart';
import '../../services/contenu_service.dart';
import '../../modeles/index.dart';
import '../lecon/ecran_detail_lecon.dart';
import '../../fournisseurs/progression_fournisseur.dart';
import '../../utils/theme.dart';

class EcranPratique extends StatelessWidget {
  const EcranPratique({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ProgressionFournisseur>(context).estModeSombre;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        title: const Text('Centre de Pratique', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroBanner(),
            const SizedBox(height: 36),
            Text(
              'Modes de Pratique',
              style: TextStyle(
                fontSize: 22, 
                fontWeight: FontWeight.w900, 
                color: isDark ? Colors.white : AppColors.textPrimary,
                letterSpacing: -0.5
              ),
            ),
            const SizedBox(height: 16),
            _buildPratiqueCard(
              context,
              'Pratique Quotidienne',
              'Renforce tes acquis avec des exercices.',
              Icons.bolt_rounded,
              const Color(0xFFF59E0B),
              isDark,
              () => _demarrerSessionAleatoire(context),
            ),
            const SizedBox(height: 16),
            _buildPratiqueCard(
              context,
              'Défi Chrono',
              'Combien de réponses en 60s ?',
              Icons.timer_rounded,
              const Color(0xFFEF4444),
              isDark,
              () => _demarrerDefiChrono(context), 
              isLocked: false,
            ),
            const SizedBox(height: 36),
            Text(
              'Révisions Ciblées',
              style: TextStyle(
                fontSize: 22, 
                fontWeight: FontWeight.w900, 
                color: isDark ? Colors.white : AppColors.textPrimary,
                letterSpacing: -0.5
              ),
            ),
            const SizedBox(height: 16),
            _buildTopicGrid(context, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Entraîne ton cerveau !',
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, height: 1.2),
                ),
                const SizedBox(height: 8),
                Text(
                  'La pratique régulière est la clé de la maîtrise du code.',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14, fontWeight: FontWeight.w500, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          const MascotteAnimee(imagePath: 'assets/images/idee.png', height: 90, width: 90),
        ],
      ),
    );
  }

  Widget _buildPratiqueCard(BuildContext context, String titre, String sousTitre, IconData icon, Color color, bool isDark, VoidCallback onTap, {bool isLocked = false}) {
    return GestureDetector(
      onTap: isLocked ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isLocked ? (isDark ? AppColors.cardDark : Colors.grey[50]) : (isDark ? AppColors.cardDark : Colors.white),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isLocked ? (isDark ? Colors.white10 : Colors.grey[200]!) : color.withValues(alpha: 0.3),
            width: 2,
          ),
          boxShadow: isLocked ? [] : [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withValues(alpha: isLocked ? 0.05 : 0.2),
                    color.withValues(alpha: isLocked ? 0.02 : 0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(isLocked ? Icons.lock_rounded : icon, color: isLocked ? AppColors.textMuted : color, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titre,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 17,
                      color: isLocked ? AppColors.textMuted : (isDark ? Colors.white : AppColors.textPrimary),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    sousTitre,
                    style: TextStyle(color: AppColors.textMuted, fontSize: 13, fontWeight: FontWeight.w600, height: 1.3),
                  ),
                ],
              ),
            ),
            if (!isLocked) Icon(Icons.arrow_forward_ios_rounded, color: color, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicGrid(BuildContext context, bool isDark) {
    final List<Color> cardColors = [
      const Color(0xFF10B981), // Emerald
      const Color(0xFF8B5CF6), // Violet
      const Color(0xFFEC4899), // Pink
      const Color(0xFF06B6D4), // Cyan
    ];

    return FutureBuilder<List<Unite>>(
      future: ContenuService.chargerContenu(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final unites = snapshot.data!;
        
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.0,
          ),
          itemCount: unites.length,
          itemBuilder: (context, index) {
            final unite = unites[index];
            final color = cardColors[index % cardColors.length];
            return GestureDetector(
              onTap: () => _demarrerRevisionUnite(context, unite),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
                  boxShadow: [
                    BoxShadow(color: color.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.menu_book_rounded, color: color, size: 28),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      unite.titre.replaceAll('Unité ${index + 1} : ', ''),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w800, 
                        fontSize: 14,
                        color: isDark ? Colors.white : AppColors.textPrimary
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _demarrerSessionAleatoire(BuildContext context) async {
    final unites = await ContenuService.chargerContenu();
    if (unites.isEmpty) return;

    List<Exercice> allExercices = [];
    for (var u in unites) {
      for (var l in u.lecons) {
        allExercices.addAll(l.exercices);
      }
    }
    
    if (allExercices.isEmpty) return;
    
    allExercices.shuffle();
    final sessionExercices = allExercices.take(5).toList();
    
    final leconPratique = Lecon(
      id: 'pratique_aleatoire',
      titre: 'Session de Pratique',
      theorie: 'Cette session regroupe des exercices aléatoires pour tester tes connaissances générales.',
      exemples: [],
      exercices: sessionExercices,
      ordre: 0,
    );

    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => EcranDetailLecon(lecon: leconPratique)),
      );
    }
  }

  void _demarrerDefiChrono(BuildContext context) async {
    final unites = await ContenuService.chargerContenu();
    if (unites.isEmpty) return;

    List<Exercice> allExercices = [];
    for (var u in unites) {
      for (var l in u.lecons) {
        allExercices.addAll(l.exercices);
      }
    }
    
    if (allExercices.isEmpty) return;
    
    allExercices.shuffle();
    // Plus d'exercices pour le chrono
    final sessionExercices = allExercices.take(10).toList();
    
    final leconPratique = Lecon(
      id: 'pratique_chrono',
      titre: 'Défi Chrono',
      theorie: 'Attention, le temps est limité ! Réponds le plus vite possible.',
      exemples: [],
      exercices: sessionExercices,
      ordre: 0,
    );

    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => EcranDetailLecon(lecon: leconPratique)),
      );
    }
  }

  void _demarrerRevisionUnite(BuildContext context, Unite unite) {
    List<Exercice> allExercices = [];
    for (var l in unite.lecons) {
      allExercices.addAll(l.exercices);
    }
    
    if (allExercices.isEmpty) return;
    
    allExercices.shuffle();
    final sessionExercices = allExercices.take(6).toList();
    
    final leconPratique = Lecon(
      id: 'pratique_unite_${unite.id}',
      titre: 'Révision : ${unite.titre}',
      theorie: 'Cette session cible uniquement ce que tu as appris dans cette unité.',
      exemples: [],
      exercices: sessionExercices,
      ordre: 0,
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EcranDetailLecon(lecon: leconPratique)),
    );
  }
}
