@echo off
setlocal

:: ============================================================================
::  ADAPTATEUR DE LANCEMENT ROBUSTE pour deploy.sh - v2
:: ============================================================================
:: Ce script vérifie et demande les droits admin, trouve dynamiquement
:: l'installation de Git, et lance le script .sh dans un environnement
:: Git Bash correctement configuré.

:: --- Étape 1: Gestion de l'élévation de privilèges ---
:: Vérifie si le script a déjà été relancé avec les droits admin.
:: L'argument ':elevated' est ajouté lors du redémarrage pour éviter une boucle infinie.
if "%1"==":elevated" (
    goto :run_script
)

:: Vérifie les droits actuels. 'net session' échoue si pas admin.
net session >nul 2>&1
if %errorLevel% == 0 (
    goto :run_script
)

:: Si les droits sont manquants, relance ce même script en tant qu'administrateur
:: via PowerShell, en passant un argument pour éviter les boucles.
echo Demande des privileges administrateur...
powershell -Command "Start-Process -FilePath '%~f0' -ArgumentList ':elevated' -Verb RunAs"
exit /b


:: --- Étape 2: Exécution du script principal (uniquement si admin) ---
:run_script
:: Change le répertoire courant pour celui où se trouve le .bat
cd /d "%~dp0"

echo Privileges administrateur OK. Recherche de Git pour Windows...

:: --- Étape 3: Recherche dynamique de l'exécutable git-bash.exe ---
:: Cherche le chemin d'installation de Git dans le Registre Windows.
:: C'est la méthode la plus fiable, indépendante du dossier d'installation.
set "GIT_INSTALL_PATH="
for /f "tokens=2,*" %%a in ('reg query "HKLM\SOFTWARE\GitForWindows" /v "InstallPath" 2^>nul') do (
    set "GIT_INSTALL_PATH=%%b"
)
if not defined GIT_INSTALL_PATH (
    for /f "tokens=2,*" %%a in ('reg query "HKCU\SOFTWARE\GitForWindows" /v "InstallPath" 2^>nul') do (
        set "GIT_INSTALL_PATH=%%b"
    )
)

:: Vérifie si Git a été trouvé.
if not defined GIT_INSTALL_PATH (
    echo.
    echo ERREUR: Impossible de trouver le chemin d'installation de Git pour Windows.
    echo Veuillez vous assurer qu'il est bien installe sur votre systeme.
    goto :end
)

:: Construit le chemin complet vers git-bash.exe
set "GIT_BASH_EXE=%GIT_INSTALL_PATH%\bin\git-bash.exe"
if not exist "%GIT_BASH_EXE%" (
    set "GIT_BASH_EXE=%GIT_INSTALL_PATH%\git-bash.exe"
)

if not exist "%GIT_BASH_EXE%" (
    echo.
    echo ERREUR: git-bash.exe n'a pas ete trouve dans le repertoire d'installation de Git:
    echo %GIT_INSTALL_PATH%
    goto :end
)

echo Git Bash trouve : %GIT_BASH_EXE%
echo Lancement du script de deploiement...
echo ------------------------------------------------------------------

:: --- Étape 4: Lancement du script .sh dans son environnement dédié ---
:: Utilise git-bash.exe -c pour exécuter la commande. C'est crucial car cela
:: prépare le bon environnement (PATH, etc.) pour que le script .sh fonctionne.
:: La commande inclut une pause a la fin, geree par Bash, pour plus de fiabilite.
"%GIT_BASH_EXE%" -c "./deploy.sh; echo; echo '------------------------------------------------'; read -p 'Le script est termine. Appuyez sur Entree pour fermer cette fenetre...'"

goto :end


:end
echo.
endlocal