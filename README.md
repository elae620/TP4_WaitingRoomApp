# 🏥 Waiting Room App (TP4)

[![Flutter CI](https://github.com/elae620/TP4_WaitingRoomApp/actions/workflows/ci.yml/badge.svg)](https://github.com/elae620/TP4_WaitingRoomApp/actions/workflows/ci.yml)
![Flutter](https://img.shields.io/badge/Flutter-3.47+-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.13+-0175C2?logo=dart&logoColor=white)
![Supabase](https://img.shields.io/badge/Supabase-Backend-3ECF8E?logo=supabase&logoColor=white)

Application Flutter de gestion de file d'attente médicale / administrative en temps réel, connectée à **Supabase** et couverte par des **tests unitaires automatisés** avec un pipeline d'**intégration continue (CI)** GitHub Actions.

---

## 🎯 Objectifs du TP4

- **Architecture découplée & testabilité** : Injection de dépendances dans `QueueProvider` pour permettre des tests unitaires isolés sans dépendre du serveur Supabase réel.
- **Tests unitaires** : Validation du comportement métier (ajout de clients, nettoyage des espaces, filtrage des noms vides, suppression, etc.).
- **Intégration continue (CI)** : Exécution automatique de l'analyse statique (`flutter analyze`) et des tests unitaires (`flutter test`) à chaque push ou pull request sur la branche `main`.

---

## ✨ Fonctionnalités

- ➕ **Ajout de client** : Saisie et enregistrement d'un client dans la file d'attente (avec nettoyage automatique des espaces).
- 🔄 **Temps réel (Realtime)** : Synchronisation instantanée de la liste via les flux Supabase (`stream`).
- ⏭️ **Client suivant** : Retrait automatique du premier client de la file avec le bouton d'action flottant.
- 🗑️ **Suppression ciblée** : Retrait manuel d'un client spécifique via son identifiant unique.
- 🔒 **Variables d'environnement** : Protection des clés d'API Supabase via `flutter_dotenv`.

---

## 📂 Structure du Projet

```text
lib/
├── models/
│   └── client.dart           # Modèle de données Client (id, name, createdAt)
├── main.dart                 # Initialisation de Supabase, .env et interface UI
└── queue_provider.dart       # Gestionnaire d'état (ChangeNotifier) et logique métier
test/
└── queue_provider_test.dart  # Tests unitaires de QueueProvider avec constructeur testable
.github/
└── workflows/
    └── ci.yml                # Configuration du pipeline GitHub Actions CI
```

---

## 🚀 Installation et Démarrage

### 1. Prérequis
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (version `>= 3.44.0` / Dart `>= 3.13.3`)
- Un compte et un projet [Supabase](https://supabase.com)

### 2. Cloner le dépôt
```bash
git clone https://github.com/elae620/TP4_WaitingRoomApp.git
cd TP4_WaitingRoomApp
```

### 3. Installer les dépendances
```bash
flutter pub get
```

### 4. Configurer les variables d'environnement
Créez un fichier `.env` à la racine du projet avec vos identifiants Supabase :
```env
SUPABASE_URL=https://votre-projet.supabase.co
SUPABASE_ANON_KEY=votre_cle_anon_publique
```

### 5. Schéma de la table Supabase
Dans votre console Supabase (SQL Editor), créez la table `clients` :
```sql
create table clients (
  id uuid default gen_random_uuid() primary key,
  name text not null,
  created_at timestamp with time zone default now()
);

-- Activer la réplication en temps réel
alter publication supabase_realtime add table clients;
```

### 6. Lancer l'application
```bash
flutter run
```

---

## 🧪 Exécution des Tests

Les tests unitaires sont conçus pour s'exécuter sans connexion internet ni instance Supabase active grâce au constructeur `QueueProvider.forTesting` :

```bash
flutter test
```

Résultat attendu :
```text
00:00 +0: addClient inserts the client name
00:00 +1: addClient trims whitespace
00:00 +2: addClient ignores empty names
00:00 +3: All tests passed!
```

Pour vérifier la qualité et le style du code :
```bash
flutter analyze
```

---

## ⚙️ Intégration Continue (GitHub Actions)

Le workflow `.github/workflows/ci.yml` automatise les vérifications à chaque contribution :
1. Configuration de l'environnement Flutter (`subosito/flutter-action`).
2. Installation des dépendances (`flutter pub get`).
3. Analyse statique (`flutter analyze`).
4. Exécution de la suite de tests (`flutter test`).