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
        backgroundColor: isDark ? AppColors.backgroundDark : Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroBanner(),
            const SizedBox(height: 32),
            Text(
              'Modes de Pratique',
              style: TextStyle(
                fontSize: 20, 
                fontWeight: FontWeight.w900, 
                color: isDark ? Colors.white : AppColors.textPrimary,
                letterSpacing: -0.5
              ),
            ),
            const SizedBox(height: 16),
            _buildPratiqueCard(
              context,
              'Pratique Quotidienne',
              'Renforce tes acquis avec des exercices variés.',
              Icons.bolt_rounded,
              Colors.orange,
              isDark,
              () => _demarrerSessionAleatoire(context),
            ),
            const SizedBox(height: 16),
            _buildPratiqueCard(
              context,
              'Défi Chrono',
              'Combien de réponses en 60 secondes ?',
              Icons.timer_rounded,
              AppColors.danger,
              isDark,
              () {}, 
              isLocked: true,
            ),
            const SizedBox(height: 32),
            Text(
              'Révisions Ciblées',
              style: TextStyle(
                fontSize: 20, 
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
      decoration: AppDecorations.gradient(),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Entraîne ton cerveau !',
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                Text(
                  'La pratique régulière est la clé de la maîtrise du code.',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          const MascotteAnimee(imagePath: 'assets/images/idee.png', height: 80, width: 80),
        ],
      ),
    );
  }

  Widget _buildPratiqueCard(BuildContext context, String titre, String sousTitre, IconData icon, Color color, bool isDark, VoidCallback onTap, {bool isLocked = false}) {
    return GestureDetector(
      onTap: isLocked ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: isLocked 
          ? AppDecorations.card(dark: isDark).copyWith(
              border: Border.all(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
            )
          : AppDecorations.cardBordered(borderColor: color, dark: isDark),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isLocked ? (isDark ? Colors.white10 : Colors.grey[100]) : color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(isLocked ? Icons.lock_rounded : icon, color: isLocked ? AppColors.textMuted : color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titre,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: isLocked ? AppColors.textMuted : (isDark ? Colors.white : AppColors.textPrimary),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sousTitre,
                    style: TextStyle(color: AppColors.textMuted, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            if (!isLocked) const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textMuted, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicGrid(BuildContext context, bool isDark) {
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
            childAspectRatio: 1.1,
          ),
          itemCount: unites.length,
          itemBuilder: (context, index) {
            final unite = unites[index];
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: AppDecorations.card(dark: isDark),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.folder_special_rounded, color: AppColors.primary, size: 32),
                  const SizedBox(height: 12),
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
}
