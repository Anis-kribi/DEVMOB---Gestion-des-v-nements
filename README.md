# 📱 DEVMOB - Gestion des Événements

Une plateforme mobile qui relie découverte, réservation et pilotage. Conçue pour offrir un parcours événementiel complet, cette application Flutter/Firebase propose trois espaces distincts : utilisateur, organisateur et administrateur. 

DevMob résout trois frictions majeures de l'événementiel local : trouver un événement, remplir une salle, et garder la plateforme sous contrôle pour éviter que les différents parcours ne restent séparés.

---

## 🚀 Fonctionnalités Principales

Le système produit organise la plateforme autour de rôles définis plutôt que d'écrans isolés. Le routage redirige intelligemment chaque utilisateur vers son espace dédié :

### 1. Espace Participant (Shell)
Le participant passe de l'intention à la réservation sans aucune rupture dans son parcours.
* **Découverte :** Accès à un catalogue riche organisé en 12 catégories.
* **Recherche et Navigation :** Utilisation de filtres, d'une carte interactive et d'un calendrier.
* **Réservation :** Gestion des transactions par capacité avec un système de paiement simulé.
* **Feedback :** Possibilité de laisser des notes et des commentaires post-événement.

### 2. Espace Organisateur (Cockpit)
L'organisateur dispose d'un tableau de bord réunissant la demande, la capacité et les retours au même endroit.
* **Création :** Paramétrage complet de l'événement (titre, description, catégorie, dates, lieu, capacité, prix).
* **Publication :** Gestion du cycle de vie (brouillon ou publié selon le statut).
* **Suivi & Mesure :** Accès aux statistiques natives incluant le total des inscrits, le feedback moyen, les événements à venir, les réservations actives et les notifications.

### 3. Espace Administrateur (Tableau de Bord)
* **Gouvernance :** Les règles Firestore transforment les rôles en garde-fous concrets, limitant les créations, lectures et modifications.
* **Contrôle d'Accès :** Gestion stricte des permissions (ex: un utilisateur ne peut lire que les événements via une authentification, et ne peut créer ou modifier que ses propres réservations/reviews).
* **Modération :** Rôles spécifiques et contrôle total sur différents types de rassemblements (Tech meetup, Concert live, Sport day, etc.).

---

## 🛠️ Architecture et Stack Technique

Le flux de données en temps réel repose sur une chaîne simple et efficace : **Vues ➔ Providers ➔ Services ➔ Firestore**.

* **Frontend :** Flutter avec une localisation complète en français (calendrier, dates et libellés).
* **Gestion d'état :** Flux de données en direct via des streams Provider.
* **Backend as a Service (BaaS) :** Firebase (Authentification et Firestore).

---

## 🎨 Expérience Utilisateur et Design System

L'application intègre un design system complet pour une compréhension rapide et intuitive de l'interface. Chaque animation est pensée pour clarifier un changement d'état.

* **Tokens Visuels :** Utilisation de couleurs de marque (Indigo, Cyan, Pink, Emerald, Amber).
* **Composants UI :** Thème adaptatif (clair/sombre via `AppTheme`), glass cards, skeletons, badges et boutons premium.
* **Animations (`flutter_animate`) :** Micro-animations, Hero routes, effets de fade, slide et scale.
* **Lecture Mobile Optimisée :** Implémentation de SliverAppBar, de cartes compactes et d'une barre de réservation en bas de l'écran (bottom reserve bar).

---

## 🗺️ Roadmap et Prochaines Étapes

Les fonctionnalités actuelles posent les bases d'une version de démonstration claire. La prochaine version proposée inclura des évolutions plus transactionnelles :

* **Paiement réel :** Remplacement de la simulation par une véritable passerelle bancaire.
* **Médias & Tickets :** Stockage des images et génération/scan de QR codes pour le check-in.
* **Moteur de recommandation :** Suggestions personnalisées selon les catégories et l'historique des utilisateurs.
* **Back-office Web :** Développement d'une console d'administration étendue pour l'exploitation.

---

👨‍💻 **Développé par Med Khalil Kribi**
