import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../composants/index.dart';
import '../../fournisseurs/progression_fournisseur.dart';

class EcranPlayground extends StatelessWidget {
  const EcranPlayground({super.key});

  @override
  Widget build(BuildContext context) {
    final progression = Provider.of<ProgressionFournisseur>(context);
    final isDark = progression.estModeSombre;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: const Text('Playground Python', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: isDark ? const Color(0xFF1F1F1F) : Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Info
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.indigo.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8)),
                ],
              ),
              child: const Row(
                children: [
                  Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 32),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Espace d\'Expérimentation',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        Text(
                          'Teste ton propre code Python ici !',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            const Text(
              'TON CODE',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            
            const EditeurCode(
              codeInitial: "# Écris ton code ici\nx = 10\ny = 5\nprint('La somme est :')\nprint(x + y)",
            ),
            
            const SizedBox(height: 24),
            
            // Helpful Tips
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb_outline_rounded, color: Colors.amber[700], size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Astuces Rapides',
                        style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.black87),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildTip('Utilise print() pour afficher des résultats.', isDark),
                  _buildTip('Tu peux définir des variables comme x = 5.', isDark),
                  _buildTip('L\'exécuteur supporte les calculs simples (+, -, *, /).', isDark),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTip(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13, color: isDark ? Colors.white54 : Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}
