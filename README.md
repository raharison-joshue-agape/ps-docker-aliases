<div align="center">

# 🚀 Docker Command Aliases

### Raccourcis Docker pour **Bash (Linux/macOS)** et **PowerShell (Windows)**

Suite d'aliases `d*` qui simplifient et accélèrent vos workflows Docker directement en ligne de commande.

---

[![GitHub stars](https://img.shields.io/github/stars/raharison-joshue-agape/ps-docker-aliases?style=for-the-badge&logo=github&logoColor=white&color=gold)](https://github.com/raharison-joshue-agape/ps-docker-aliases/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/raharison-joshue-agape/ps-docker-aliases?style=for-the-badge&logo=github&logoColor=white&color=blue)](https://github.com/raharison-joshue-agape/ps-docker-aliases/forks)
[![GitHub issues](https://img.shields.io/github/issues/raharison-joshue-agape/ps-docker-aliases?style=for-the-badge&logo=github&logoColor=white&color=red)](https://github.com/raharison-joshue-agape/ps-docker-aliases/issues)
[![Bash](https://img.shields.io/badge/Bash-4.0%2B-4EAA25?style=for-the-badge&logo=gnubash&logoColor=white)](https://www.gnu.org/software/bash/)
[![Zsh](https://img.shields.io/badge/Zsh-5.x-F15A24?style=for-the-badge&logo=zsh&logoColor=white)](https://www.zsh.org/)
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-5391FE?style=for-the-badge&logo=powershell&logoColor=white)](https://learn.microsoft.com/powershell/)
[![Linux](https://img.shields.io/badge/Linux-ready-FCC624?style=for-the-badge&logo=linux&logoColor=black)](https://www.linux.org/)
[![macOS](https://img.shields.io/badge/macOS-ready-000000?style=for-the-badge&logo=apple&logoColor=white)](https://www.apple.com/macos/)
[![Windows](https://img.shields.io/badge/Windows-ready-0078D6?style=for-the-badge&logo=windows&logoColor=white)](https://www.microsoft.com/windows)
[![Docker](https://img.shields.io/badge/Docker-requis-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://www.docker.com/)
[![Repo size](https://img.shields.io/github/repo-size/raharison-joshue-agape/ps-docker-aliases?style=for-the-badge&logo=github&logoColor=white)]()

</div>

---

## 📑 Table des matières

- [✨ Fonctionnalités](#-fonctionnalités)
- [🛠️ Stack technique](#️-stack-technique)
- [🏗️ Architecture](#️-architecture)
- [⚡ Démarrage rapide](#-démarrage-rapide)
- [🖥️ Linux / Bash](#️-linux--bash)
- [🍎 macOS / Zsh](#-macos--zsh)
- [🪟 Windows / PowerShell](#-windows--powershell)
- [🔧 Référence des commandes](#-référence-des-commandes)
- [📖 Aide intégrée](#-aide-intégrée)
- [🔌 Modules](#-modules)
- [📂 Structure du projet](#-structure-du-projet)
- [🧹 Désinstallation](#-désinstallation)
- [🛟 Dépannage](#-dépannage)
- [📄 Licence](#-licence)

---

## ✨ Fonctionnalités

| | |
|---|---|
| ⚡ **Aliases `d*`** | Des dizaines de raccourcis vers les commandes Docker essentielles, identiques sur les trois plateformes |
| 🧩 **Architecture modulaire** | Modules thématiques (système, images, conteneurs, Compose, volumes, réseaux, Swarm...) chargés depuis un point d'entrée unique |
| 🐧 **Linux / Bash** | Scripts `.sh` compatibles bash 4.0+ et zsh |
| 🍎 **macOS / Zsh** | Scripts `.sh` bash compatibles zsh, shell par défaut de macOS depuis Catalina |
| 🪟 **Windows / PowerShell** | Scripts `.ps1` compatibles Windows PowerShell 5.1+ et PowerShell 7 |
| 🛡️ **Vérification de Docker** | Disponibilité de la CLI Docker contrôlée avant chaque appel, avec arrêt propre si absente |
| ✅ **Feedback clair** | Messages de succès (`✅`) et d'erreur (`❌`) pour chaque opération |
| 🔐 **Actions destructives protégées** | Confirmation demandée avant suppression / prune (`-f` ou `-Force` pour passer outre) |
| 📖 **Cheat sheet intégrée** | `dDocs` affiche la liste complète des commandes groupées par thème |
| 🧠 **Aide contextuelle** | Cheat sheets par catégorie (`dContainerDocs`, `dImageDocs`...), `Get-Help` côté PowerShell |

---

## 🛠️ Stack technique

| Domaine | Technologie |
|---|---|
| **Shell Linux** | [Bash](https://www.gnu.org/software/bash/) 4.0+ (ou [Zsh](https://www.zsh.org/)) |
| **Shell macOS** | [Zsh](https://www.zsh.org/) 5.x (shell par défaut) ou Bash 4.0+ |
| **Shell Windows** | [Windows PowerShell](https://learn.microsoft.com/powershell/) 5.1+ ou [PowerShell 7](https://learn.microsoft.com/powershell/) |
| **Runtime** | [Docker CLI](https://docs.docker.com/) (Engine, Desktop ou tout runtime compatible) |
| **Format** | Scripts shell / PowerShell — **aucune dépendance externe** |
| **Point d'entrée** | `index.sh` / `index.ps1` (chargement automatique des modules) |
| **Couche utilitaire** | `docker-helpers.sh` / `docker-helpers.ps1` (vérification, exécution, messages) |
| **Documentation** | Cheat sheet intégrée (`dDocs`) + `Get-Help` (PowerShell) |

---

## 🏗️ Architecture

L'implémentation suit une **architecture modulaire en couches**, chaque couche ayant une responsabilité unique :

```
 Terminal / Shell de l'utilisateur
      │      (~/.bashrc | ~/.zshrc | $PROFILE)
      ▼
┌────────────────────────────┐
│    index.sh / index.ps1    │  Point d'entrée — charge tous les modules
└────────────┬───────────────┘
             ▼
┌────────────────────────────┐
│  Modules thématiques       │  docker-system.sh, docker-images.sh,
│                            │  docker-containers.sh, docker-compose.sh,
│                            │  docker-volumes.sh, docker-networks.sh, ...
└────────────┬───────────────┘
             ▼
┌────────────────────────────┐
│ docker-helpers.sh/helpers.ps1│  d_check_cli / Test-DockerCLI,
│                            │  d_confirm / Confirm-Action,
│                            │  messages de succès et d'erreur
└────────────┬───────────────┘
             ▼
           Docker CLI
```

- **`index.sh` / `index.ps1`** : source l'ensemble des modules situés dans son propre répertoire, quel que soit l'endroit où le projet a été copié.
- **Modules thématiques** : chacun expose les fonctions publiques `d*` d'un domaine Docker.
- **Helpers** : portent la logique transversale (disponibilité de Docker, exécution, feedback coloré).
- Les deux implémentations (`linux/` et `windows/`) sont **fonctionnellement équivalentes** : mêmes commandes, mêmes comportements. Les options suivent la convention de chaque shell — flags courts en bash (`-d`, `-a`, `-v`), paramètres nommés en PowerShell (`-Detach`, `-All`, `-Volumes`).

---

## ⚡ Démarrage rapide

### Prérequis

- **Docker CLI** installée et accessible depuis le terminal — voir [Docker Engine](https://docs.docker.com/engine/install/) ou [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- **Linux** : bash 4.0+ (ou zsh)
- **macOS** : zsh 5.x (shell par défaut) ou bash 4.0+
- **Windows** : Windows 10/11 avec Windows PowerShell 5.1+ ou PowerShell 7

Puis suivez les étapes correspondant à votre plateforme ci-dessous.

---

## 🖥️ Linux / Bash

### 1. Copier les fichiers dans votre répertoire de configuration

```bash
mkdir -p ~/.config/alias
cp -r linux ~/.config/alias/docker-commandes/
```

### 2. Ouvrir votre fichier de configuration shell

```bash
nano ~/.bashrc        # Bash
nano ~/.zshrc         # Zsh
```

### 3. Importer les aliases

Ajoutez cette ligne à la fin du fichier :

```bash
. ~/.config/alias/docker-commandes/linux/index.sh
```

### 4. Recharger votre configuration

```bash
source ~/.bashrc      # ou : source ~/.zshrc
```

---

## 🍎 macOS / Zsh

### 1. Copier les fichiers dans votre répertoire de configuration

```bash
mkdir -p ~/.config/alias
cp -r linux ~/.config/alias/docker-commandes/
```

### 2. Ouvrir votre fichier de configuration shell

```bash
nano ~/.zshrc         # Zsh (shell par défaut)
nano ~/.bash_profile  # Bash
```

### 3. Importer les aliases

Ajoutez cette ligne à la fin du fichier :

```bash
. ~/.config/alias/docker-commandes/linux/index.sh
```

### 4. Recharger votre configuration

```bash
source ~/.zshrc       # ou : source ~/.bash_profile
```

> 💡 Si Docker est absent : installez [Docker Desktop pour Mac](https://www.docker.com/products/docker-desktop/) ou la CLI via `brew install docker`.
> ⚠️ Le Bash fourni par macOS (3.2) est trop ancien — utilisez Zsh ou installez un Bash moderne via Homebrew (`brew install bash`).

---

## 🪟 Windows / PowerShell

### 1. Copier les fichiers dans votre répertoire de configuration

```powershell
New-Item -ItemType Directory -Path "$HOME\.config\alias\docker-commandes" -Force
Copy-Item -Path "windows" -Destination "$HOME\.config\alias\docker-commandes\" -Recurse
```

### 2. Vérifier que votre profil PowerShell existe

```powershell
Test-Path $PROFILE
```

- `True` → votre profil existe, passez à l'étape 4.
- `False` → créez-le :

```powershell
New-Item -Path $PROFILE -ItemType File -Force
```

### 3. Ouvrir votre profil

```powershell
notepad $PROFILE      # ou : code $PROFILE
```

### 4. Importer les aliases

Ajoutez cette ligne à votre profil :

```powershell
. "$HOME\.config\alias\docker-commandes\windows\index.ps1"
```

### 5. Recharger votre profil

```powershell
. $PROFILE
```

---

## 🔧 Référence des commandes

Les fonctions se comportent comme des commandes natives et acceptent les mêmes arguments que les commandes Docker sous-jacentes. L'alias court est indiqué après le `/`.

### Exemples rapides

```bash
# Linux (Bash) / macOS (Zsh)
dContainers             # liste des conteneurs actifs (docker ps)
dRunContainer nginx --name web -d -p 8080:80
dImages                 # liste des images locales
dComposeUp -d           # démarre les services Compose
dLogsContainer web -f   # suit les logs du conteneur web
```

```powershell
# Windows (PowerShell)
dContainers                                  # liste des conteneurs actifs (docker ps)
dRunContainer -ImageName nginx -ContainerName web -Detach -Ports 8080:80
dImages                                      # liste des images locales
dComposeUp -Detach                           # démarre les services Compose
dLogsContainer web -Follow                   # suit les logs du conteneur web
```

### 🐳 Système — System

| Commande | Description |
|---|---|
| `dVersion / dver` | Affiche la version de Docker installée |
| `dInfo / dinfo` | Affiche les informations du système Docker |
| `dDiskSystem / ddf` | Affiche l'utilisation du disque par Docker |
| `dEvents / devents` | Affiche en continu les événements du moteur Docker |
| `dPruneSystem / dprune` | Nettoie les conteneurs, images et réseaux inutilisés (`-v` ajoute les volumes) |
| `dLogin / dlogin` | S'authentifie auprès d'un registre Docker |
| `dLogout / dlogout` | Se déconnecte d'un registre Docker |

### 🐳 Images

| Commande | Description |
|---|---|
| `dImages / dimg` | Liste les images locales |
| `dBuildImage / dbuild` | Construit une image depuis un dossier |
| `dGetImage / dpull` | Télécharge une image |
| `dPushImage / dpush` | Pousse une image locale vers un registre |
| `dRemoveImage / drmi` | Supprime une image (`-f` sans confirmation) |
| `dPruneImage / dpruneimg` | Supprime les images inutilisées / suspendues |
| `dTagImage / dtag` | Applique un tag à une image |
| `dSaveImage / dsave` | Exporte une image vers un fichier `.tar` |
| `dLoadImage / dload` | Importe une image depuis un fichier `.tar` |
| `dHistoryImage / dhist` | Affiche l'historique de construction d'une image |
| `dInspectImage / dinsp` | Affiche les détails d'une image |

### 🐳 Conteneurs

| Commande | Description |
|---|---|
| `dContainers / dps` | Liste les conteneurs (actifs par défaut) |
| `dRunContainer / drun` | Exécute un conteneur (ports, volumes, env, réseau, restart...) |
| `dCreateContainer / dcreate` | Crée un conteneur sans le démarrer |
| `dStartContainer / dstart` | Démarre un conteneur |
| `dStopContainer / dstop` | Arrête un conteneur |
| `dRestartContainer / drestart` | Redémarre un conteneur |
| `dKillContainer / dkill` | Tue de force un conteneur |
| `dRemoveContainer / drm` | Supprime un conteneur (`-f` sans confirmation, `-v` avec volumes) |
| `dLogsContainer / dlogs` | Affiche les logs d'un conteneur (`-f` suit, `-n` limite) |
| `dExecContainer / dexec` | Exécute une commande dans un conteneur |
| `dAttachContainer / dattach` | S'attache à un conteneur |
| `dTopContainer / dtop` | Affiche les processus d'un conteneur |
| `dStatsContainer / dstats` | Affiche les statistiques en direct des conteneurs |
| `dWaitContainer / dwait` | Attend l'arrêt d'un conteneur |
| `dRenameContainer / dren` | Renomme un conteneur |
| `dUpdateContainer / dupdate` | Met à jour les ressources d'un conteneur |
| `dPauseContainer / dpause` | Met en pause un conteneur |
| `dUnpauseContainer / dunpause` | Reprend un conteneur en pause |
| `dExportContainer / dexport` | Exporte le système de fichiers d'un conteneur |
| `dCommitContainer / dcommit` | Crée une image depuis un conteneur |
| `dDiffContainer / ddiff` | Affiche les changements du système de fichiers |
| `dCpContainer / dcp` | Copie des fichiers hôte ↔ conteneur |
| `dInspectContainer / dinspc` | Affiche les détails d'un conteneur |
| `dPortContainer / dport` | Affiche les ports d'un conteneur |

### 🐳 Compose

| Commande | Description |
|---|---|
| `dComposes / dcps` | Liste les services Compose |
| `dComposeUp / dcup` | Démarre les services Compose (`-d` détaché, `-b` build) |
| `dComposeDown / dcdown` | Arrête et supprime les services Compose (`-v` avec volumes) |
| `dComposeBuild / dcbuild` | Construit les images Compose |
| `dComposeLogs / dclogs` | Affiche les logs des services |
| `dComposeExec / dcexec` | Exécute une commande dans un service |
| `dComposeRestart / dcrestart` | Redémarre les services Compose |
| `dComposePull / dcpull` | Télécharge les images Compose |
| `dComposeStop / dcstop` | Arrête les services (en conservant les conteneurs) |
| `dComposeConfig / dcconfig` | Affiche la configuration Compose fusionnée |
| `dComposeValidate / dccheck` | Valide le fichier Compose |

### 🐳 Volumes

| Commande | Description |
|---|---|
| `dVolumes / dvol` | Liste les volumes |
| `dCreateVolume / dvolc` | Crée un volume |
| `dInspectVolume / dvoli` | Affiche les détails d'un volume |
| `dRemoveVolume / dvolr` | Supprime un volume |
| `dPruneVolume / dvolp` | Supprime les volumes inutilisés |

### 🐳 Réseaux

| Commande | Description |
|---|---|
| `dNetworks / dnet` | Liste les réseaux |
| `dCreateNetwork / dnetc` | Crée un réseau |
| `dInspectNetwork / dneti` | Affiche les détails d'un réseau |
| `dConnectNetwork / dnetco` | Connecte un conteneur à un réseau |
| `dDisconnectNetwork / dnetd` | Déconnecte un conteneur d'un réseau |
| `dRemoveNetwork / dnetr` | Supprime un réseau |
| `dPruneNetwork / dnetp` | Supprime les réseaux inutilisés |

### 🐳 Swarm

| Commande | Description |
|---|---|
| `dInitSwarm / dswarm` | Initialise un cluster Swarm |
| `dJoinSwarm / dswarmjoin` | Rejoint un cluster Swarm (token + adresse du manager) |
| `dLeaveSwarm / dswarmleave` | Quitte le cluster Swarm (`-f` même en tant que manager) |
| `dSwarmToken / dswarmtoken` | Affiche le jeton d'adhésion manager / worker |
| `dNodes / dnodes` | Liste les nœuds du cluster |
| `dServices / dsvcs` | Liste les services Swarm |
| `dCreateService / dsvcc` | Crée un service Swarm |
| `dRemoveService / dsvcr` | Supprime un service |
| `dScaleService / dsvcscale` | Met à l'échelle un service (réplicas) |
| `dServiceLogs / dsvclogs` | Affiche les logs d'un service |
| `dStackDeploy / dstack` | Déploie une stack depuis un fichier Compose |
| `dStacks / dstacks` | Liste les stacks déployées |
| `dStackRemove / dstackrm` | Supprime une stack déployée |

### 📖 Références

| Commande | Description |
|---|---|
| `dDocs / dhelp` | Affiche la cheat sheet complète de toutes les commandes |
| `dContainerDocs / dcdocs` | Cheat sheet des commandes conteneurs |
| `dImageDocs / didocs` | Cheat sheet des commandes images |
| `dComposeDocs / dcompdocs` | Cheat sheet des commandes Compose |
| `dVolumeDocs / dvolumdocs` | Cheat sheet des commandes volumes |
| `dNetworkDocs / dnetdocs` | Cheat sheet des commandes réseaux |
| `dSwarmDocs / dswarmdocs` | Cheat sheet des commandes Swarm |

---

## 📖 Aide intégrée

| Commande | Description |
|---|---|
| `dDocs` | Affiche la cheat sheet complète de toutes les commandes, groupées par thème |
| `dhelp` | Alias de `dDocs` |
| `Get-Help <fonction>` | *(PowerShell)* Documentation comment-based de n'importe quelle fonction |

```bash
dDocs
```

```powershell
dDocs
Get-Help dRunContainer
```

> 💡 Chaque fonction PowerShell possède une aide comment-based (`Get-Help`) décrivant ses paramètres et fournissant des exemples.

---

## 🔌 Modules

Chaque module regroupe les fonctions d'un même thème. Les deux plateformes sont strictement alignées :

| Fichier (Linux / Windows) | Fonctions |
|---|---|
| `docker-helpers.sh` / `docker-helpers.ps1` | `d_check_cli`, `d_confirm`, `d_show_result`, `d_read_value`, `d_complete_image`, `d_local_images`, `d_image_exists`, `d_show_images`, `d_resolve_image`, `d_show_containers`, `d_container_names`, `d_container_exists`, `d_container_running`, `d_resolve_container`, `d_volume_names`, `d_volume_exists`, `d_network_names`, `d_network_exists`, `d_service_names`, `d_service_exists`, `d_resolve_service`, `d_doc_table` / `Test-DockerCLI`, `Assert-DockerCLI`, `Confirm-Action`, `Show-DockerResult`, `Read-Value`, `Complete-ImageName`, `Get-LocalImages`, `Test-ImageExists`, `Resolve-ImageName`, `Show-ContainerList`, `Get-ContainerNames`, `Test-ContainerExists`, `Test-ContainerRunning`, `Resolve-ContainerName`, `Get-VolumeNames`, `Test-VolumeExists`, `Get-NetworkNames`, `Test-NetworkExists`, `Get-ServiceNames`, `Test-ServiceExists`, `Resolve-ServiceName`, `Show-DocTable` |
| `docker-system.sh` / `docker-system.ps1` | `dVersion`, `dInfo`, `dDiskSystem`, `dEvents`, `dPruneSystem`, `dLogin`, `dLogout` |
| `docker-images.sh` / `docker-images.ps1` | `dImages`, `dBuildImage`, `dGetImage`, `dPushImage`, `dRemoveImage`, `dPruneImage`, `dTagImage`, `dSaveImage`, `dLoadImage`, `dHistoryImage`, `dInspectImage`, `dImageDocs` |
| `docker-containers.sh` / `docker-containers.ps1` | `dContainers`, `dRunContainer`, `dCreateContainer`, `dStartContainer`, `dStopContainer`, `dRestartContainer`, `dKillContainer`, `dRemoveContainer`, `dLogsContainer`, `dExecContainer`, `dAttachContainer`, `dTopContainer`, `dStatsContainer`, `dWaitContainer`, `dRenameContainer`, `dUpdateContainer`, `dPauseContainer`, `dUnpauseContainer`, `dExportContainer`, `dCommitContainer`, `dDiffContainer`, `dCpContainer`, `dInspectContainer`, `dPortContainer`, `dContainerDocs` |
| `docker-compose.sh` / `docker-compose.ps1` | `dComposes`, `dComposeUp`, `dComposeDown`, `dComposeBuild`, `dComposeLogs`, `dComposeExec`, `dComposeRestart`, `dComposePull`, `dComposeStop`, `dComposeConfig`, `dComposeValidate`, `dComposeDocs` |
| `docker-volumes.sh` / `docker-volumes.ps1` | `dVolumes`, `dCreateVolume`, `dInspectVolume`, `dRemoveVolume`, `dPruneVolume`, `dVolumeDocs` |
| `docker-networks.sh` / `docker-networks.ps1` | `dNetworks`, `dCreateNetwork`, `dInspectNetwork`, `dConnectNetwork`, `dDisconnectNetwork`, `dRemoveNetwork`, `dPruneNetwork`, `dNetworkDocs` |
| `docker-swarm.sh` / `docker-swarm.ps1` | `dInitSwarm`, `dJoinSwarm`, `dLeaveSwarm`, `dSwarmToken`, `dNodes`, `dServices`, `dCreateService`, `dRemoveService`, `dScaleService`, `dServiceLogs`, `dStackDeploy`, `dStacks`, `dStackRemove`, `dSwarmDocs` |
| `docker-docs.sh` / `docker-docs.ps1` | `dDocs` |
| `docker-aliases.sh` / `docker-aliases.ps1` | Alias courts (`dps`, `drun`, `dstop`, `dlogs`, `dcup`...) et wrappers (`dpsa`, `drmf`, `drmv`, `drmif`) |

---

## 📂 Structure du projet

```
docker-commandes/
├── linux/                     # Implémentation Bash pour Linux/macOS
│   ├── index.sh               # Point d'entrée (charge tous les modules)
│   ├── docker-helpers.sh      # Utilitaires partagés (d_check_cli, d_confirm...)
│   ├── docker-system.sh       # dVersion, dInfo, dDiskSystem, dPruneSystem...
│   ├── docker-images.sh       # dImages, dBuildImage, dGetImage, dPushImage...
│   ├── docker-containers.sh   # dContainers, dRunContainer, dStopContainer...
│   ├── docker-compose.sh      # dComposes, dComposeUp, dComposeDown...
│   ├── docker-volumes.sh      # dVolumes, dCreateVolume, dPruneVolume...
│   ├── docker-networks.sh     # dNetworks, dCreateNetwork, dPruneNetwork...
│   ├── docker-swarm.sh        # dInitSwarm, dNodes, dServices, dStacks...
│   ├── docker-docs.sh         # dDocs (cheat sheet intégrée)
│   ├── docker-aliases.sh      # Alias courts (dps, drun, dstop, dlogs...)
│   └── README.md              # Guide d'installation Linux
└── windows/                   # Implémentation PowerShell pour Windows
    ├── index.ps1              # Point d'entrée PowerShell (sourcez depuis $PROFILE)
    ├── docker-helpers.ps1     # Utilitaires partagés (Test-DockerCLI, Confirm-Action...)
    ├── docker-system.ps1      # dVersion, dInfo, dDiskSystem, dPruneSystem...
    ├── docker-images.ps1      # dImages, dBuildImage, dGetImage, dPushImage...
    ├── docker-containers.ps1  # dContainers, dRunContainer, dStopContainer...
    ├── docker-compose.ps1     # dComposes, dComposeUp, dComposeDown...
    ├── docker-volumes.ps1     # dVolumes, dCreateVolume, dPruneVolume...
    ├── docker-networks.ps1    # dNetworks, dCreateNetwork, dPruneNetwork...
    ├── docker-swarm.ps1       # dInitSwarm, dNodes, dServices, dStacks...
    ├── docker-docs.ps1        # dDocs (cheat sheet intégrée)
    ├── docker-aliases.ps1     # Alias courts (dps, drun, dstop, dlogs...)
    └── README.md              # Guide d'installation Windows
```

---

## 🧹 Désinstallation

### Linux

1. Supprimez la ligne d'import de `~/.bashrc` (ou `~/.zshrc`).
2. Supprimez le répertoire :

```bash
rm -rf ~/.config/alias/docker-commandes
```

### macOS

1. Supprimez la ligne d'import de `~/.zshrc` (ou `~/.bash_profile`).
2. Supprimez le répertoire :

```bash
rm -rf ~/.config/alias/docker-commandes
```

### Windows

1. Supprimez la ligne d'import de `$PROFILE`.
2. Supprimez le répertoire :

```powershell
Remove-Item -Path "$HOME\.config\alias\docker-commandes" -Recurse -Force
```

---

## 🛟 Dépannage

| Symptôme | Solution |
|---|---|
| Les commandes ne fonctionnent pas | Vérifiez le chemin dans la ligne d'import, puis rechargez : `source ~/.bashrc` (Linux), `source ~/.zshrc` (macOS) ou `. $PROFILE` (Windows) |
| `❌ Docker CLI not found` | Installez Docker (`sudo apt install docker.io` sous Debian/Ubuntu, Docker Desktop ou `brew install docker` sous macOS, Docker Desktop sous Windows) et redémarrez votre terminal |
| `command not found: dContainers` | Les fonctions ne sont pas chargées : confirmez la présence de la ligne d'import correspondant à votre plateforme dans votre fichier de configuration |
| `Module not found: ...` (jaune) | Un fichier de module est absent — réinstallez le dossier `linux/` ou `windows/` en entier |
| Erreurs de syntaxe sur macOS | Le Bash 3.2 fourni par macOS est obsolète — utilisez Zsh, ou installez un Bash moderne via Homebrew |
| Les alias ne s'expandent pas dans un script | Les alias bash ne s'appliquent qu'aux shells interactifs — utilisez le nom complet de la fonction (ex. `dContainers`) |
| `Get-Help` ne retourne rien | Rechargez le profil (`. $PROFILE`) pour que les fonctions soient définies |

---

## 📄 Licence

Ce projet est **open source**. Vous pouvez l'utiliser, le modifier et le partager librement.

---

<div align="center">

**Fait avec ❤️ par [Joshué Agapé](https://github.com/raharison-joshue-agape)**

</div>
