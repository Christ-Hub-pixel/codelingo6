import 'package:flutter/material.dart';
import '../../modeles/index.dart';
import '../../composants/index.dart';
import 'ecran_detail_lecon.dart';

class EcranTutoriel extends StatelessWidget {
  final Lecon lecon;
  const EcranTutoriel({super.key, required this.lecon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(lecon.titre, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    
                    // Zone Théorie avec Mascotte
                    BulleTuto(
                      message: lecon.theorie,
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Zone Exemples (Style W3Schools)
                    if (lecon.exemples.isNotEmpty) ...[
                      const Text(
                        'Exemples Pratiques :',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87),
                      ),
                      const SizedBox(height: 16),
                      ...lecon.exemples.map((exemple) => _buildCodeExample(exemple)),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            BoutonDuo(
              texte: 'PRATIQUER !',
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => EcranDetailLecon(lecon: lecon)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCodeExample(String code) {
    return EditeurCode(codeInitial: code);
  }
}
