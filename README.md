# J.A.M.Z.I. AI STACK - Framework de Déploiement Modulaire

![J.A.M.Z.I. Logo Placeholder](https://via.placeholder.com/150x50?text=J.A.M.Z.I.)

## Table des Matières

1.  [Introduction](#1-introduction)
2.  [Fonctionnalités Clés](#2-fonctionnalités-clés)
3.  [Prérequis](#3-prérequis)
4.  [Installation et Démarrage](#4-installation-et-démarrage)
    *   [Menu Principal](#menu-principal)
    *   [Packs Pré-configurés](#packs-pré-configurés)
    *   [Installation Personnalisée](#installation-personnalisée)
    *   [Mise à Jour des Assets](#mise-à-jour-des-assets)
    *   [Gérer l'Espace Disque Docker](#gérer-lespace-disque-docker)
    *   [Installer WSL2 + NVIDIA CUDA Toolkit](#installer-wsl2--nvidia-cuda-toolkit)
    *   [Arrêter et Nettoyer l'Environnement](#arrêter-et-nettoyer-lenvironnement)
5.  [Accès aux Services](#5-accès-aux-services)
6.  [Architecture du Projet](#6-architecture-du-projet)
7.  [Structure des Dossiers](#7-structure-des-dossiers)
8.  [Dépannage](#8-dépannage)
9.  [Licence](#9-licence)

---

## 1. Introduction

Bienvenue dans le framework J.A.M.Z.I. AI Stack ! Ce projet est une solution complète et modulaire pour déployer et gérer une suite d'outils d'intelligence artificielle locaux, axée sur la génération de contenu (texte, image, vidéo) et l'automatisation. Que vous soyez un développeur, un créateur de contenu ou un passionné d'IA, J.A.M.Z.I. vous permet de construire votre propre "usine" d'IA sur mesure.

Ce framework est conçu pour être robuste, flexible et facile à utiliser, vous permettant de choisir précisément les composants que vous souhaitez installer et de les maintenir à jour.

## 2. Fonctionnalités Clés

*   **Déploiement Modulaire :** Choisissez parmi des packs pré-configurés ou personnalisez votre installation service par service, modèle par modèle.
*   **Gestion Complète des Assets :** Téléchargement et synchronisation automatiques des modèles d'IA (Checkpoints, LoRA, VAE, ControlNet, Upscale, GFPGAN, Wav2Lip), des plugins ComfyUI et des workflows (ComfyUI, n8n).
*   **Environnement Dockerisé :** Tous les services s'exécutent dans des conteneurs Docker isolés, garantissant portabilité et propreté de votre système.
*   **Optimisation des Performances :** Dockerfiles optimisés pour des builds rapides et des images légères, avec gestion des ressources GPU.
*   **Robustesse :** Gestion des erreurs, journalisation détaillée et vérifications post-déploiement pour une stabilité maximale.
*   **Gestion de l'Espace Disque :** Outils intégrés pour nettoyer les images et le système Docker, évitant l'encombrement.
*   **Installation de WSL2 + NVIDIA CUDA Toolkit :** Guide interactif pour configurer votre environnement Windows pour l'IA.
*   **Automatisation :** Intégration de n8n pour orchestrer des workflows complexes entre les différents services IA.
*   **Contenu Spécialisé :** Support pour l'intégration de modèles et workflows NSFW pour la génération de contenu spécifique.

## 3. Prérequis

Avant de commencer, assurez-vous que les éléments suivants sont installés sur votre système :

*   **Docker Desktop :** Indispensable pour faire fonctionner les conteneurs. Téléchargez-le ici : [Docker Desktop Installer](https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe?utm_source=docker&utm_medium=webreferral&utm_campaign=docs-driven-download-win-amd64). Assurez-vous que Docker est configuré pour utiliser votre GPU NVIDIA si vous en avez un (via Docker Desktop settings -> Resources -> GPU).
*   **Git :** Nécessaire pour cloner les dépôts des plugins.
*   **aria2c :** Un outil de téléchargement puissant utilisé pour les modèles. (Généralement inclus dans les distributions Linux, peut nécessiter une installation séparée sur Windows/macOS).
*   **Un fichier `.env` :** Créez un fichier `.env` à la racine du projet avec les variables d'environnement nécessaires (ex: `COMFYUI_PORT=8188`, `N8N_PORT=5678`, `OPEN_WEBUI_PORT=8080`, `POSTGRES_USER=user`, `POSTGRES_PASSWORD=password`, `POSTGRES_DB=n8n`, `PIXABAY_API_KEY=your_key`).

## 4. Installation et Démarrage

Pour lancer le framework J.A.M.Z.I., ouvrez un terminal dans le répertoire racine du projet et exécutez le script `deploy.sh` :

**Note pour les utilisateurs Windows :** Ce script est un script Bash. Il doit être exécuté dans un environnement compatible Bash, tel que **Git Bash** (recommandé), le **Sous-système Windows pour Linux (WSL)**, ou en appelant `bash.exe` directement si Bash est dans votre PATH.

```bash
bash deploy.sh
```

**Exemple avec Git Bash (recommandé sur Windows) :**
1. Ouvrez l'application "Git Bash".
2. Naviguez jusqu'au répertoire du projet (par exemple, `cd /e/my_ia_stack`).
3. Exécutez le script : `bash deploy.sh` ou `./deploy.sh`.


Le script vous présentera un menu interactif :

### Menu Principal

```
J.A.M.Z.I. AI STACK - Framework de Déploiement v50.0
---------------------------------------------------------

  --- Packs Pré-configurés ---
  1) IA Conversatonnelle (Ollama + WebUI)
  2) Usine d'Automatisation (n8n + BDD)
  3) Studio Créatif de Base (Images SFW)
  4) Studio Vidéo Avancé (SFW)
  5) Atelier d'Images Photoréalistes (NSFW)
  6) Studio Vidéo Complet (NSFW)
  7) Déploiement Total

  --- Options Avancées ---
  8) Installation Personnalisée
  9) Mettre à jour les assets
  10) Gérer l'espace disque Docker
  11) Installer WSL2 + NVIDIA CUDA Toolkit
  12) Arrêter et Nettoyer l'Environnement
  0) Quitter
---------------------------------------------------------
Votre choix : 
```

### Packs Pré-configurés

Choisissez l'un des packs numérotés (1 à 7) pour un déploiement rapide et optimisé pour un cas d'usage spécifique. Le script sélectionnera automatiquement les services, modèles, plugins et workflows nécessaires.

*   **1) IA Conversatonnelle :** Pour interagir avec des modèles de langage locaux.
*   **2) Usine d'Automatisation :** Pour construire des workflows d'automatisation avec n8n.
*   **3) Studio Créatif de Base :** Pour la génération d'images SFW de haute qualité avec ComfyUI et ses outils essentiels.
*   **4) Studio Vidéo Avancé (SFW) :** Pour la production de vidéos SFW, incluant l'animation, le contrôle et la synchronisation labiale.
*   **5) Atelier d'Images Photoréalistes (NSFW) :** Pour la génération d'images NSFW de haute qualité.
*   **6) Studio Vidéo Complet (NSFW) :** Le pack ultime pour la production vidéo NSFW, combinant toutes les capacités.
*   **7) Déploiement Total :** Installe absolument tous les services et assets disponibles.

### Installation Personnalisée

L'option `8)` vous permet de sélectionner manuellement chaque composant (services Docker, modèles Ollama, plugins ComfyUI, modèles ComfyUI par catégorie, workflows) pour une configuration sur mesure. Le script vous guidera à travers une série de questions, y compris la possibilité de définir des **chemins absolus sur votre disque local** pour les données volumineuses de ComfyUI, Ollama et n8n. Cela utilise des "bind mounts" Docker pour un contrôle total sur l'emplacement de vos données.

### Mise à Jour des Assets

L'option `9)` vous permet de mettre à jour vos plugins ComfyUI (via `git pull`) et de re-vérifier/télécharger tous les modèles définis dans `config.sh`. Cette opération re-télécharge les modèles manquants ou corrompus, mais ne force pas le re-téléchargement de fichiers déjà présents et valides.

### Gérer l'Espace Disque Docker

L'option `10)` ouvre un sous-menu pour vous aider à nettoyer l'espace disque utilisé par Docker. Vous pouvez choisir de supprimer les images inutilisées, les conteneurs arrêtés, ou même purger l'ensemble du système Docker (avec ou sans les volumes de données).

### Installer WSL2 + NVIDIA CUDA Toolkit

L'option `11)` vous guidera pas à pas pour installer et configurer WSL2 et le NVIDIA CUDA Toolkit sur votre système Windows. Ce processus est interactif et nécessitera votre intervention pour certaines étapes (téléchargements, redémarrages, saisie de mot de passe).

### Arrêter et Nettoyer l'Environnement

L'option `12)` arrêtera tous les conteneurs Docker et supprimera leurs volumes associés, nettoyant ainsi complètement l'environnement J.A.M.Z.I. de votre système.

## 5. Accès aux Services

Une fois le déploiement terminé avec succès, le script affichera les URLs pour accéder aux services installés (les ports sont configurables dans votre fichier `.env`) :

*   **ComfyUI (Image/Vidéo) :** `http://localhost:COMFYUI_PORT`
*   **n8n (Automatisation) :** `http://localhost:N8N_PORT`
*   **Open WebUI (Langage) :** `http://localhost:OPEN_WEBUI_PORT`

## 6. Architecture du Projet

Le projet J.A.M.Z.I. utilise une architecture Dockerisée pour garantir l'isolation et la portabilité des services. Les données persistantes sont gérées via des volumes Docker montés sur votre machine hôte.

*   **Dans les conteneurs Docker :** Les applications (Ollama, Open WebUI, ComfyUI, n8n, Postgres, Redis) et leurs environnements d'exécution spécifiques.
*   **Sur votre machine hôte :**
    *   Le script `deploy.sh` et le fichier `config.sh`.
    *   Le fichier `.env`.
    *   Le dossier `templates/` contenant les fragments de configuration.
    *   Le dossier `data/` (monté comme volume dans les conteneurs par défaut) qui stocke tous vos modèles, plugins et données persistantes. Si des chemins locaux personnalisés sont définis, ces dossiers seront créés à l'emplacement spécifié.
    *   Le dossier `builders/` contenant les Dockerfiles générés pour la construction des images.
    *   Le dossier `user_assets/` où vous pouvez placer vos workflows ComfyUI et n8n locaux avant le déploiement.

## 7. Structure des Dossiers

```
E:/my_ia_stack/
├── .env
├── .gitignore
├── config.sh             # Le catalogue central des assets et la définition des packs
├── deploy.sh             # Le script principal de déploiement et de gestion
├── templates/            # Contient les fragments de configuration pour la génération dynamique
│   ├── services/         # Fragments de docker-compose.yml par service
│   ├── comfyui.Dockerfile.template
│   ├── n8n.Dockerfile.template
│   ├── config.ini.template
│   └── gitignore.template
├── user_assets/          # Placez ici vos workflows et modèles locaux avant le déploiement
│   ├── comfyui_workflows/
│   ├── n8n_workflows/
│   └── models/           # Pour les modèles que vous gérez manuellement
├── data/                 # (Créé et géré par le script) Contient tous les modèles, plugins, et données persistantes
│   ├── comfyui/
│   ├── n8n/
│   ├── ollama/
│   ├── open-webui/
│   └── shared-files/
└── builders/             # (Créé et géré par le script) Contient les Dockerfiles utilisés pour la construction des images
    ├── comfyui/
    └── n8n/
```

## 8. Dépannage

*   **"Commande requise 'docker' introuvable." :** Assurez-vous que Docker Desktop est installé et en cours d'exécution.
*   **"Docker ne peut pas accéder au GPU NVIDIA." :** Vérifiez les paramètres de Docker Desktop pour vous assurer que l'intégration GPU est activée.
*   **Problèmes de téléchargement (`aria2c`) :** Vérifiez votre connexion internet. Le script utilise `aria2c -c` pour reprendre les téléchargements, vous pouvez donc relancer le script.
*   **Conteneurs qui ne démarrent pas :** Utilisez `docker compose logs -f` dans le répertoire du projet pour voir les logs détaillés des services et identifier la cause du problème.
*   **Problèmes de compatibilité ComfyUI/CUDA :** Si ComfyUI ne démarre pas correctement ou affiche des erreurs CUDA, vérifiez que votre pilote NVIDIA est à jour et que la version de CUDA dans le Dockerfile correspond à celle de votre GPU.
*   **Problèmes avec les workflows ComfyUI :** Si un workflow ne fonctionne pas comme prévu, même après un déploiement réussi, il peut nécessiter des ajustements manuels. Vérifiez les messages d'erreur dans les logs de ComfyUI. Parfois, des nœuds peuvent avoir des dépendances implicites ou des changements de version qui nécessitent une petite intervention.

## 9. Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails. (Note: Vous devrez créer un fichier LICENSE si vous souhaitez en inclure un.)