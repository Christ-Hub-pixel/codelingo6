import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../composants/index.dart';
import '../../services/traduction_service.dart';
import '../connexion/ecran_connexion.dart';
import '../../utils/theme.dart';
import '../../fournisseurs/progression_fournisseur.dart';

class EcranLangueMaternelle extends StatelessWidget {
  const EcranLangueMaternelle({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ProgressionFournisseur>(context).estModeSombre;
    final langues = [
      {'code': 'fr', 'nom': 'Français', 'flag': '🇫🇷'},
      {'code': 'en', 'nom': 'English', 'flag': '🇺🇸'},
      {'code': 'es', 'nom': 'Español', 'flag': '🇪🇸'},
      {'code': 'de', 'nom': 'Deutsch', 'flag': '🇩🇪'},
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
                const MascotteAnimee(
                  imagePath: 'assets/images/idee.png',
                  height: 150,
                  width: 150,
                ),
                const SizedBox(height: 32),
                const Text(
                  'Quelle est ta langue ?',
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
                  'Choisis ta langue maternelle pour commencer',
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
                      childAspectRatio: 1.3,
                    ),
                    itemCount: langues.length,
                    itemBuilder: (context, index) {
                      final langue = langues[index];
                      return _buildLangueCard(context, langue, isDark);
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

  Widget _buildLangueCard(BuildContext context, Map<String, String> langue, bool isDark) {
    return GestureDetector(
      onTap: () {
        TraductionService.changerLangue(langue['code']!);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const EcranConnexion()),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(langue['flag']!, style: const TextStyle(fontSize: 40)),
            const SizedBox(height: 8),
            Text(
              langue['nom']!,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
