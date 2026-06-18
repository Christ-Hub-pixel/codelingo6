// lib/ecrans/accueil/ecran_accueil.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../composants/index.dart';
import '../../fournisseurs/progression_fournisseur.dart';
import '../lecon/ecran_detail_lecon.dart';
import '../classement/ecran_classement.dart';
import '../../modeles/index.dart';
import '../profil/ecran_profil.dart';

class EcranAccueil extends StatefulWidget {
  const EcranAccueil({super.key});

  @override
  State<EcranAccueil> createState() => _EcranAccueilState();
}

class _EcranAccueilState extends State<EcranAccueil> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> niveaux = [
    {
      'id': 'lecon_1',
      'titre': 'Les Variables',
      'icone': Icons.star_rounded,
      'couleur': Colors.green,
      'couleurOmbre': Colors.green[700],
      'estDebloque': true,
      'estTermine': true,
    },
    {
      'id': 'lecon_2',
      'titre': 'Types de Données',
      'icone': Icons.code_rounded,
      'couleur': Colors.blue,
      'couleurOmbre': Colors.blue[700],
      'estDebloque': true,
      'estTermine': false,
    },
    {
      'id': 'lecon_3',
      'titre': 'Conditions',
      'icone': Icons.alt_route_rounded,
      'couleur': Colors.purple,
      'couleurOmbre': Colors.purple[700],
      'estDebloque': false,
      'estTermine': false,
    },
    {
      'id': 'lecon_4',
      'titre': 'Boucles',
      'icone': Icons.loop_rounded,
      'couleur': Colors.orange,
      'couleurOmbre': Colors.orange[700],
      'estDebloque': false,
      'estTermine': false,
    },
    {
      'id': 'lecon_5',
      'titre': 'Fonctions',
      'icone': Icons.functions_rounded,
      'couleur': Colors.pink,
      'couleurOmbre': Colors.pink[700],
      'estDebloque': false,
      'estTermine': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final progression = Provider.of<ProgressionFournisseur>(context);

    return Scaffold(
      appBar: _selectedIndex == 0 ? BarreStatutDuo(
        vies: progression.vies,
        serieJours: progression.serieJours,
        gemmes: progression.gemmes,
      ) : null,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildParcours(),
          const EcranClassement(),
          const EcranProfil(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Apprendre',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shield_rounded),
            label: 'Classement',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.face_rounded),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  Widget _buildParcours() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Stack(
          children: [
            // Lignes du parcours
            Positioned.fill(
              child: CustomPaint(
                painter: _LignesCheminPainter(niveaux.length),
              ),
            ),
            // Nœuds du parcours
            Column(
              children: List.generate(niveaux.length, (index) {
                final niveau = niveaux[index];
                double offset = index % 2 == 0 ? 0 : (index % 4 == 1 ? 60 : -60);

                return Container(
                  height: 140,
                  alignment: Alignment.center,
                  child: Transform.translate(
                    offset: Offset(offset, 0),
                    child: GestureDetector(
                      onTap: niveau['estDebloque'] ? () {
                        // On transforme la Map en un vrai objet Lecon
                        final lecon = Lecon(
                          id: niveau['id'],
                          titre: niveau['titre'],
                          theorie: 'Bienvenue dans ce niveau ! Apprends à maîtriser les concepts de ${niveau['titre']} pas à pas.',
                          exemples: [],
                          ordre: 1,
                          exercices: [
                            Exercice(
                              id: 'ex_${niveau['id']}',
                              instruction: 'Complétez ce code',
                              codeAvant: 'print(',
                              codeApres: ')',
                              options: ['"Hello"', 'Hello', 'print'],
                              reponseCorrecte: '"Hello"',
                              explication: 'Il faut des guillemets pour du texte.',
                              indice: 'N\'oublie pas les guillemets !',
                            ),
                          ],
                        );

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EcranDetailLecon(lecon: lecon),
                          ),
                        );
                      } : null,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: niveau['estDebloque'] ? niveau['couleur'] : Colors.grey[300],
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: niveau['estDebloque'] ? niveau['couleurOmbre'] : Colors.grey[400]!,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Icon(
                          niveau['estDebloque'] ? niveau['icone'] : Icons.lock_rounded,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _LignesCheminPainter extends CustomPainter {
  final int nbNiveaux;
  _LignesCheminPainter(this.nbNiveaux);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    
    // Le premier cercle est à y = 40 (Padding) + 40 (Moitié du Container 80)
    // Mais le Container est centré dans un parent de height 140.
    // Donc le centre Y du premier cercle est 140 / 2 = 70.
    double centerY = 70;

    for (int i = 0; i < nbNiveaux - 1; i++) {
      double x1 = size.width / 2 + (i % 2 == 0 ? 0 : (i % 4 == 1 ? 60 : -60));
      double y1 = centerY + (i * 140);
      
      int nextI = i + 1;
      double x2 = size.width / 2 + (nextI % 2 == 0 ? 0 : (nextI % 4 == 1 ? 60 : -60));
      double y2 = centerY + (nextI * 140);

      path.moveTo(x1, y1);
      // On courbe vers le centre X pour un look plus "chemin"
      path.quadraticBezierTo(
        size.width / 2, // point de contrôle X (centre)
        (y1 + y2) / 2, // point de contrôle Y
        x2, y2
      );
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
