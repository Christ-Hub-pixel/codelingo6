import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:highlight/highlight.dart' show highlight, Node;
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import '../services/audio_service.dart';

class EditeurCode extends StatefulWidget {
  final String codeInitial;
  const EditeurCode({super.key, required this.codeInitial});

  @override
  State<EditeurCode> createState() => _EditeurCodeState();
}

class _EditeurCodeState extends State<EditeurCode> {
  late CustomCodeController _controller;
  String _output = "";
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _controller = CustomCodeController(text: widget.codeInitial);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _executerCode() async {
    if (_controller.text.trim().isEmpty) return;

    String stdinInputs = '';
    // Détecter si le code demande des entrées utilisateur
    if (_controller.text.contains('input(')) {
      final result = await showDialog<String>(
        context: context,
        builder: (context) {
          final stdinCtrl = TextEditingController();
          return AlertDialog(
            backgroundColor: const Color(0xFF23241f),
            title: const Text('Entrée requise (stdin)', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Votre code utilise la fonction input().\nSaisissez les valeurs ci-dessous (une par ligne) :', style: TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 16),
                TextField(
                  controller: stdinCtrl,
                  maxLines: 4,
                  style: const TextStyle(color: Colors.greenAccent, fontFamily: 'monospace'),
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Color(0xFF1E1E1E),
                    border: OutlineInputBorder(),
                    hintText: 'Ex: Alice\\n25',
                    hintStyle: TextStyle(color: Colors.white30),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, null),
                child: const Text('Annuler', style: TextStyle(color: Colors.redAccent)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent, foregroundColor: Colors.black),
                onPressed: () => Navigator.pop(context, stdinCtrl.text),
                child: const Text('Exécuter', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          );
        }
      );
      
      // Si l'utilisateur annule la boîte de dialogue, on arrête l'exécution
      if (result == null) return;
      stdinInputs = result;
    }

    AudioService.jouerSonExecutionCode();

    setState(() {
      _isRunning = true;
      _output = "";
    });

    try {
      final response = await http.post(
        Uri.parse('https://godbolt.org/api/compiler/python311/compile'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'source': _controller.text,
          'compiler': 'python311',
          'options': {
            'userArguments': '',
            'executeParameters': {'args': '', 'stdin': stdinInputs},
            'compilerOptions': {'executorRequest': true},
            'filters': {'execute': true}
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        String executionOutput = "";
        
        if (data['stdout'] != null) {
          for (var line in data['stdout']) {
            executionOutput += "${line['text']}\n";
          }
        }
        
        if (data['stderr'] != null) {
          for (var line in data['stderr']) {
            executionOutput += "${line['text']}\n";
          }
        }

        if (executionOutput.trim().isEmpty) {
          executionOutput = "Program completed (no output).";
        }

        setState(() {
          _output = executionOutput;
        });
      } else {
        AudioService.jouerSonErreur();
        setState(() {
          _output = "Erreur du serveur (Code ${response.statusCode})\n${response.body}";
        });
      }
    } catch (e) {
      AudioService.jouerSonErreur();
      setState(() {
        _output = "Erreur de connexion : Impossible de joindre le serveur d'exécution.\nVérifiez votre connexion internet.";
      });
    } finally {
      if (mounted) {
        setState(() {
          _isRunning = false;
        });
      }
    }
  }

  void _copyCode() {
    Clipboard.setData(ClipboardData(text: _controller.text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Code copié dans le presse-papiers !'), duration: Duration(seconds: 2)),
    );
  }

  void _clearConsole() {
    setState(() {
      _output = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFF333333),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                _buildDot(Colors.red),
                const SizedBox(width: 6),
                _buildDot(Colors.amber),
                const SizedBox(width: 6),
                _buildDot(Colors.green),
                const SizedBox(width: 12),
                const Text('main.py', style: TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'monospace')),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.copy_rounded, color: Colors.blueAccent, size: 18),
                  onPressed: _copyCode,
                  tooltip: 'Copier le code',
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                IconButton(
                  icon: Icon(_isRunning ? Icons.hourglass_empty : Icons.play_arrow_rounded, color: Colors.greenAccent),
                  onPressed: _isRunning ? null : _executerCode,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Exécuter le code',
                ),
              ],
            ),
          ),
          
          Container(
            color: const Color(0xFF23241f),
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Colonne des numéros de ligne
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  child: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _controller,
                    builder: (context, value, child) {
                      final lineCount = value.text.split('\n').length;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: List.generate(lineCount, (index) {
                          return Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.white30,
                              fontFamily: 'monospace',
                              fontSize: 14,
                              height: 1.5,
                            ),
                          );
                        }),
                      );
                    },
                  ),
                ),
                // Éditeur de texte
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: TextField(
                      controller: _controller,
                      maxLines: null,
                      style: const TextStyle(
                        color: Color(0xFFD4D4D4), 
                        fontFamily: 'monospace', 
                        fontSize: 14, 
                        height: 1.5
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      cursorColor: Colors.blueAccent,
                      keyboardType: TextInputType.multiline,
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (_output.isNotEmpty || _isRunning)
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFF000000),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    color: Colors.white.withValues(alpha: 0.1),
                    child: Row(
                      children: [
                        const Icon(Icons.terminal_rounded, color: Colors.grey, size: 14),
                        const SizedBox(width: 8),
                        const Text(
                          'TERMINAL OUTPUT', 
                          style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.delete_sweep_rounded, color: Colors.grey, size: 16),
                          onPressed: _clearConsole,
                          tooltip: 'Effacer la console',
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                        ),
                        if (_isRunning) ...[
                          const SizedBox(width: 8),
                          const SizedBox(
                            width: 10,
                            height: 10,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.greenAccent),
                          ),
                        ]
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SelectableText(
                      _isRunning ? ">_ Exécution du code en cours sur le serveur distant..." : _output,
                      style: TextStyle(
                        color: _output.contains('Error') || _output.contains('Erreur') || _output.contains('Traceback') ? Colors.redAccent : Colors.greenAccent,
                        fontFamily: 'monospace',
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDot(Color color) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class CustomCodeController extends TextEditingController {
  CustomCodeController({super.text});

  @override
  TextSpan buildTextSpan({required BuildContext context, TextStyle? style, required bool withComposing}) {
    // Utiliser Highlight pour parser le code Python
    var result = highlight.parse(text, language: 'python');
    
    // Convertir les noeuds Highlight en TextSpans
    List<TextSpan> spans = _convertNodes(result.nodes, monokaiSublimeTheme, style);
    return TextSpan(style: style, children: spans);
  }

  List<TextSpan> _convertNodes(List<Node>? nodes, Map<String, TextStyle> theme, TextStyle? defaultStyle) {
    List<TextSpan> spans = [];
    if (nodes == null) return spans;
    
    for (var node in nodes) {
      if (node.value != null) {
        // Appliquer le style du thème ou le style par défaut
        spans.add(TextSpan(text: node.value, style: theme[node.className] ?? defaultStyle));
      } else if (node.children != null) {
        // Noeud parent, on applique le style aux enfants
        spans.add(TextSpan(children: _convertNodes(node.children, theme, theme[node.className] ?? defaultStyle)));
      }
    }
    return spans;
  }
}
