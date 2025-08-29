# trhacknon-video-post-traitement

MixIntro est un script Bash interactif permettant de générer automatiquement une intro animée "TRHACKNON TV" et de la concaténer à un film. Il supporte la conversion MKV → MP4 et propose un mode 3D actif compatible avec les TV 3D frame-sequential.

Arborescence recommandée :

```markdown
.
├── intros/           # Dossier contenant les fichiers intros (.mp4)
├── movies/           # Dossier contenant les films (.mp4 ou .mkv)
├── output/           # Dossier où seront générés les films avec intro
├── temp/             # Dossier temporaire pour fichiers intermédiaires
└── mixintro.sh       # Script principal
```

---

Prérequis :

- ffmpeg
- ffprobe
- Bash 4+
- Fonts Roboto-Bold installée sur le système (ou modifier le chemin dans le script)

---

Utilisation :

```bash
mkdir -p intros movies output temp
```

1. Placer vos intros dans le dossier `intros/`  
2. Placer vos films dans le dossier `movies/`  
3. Lancer le script :

```bash
bash mixintro.sh
```

Le script vous demandera :

- Choix du fichier intro (interactif)
- Choix du film (interactif)
- Conversion automatique si le film est en MKV
- Choix du mode : 2D ou 3D actif (pour TV 3D)

Le film final sera généré dans le dossier `output/` avec le suffixe `-with-intro.mp4`.

---

Fonctionnalités :

- Détection automatique des paramètres vidéo et audio du film
- Génération d’intro animée en 2D ou 3D
- Jingle audio simple synchronisé avec l’animation
- Concaténation intro + film avec adaptation de FPS, résolution et canaux audio
- Conversion MKV → MP4 si nécessaire
- Mode 3D actif compatible avec les TV 3D utilisant frame-sequential
- Nettoyage automatique des fichiers temporaires

---

Exemple d’utilisation dans un terminal :

```bash
bash mixintro.sh
```

Choisir l’intro :

```bash
1) intros/intro_trhacknon.mp4
2) intros/intro_demo.mp4
```

# Entrez le numéro correspondant

Choisir le film :

```bash
1) movies/Les.Condes.2025.FRENCH.720p.WEB-DL.H264-Slay3R.mkv
2) movies/AutreFilm.mp4
```

# Entrez le numéro correspondant

Choisir le mode :

```bash
1) 2D
2) 3D
```

# Entrez le numéro correspondant

✅ Film final généré : 
```bash
output/Les.Condes.2025.FRENCH.720p.WEB-DL.H264-Slay3R-with-intro.mp4
```
