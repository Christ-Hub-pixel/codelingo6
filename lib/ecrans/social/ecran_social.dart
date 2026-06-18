import 'package:flutter/material.dart';
import '../../services/cloud_service.dart';
import '../../composants/index.dart';

class EcranSocial extends StatefulWidget {
  const EcranSocial({super.key});

  @override
  State<EcranSocial> createState() => _EcranSocialState();
}

class _EcranSocialState extends State<EcranSocial> {
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  List<Map<String, dynamic>> _friends = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  Future<void> _loadFriends() async {
    setState(() => _isLoading = true);
    final friends = await CloudService.chargerAmis();
    if (!mounted) return;
    setState(() {
      _friends = friends;
      _isLoading = false;
    });
  }

  Future<void> _searchUsers(String query) async {
    if (query.isEmpty) return;
    setState(() => _isLoading = true);
    final results = await CloudService.chercherUtilisateurs(query);
    if (!mounted) return;
    setState(() {
      _searchResults = results;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text('Communauté', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Chercher un ami (email)...',
                  prefixIcon: const Icon(Icons.search_rounded, color: Colors.blue),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.send_rounded, color: Colors.blue),
                    onPressed: () => _searchUsers(_searchController.text),
                  ),
                ),
                onSubmitted: _searchUsers,
              ),
            ),
          ),

          if (_searchResults.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('RÉSULTATS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.grey)),
              ),
            ),
            _buildUserList(_searchResults, isSearch: true),
            const Divider(),
          ],
          
          // Section Défis Reçus
          StreamBuilder(
            stream: CloudService.ecouterDefisRecus(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                return Column(
                  children: snapshot.data!.docs.map((doc) {
                    final defi = doc.data() as Map<String, dynamic>;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.orange[200]!),
                      ),
                      child: Row(
                        children: [
                          const Text('⚔️', style: TextStyle(fontSize: 24)),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${defi['expediteur_nom']} t\'a défié !', style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text('Leçon : ${defi['lecon_titre']}', style: const TextStyle(fontSize: 12)),
                              ],
                            ),
                          ),
                          BoutonDuo(
                            texte: 'ACCEPTER',
                            couleur: Colors.orange,
                            onPressed: () {},
                            width: 100,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              }
              return const SizedBox();
            },
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('MES AMIS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.grey)),
            ),
          ),

          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _friends.isEmpty 
                  ? _buildEmptyState()
                  : _buildUserList(_friends),
          ),
        ],
      ),
    );
  }

  Widget _buildUserList(List<Map<String, dynamic>> users, {bool isSearch = false}) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: users.length,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, index) {
        final user = users[index];
        final progression = user['progression'] ?? {};
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 5)],
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue[50],
              child: Text(user['email']?[0].toUpperCase() ?? 'U'),
            ),
            title: Text(user['email'] ?? 'Anonyme', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Série: ${progression['serie_jours'] ?? 0} 🔥 • Gemmes: ${progression['gemmes'] ?? 0} 💎'),
            trailing: isSearch 
              ? IconButton(
                  icon: const Icon(Icons.person_add_alt_1_rounded, color: Colors.green),
                  onPressed: () async {
                    await CloudService.ajouterAmi(user['uid']);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ami ajouté !')));
                    _loadFriends();
                    setState(() => _searchResults = []);
                  },
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.flash_on_rounded, color: Colors.orange),
                      onPressed: () {
                        CloudService.envoyerDefi(user['uid'], 'Variables Python 🐍');
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Défi envoyé ! ⚔️')));
                      },
                      tooltip: 'Défier',
                    ),
                    const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                  ],
                ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const MascotteAnimee(imagePath: 'assets/images/idee.png', height: 120, width: 120),
          const SizedBox(height: 24),
          const Text(
            'C\'est un peu vide ici...',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Ajoute des amis pour comparer ton XP !',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          BoutonDuo(
            texte: 'INVITER DES AMIS',
            onPressed: () {},
            width: 200,
          ),
        ],
      ),
    );
  }
}
