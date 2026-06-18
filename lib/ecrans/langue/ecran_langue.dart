import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../accueil/ecran_principal.dart';
import '../../utils/theme.dart';
import '../../fournisseurs/progression_fournisseur.dart';

class EcranLangue extends StatelessWidget {
  const EcranLangue({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ProgressionFournisseur>(context).estModeSombre;
    final langues = [
      {'nom': 'Python', 'icone': '🐍', 'color': AppColors.primary, 'actif': true},
      {'nom': 'JavaScript', 'icone': '📜', 'color': Colors.amber, 'actif': false},
      {'nom': 'Dart', 'icone': '🎯', 'color': Colors.cyan, 'actif': false},
      {'nom': 'HTML/CSS', 'icone': '🎨', 'color': Colors.orange, 'actif': false},
    ];

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark 
              ? [AppColors.backgroundDark, const Color(0xFF1E1B4B)]
              : [const Color(0xFF6366F1), const Color(0xFF4F46E5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 60),
                const Text(
                  'Que veux-tu apprendre ?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Python est idéal pour les débutants ! 🚀',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 48),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.9,
                    ),
                    itemCount: langues.length,
                    itemBuilder: (context, index) {
                      final langue = langues[index];
                      return _buildLangueStudyCard(context, langue, isDark);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLangueStudyCard(BuildContext context, Map<String, dynamic> langue, bool isDark) {
    final bool estActif = langue['actif'] as bool;
    final Color color = langue['color'] as Color;

    return GestureDetector(
      onTap: estActif ? () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const EcranPrincipal()),
        );
      } : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: estActif ? 1.0 : 0.6,
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: estActif ? Colors.white.withValues(alpha: 0.5) : Colors.transparent,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Text(langue['icone'] as String, style: const TextStyle(fontSize: 48)),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      langue['nom'] as String,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              if (!estActif)
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white10 : Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'BIENTÔT',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white38 : Colors.grey,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
