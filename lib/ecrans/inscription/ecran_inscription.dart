import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../composants/index.dart';
import '../langue/ecran_langue.dart';
import '../connexion/ecran_connexion.dart';
import '../../services/traduction_service.dart';
import '../../utils/theme.dart';
import '../../fournisseurs/progression_fournisseur.dart';
import '../../fournisseurs/auth_fournisseur.dart';
import '../../services/securite_service.dart';

class EcranInscription extends StatefulWidget {
  const EcranInscription({super.key});

  @override
  State<EcranInscription> createState() => _EcranInscriptionState();
}

class _EcranInscriptionState extends State<EcranInscription> {
  bool _obscurePassword = true;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ProgressionFournisseur>(context).estModeSombre;
    final authFournisseur = Provider.of<AuthFournisseur>(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white, size: 28),
      ),
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const Hero(
                  tag: 'mascotte',
                  child: MascotteAnimee(
                    imagePath: 'assets/images/idee.png',
                    height: 120,
                    width: 120,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  TraductionService.t('inscription_titre'),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  "Rejoins l'aventure Codelingo !",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 32),

                // Formulaire
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildTextField(
                        Icons.person_rounded,
                        "Nom d'utilisateur",
                        _nameController,
                        isDark,
                        hint: 'ex: codie',
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        Icons.email_rounded,
                        TraductionService.t('email'),
                        _emailController,
                        isDark,
                        hint: 'ex: jean@exemple.com',
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        Icons.lock_rounded,
                        TraductionService.t('mot_de_passe'),
                        _passwordController,
                        isDark,
                        hint: 'ex: secret123',
                        obscure: _obscurePassword,
                        suffix: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      const SizedBox(height: 24),
                      authFournisseur.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : BoutonDuo(
                              texte: TraductionService.t('sinscrire').toUpperCase(),
                              onPressed: _handleInscription,
                            ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
                
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.3))),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OU S\'INSCRIRE AVEC',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.3))),
                  ],
                ),

                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(child: _buildMiniSocialButton('google', isDark)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildMiniSocialButton('github', isDark)),
                  ],
                ),

                const SizedBox(height: 32),

                // Lien vers la Connexion
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const EcranConnexion()),
                    );
                  },
                  child: RichText(
                    text: TextSpan(
                      text: "Déjà un compte ? ",
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 15),
                      children: const [
                        TextSpan(
                          text: "Se connecter",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, decoration: TextDecoration.underline),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Bouton Invité (Test)
                TextButton(
                  onPressed: () async {
                    final erreur = await authFournisseur.seConnecterAnonymement();
                    if (erreur == null) {
                      if (context.mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const EcranLangue()),
                        );
                      }
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(erreur), backgroundColor: AppColors.danger));
                      }
                    }
                  },
                  child: const Text(
                    "Continuer en tant qu'invité (Test)",
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Privacy text
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "En t'inscrivant, tu acceptes nos Conditions Générales et notre Politique de Confidentialité.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11, height: 1.5),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(IconData icon, String label, TextEditingController controller, bool isDark, {bool obscure = false, Widget? suffix, String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textMuted, letterSpacing: 1),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white : AppColors.textPrimary),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
            suffixIcon: suffix,
            hintText: hint,
            hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 14),
            filled: true,
            fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.grey[300]!, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.grey[200]!, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMiniSocialButton(String type, bool isDark) {
    final isGoogle = type == 'google';
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Image.asset(
              isGoogle ? 'assets/images/google.png' : 'assets/images/github.webp',
              height: 26,
            ),
          ),
        ),
      ),
    );
  }

  void _handleInscription() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final name = _nameController.text.trim();

    if (email.isEmpty || password.isEmpty || name.isEmpty) {
      _showError('Veuillez remplir tous les champs.');
      return;
    }

    if (!SecuriteService.estEmailValide(email)) {
      _showError('Email invalide.');
      return;
    }

    final authFournisseur = Provider.of<AuthFournisseur>(context, listen: false);
    final erreur = await authFournisseur.sinscrire(email, password, name);

    if (erreur == null) {
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const EcranLangue()));
      }
    } else {
      if (mounted) {
        _showError(erreur);
      }
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: AppColors.danger));
  }
}
