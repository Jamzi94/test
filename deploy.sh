#!/bin/bash
# ============================================================================== 
#      J.A.M.Z.I. AI STACK - DEPLOYMENT & MANAGEMENT FRAMEWORK v51.0 
# ============================================================================== 
#      Orchestrateur interactif pour le déploiement modulaire de la stack IA
#      ➜ v51.0 : ajout d’un prompt interactif pour définir le chemin d’import
#                de la distribution « docker-desktop » afin d’éviter
#                HCS/ERROR_PATH_NOT_FOUND lors de l’installation WSL.

# --- SETUP INITIAL & ROBUSTESSE ---------------------------------------------
set -euo pipefail
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --- UI & LOGGING ------------------------------------------------------------
C_RESET='\033[0m' C_RED='\033[0;31m' C_GREEN='\033[0;32m' C_YELLOW='\033[0;33m' C_BLUE='\033[0;34m' C_CYAN='\033[0;36m' C_WHITE='\033[0;37m' C_BOLD='\033[1m' C_DIM='\033[2m'
ICON_OK="${C_GREEN}✔${C_RESET}" ICON_WARN="${C_YELLOW}⚠${C_RESET}" ICON_ERROR="${C_RED}❌${C_RESET}" ICON_DOWNLOAD="${C_YELLOW}📥${C_RESET}" ICON_UPDATE="${C_GREEN}🔄${C_RESET}" ICON_BRAIN="${C_GREEN}🧠${C_RESET}" ICON_GEAR="${C_BLUE}⚙️${C_RESET}"

log_header(){ echo -e "\n${C_BLUE}${C_BOLD}┃ $1${C_RESET}"; }
log_ok()    { echo -e "  $ICON_OK $1"; }
log_warn()  { echo -e "  $ICON_WARN ${C_YELLOW}AVERTISSEMENT:${C_RESET} $1"; }
log_error() { echo -e "\n$ICON_ERROR ${C_RED}ERREUR:${C_RESET} $1\n" >&2; exit 1; }

# --- GESTION DES INTERRUPTIONS ----------------------------------------------
cleanup(){
  echo -e "\n  $ICON_WARN ${C_YELLOW}Opération annulée. Nettoyage...${C_RESET}"
  if [ -f "$BASE_DIR/docker-compose.yml" ]; then
    cd "$BASE_DIR" && docker compose down --remove-orphans &>/dev/null
    log_ok "Conteneurs Docker arrêtés."
  fi
  exit 1
}
trap cleanup SIGINT SIGTERM ERR

# ---------------------------------------------------------------------------
# 🆕 Vérifie / importe la distro docker-desktop avec chemin utilisateur
# ---------------------------------------------------------------------------
ensure_docker_desktop_distro(){
  log_header "VÉRIFICATION DE LA DISTRIBUTION docker-desktop (WSL)"
  if wsl.exe -l -v 2>/dev/null | grep -q "docker-desktop"; then
    log_ok "Distribution 'docker-desktop' déjà présente."
    return 0
  fi
  log_warn "Distribution 'docker-desktop' absente ou corrompue."
  local default_path
  default_path="$(cmd.exe /c "echo %LOCALAPPDATA%" | tr -d '\r')\\Docker\\wsl\\main"
  echo -e "  ${C_DIM}Chemin proposé :${C_RESET} $default_path"
  read -p "  Chemin d'import (Entrée = défaut) : " docker_path
  [[ -z "$docker_path" ]] && docker_path="$default_path"
  powershell.exe -NoLogo -Command "if (-not (Test-Path -Path \"${docker_path//\\/\\\\}\")) { New-Item -ItemType Directory -Force -Path \"${docker_path//\\/\\\\}\" | Out-Null }"
  local tarball="C:\\Program Files\\Docker\\Docker\\resources\\wsl\\wsl-bootstrap.tar"
  echo -e "  ${C_DIM}Import de docker-desktop…${C_RESET}"
  if ! wsl.exe --import docker-desktop "$docker_path" "$tarball" --version 2; then
    log_error "Échec de l'import docker-desktop. Vérifiez le chemin."
  fi
  log_ok "Distribution 'docker-desktop' importée avec succès."
}
# --- FONCTIONS DE CONTRÔLE (Améliorées & Modularisées) ---

# Vérifie l'environnement système et charge les configurations
function check_environment() {
    log_header "PHASE 1 : VÉRIFICATION DE L'ENVIRONNEMENT"
    # La vérification des droits admin est maintenant dans le .bat, plus besoin ici.
    
    if [ ! -f "config.sh" ] || [ ! -f ".env" ]; then log_error "'config.sh' et/ou '.env' introuvables."; fi
    
    # Charge les variables d'environnement et de configuration
    set -o allexport
    source .env
    set +o allexport
    source config.sh
    log_ok "Fichiers de configuration chargés."

    # Vérifie la présence des commandes critiques (docker, git)
    for cmd in docker git; do
      if ! command -v $cmd &>/dev/null; then log_error "Commande requise '$cmd' introuvable. Veuillez l'installer manuellement."; fi
    done
    log_ok "Dépendances logicielles (docker, git) présentes."

    # Vérifie et installe aria2c si manquant
    if ! command -v aria2c &>/dev/null; then
        log_warn "Commande 'aria2c' introuvable. Lancement du script d'installation unifié..."

        # Bloc de script PowerShell unifié pour installer Choco et aria2c en une seule passe.
        # Cette méthode garantit que l'environnement reste cohérent.
        PS_SCRIPT=$(cat <<-'EOF'
        # --- DEBUT DU SCRIPT POWERSHELL UNIFIÉ ---

        Write-Host "Verification de Chocolatey..."
        # Vérifie si Chocolatey est déjà accessible
        if (Get-Command choco -ErrorAction SilentlyContinue) {
            Write-Host "  -> Chocolatey est deja present."
        } else {
            Write-Host "  -> Chocolatey non trouve. Tentative d'installation..."
            try {
                # Script d'installation officiel
                Set-ExecutionPolicy Bypass -Scope Process -Force;
                [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
                iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'));
            } catch {
                Write-Error "L'installation de Chocolatey a echoue."
                exit 1
            }
        }

        Write-Host "Verification de aria2c..."
        if (Get-Command aria2c -ErrorAction SilentlyContinue) {
            Write-Host "  -> aria2c est deja present."
        } else {
            Write-Host "  -> aria2c non trouve. Installation via Chocolatey..."
            try {
                # Force l'ajout du chemin au PATH de la session actuelle par sécurité
                $env:Path = "C:\ProgramData\chocolatey\bin;" + $env:Path
                choco install aria2 -y
            } catch {
                Write-Error "L'installation de aria2c via Chocolatey a echoue."
                exit 1
            }
        }

        Write-Host "  -> Verification finale de la commande 'aria2c'..."
        if (-not (Get-Command aria2c -ErrorAction SilentlyContinue)) {
            Write-Error "ERREUR FATALE: aria2c n'a pas pu etre installe ou detecte apres installation."
            exit 1
        }

        Write-Host "Toutes les dependances sont satisfaites."
        # --- FIN DU SCRIPT POWERSHELL UNIFIÉ ---
EOF
        )

        # Exécute l'intégralité du bloc dans un seul processus PowerShell
        powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$PS_SCRIPT"

        if [ $? -ne 0 ]; then
            log_error "Le script d'installation unifié a échoué. Veuillez vérifier les logs ci-dessus."
        fi
        log_ok "Dépendance 'aria2c' installée et vérifiée."
    else
        log_ok "Commande 'aria2c' présente."
    fi
}

# Génère les fichiers de configuration essentiels (docker-compose, Dockerfiles, etc.)
function generate_all_files() {
    log_header "PHASE 2 : GÉNÉRATION DES FICHIERS DE CONFIGURATION"
    
    # --- Génération docker-compose.yml ---
    echo -e "  ${C_DIM}Assemblage du fichier docker-compose.yml...${C_RESET}"
    
    # Construire le contenu du docker-compose.yml dynamiquement
    local docker_compose_content=""
    docker_compose_content+=$(cat "$BASE_DIR/templates/docker-compose.header.yml")

    for service in $SELECTED_SERVICES; do
        local service_template_path="$BASE_DIR/templates/services/${service}.yml"
        local service_content=$(cat "$service_template_path")

        # Remplacer les placeholders de chemins si des chemins personnalisés sont définis
        if [[ "$service" == "comfyui" && -n "$SELECTED_COMFYUI_MODELS_HOST_PATH" ]]; then
            service_content=$(echo "$service_content" | sed "s|- ./data/comfyui/models:/app/models|- $SELECTED_COMFYUI_MODELS_HOST_PATH:/app/models|")
        fi
        if [[ "$service" == "ollama" && -n "$SELECTED_OLLAMA_HOST_PATH" ]]; then
            service_content=$(echo "$service_content" | sed "s|- ./data/ollama:/root/.ollama|- $SELECTED_OLLAMA_HOST_PATH:/root/.ollama|")
        fi
        if [[ "$service" == "n8n" && -n "$SELECTED_N8N_HOST_PATH" ]]; then
            service_content=$(echo "$service_content" | sed "s|- ./data/n8n:/home/node/.n8n|- $SELECTED_N8N_HOST_PATH:/home/node/.n8n|")
        fi
        docker_compose_content+="$service_content"
    done;
    docker_compose_content+=$(cat "$BASE_DIR/templates/docker-compose.footer.yml")

    echo "$docker_compose_content" > "$BASE_DIR/docker-compose.yml"
    log_ok "docker-compose.yml généré pour les services : ${C_GREEN}${SELECTED_SERVICES}${C_RESET}"

    # --- Génération .gitignore ---
    echo -e "  ${C_DIM}Génération du .gitignore...${C_RESET}"
    cp "$BASE_DIR/templates/gitignore.template" "$BASE_DIR/.gitignore"
    log_ok ".gitignore généré."

    # --- Génération config.ini pour ComfyUI Manager ---
    echo -e "  ${C_DIM}Génération du config.ini pour ComfyUI Manager...${C_RESET}"
    mkdir -p "$BASE_DIR/builders/comfyui"
    cp "$BASE_DIR/templates/config.ini.template" "$BASE_DIR/builders/comfyui/config.ini"
    log_ok "config.ini pour ComfyUI Manager généré."

    # --- Génération Dockerfiles ---
    echo -e "  ${C_DIM}Génération des Dockerfiles...${C_RESET}"
    mkdir -p "$BASE_DIR/builders/n8n"
    cp "$BASE_DIR/templates/n8n.Dockerfile.template" "$BASE_DIR/builders/n8n/Dockerfile"
    cp "$BASE_DIR/templates/comfyui.Dockerfile.template" "$BASE_DIR/builders/comfyui/Dockerfile"
    log_ok "Dockerfiles générés."

    # --- Création de l'arborescence data/ (Préservé de v44.0) ---
    echo -e "  ${C_DIM}Création de l'arborescence des dossiers de données...${C_RESET}"
    # Créer les dossiers par défaut si aucun chemin personnalisé n'est défini
    if [[ -z "$SELECTED_COMFYUI_MODELS_HOST_PATH" ]]; then
        mkdir -p "$BASE_DIR/data/comfyui/models/checkpoints"
        mkdir -p "$BASE_DIR/data/comfyui/models/vae"
        mkdir -p "$BASE_DIR/data/comfyui/models/loras"
        mkdir -p "$BASE_DIR/data/comfyui/models/controlnet"
        mkdir -p "$BASE_DIR/data/comfyui/models/animatediff_models"
        mkdir -p "$BASE_DIR/data/comfyui/models/upscale_models"
        mkdir -p "$BASE_DIR/data/comfyui/models/gfpgan/weights"
    fi
    if [[ -z "$SELECTED_OLLAMA_HOST_PATH" ]]; then
        mkdir -p "$BASE_DIR/data/ollama"
    fi
    if [[ -z "$SELECTED_N8N_HOST_PATH" ]]; then
        mkdir -p "$BASE_DIR/data/n8n"
    fi

    mkdir -p "$BASE_DIR/data/comfyui/custom_nodes"
    mkdir -p "$BASE_DIR/data/comfyui/workflows"
    mkdir -p "$BASE_DIR/data/n8n/workflows"
    mkdir -p "$BASE_DIR/data/open-webui"
    mkdir -p "$BASE_DIR/data/ollama"
    mkdir -p "$BASE_DIR/shared-files" # Renommé de 'shared' pour éviter les conflits
    log_ok "Arborescence des dossiers de données créée."
}

# Synchronise les assets (plugins, modèles, workflows) en les téléchargeant ou en les copiant
function sync_all_assets() {
    log_header "PHASE 3 : SYNCHRONISATION DES ASSETS"
    ARIA_CMD="aria2c -c -x8 -s8 --max-connection-per-server=4 --console-log-level=warn --auto-file-renaming=false"

    # --- Plugins ComfyUI ---
    if [[ -n "$SELECTED_PLUGINS" ]]; then
        echo -e "  ${C_DIM}Synchronisation des plugins ComfyUI...${C_RESET}"
        for plugin_name in $SELECTED_PLUGINS; do
            plugin_url=${PLUGINS_GIT[$plugin_name]}
            repo_name=$(basename "$plugin_url" .git)
            target_dir="$BASE_DIR/data/comfyui/custom_nodes/$repo_name"
            if [ -d "$target_dir" ]; then
                (cd "$target_dir" && git pull &>/dev/null) && log_ok "$ICON_UPDATE Plugin '$plugin_name' mis à jour."
            else
                git clone --quiet --depth 1 "$plugin_url" "$target_dir" && log_ok "$ICON_DOWNLOAD Plugin '$plugin_name' cloné."
            fi
        done
    fi

    # --- Modèles et Workflows ---
    echo -e "  ${C_DIM}Synchronisation des modèles et workflows...${C_RESET}"
    declare -A ASSETS_TO_PROCESS
    # Parcourt tous les types d'assets définis dans config.sh
    for asset_type in CHECKPOINTS VAE CONTROLNET UPSCALE GFPGAN WAV2LIP LORAS CLIP WORKFLOWS_COMFYUI WORKFLOWS_N8N; do
        selected_assets_var_name="SELECTED_${asset_type}"
        assets_map_name="${asset_type}"
        
        if [[ -n "${!selected_assets_var_name}" ]]; then
            declare -n assets_map="$assets_map_name"
            for asset_name in ${!selected_assets_var_name}; do
                ASSETS_TO_PROCESS[${assets_map[$asset_name]}]="${asset_type}" # Store combined value and type
            done
        fi
    done

    # Exécute le téléchargement ou la copie pour chaque asset
    for asset_info in "${!ASSETS_TO_PROCESS[@]}"; do
        IFS='|' read -r asset_url asset_dest_path <<< "$asset_info"
        asset_type="${ASSETS_TO_PROCESS[$asset_info]}"
        full_dest_path="$BASE_DIR/data/$asset_dest_path"
        asset_basename="$(basename "$asset_dest_path")"

        if [ ! -f "$full_dest_path" ]; then
             echo -e "    $ICON_DOWNLOAD Téléchargement de '$asset_basename'..."
             mkdir -p "$(dirname "$full_dest_path")"
             if [[ "$asset_url" == file://* ]]; then
                local_file_path="${asset_url#file://}"
                if cp "$local_file_path" "$full_dest_path"; then
                    log_ok "Copié '$local_file_path' vers '$asset_basename'."
                else
                    log_warn "La copie de '$asset_basename' depuis '$local_file_path' a échoué."
                fi
             else
                if ! $ARIA_CMD -d "$(dirname "$full_dest_path")" -o "$asset_basename" "$asset_url"; then
                    if [[ "$asset_type" == WORKFLOWS_* ]]; then
                        log_warn "Le téléchargement du workflow '$asset_basename' a échoué."
                    else
                        log_error "Le téléchargement du modèle '$asset_basename' a échoué. Veuillez vérifier l'URL ou votre connexion."
                    fi
                else
                    log_ok "Asset '$asset_basename' téléchargé."
                fi
             fi
        else
            log_ok "Asset '$asset_basename' déjà présent."
        fi
    done

    log_ok "Synchronisation des assets terminée."
}

# Démarre la stack Docker
function launch_stack() {
    log_header "PHASE 4 : DÉMARRAGE DE LA STACK DOCKER"
    cd "$BASE_DIR"
    echo -e "  ${C_DIM}Construction et démarrage des conteneurs en arrière-plan...${C_RESET}"
    echo -e "  ${C_DIM}Cette opération peut prendre plusieurs minutes lors du premier lancement.${C_RESET}"
    docker compose up --build -d
    log_ok "Tous les services sélectionnés sont en cours de démarrage."
}

# Synchronise les modèles Ollama après le démarrage du service
function sync_ollama_models() {
    # Vérifier si ollama est dans la liste des services sélectionnés
    if [[ " $SELECTED_SERVICES " =~ " ollama " && -n "$SELECTED_MODELS_OLLAMA" ]]; then
        log_header "PHASE 5 : SYNCHRONISATION DES MODÈLES OLLAMA"
        echo -e "  ${C_DIM}Attente de la disponibilité du service Ollama...${C_RESET}"
        
        local spinner_chars=("-" "\\" "|" "/")
        local i=0
        TIMEOUT=300; SECONDS=0
        while [[ "$(docker inspect -f '{{.State.Health.Status}}' ollama 2>/dev/null)" != "healthy" ]]; do
            if [ $SECONDS -ge $TIMEOUT ]; then log_error "Timeout atteint en attendant Ollama."; fi
            printf "\r  ${C_YELLOW}%s${C_RESET} Attente... (%ds)" "${spinner_chars[$((i++ % 4))]}" "$SECONDS"
            sleep 1; SECONDS=$((SECONDS + 1))
        done
        printf "\r"; log_ok "Service Ollama opérationnel.                      "

        for model_key in $SELECTED_MODELS_OLLAMA; do
            model_source=${OLLAMA_MODELS[$model_key]}
            model_name=$(basename "$model_source" .gguf) # Extrait le nom du modèle pour l'importation

            if [[ "$model_source" == http* ]]; then # C'est une URL directe (GGUF)
                local temp_gguf_path="$BASE_DIR/data/ollama/temp_gguf/$(basename "$model_source")"
                mkdir -p "$(dirname "$temp_gguf_path")"
                
                echo -e "  $ICON_DOWNLOAD Téléchargement du modèle GGUF '$model_key'..."
                if ! aria2c -d "$(dirname "$temp_gguf_path")" -o "$(basename "$temp_gguf_path")" "$model_source"; then
                    log_warn "Le téléchargement du GGUF '$model_key' a échoué."
                    continue
                fi
                
                echo -e "  $ICON_BRAIN Importation du modèle GGUF '$model_key' dans Ollama..."
                # Utilise le nom du fichier GGUF comme nom de modèle pour l'importation
                if ! docker exec ollama ollama run --import "$(basename "$model_source" .gguf)" "/root/.ollama/temp_gguf/$(basename "$model_source")"; then
                    log_warn "L'importation du GGUF '$model_key' a échoué."
                else
                    log_ok "$ICON_BRAIN Modèle GGUF '$model_key' importé."
                fi
                rm -f "$temp_gguf_path" # Nettoyer le fichier temporaire
            else # C'est un nom de modèle Ollama standard
                if ! docker exec ollama ollama list 2>/dev/null | grep -q "^${model_source%%:*}"; then
                    echo -e "  $ICON_DOWNLOAD Téléchargement du modèle Ollama: ${C_BOLD}$model_key${C_RESET}"
                    if ! docker exec ollama ollama pull "$model_source"; then
                        log_warn "Le téléchargement de '$model_key' a échoué."
                    else
                        log_ok "$ICON_BRAIN Modèle '$model_key' installé."
                    fi
                else
                    log_ok "$ICON_BRAIN Modèle '$model_key' déjà présent."
                fi
            fi
        done
    fi
}

# Vérifie les dépendances de ComfyUI après le démarrage du service
function verify_comfyui_dependencies() {
    # Vérifier si comfyui est dans la liste des services sélectionnés
    if [[ " $SELECTED_SERVICES " =~ " comfyui " ]]; then
        log_header "PHASE 6 : VÉRIFICATION POST-DÉMARRAGE DE COMFYUI"
        echo -e "  ${C_DIM}Attente que ComfyUI soit pleinement opérationnel...${C_RESET}"
        local spinner_chars=("-" "\\" "|" "/")
        local i=0
        TIMEOUT=300; SECONDS=0
        while [[ "$(docker inspect -f '{{.State.Health.Status}}' comfyui 2>/dev/null)" != "healthy" ]]; do
            if [ $SECONDS -ge $TIMEOUT ]; then log_error "Timeout atteint en attendant ComfyUI."; fi
            printf "\r  ${C_YELLOW}%s${C_RESET} Attente... (%ds)" "${spinner_chars[$((i++ % 4))]}" "$SECONDS"
            sleep 1; SECONDS=$((SECONDS + 1))
        done
        printf "\r"; log_ok "Service ComfyUI opérationnel.                      "

        echo -e "\n${C_CYAN}${C_BOLD}--- Informations PyTorch dans ComfyUI ---${C_RESET}"
        docker exec comfyui python -c 'import torch; print(f"Torch: {torch.__version__}, CUDA: {torch.cuda.is_available()}")'
        log_ok "Vérification des dépendances ComfyUI terminée."
    fi
}

# --- FONCTIONS DE SÉLECTION INTERACTIVE POUR L'INSTALLATION PERSONNALISÉE ---

# Fonction pour demander les chemins d'hôte personnalisés
function select_custom_host_paths() {
    log_header "CHEMINS D'HÔTE PERSONNALISÉS"
    echo -e "  ${C_DIM}Vous pouvez spécifier des chemins absolus sur votre machine hôte pour stocker les données volumineuses.${C_RESET}"
    echo -e "  ${C_DIM}Laissez vide pour utiliser les chemins par défaut (./data/comfyui, ./data/ollama, ./data/n8n).${C_RESET}"

    read -p "  Chemin absolu pour les modèles ComfyUI (ex: /mnt/data/comfyui_models) : " input_comfyui_path
    if [[ -n "$input_comfyui_path" ]]; then
        SELECTED_COMFYUI_MODELS_HOST_PATH="$input_comfyui_path"
        log_ok "Chemin ComfyUI défini sur : $SELECTED_COMFYUI_MODELS_HOST_PATH"
    fi

    read -p "  Chemin absolu pour les données Ollama (ex: /mnt/data/ollama_data) : " input_ollama_path
    if [[ -n "$input_ollama_path" ]]; then
        SELECTED_OLLAMA_HOST_PATH="$input_ollama_path"
        log_ok "Chemin Ollama défini sur : $SELECTED_OLLAMA_HOST_PATH"
    fi

    read -p "  Chemin absolu pour les données n8n (ex: /mnt/data/n8n_data) : " input_n8n_path
    if [[ -n "$input_n8n_path" ]]; then
        SELECTED_N8N_HOST_PATH="$input_n8n_path"
        log_ok "Chemin n8n défini sur : $SELECTED_N8N_HOST_PATH"
    fi
}


# Fonction générique pour sélectionner des éléments à partir d'une map
# Args: 1=map_name (string), 2=prompt_message (string)
# Returns: space-separated list of selected keys
function _select_from_map() {
    local map_name=$1
    local prompt_message=$2
    local -n map_ref=$map_name # Nameref to access the associative array
    local keys=()
    local i=1

    # Collect keys and display them with numbers
    for key in "${!map_ref[@]}"; do
        keys+=("$key")
        echo -e "  ${C_CYAN}$((i++)))${C_RESET} $key"
    done

    local selection_valid=false
    local result_keys=()
    while ! $selection_valid; do
        echo -e "\n  ${C_DIM}Entrez les numéros des éléments à sélectionner (ex: 1 3 5), 'all' pour tout sélectionner, 'none' pour tout désélectionner, ou appuyez sur Entrée pour ignorer.${C_RESET}"
        read -p "$prompt_message : " selection

        result_keys=()
        selection_valid=true # Assume valid until proven otherwise

        if [[ "$selection" == "all" ]]; then
            result_keys=("${keys[@]}")
        elif [[ "$selection" == "none" ]]; then
            result_keys=()
        elif [[ -z "$selection" ]]; then # Empty input, means skip
            result_keys=()
        else
            # Validate each part of the input
            for num_str in $selection; do
                if ! [[ "$num_str" =~ ^[0-9]+$ ]]; then # If not a number
                    log_warn "Entrée invalide: '$num_str' (pas un nombre). Veuillez réessayer."
                    selection_valid=false
                    break # Exit inner loop, re-prompt
                fi

                local num=$((num_str))
                if (( num <= 0 || num > ${#keys[@]} )); then # If out of range
                    log_warn "Numéro invalide: $num_str (hors de portée). Veuillez réessayer."
                    selection_valid=false
                    break # Exit inner loop, re-prompt
                fi
                result_keys+=("${keys[$((num-1))]}")
            done
        fi
    done # End while ! $selection_valid
    echo "${result_keys[@]}"
}

function select_services() {
    log_header "SÉLECTION DES SERVICES DOCKER"
    local all_services_map=(
        [ollama]="Ollama (Modèles de Langage)"
        [open-webui]="Open WebUI (Interface Chat IA)"
        [comfyui]="ComfyUI (Génération Image/Vidéo)"
        [n8n]="n8n (Automatisation)"
        [postgres]="PostgreSQL (Base de données pour n8n)"
        [redis]="Redis (Cache/Queue pour n8n)"
    )
    local selected_str=$(_select_from_map "all_services_map" "Services à activer")
    SELECTED_SERVICES="$selected_str"
}

function select_ollama_models() {
    log_header "SÉLECTION DES MODÈLES OLLAMA"
    local selected_str=$(_select_from_map "OLLAMA_MODELS" "Modèles Ollama à télécharger")
    SELECTED_MODELS_OLLAMA="$selected_str"
}

function select_comfyui_checkpoints() {
    log_header "SÉLECTION DES CHECKPOINTS COMFYUI"
    local selected_str=$(_select_from_map "MODELS_CHECKPOINTS" "Checkpoints ComfyUI à télécharger")
    SELECTED_MODELS_CHECKPOINTS="$selected_str"
}

function select_comfyui_vae() {
    log_header "SÉLECTION DES VAE COMFYUI"
    local selected_str=$(_select_from_map "MODELS_VAE" "VAE ComfyUI à télécharger")
    SELECTED_MODELS_VAE="$selected_str"
}

function select_comfyui_controlnet() {
    log_header "SÉLECTION DES CONTROLNET COMFYUI"
    local selected_str=$(_select_from_map "MODELS_CONTROLNET" "ControlNet ComfyUI à télécharger")
    SELECTED_MODELS_CONTROLNET="$selected_str"
}

function select_comfyui_upscale() {
    log_header "SÉLECTION DES MODÈLES UPSCALE COMFYUI"
    local selected_str=$(_select_from_map "MODELS_UPSCALE" "Modèles Upscale ComfyUI à télécharger")
    SELECTED_MODELS_UPSCALE="$selected_str"
}

function select_comfyui_gfpgan() {
    log_header "SÉLECTION DES MODÈLES GFPGAN COMFYUI"
    local selected_str=$(_select_from_map "MODELS_GFPGAN" "Modèles GFPGAN ComfyUI à télécharger")
    SELECTED_MODELS_GFPGAN="$selected_str"
}

function select_comfyui_wav2lip() {
    log_header "SÉLECTION DES MODÈLES WAV2LIP COMFYUI"
    local selected_str=$(_select_from_map "MODELS_WAV2LIP" "Modèles Wav2Lip ComfyUI à télécharger")
    SELECTED_MODELS_WAV2LIP="$selected_str"
}

function select_comfyui_loras() {
    log_header "SÉLECTION DES LORAS COMFYUI"
    local selected_str=$(_select_from_map "MODELS_LORAS" "LoRAs ComfyUI à télécharger")
    SELECTED_MODELS_LORAS="$selected_str"
}

function select_comfyui_plugins() {
    log_header "SÉLECTION DES PLUGINS COMFYUI"
    local selected_str=$(_select_from_map "PLUGINS_GIT" "Plugins ComfyUI à cloner/mettre à jour")
    SELECTED_PLUGINS="$selected_str"
}

function select_comfyui_workflows() {
    log_header "SÉLECTION DES WORKFLOWS COMFYUI"
    local selected_str=$(_select_from_map "WORKFLOWS_COMFYUI" "Workflows ComfyUI à installer")
    SELECTED_WORKFLOWS_COMFYUI="$selected_str"
}

function select_n8n_workflows() {
    log_header "SÉLECTION DES WORKFLOWS N8N"
    local selected_str=$(_select_from_map "WORKFLOWS_N8N" "Workflows n8n à installer")
    SELECTED_WORKFLOWS_N8N="$selected_str"
}

# Met à jour les plugins Git et re-télécharge les modèles
function _update_plugins() {
    echo -e "  ${C_DIM}Mise à jour des plugins ComfyUI...${C_RESET}"
    for plugin_name in "${!PLUGINS_GIT[@]}"; do
        plugin_url=${PLUGINS_GIT[$plugin_name]}
        repo_name=$(basename "$plugin_url" .git)
        target_dir="$BASE_DIR/data/comfyui/custom_nodes/$repo_name"
        if [ -d "$target_dir" ]; then
            (cd "$target_dir" && git pull &>/dev/null) && log_ok "$ICON_UPDATE Plugin '$plugin_name' mis à jour."
        else
            log_warn "Plugin '$plugin_name' non trouvé localement, ignoré pour la mise à jour."
        fi
    done
}

function _update_all_models() {
    echo -e "  ${C_DIM}Re-vérification et téléchargement de TOUS les modèles définis...${C_RESET}"
    # Sauvegarder les sélections actuelles pour les restaurer après la mise à jour
    local _temp_SELECTED_MODELS_CHECKPOINTS="$SELECTED_MODELS_CHECKPOINTS"
    local _temp_SELECTED_MODELS_VAE="$SELECTED_MODELS_VAE"
    local _temp_SELECTED_MODELS_CONTROLNET="$SELECTED_MODELS_CONTROLNET"
    local _temp_SELECTED_MODELS_UPSCALE="$SELECTED_MODELS_UPSCALE"
    local _temp_SELECTED_MODELS_GFPGAN="$SELECTED_MODELS_GFPGAN"
    local _temp_SELECTED_MODELS_WAV2LIP="$SELECTED_MODELS_WAV2LIP"
    local _temp_SELECTED_MODELS_LORAS="$SELECTED_MODELS_LORAS"

    # Sélectionner tous les modèles pour la mise à jour (force le re-téléchargement si besoin)
    SELECTED_MODELS_CHECKPOINTS="${!MODELS_CHECKPOINTS[@]}"
    SELECTED_MODELS_VAE="${!MODELS_VAE[@]}"
    SELECTED_MODELS_CONTROLNET="${!MODELS_CONTROLNET[@]}"
    SELECTED_MODELS_UPSCALE="${!MODELS_UPSCALE[@]}"
    SELECTED_MODELS_GFPGAN="${!MODELS_GFPGAN[@]}"
    SELECTED_MODELS_WAV2LIP="${!MODELS_WAV2LIP[@]}"
    SELECTED_MODELS_LORAS="${!MODELS_LORAS[@]}"

    sync_all_assets # Appelle la fonction de synchronisation qui gère la reprise

    # Restaurer les sélections originales pour ne pas affecter un déploiement ultérieur
    SELECTED_MODELS_CHECKPOINTS="$_temp_SELECTED_MODELS_CHECKPOINTS"
    SELECTED_MODELS_VAE="$_temp_SELECTED_MODELS_VAE"
    SELECTED_MODELS_CONTROLNET="$_temp_SELECTED_MODELS_CONTROLNET"
    SELECTED_MODELS_UPSCALE="$_temp_SELECTED_MODELS_UPSCALE"
    SELECTED_MODELS_GFPGAN="$_temp_SELECTED_MODELS_GFPGAN"
    SELECTED_MODELS_WAV2LIP="$_temp_SELECTED_MODELS_WAV2LIP"
    SELECTED_MODELS_LORAS="$_temp_SELECTED_MODELS_LORAS"
}

function handle_asset_update() {
    log_header "MISE À JOUR DES ASSETS"
    echo -e "\n  ${C_BOLD}Que souhaitez-vous mettre à jour ?${C_RESET}"
    echo -e "  1) ${C_GREEN}Plugins ComfyUI${C_RESET} (git pull sur les dépôts existants)"
    echo -e "  2) ${C_GREEN}Modèles ComfyUI${C_RESET} (re-vérifie et télécharge TOUS les modèles définis dans config.sh)"
    echo -e "  3) ${C_GREEN}Les deux${C_RESET}"
    echo -e "0) ${C_YELLOW}Annuler${C_RESET}"
    read -p "Votre choix : " update_choice

    case $update_choice in
        1) _update_plugins ;;
        2) _update_all_models ;;
        3) _update_plugins; _update_all_models ;;
        0) log_ok "Mise à jour annulée."; return ;;
        *) log_warn "Choix invalide. Annulation de la mise à jour."; return ;;
    esac
    log_ok "Mise à jour des assets terminée."
}

# --- FONCTIONS DE GESTION DE L'ESPACE DISQUE DOCKER ---
function handle_docker_cleanup() {
    log_header "GESTION DE L'ESPACE DISQUE DOCKER"
    echo -e "\n  ${C_BOLD}Quel type de nettoyage Docker souhaitez-vous effectuer ?${C_RESET}"
    echo -e "  1) ${C_GREEN}Nettoyer les images 'dangling'${C_RESET} (images sans tag ni conteneur associé)"
    echo -e "  2) ${C_GREEN}Nettoyer toutes les images inutilisées${C_RESET} (y compris les images non 'dangling')"
    echo -e "  3) ${C_GREEN}Nettoyer le système Docker (sauf volumes)${C_RESET} (conteneurs arrêtés, réseaux non utilisés, images inutilisées, cache de build)"
    echo -e "  4) ${C_RED}Nettoyer le système Docker COMPLET (avec volumes)${C_RESET} (ATTENTION: Supprime TOUTES les données non utilisées, y compris les volumes non montés !)"
    echo -e "0) ${C_YELLOW}Annuler${C_RESET}"
    read -p "Votre choix : " cleanup_choice

    case $cleanup_choice in
        1) docker image prune -f ;;
        2) docker image prune -a -f ;;
        3) docker system prune -f ;;
        4) docker system prune -a --volumes -f ;;
        0) log_ok "Nettoyage annulé."; return ;;
        *) log_warn "Choix invalide. Annulation du nettoyage."; return ;;
    esac
    log_ok "Nettoyage Docker terminé."
}

# --- FONCTIONS D'INSTALLATION WSL2 + NVIDIA CUDA TOOLKIT (v5 - Avec install Ubuntu) ---
function install_wsl_cuda() {
    log_header "ASSISTANT D'INSTALLATION WSL2 + ACCÈS GPU NVIDIA"
    echo -e "${C_BOLD}Ce processus va vérifier les composants essentiels pour l'accès GPU et proposer l'installation d'Ubuntu.${C_RESET}"
    echo -e "${C_YELLOW}ATTENTION : Ce processus peut modifier les paramètres de Windows et nécessite des droits admin.${C_RESET}"
    read -p "Appuyez sur Entrée pour commencer, ou Ctrl+C pour annuler."

    # --- ÉTAPE 1: Activation des fonctionnalités Windows ---
    log_header "ÉTAPE 1 : ACTIVER LES FONCTIONNALITÉS WINDOWS"
    echo -e "  ${C_DIM}Activation de 'VirtualMachinePlatform' et 'Microsoft-Windows-Subsystem-Linux'...${C_RESET}"
    if ! powershell.exe -Command "Get-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform" | grep -q "State\s*:\s*Enabled"; then
        powershell.exe -Command "Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -All -NoRestart"
        powershell.exe -Command "Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -All -NoRestart"
        echo -e "${C_YELLOW}Les fonctionnalités Windows ont été activées. Un redémarrage complet de votre PC est requis.${C_RESET}"
        read -p "Veuillez redémarrer votre ordinateur, puis relancez ce script. Appuyez sur Entrée pour quitter."
        exit 1
    else
        log_ok "Les fonctionnalités Windows nécessaires sont déjà activées."
    fi
    read -p "Appuyez sur Entrée pour continuer."

    # --- ÉTAPE 2: Installation & Mise à Jour de WSL2 / Ubuntu ---
    log_header "ÉTAPE 2 : INSTALLATION & MISE À JOUR DE WSL2 / UBUNTU"
    echo -e "  ${C_DIM}Vérification de l'installation de WSL et Ubuntu...${C_RESET}"
    if ! wsl.exe -l -q | grep -q "Ubuntu"; then
        echo -e "  ${C_YELLOW}Aucune distribution Ubuntu détectée dans WSL.${C_RESET}"
        read -p "Voulez-vous installer Ubuntu via WSL (recommandé) ? (y/n) " -n 1 -r; echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo -e "  ${C_DIM}Lancement de l'installation de WSL et Ubuntu. Suivez les instructions (création d'un utilisateur/mot de passe)...${C_RESET}"
            wsl.exe --install Ubuntu
            INSTALL_STATUS=$?
            if [[ $INSTALL_STATUS -ne 0 ]]; then
                log_error "Erreur lors de l'installation d'Ubuntu (code $INSTALL_STATUS). Tentative de réparation automatique..."
                # Appel d'un script PowerShell pour réparer WSL/Ubuntu
                powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "& {
                    Write-Output '--- Réparation WSL2/Ubuntu en cours ---'
                    wsl --shutdown
                    wsl --list --all | Select-String 'Ubuntu' | ForEach-Object { wsl --unregister \$_.ToString().Trim() }
                    dism.exe /online /disable-feature /featurename:Microsoft-Windows-Subsystem-Linux /norestart
                    dism.exe /online /disable-feature /featurename:VirtualMachinePlatform /norestart
                    dism.exe /online /disable-feature /featurename:Windows-Hypervisor-Platform /norestart
                    Write-Output 'Redémarrage recommandé après désactivation des features.'
                    Read-Host 'Appuyez sur Entrée après redémarrage pour continuer...'
                    dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
                    dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
                    dism.exe /online /enable-feature /featurename:Windows-Hypervisor-Platform /all /norestart
                    Write-Output 'Merci de redémarrer à nouveau pour finaliser la réparation.'
                    Read-Host 'Appuyez sur Entrée après redémarrage pour continuer...'
                    wsl --update
                    wsl --shutdown
                    wsl --install -d Ubuntu
                }"
                echo -e "${C_YELLOW}Une réparation a été lancée. Redémarrez votre PC si demandé, puis relancez ce script.${C_RESET}"
                exit 1
            fi
            log_ok "Installation de WSL/Ubuntu terminée."
        else
            log_error "L'installation a été refusée. Ubuntu est recommandé pour la suite du processus automatisé."
        fi
    else
        log_ok "Distribution Ubuntu trouvée. Mise à jour du noyau WSL..."
        wsl.exe --update
        log_ok "Noyau WSL mis à jour."
    fi
    read -p "Appuyez sur Entrée pour continuer."
}

# --- EXÉCUTION PRINCIPALE (Moteur Interactif) ---

# Variables globales pour stocker les sélections de l'utilisateur
SELECTED_SERVICES=""
SELECTED_PLUGINS=""
SELECTED_MODELS_OLLAMA=""
SELECTED_MODELS_CHECKPOINTS=""
SELECTED_MODELS_VAE=""
SELECTED_MODELS_CONTROLNET=""
SELECTED_MODELS_UPSCALE=""
SELECTED_MODELS_GFPGAN=""
SELECTED_MODELS_WAV2LIP=""
SELECTED_MODELS_LORAS=""
SELECTED_WORKFLOWS_COMFYUI=""
SELECTED_WORKFLOWS_N8N=""
SELECTED_COMFYUI_MODELS_HOST_PATH="" # Nouveau: Chemin personnalisé pour les modèles ComfyUI
SELECTED_OLLAMA_HOST_PATH=""         # Nouveau: Chemin personnalisé pour les données Ollama
SELECTED_N8N_HOST_PATH=""            # Nouveau: Chemin personnalisé pour les données n8n

function display_main_menu() {
    clear
    echo -e "${C_CYAN}${C_BOLD}J.A.M.Z.I. AI STACK - Framework de Déploiement v50.0${C_RESET}"
    echo -e "${C_DIM}---------------------------------------------------------${C_RESET}"
    echo -e "\n  ${C_BOLD}--- Packs Pré-configurés ---${C_RESET}"
    echo -e "  1) ${C_GREEN}IA Conversatonnelle${C_RESET} (Ollama + WebUI)"
    echo -e "  2) ${C_GREEN}Usine d'Automatisation${C_RESET} (n8n + BDD)"
    echo -e "  3) ${C_GREEN}Studio Créatif de Base${C_RESET} (Images SFW)"
    echo -e "  4) ${C_GREEN}Studio Vidéo Avancé (SFW)${C_RESET}"
    echo -e "  5) ${C_YELLOW}Atelier d'Images Photoréalistes (NSFW)${C_RESET}"
    echo -e "  6) ${C_RED}Studio Vidéo Complet (NSFW)${C_RESET}"
    echo -e "  7) ${C_BLUE}Déploiement Total${C_RESET}"
    echo -e "\n  ${C_BOLD}--- Options Avancées ---${C_RESET}"
    echo -e "  8) Installation Personnalisée"
    echo -e "  9) Mettre à jour les assets"
    echo -e "  10) Gérer l'espace disque Docker"
    echo -e "  11) Installer WSL2 + NVIDIA CUDA Toolkit"
    echo -e "  12) Arrêter et nettoyer l'environnement"
    echo -e "  0) Quitter"
    echo -e "${C_DIM}---------------------------------------------------------${C_RESET}"
    read -p "Votre choix : " main_choice
}

function main() {
    check_environment

    while true; do
        display_main_menu

        case $main_choice in
            1|2|3|4|5|6|7|8)
                # Reset selections for a new deployment choice
                SELECTED_SERVICES=""
                SELECTED_PLUGINS=""
                SELECTED_MODELS_OLLAMA=""
                SELECTED_MODELS_CHECKPOINTS=""
                SELECTED_MODELS_VAE=""
                SELECTED_MODELS_CONTROLNET=""
                SELECTED_MODELS_UPSCALE=""
                SELECTED_MODELS_GFPGAN=""
                SELECTED_MODELS_WAV2LIP=""
                SELECTED_MODELS_LORAS=""
                SELECTED_WORKFLOWS_COMFYUI=""
                SELECTED_WORKFLOWS_N8N=""
                SELECTED_COMFYUI_MODELS_HOST_PATH=""
                SELECTED_OLLAMA_HOST_PATH=""
                SELECTED_N8N_HOST_PATH=""

                case $main_choice in
                    1) # Pack 1: IA Conversatonnelle
                        SELECTED_SERVICES=$PACK_LLM_CORE_SERVICES
                        SELECTED_MODELS_OLLAMA=$PACK_LLM_CORE_MODELS_OLLAMA
                        ;;
                    2) # Pack 2: Usine d'Automatisation
                        SELECTED_SERVICES=$PACK_AUTOMATION_CORE_SERVICES
                        SELECTED_WORKFLOWS_N8N=$PACK_AUTOMATION_WORKFLOWS_N8N
                        ;;
                    3) # Pack 3: Studio Créatif de Base
                        SELECTED_SERVICES=$PACK_CREATIVE_BASE_SERVICES
                        SELECTED_PLUGINS=$PACK_CREATIVE_BASE_PLUGINS
                        SELECTED_MODELS_CHECKPOINTS=$PACK_CREATIVE_BASE_MODELS_CHECKPOINTS
                        SELECTED_MODELS_VAE=$PACK_CREATIVE_BASE_MODELS_VAE
                        SELECTED_MODELS_UPSCALE=$PACK_CREATIVE_BASE_MODELS_UPSCALE
                        SELECTED_MODELS_GFPGAN=$PACK_CREATIVE_BASE_MODELS_GFPGAN
                        ;;
                    4) # Pack 4: Studio Vidéo Avancé (SFW)
                        SELECTED_SERVICES=$PACK_VIDEO_ADVANCED_SFW_SERVICES
                        SELECTED_PLUGINS=$PACK_VIDEO_ADVANCED_SFW_PLUGINS
                        SELECTED_MODELS_CHECKPOINTS=$PACK_VIDEO_ADVANCED_SFW_MODELS_CHECKPOINTS
                        SELECTED_MODELS_VAE=$PACK_VIDEO_ADVANCED_SFW_MODELS_VAE
                        SELECTED_MODELS_CONTROLNET=$PACK_VIDEO_ADVANCED_SFW_MODELS_CONTROLNET
                        SELECTED_MODELS_UPSCALE=$PACK_VIDEO_ADVANCED_SFW_MODELS_UPSCALE
                        SELECTED_MODELS_GFPGAN=$PACK_VIDEO_ADVANCED_SFW_MODELS_GFPGAN
                        SELECTED_MODELS_WAV2LIP=$PACK_VIDEO_ADVANCED_SFW_MODELS_WAV2LIP
                        SELECTED_WORKFLOWS_COMFYUI=$PACK_VIDEO_ADVANCED_SFW_WORKFLOWS_COMFYUI
                        SELECTED_WORKFLOWS_N8N=$PACK_VIDEO_ADVANCED_SFW_WORKFLOWS_N8N
                        ;;
                    5) # Pack 5: Atelier d'Images Photoréalistes (NSFW)
                        log_warn "Vous avez sélectionné un pack contenant du contenu potentiellement NSFW. Veuillez confirmer que vous avez l'âge légal et que vous acceptez de télécharger ce type de contenu."
                        read -p "Confirmez-vous le téléchargement de contenu NSFW ? (y/n) " -n 1 -r; echo
                        if [[ ! $REPLY =~ ^[Yy]$ ]]; then log_warn "Déploiement du pack NSFW annulé."; continue; fi
                        SELECTED_SERVICES=$PACK_IMAGE_PHOTOREAL_NSFW_SERVICES
                        SELECTED_PLUGINS=$PACK_IMAGE_PHOTOREAL_NSFW_PLUGINS
                        SELECTED_MODELS_OLLAMA=$PACK_IMAGE_PHOTOREAL_NSFW_MODELS_OLLAMA
                        SELECTED_MODELS_CHECKPOINTS=$PACK_IMAGE_PHOTOREAL_NSFW_MODELS_CHECKPOINTS
                        SELECTED_MODELS_VAE=$PACK_IMAGE_PHOTOREAL_NSFW_MODELS_VAE
                        SELECTED_MODELS_UPSCALE=$PACK_IMAGE_PHOTOREAL_NSFW_MODELS_UPSCALE
                        SELECTED_MODELS_GFPGAN=$PACK_IMAGE_PHOTOREAL_NSFW_MODELS_GFPGAN
                        SELECTED_MODELS_LORAS=$PACK_IMAGE_PHOTOREAL_NSFW_MODELS_LORAS
                        SELECTED_WORKFLOWS_COMFYUI=$PACK_IMAGE_PHOTOREAL_NSFW_WORKFLOWS_COMFYUI
                        ;;
                    6) # Pack 6: Studio Vidéo Complet (NSFW)
                        log_warn "Vous avez sélectionné un pack contenant du contenu potentiellement NSFW. Veuillez confirmer que vous avez l'âge légal et que vous acceptez de télécharger ce type de contenu."
                        read -p "Confirmez-vous le téléchargement de contenu NSFW ? (y/n) " -n 1 -r; echo
                        if [[ ! $REPLY =~ ^[Yy]$ ]]; then log_warn "Déploiement du pack NSFW annulé."; continue; fi
                        SELECTED_SERVICES=$PACK_VIDEO_FULL_NSFW_SERVICES
                        SELECTED_PLUGINS=$PACK_VIDEO_FULL_NSFW_PLUGINS
                        SELECTED_MODELS_OLLAMA=$PACK_VIDEO_FULL_NSFW_MODELS_OLLAMA
                        SELECTED_MODELS_CHECKPOINTS=$PACK_VIDEO_FULL_NSFW_MODELS_CHECKPOINTS
                        SELECTED_MODELS_VAE=$PACK_VIDEO_FULL_NSFW_MODELS_VAE
                        SELECTED_MODELS_CONTROLNET=$PACK_VIDEO_FULL_NSFW_MODELS_CONTROLNET
                        SELECTED_MODELS_UPSCALE=$PACK_VIDEO_FULL_NSFW_MODELS_UPSCALE
                        SELECTED_MODELS_GFPGAN=$PACK_VIDEO_FULL_NSFW_MODELS_GFPGAN
                        SELECTED_MODELS_WAV2LIP=$PACK_VIDEO_FULL_NSFW_MODELS_WAV2LIP
                        SELECTED_MODELS_LORAS=$PACK_VIDEO_FULL_NSFW_MODELS_LORAS
                        SELECTED_WORKFLOWS_COMFYUI=$PACK_VIDEO_FULL_NSFW_WORKFLOWS_COMFYUI
                        SELECTED_WORKFLOWS_N8N=$PACK_VIDEO_FULL_NSFW_WORKFLOWS_N8N
                        ;;
                    7) # Pack 7: Déploiement Total
                        log_warn "Vous avez sélectionné le pack de déploiement TOTAL, qui inclut du contenu potentiellement NSFW. Veuillez confirmer que vous avez l'âge légal et que vous acceptez de télécharger ce type de contenu."
                        read -p "Confirmez-vous le téléchargement de contenu NSFW ? (y/n) " -n 1 -r; echo
                        if [[ ! $REPLY =~ ^[Yy]$ ]]; then log_warn "Déploiement du pack TOTAL annulé."; continue; fi
                        SELECTED_SERVICES=$PACK_FULL_MONTY_SERVICES
                        SELECTED_PLUGINS=$PACK_FULL_MONTY_PLUGINS
                        SELECTED_MODELS_OLLAMA=$PACK_FULL_MONTY_MODELS_OLLAMA
                        SELECTED_MODELS_CHECKPOINTS=$PACK_FULL_MONTY_MODELS_CHECKPOINTS
                        SELECTED_MODELS_VAE=$PACK_FULL_MONTY_MODELS_VAE
                        SELECTED_MODELS_CONTROLNET=$PACK_FULL_MONTY_MODELS_CONTROLNET
                        SELECTED_MODELS_UPSCALE=$PACK_FULL_MONTY_MODELS_UPSCALE
                        SELECTED_MODELS_GFPGAN=$PACK_FULL_MONTY_MODELS_GFPGAN
                        SELECTED_MODELS_WAV2LIP=$PACK_FULL_MONTY_MODELS_WAV2LIP
                        SELECTED_MODELS_LORAS=$PACK_FULL_MONTY_MODELS_LORAS
                        SELECTED_WORKFLOWS_COMFYUI=$PACK_FULL_MONTY_WORKFLOWS_COMFYUI
                        SELECTED_WORKFLOWS_N8N=$PACK_FULL_MONTY_WORKFLOWS_N8N
                        ;;
                    8) # Installation Personnalisée
                        select_custom_host_paths
                        select_services
                        select_ollama_models
                        select_comfyui_plugins
                        select_comfyui_checkpoints
                        select_comfyui_vae
                        select_comfyui_controlnet
                        select_comfyui_upscale
                        select_comfyui_gfpgan
                        select_comfyui_wav2lip
                        select_comfyui_loras
                        select_comfyui_workflows
                        select_n8n_workflows
                        ;;
                esac
                break # Exit the main menu loop to proceed with deployment
                ;;
            9) # Mettre à jour les assets
                handle_asset_update
                ;;
            10) # Gérer l'espace disque Docker
                handle_docker_cleanup
                ;;
            11) # Installer WSL2 + NVIDIA CUDA Toolkit
                install_wsl_cuda
                ;;
            12) # Arrêter et nettoyer l'environnement
                cd "$BASE_DIR" && docker compose down --remove-orphans
                log_ok "Environnement Docker arrêté et nettoyé."
                exit 0
                ;;
            0) # Quitter
                echo "Opération annulée." && exit 0
                ;;
            *) # Choix invalide
                log_warn "Choix invalide. Veuillez réessayer."
                ;;
        esac
    done

    log_header "RÉCAPITULATIF DE L'INSTALLATION"
    echo -e "  ${C_BOLD}Services :${C_RESET} ${SELECTED_SERVICES:-aucun}"
    echo -e "  ${C_BOLD}Plugins :${C_RESET} ${SELECTED_PLUGINS:-aucun}"
    echo -e "  ${C_BOLD}Modèles Ollama :${C_RESET} ${SELECTED_MODELS_OLLAMA:-aucun}"
    echo -e "  ${C_BOLD}Checkpoints :${C_RESET} ${SELECTED_MODELS_CHECKPOINTS:-aucun}"
    echo -e "  ${C_BOLD}VAE :${C_RESET} ${SELECTED_MODELS_VAE:-aucun}"
    echo -e "  ${C_BOLD}ControlNet :${C_RESET} ${SELECTED_MODELS_CONTROLNET:-aucun}"
    echo -e "  ${C_BOLD}Upscale :${C_RESET} ${SELECTED_MODELS_UPSCALE:-aucun}"
    echo -e "  ${C_BOLD}GFPGAN :${C_RESET} ${SELECTED_MODELS_GFPGAN:-aucun}"
    echo -e "  ${C_BOLD}Wav2Lip :${C_RESET} ${SELECTED_MODELS_WAV2LIP:-aucun}"
    echo -e "  ${C_BOLD}LoRAs :${C_RESET} ${SELECTED_MODELS_LORAS:-aucun}"
    echo -e "  ${C_BOLD}Workflows ComfyUI :${C_RESET} ${SELECTED_WORKFLOWS_COMFYUI:-aucun}"
    echo -e "  ${C_BOLD}Workflows n8n :${C_RESET} ${SELECTED_WORKFLOWS_N8N:-aucun}"
    echo -e "  ${C_BOLD}Chemin Modèles ComfyUI (Hôte) :${C_RESET} ${SELECTED_COMFYUI_MODELS_HOST_PATH:-Défaut}"
    echo -e "  ${C_BOLD}Chemin Données Ollama (Hôte) :${C_RESET} ${SELECTED_OLLAMA_HOST_PATH:-Défaut}"
    echo -e "  ${C_BOLD}Chemin Données n8n (Hôte) :${C_RESET} ${SELECTED_N8N_HOST_PATH:-Défaut}"

    read -p "Lancer le déploiement avec cette configuration ? (y/n) " -n 1 -r; echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then echo -e "\n${C_YELLOW}Opération annulée par l'utilisateur.${C_RESET}"; exit 0; fi

    generate_all_files
    sync_all_assets
    launch_stack
    sync_ollama_models
    verify_comfyui_dependencies

    echo -e "${C_GREEN}${C_BOLD}\nL'ENVIRONNEMENT EST DÉPLOYÉ ET OPÉRATIONNEL${C_RESET}"
    echo -e "\n  ${C_BOLD}ACCÈS À VOS SERVICES :${C_RESET}"
    if [[ " $SELECTED_SERVICES " =~ " comfyui " ]]; then echo -e "  ${C_CYAN} → ${C_WHITE}ComfyUI (Image/Vidéo):${C_RESET} http://localhost:${COMFYUI_PORT}"; fi
    if [[ " $SELECTED_SERVICES " =~ " n8n " ]]; then echo -e "  ${C_CYAN} → ${C_WHITE}n8n (Automatisation):${C_RESET} http://localhost:${N8N_PORT}"; fi
    if [[ " $SELECTED_SERVICES " =~ " open-webui " ]]; then echo -e "  ${C_CYAN} → ${C_WHITE}Open WebUI (Langage):${C_RESET} http://localhost:${OPEN_WEBUI_PORT}"; fi

    echo -e "  ${C_BOLD}GESTION DES SERVICES :${C_RESET}"
    echo -e "  ${C_DIM}  Pour tout arrêter : ${C_WHITE}docker compose down${C_RESET}"
    echo -e "  ${C_DIM}  Pour relancer : ${C_WHITE}docker compose up -d${C_RESET}"
    echo -e "  ${C_DIM}  Pour voir les logs : ${C_WHITE}docker compose logs -f${C_RESET}"
}

main "$@"
