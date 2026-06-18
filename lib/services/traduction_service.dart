class TraductionService {
  static String langueActive = 'fr'; // Par défaut

  static final Map<String, Map<String, String>> _dictionnaires = {
    'fr': {
      'app_name': 'Codelingo',
      'splash_tagline': 'Apprenez le code comme une langue',
      'connexion_titre': 'Bon retour !',
      'connexion_sous_titre': 'Connectez-vous pour continuer',
      'inscription_titre': 'Rejoignez l\'aventure',
      'email': 'Email',
      'mot_de_passe': 'Mot de passe',
      'se_connecter': 'Se connecter',
      'sinscrire': 'S\'inscrire',
      'pas_de_compte': 'Pas encore de compte ? ',
      'continuer_google': 'Continuer avec Google',
      'continuer_github': 'Continuer avec GitHub',
      'choisir_langue_apprendre': 'Quelle langue voulez-vous apprendre ?',
      'choisir_langue_maternelle': 'Quelle est votre langue maternelle ?',
      'suivant': 'CONTINUER',
      'terminer': 'TERMINER',
      'bravo': 'Bravo !',
      'erreur': 'Oups, réessaye !',
      'verifier': 'VÉRIFIER',
      'reponse_correcte': 'La réponse était',
      'lecon_terminee': 'Leçon Terminée !',
      'continuer': 'CONTINUER',
    },
    'en': {
      'app_name': 'Codelingo',
      'splash_tagline': 'Learn code like a language',
      'connexion_titre': 'Welcome back!',
      'connexion_sous_titre': 'Login to continue your journey',
      'inscription_titre': 'Join the adventure',
      'email': 'Email',
      'mot_de_passe': 'Password',
      'se_connecter': 'Login',
      'sinscrire': 'Sign Up',
      'pas_de_compte': 'Don\'t have an account? ',
      'continuer_google': 'Continue with Google',
      'continuer_github': 'Continue with GitHub',
      'choisir_langue_apprendre': 'Which language do you want to learn?',
      'choisir_langue_maternelle': 'What is your native language?',
      'suivant': 'CONTINUE',
      'terminer': 'FINISH',
      'bravo': 'Great job!',
      'erreur': 'Oops, try again!',
      'verifier': 'CHECK',
      'reponse_correcte': 'The answer was',
      'lecon_terminee': 'Lesson Complete!',
      'continuer': 'CONTINUE',
    },
    'es': {
      'app_name': 'Codelingo',
      'splash_tagline': 'Aprende código como un idioma',
      'connexion_titre': '¡Bienvenido de nuevo!',
      'connexion_sous_titre': 'Inicia sesión para continuar',
      'inscription_titre': 'Únete a la aventura',
      'email': 'Correo electrónico',
      'mot_de_passe': 'Contraseña',
      'se_connecter': 'Iniciar sesión',
      'sinscrire': 'Registrarse',
      'pas_de_compte': '¿No tienes cuenta? ',
      'continuer_google': 'Continuar con Google',
      'continuer_github': 'Continuar con GitHub',
      'choisir_langue_apprendre': '¿Qué idioma quieres aprender?',
      'choisir_langue_maternelle': '¿Cuál es tu lengua materna?',
      'suivant': 'CONTINUAR',
      'terminer': 'FINALIZAR',
      'bravo': '¡Buen trabajo!',
      'erreur': '¡Uy, inténtalo de nuevo!',
      'verifier': 'COMPROBAR',
      'reponse_correcte': 'La respuesta era',
      'lecon_terminee': '¡Lección terminada!',
      'continuer': 'CONTINUAR',
    },
  };

  static String t(String cle) {
    return _dictionnaires[langueActive]?[cle] ?? cle;
  }

  static void changerLangue(String nouvelleLangue) {
    langueActive = nouvelleLangue;
  }
}
