// lib/services/service_lecons.dart

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

const List<Map<String, dynamic>> donneesLecons = [
  {
    'id': 'lecon_1_variables',
    'titre': 'Les Variables',
    'description': 'Apprendre à créer et utiliser des variables en Python',
    'concept': 'variables',
    'contenu': '''
# Les Variables en Python

Une variable est un conteneur qui stocke une valeur. Elle porte un nom et peut contenir des nombres, du texte, etc.

## Syntaxe:
```python
nom_variable = valeur
```

## Exemples:
```python
age = 25
nom = "Alice"
prix = 19.99
```

Les variables permettent de:
- Stocker des données
- Réutiliser des valeurs
- Rendre le code plus lisible
    ''',
    'idsExercices': ['ex_1_1', 'ex_1_2', 'ex_1_3'],
    'ordre': 0,
  },
  {
    'id': 'lecon_2_types',
    'titre': 'Types de Données',
    'description': 'Découvrir les différents types: int, str, float, bool',
    'concept': 'types',
    'contenu': '''
# Types de Données en Python

Python a plusieurs types de base:

## int (Entier)
```python
age = 25
```

## str (Chaîne de caractères)
```python
nom = "Alice"
```

## float (Nombre décimal)
```python
prix = 19.99
```

## bool (Booléen: True/False)
```python
est_actif = True
```

Vous pouvez vérifier le type avec: type(variable)
    ''',
    'idsExercices': ['ex_2_1', 'ex_2_2', 'ex_2_3'],
    'ordre': 1,
  },
  {
    'id': 'lecon_3_conditions',
    'titre': 'Les Conditions (if/else)',
    'description': 'Utiliser if, elif, else pour contrôler le flux du programme',
    'concept': 'conditions',
    'contenu': '''
# Conditions en Python

Les conditions permettent d'exécuter du code selon une situation.

## Syntaxe if:
```python
if condition:
    # Code exécuté si vrai
```

## Syntaxe if/else:
```python
if condition:
    # Code si vrai
else:
    # Code si faux
```

## Syntaxe if/elif/else:
```python
if condition1:
    # Code si condition1 est vrai
elif condition2:
    # Code si condition2 est vrai
else:
    # Code si aucune n'est vrai
```

## Opérateurs de comparaison:
- `==` (égal)
- `!=` (différent)
- `>` (plus grand)
- `<` (plus petit)
- `>=` (plus grand ou égal)
- `<=` (plus petit ou égal)
    ''',
    'idsExercices': ['ex_3_1', 'ex_3_2', 'ex_3_3'],
    'ordre': 2,
  },
];

const List<Map<String, dynamic>> donneesExercices = [
  // Leçon 1 - Variables
  {
    'id': 'ex_1_1',
    'idLecon': 'lecon_1_variables',
    'question': 'Quel est le résultat de ce code ?',
    'extrait': '''nom = "Bob"
age = 30
print(age)''',
    'options': ['Bob', '30', 'age', 'Erreur'],
    'reponseCorrecte': '30',
    'explication': 'La variable `age` contient la valeur 30. Donc print(age) affiche 30.',
    'points': 10,
  },
  {
    'id': 'ex_1_2',
    'idLecon': 'lecon_1_variables',
    'question': 'Que va afficher ce code ?',
    'extrait': '''x = 5
y = 10
z = x + y
print(z)''',
    'options': ['5', '10', '15', 'xy'],
    'reponseCorrecte': '15',
    'explication': 'x = 5, y = 10, donc z = 5 + 10 = 15. print(z) affiche 15.',
    'points': 10,
  },
  {
    'id': 'ex_1_3',
    'idLecon': 'lecon_1_variables',
    'question': 'Quel est le résultat ?',
    'extrait': '''a = 20
b = a
a = 100
print(b)''',
    'options': ['20', '100', 'a', 'Erreur'],
    'reponseCorrecte': '20',
    'explication': 'b reçoit la valeur de a (20). Puis a change à 100, mais b garde sa valeur 20.',
    'points': 10,
  },
  // Leçon 2 - Types
  {
    'id': 'ex_2_1',
    'idLecon': 'lecon_2_types',
    'question': 'Quel type est "hello" ?',
    'extrait': '''texte = "hello"
print(type(texte))''',
    'options': ['<class \'str\'>', '<class \'int\'>', '<class \'float\'>', '<class \'bool\'>'],
    'reponseCorrecte': '<class \'str\'>',
    'explication': '"hello" est une chaîne de caractères (string). type() retourne <class \'str\'>.',
    'points': 10,
  },
  {
    'id': 'ex_2_2',
    'idLecon': 'lecon_2_types',
    'question': 'Quel est le résultat ?',
    'extrait': '''x = 3.5
y = 2
z = x + y
print(z)''',
    'options': ['5', '5.5', '6', 'Erreur'],
    'reponseCorrecte': '5.5',
    'explication': 'x = 3.5 (float), y = 2 (int). 3.5 + 2 = 5.5. Le résultat est un float.',
    'points': 10,
  },
  {
    'id': 'ex_2_3',
    'idLecon': 'lecon_2_types',
    'question': 'Quel est le type de True ?',
    'extrait': '''valeur = True
print(type(valeur))''',
    'options': ['<class \'str\'>', '<class \'int\'>', '<class \'bool\'>', '<class \'float\'>'],
    'reponseCorrecte': '<class \'bool\'>',
    'explication': 'True et False sont des booléens. type(True) retourne <class \'bool\'>.',
    'points': 10,
  },
  // Leçon 3 - Conditions
  {
    'id': 'ex_3_1',
    'idLecon': 'lecon_3_conditions',
    'question': 'Quel est le résultat ?',
    'extrait': '''age = 18
if age >= 18:
    print("Adulte")
else:
    print("Mineur")''',
    'options': ['Adulte', 'Mineur', 'age >= 18', 'Erreur'],
    'reponseCorrecte': 'Adulte',
    'explication': 'age = 18. La condition (age >= 18) est vrai. Donc "Adulte" s\'affiche.',
    'points': 10,
  },
  {
    'id': 'ex_3_2',
    'idLecon': 'lecon_3_conditions',
    'question': 'Quel est le résultat ?',
    'extrait': '''score = 75
if score >= 80:
    print("A")
elif score >= 70:
    print("B")
else:
    print("C")''',
    'options': ['A', 'B', 'C', 'Erreur'],
    'reponseCorrecte': 'B',
    'explication': 'score = 75. La première condition (>= 80) est fausse. La deuxième (>= 70) est vrai. Donc "B".',
    'points': 10,
  },
  {
    'id': 'ex_3_3',
    'idLecon': 'lecon_3_conditions',
    'question': 'Quel est le résultat ?',
    'extrait': '''x = 5
y = 5
if x == y:
    print("Égal")
else:
    print("Différent")''',
    'options': ['Égal', 'Différent', 'x == y', 'Erreur'],
    'reponseCorrecte': 'Égal',
    'explication': 'x = 5 et y = 5. La condition (x == y) est vrai. Donc "Égal" s\'affiche.',
    'points': 10,
  },
];

class ServiceLecons {
  static const String cleLecons = 'codelingo_lecons';
  static const String cleExercices = 'codelingo_exercices';
  static const String cleProgression = 'codelingo_progression';

  static Future<void> initialiserLecons() async {
    final prefs = await SharedPreferences.getInstance();
    
    if (!prefs.containsKey(cleLecons)) {
      await prefs.setString(cleLecons, jsonEncode(donneesLecons));
      await prefs.setString(cleExercices, jsonEncode(donneesExercices));
    }
  }

  static Future<List<dynamic>> obtenirLecons() async {
    await initialiserLecons();
    final prefs = await SharedPreferences.getInstance();
    final donnees = prefs.getString(cleLecons);
    return jsonDecode(donnees ?? '[]');
  }

  static Future<List<dynamic>> obtenirExercices() async {
    await initialiserLecons();
    final prefs = await SharedPreferences.getInstance();
    final donnees = prefs.getString(cleExercices);
    return jsonDecode(donnees ?? '[]');
  }

  static Future<List<dynamic>> obtenirExercicesParLecon(String idLecon) async {
    final exercices = await obtenirExercices();
    return exercices.where((e) => e['idLecon'] == idLecon).toList();
  }
}
