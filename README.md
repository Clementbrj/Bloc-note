# Notes App - Flutter

Application de prise de notes simple développée avec Flutter.  
Permet de créer, afficher, éditer et supprimer des notes.  
Les notes sont stockées localement via `StorageService`.

---

## Structure

```
lib/
│
├── models/
│   └── note.dart              # Modèle de données Note
│
├── services/
│   └── storage_services.dart  # Lecture/écriture locale des notes
│
├── screens/
│   ├── home_screen.dart       # Écran principal listant toutes les notes
│   ├── edit_note.dart         # Création / modification de note
│   └── note_detail.dart       # Vue détaillée d'une note avec suppression
│
└── main.dart                  # Point d'entrée de l'application
```

---

## Fonctionnalités

- **Liste des notes** avec aperçu
- **Ajout** de nouvelles notes
- **Édition** des notes existantes
- **Suppression** après confirmation
-  Sauvegarde **locale** (pas besoin d'Internet)

---

## Lancer le projet

1. Cloner ce dépôt :
   ```bash
   git clone <url-du-projet>
   cd notes_app
   ```

2. Installer les dépendances :
   ```bash
   flutter pub get
   ```

3. Lancer l'app :
   ```bash
   flutter run
   ```

---

## Test rapide

- Crée une note depuis l'accueil.
- Appuie sur une note pour l'ouvrir.
- Utilise la croix rouge 🔴 pour la supprimer.
- Retour automatique à la liste après suppression.

---

## Auteur

Clément
