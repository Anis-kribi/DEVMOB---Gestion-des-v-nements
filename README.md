# 📱 DEVMOB — Gestion des Événements

> Une application mobile Flutter/Firebase conçue pour réunir **découverte, réservation et gestion d'événements** au sein d'une même plateforme.

**DEVMOB** propose une expérience événementielle complète autour de trois rôles : **participant, organisateur et administrateur**.

L'objectif est de résoudre trois problématiques principales de l'événementiel local :

* 🔎 **Permettre aux participants de trouver facilement des événements**
* 🎟️ **Aider les organisateurs à remplir et gérer leurs événements**
* 🛡️ **Donner aux administrateurs les outils nécessaires pour superviser la plateforme**

---

## ✨ Fonctionnalités

### 👤 Espace Participant

Un parcours conçu pour passer de la découverte à la réservation de manière fluide.

* 📚 Catalogue d'événements organisé en **12 catégories**
* 🔎 Recherche et filtres
* 🗺️ Carte interactive
* 📅 Calendrier des événements
* 🎟️ Réservation selon la capacité disponible
* 💳 Système de paiement simulé
* ⭐ Notation et commentaires après participation
* 🔔 Notifications

---

### 🎤 Espace Organisateur

Un espace de pilotage permettant de gérer les événements et de suivre leur activité.

#### Création et publication

* Création complète d'un événement
* Titre et description
* Catégorie
* Date et horaires
* Lieu
* Capacité
* Prix
* Gestion du statut : **brouillon / publié**

#### Suivi et statistiques

* 👥 Nombre total d'inscrits
* ⭐ Moyenne des retours
* 📅 Événements à venir
* 🎟️ Réservations actives
* 🔔 Notifications
* 📊 Statistiques liées aux événements

---

### 🛡️ Espace Administrateur

Le rôle administrateur assure la supervision et la gouvernance de la plateforme.

#### Contrôle des accès

Les règles **Firestore Security Rules** permettent d'appliquer les permissions directement au niveau des données.

Exemples :

* 🔐 Les utilisateurs doivent être authentifiés pour accéder aux données protégées
* 👤 Un utilisateur peut gérer uniquement ses propres réservations et avis
* 📝 Les opérations de création et de modification sont limitées selon le rôle
* 🛡️ Les permissions sont adaptées aux différents espaces de l'application

#### Modération

L'administrateur peut superviser les différents types d'événements disponibles sur la plateforme, notamment :

* 💻 Tech Meetup
* 🎵 Concert Live
* 🏃 Sport Day
* 🎭 Et d'autres catégories d'événements

---

# 🏗️ Architecture

DEVMOB suit une architecture simple permettant de séparer clairement l'interface, la logique métier et l'accès aux données.

```text
┌──────────────┐
│     Views    │
└──────┬───────┘
       ↓
┌──────────────┐
│   Providers  │
└──────┬───────┘
       ↓
┌──────────────┐
│   Services   │
└──────┬───────┘
       ↓
┌──────────────┐
│   Firestore  │
└──────────────┘
```

Cette organisation permet notamment de centraliser la gestion des données et de maintenir une séparation claire entre l'interface utilisateur et la logique applicative.

---

# 🛠️ Stack Technique

### Frontend

* **Flutter**
* **Dart**

### Backend / Services

* **Firebase**
* **Firebase Authentication**
* **Cloud Firestore**

### Gestion d'état

* **Provider**
* Flux de données en temps réel avec des **Streams**

### UI & Animations

* `flutter_animate`
* `AppTheme`
* Support **Light / Dark Mode**
* Glass cards
* Skeleton loaders
* Badges
* Boutons personnalisés
* `SliverAppBar`
* Hero animations
* Transitions `fade`, `slide` et `scale`

### Localisation

* Interface en **français**
* Formats localisés pour les dates, calendriers et libellés

---

# 🎨 Design & Expérience Utilisateur

DEVMOB utilise un **Design System cohérent** afin de rendre les différentes interfaces rapides à comprendre et agréables à utiliser.

### 🎨 Identité visuelle

Le système de design utilise notamment des couleurs de marque telles que :

**Indigo · Cyan · Pink · Emerald · Amber**

### 🧩 Composants

* Cartes vitrées (*Glass Cards*)
* Skeletons
* Badges
* Boutons premium
* Bottom Reserve Bar
* SliverAppBar

### ✨ Animations

Les animations sont utilisées pour accompagner les changements d'état et améliorer la compréhension de l'interface :

* Fade
* Slide
* Scale
* Hero transitions
* Micro-interactions

L'interface est également pensée pour une **utilisation mobile**, avec une attention particulière portée à la lisibilité, aux interactions tactiles et à la navigation.

---

# 📸 Aperçu

> Ajoutez ici quelques captures d'écran de l'application afin de présenter rapidement les principales interfaces.
### Connexion
<img width="622" height="933" alt="image" src="https://github.com/user-attachments/assets/9168842d-a341-4e7b-a6c8-78bdba892bf6" />
<img width="618" height="925" alt="image" src="https://github.com/user-attachments/assets/a8fa98f2-6e49-46d5-ada9-1a577c9b62ec" />



### Participant
<img width="622" height="953" alt="image" src="https://github.com/user-attachments/assets/3f40c3a3-212c-416f-b90b-80edbb85cfbc" />
<img width="622" height="940" alt="image" src="https://github.com/user-attachments/assets/0ff13398-c78d-41bf-af41-7830435e1aaf" />
<img width="620" height="937" alt="image" src="https://github.com/user-attachments/assets/8788f35f-e1a0-403e-af6f-af2af7be0bee" />
<img width="620" height="943" alt="image" src="https://github.com/user-attachments/assets/cd6dd60e-9295-4aff-9393-8046dc5963ae" />
<img width="622" height="942" alt="image" src="https://github.com/user-attachments/assets/f1768321-a14e-4f67-8b43-5a8be2e2c6ae" />
<img width="622" height="942" alt="image" src="https://github.com/user-attachments/assets/dcb46c4e-2e9c-4dd7-8db4-29d60a22d69d" />
<img width="617" height="946" alt="image" src="https://github.com/user-attachments/assets/7c54dc4d-09bd-4df0-95e4-124ad679ff3e" />
<img width="628" height="943" alt="image" src="https://github.com/user-attachments/assets/292c95f5-67fe-43f3-a5ba-62c5b82efc48" />



### Organisateur

<img width="623" height="937" alt="image" src="https://github.com/user-attachments/assets/fc968896-d98f-453c-8c47-e1c282cc2ef0" />
<img width="627" height="943" alt="image" src="https://github.com/user-attachments/assets/68c8bed2-14c2-470f-acdc-d6e7dca57a15" />
<img width="622" height="942" alt="image" src="https://github.com/user-attachments/assets/faa189fe-a1fd-4876-b3f9-909ef2df2e4b" />
<img width="622" height="941" alt="image" src="https://github.com/user-attachments/assets/1c180e7e-1d04-4f24-bfbc-f52dcdf11cdd" />
<img width="627" height="938" alt="image" src="https://github.com/user-attachments/assets/97de58d8-d2da-4f45-9508-a1573e4cf28b" />
<img width="625" height="942" alt="image" src="https://github.com/user-attachments/assets/b811c4ee-8cfd-4bd2-8683-d31f239fe94d" />
<img width="618" height="943" alt="image" src="https://github.com/user-attachments/assets/204a6949-5b16-4f79-8e59-001fb35df79b" />


### Administrateur

<img width="607" height="940" alt="image" src="https://github.com/user-attachments/assets/7c514eea-e173-4c02-87b1-b4cb55d6219e" />
<img width="627" height="931" alt="image" src="https://github.com/user-attachments/assets/901919fe-62e8-484e-b06c-c933cd0267be" />
<img width="623" height="941" alt="image" src="https://github.com/user-attachments/assets/5495adc6-fe19-4c02-bfd7-9ea5fd9b9ae9" />
<img width="618" height="930" alt="image" src="https://github.com/user-attachments/assets/70c0cd80-4e1c-4708-af94-5afd1a1ad06b" />


---

# 🚀 Installation

### Prérequis

Avant de commencer, assurez-vous d'avoir installé :

* [Flutter](https://flutter.dev/)
* Dart
* Un environnement de développement compatible avec Flutter
* Un projet Firebase configuré

### Installation du projet

```bash
git clone https://github.com/Anis-kribi/DEVMOB.git
cd DEVMOB
flutter pub get
```

Configurez ensuite votre projet Firebase selon votre environnement, puis lancez l'application :

```bash
flutter run
```

> ⚠️ La configuration Firebase nécessaire au projet n'est pas incluse dans le dépôt lorsqu'elle contient des informations spécifiques à l'environnement.

---

# 🗺️ Roadmap

Les fonctionnalités actuelles constituent une base solide pour une plateforme événementielle complète.

Les prochaines évolutions envisagées sont :

* 💳 **Paiement réel** — intégration d'une véritable solution de paiement
* 🎟️ **Tickets numériques** — génération de QR codes
* 📷 **Check-in** — scan des QR codes à l'entrée des événements
* 🖼️ **Gestion des médias** — stockage et gestion des images
* 🤖 **Recommandations personnalisées** — suggestions basées sur les catégories et l'historique des utilisateurs
* 🖥️ **Back-office Web** — console d'administration plus complète pour l'exploitation de la plateforme

---

# 🎯 Objectif du projet

DEVMOB a été conçu pour démontrer la mise en œuvre d'une **application mobile complète**, depuis l'expérience utilisateur jusqu'à la gestion des données et des permissions côté backend.

Le projet met particulièrement l'accent sur :

**UX/UI · Architecture · Gestion d'état · Firebase · Sécurité des données · Gestion des rôles · Temps réel**

---

# 👨‍💻 Auteur

**Med Khalil Kribi**
GitHub : [@Anis-kribi](https://github.com/Anis-kribi)

> *Built with Flutter & Firebase.*
