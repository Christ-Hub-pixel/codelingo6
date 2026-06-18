import 'package:flutter/material.dart';
import '../../modeles/index.dart';
import '../../services/traduction_service.dart';
import '../../services/securite_service.dart';
import '../../composants/index.dart';
import '../../services/haptic_service.dart';
import '../accueil/ecran_recompense.dart';
import '../../utils/theme.dart';
import '../../services/audio_service.dart';
import '../../services/notification_service.dart';
import 'package:provider/provider.dart';
import '../../fournisseurs/progression_fournisseur.dart';

class EcranDetailLecon extends StatefulWidget {
  final Lecon lecon;

  const EcranDetailLecon({super.key, required this.lecon});

  @override
  State<EcranDetailLecon> createState() => _EcranDetailLeconState();
}

class _EcranDetailLeconState extends State<EcranDetailLecon> with WidgetsBindingObserver {
  int _indexExerciceActuel = 0;
  String? _reponseSelectionnee;
  bool _estVerifie = false;
  bool _estCorrect = false;
  final GlobalKey<ShakeWidgetState> _shakeKey = GlobalKey<ShakeWidgetState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SecuriteService.demarrerChronoExercice();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Codie : Pas de triche ! Reste concentré sur ton code.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _verifierReponse() {
    if (SecuriteService.estReponseTropRapide()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚡ Codie : Wow, trop rapide ! Prends le temps de bien lire.'),
          backgroundColor: Colors.amber,
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    final progression = Provider.of<ProgressionFournisseur>(context, listen: false);

    setState(() {
      _estVerifie = true;
      _estCorrect = _reponseSelectionnee == widget.lecon.exercices[_indexExerciceActuel].reponseCorrecte;
      
      if (!_estCorrect) {
        _shakeKey.currentState?.shake();
        HapticService.error();
        AudioService.jouerSonErreur();
        progression.perdreVie(); // L'erreur a un coût !
        NotificationService.afficherNotificationInstantanee('Courage ! 💪', 'L\'erreur est le meilleur moyen d\'apprendre, continue !');
      } else {
        HapticService.success();
        AudioService.jouerSonSucces();
        progression.ajouterXP(15); // Gain d'XP réel
        _afficherXPFrottant(); // Animation addictive
      }
    });
    
    _afficherFeedback();
  }

  void _afficherXPFrottant() {
    AudioService.jouerSonGemmes(); // Le petit "bling" de récompense
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _FloatingXPWidget(
        onComplete: () => entry.remove(),
      ),
    );
    Overlay.of(context).insert(entry);
  }

  String _obtenirMessageEncouragement(bool estCorrect) {
    final succes = [
      "Excellent travail !",
      "Tu progresses vite !",
      "C'est parfait, continue comme ça !",
      "Bravo ! Tu as l'esprit d'un développeur.",
      "Impressionnant !",
    ];
    final erreurs = [
      "Ce n'est pas grave, n'abandonne jamais !",
      "Réessaie, tu vas y arriver ! Le code c'est de la persévérance.",
      "Presque ! Analyse bien le code et n'abandonne jamais.",
      "Codie croit en toi ! N'abandonne pas, on apprend de ses erreurs.",
      "Chaque erreur te fait progresser. N'abandonne jamais !",
    ];
    
    final liste = estCorrect ? succes : erreurs;
    return (liste..shuffle()).first;
  }

  void _afficherFeedback() {
    final isDark = Provider.of<ProgressionFournisseur>(context, listen: false).estModeSombre;
    final message = _obtenirMessageEncouragement(_estCorrect);
    final mascotteKey = GlobalKey<MascotteAnimeeState>();

    if (_estCorrect) {
      Future.delayed(const Duration(milliseconds: 100), () {
        mascotteKey.currentState?.sauter();
      });
    }

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark 
              ? AppColors.cardDark 
              : (_estCorrect ? AppColors.successLight : AppColors.dangerLight),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border(top: BorderSide(color: _estCorrect ? AppColors.success : AppColors.danger, width: 2)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  MascotteAnimee(
                    key: mascotteKey,
                    imagePath: _estCorrect ? 'assets/images/joyeuse.png' : 'assets/images/idee.png',
                    height: 70,
                    width: 70,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _estCorrect ? TraductionService.t('bravo') : TraductionService.t('erreur'),
                          style: TextStyle(
                            fontSize: 22, 
                            fontWeight: FontWeight.w900, 
                            color: _estCorrect ? AppColors.success : AppColors.danger
                          ),
                        ),
                        if (!_estCorrect)
                          Text(
                            '${TraductionService.t('reponse_correcte')} : ${widget.lecon.exercices[_indexExerciceActuel].reponseCorrecte}',
                            style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        const SizedBox(height: 4),
                        Text(
                          message,
                          style: TextStyle(
                            color: _estCorrect ? AppColors.success.withValues(alpha: 0.7) : AppColors.danger.withValues(alpha: 0.7),
                            fontStyle: FontStyle.italic,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              BoutonDuo(
                texte: _estCorrect ? TraductionService.t('suivant') : 'Réessayer',
                couleur: _estCorrect ? AppColors.success : AppColors.danger,
                onPressed: () {
                  Navigator.pop(context);
                  if (_estCorrect) {
                    _passerAuSuivant();
                  } else {
                    setState(() {
                      _reponseSelectionnee = null;
                      _estVerifie = false;
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _passerAuSuivant() {
    if (_indexExerciceActuel < widget.lecon.exercices.length - 1) {
      setState(() {
        _indexExerciceActuel++;
        _reponseSelectionnee = null;
        _estVerifie = false;
      });
    } else {
      final progression = Provider.of<ProgressionFournisseur>(context, listen: false);
      progression.completerLecon(widget.lecon.ordre);
      AudioService.jouerSonVictoire();
      NotificationService.afficherNotificationInstantanee('Félicitations ! 🏆', 'Tu as brillamment terminé cette leçon, continue sur ta lancée !');
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const EcranRecompense(
            gemmesGagnees: 30,
            titre: 'Leçon Terminée ! 🎯',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final exercice = widget.lecon.exercices[_indexExerciceActuel];

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(widget.lecon.titre, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textSecondary),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6),
          child: LinearProgressIndicator(
            value: (_indexExerciceActuel + 1) / widget.lecon.exercices.length,
            backgroundColor: AppColors.primaryLight,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.success),
            minHeight: 6,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              exercice.instruction,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const MascotteAnimee(
                  imagePath: 'assets/images/idee.png',
                  height: 60,
                  width: 60,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
                    ),
                    child: Text(
                      exercice.indice,
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            // Code block
            ShakeWidget(
              key: _shakeKey,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Text(
                        exercice.codeAvant,
                        style: const TextStyle(color: Color(0xFFD4D4D4), fontSize: 18, fontFamily: 'monospace'),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        constraints: const BoxConstraints(minWidth: 60),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: AppColors.primary, width: 2.5)),
                        ),
                        child: Text(
                          _reponseSelectionnee ?? '____',
                          style: TextStyle(
                            color: _reponseSelectionnee != null ? AppColors.primary : Colors.white24,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        exercice.codeApres,
                        style: const TextStyle(color: Color(0xFFD4D4D4), fontSize: 18, fontFamily: 'monospace'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const Spacer(),
            
            // Options
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: exercice.options.map((option) {
                final estSelectionne = _reponseSelectionnee == option;
                return GestureDetector(
                  onTap: _estVerifie ? null : () => setState(() => _reponseSelectionnee = option),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      color: estSelectionne ? AppColors.primaryLight : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: estSelectionne ? AppColors.primary : Colors.grey[300]!,
                        width: 2,
                      ),
                      boxShadow: [
                        if (!estSelectionne)
                          BoxShadow(color: Colors.grey[200]!, offset: const Offset(0, 3)),
                      ],
                    ),
                    child: Text(
                      option,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: estSelectionne ? AppColors.primary : AppColors.textPrimary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 40),
            BoutonDuo(
              texte: TraductionService.t('verifier'),
              estActif: _reponseSelectionnee != null && !_estVerifie,
              onPressed: _verifierReponse,
              couleur: AppColors.success,
            ),
          ],
        ),
      ),
    );
  }
}

class _FloatingXPWidget extends StatefulWidget {
  final VoidCallback onComplete;
  const _FloatingXPWidget({required this.onComplete});

  @override
  State<_FloatingXPWidget> createState() => _FloatingXPWidgetState();
}

class _FloatingXPWidgetState extends State<_FloatingXPWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _yAnim;
  late Animation<double> _opacityAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _yAnim = Tween<double>(begin: 0, end: -100).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _opacityAnim = TweenSequence([
      TweenSequenceItem(tween: Tween<double>(begin: 0, end: 1), weight: 20),
      TweenSequenceItem(tween: Tween<double>(begin: 1, end: 1), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: 1, end: 0), weight: 30),
    ]).animate(_controller);

    _controller.forward().then((_) => widget.onComplete());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).size.height * 0.4,
      left: MediaQuery.of(context).size.width * 0.45,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Transform.translate(
          offset: Offset(0, _yAnim.value),
          child: Opacity(
            opacity: _opacityAnim.value,
            child: const Text(
              '+15 XP',
              style: TextStyle(
                color: Color(0xFFFFD700),
                fontSize: 32,
                fontWeight: FontWeight.w900,
                decoration: TextDecoration.none,
                shadows: [Shadow(color: Colors.black54, blurRadius: 8, offset: Offset(0, 2))],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
