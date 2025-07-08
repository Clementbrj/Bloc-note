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

## Exécutable de l'application

- Rendez-vous dans le dossier build\windows\x64\runner\Release 
- Lancer l'application : NoteTaking 
- Profitez !
- L'installateur  "Inno_setup" est     disponible dans le dossier : "installers"

## Création de l'installeur Windows (Inno Setup)

L’application Flutter Windows peut être distribuée via un exécutable `.exe` généré avec **Inno Setup**, permettant une installation simple sur n’importe quel poste Windows.

### Étapes

1. **Installer Inno Setup** :  
   https://jrsoftware.org/isinfo.php

2. **Créer le script `installer.iss`** :
   Exemple minimal :

   ```pascal
   [Setup]
   AppName=NotesApp
   AppVersion=1.0
   DefaultDirName={pf}\NotesApp
   DefaultGroupName=NotesApp
   OutputBaseFilename=NotesAppSetup

   [Files]
   Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: recursesubdirs

   [Icons]
   Name: "{group}\NotesApp"; Filename: "{app}\NoteTaking.exe"

## Test rapide

- Crée une note depuis l'accueil.
- Appuie sur une note pour l'ouvrir.
- Utilise la croix rouge 🔴 pour la supprimer.
- Retour automatique à la liste après suppression.

---

## Auteur

Clément
