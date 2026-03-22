@echo off
REM =============================================================================
REM CinePass — Reset complet du schéma métier + seed (base propre)
REM cine_pass_schema.sql inclut déjà le DROP (phase 0) puis la recréation.
REM À lancer depuis cine_pass_server avec Docker qui tourne.
REM Usage: schema\reset_and_seed.cmd
REM =============================================================================

set CONTAINER=cine_pass_server-postgres-1
set DB=cine_pass
set USER=postgres

echo.
echo [1/2] Drop + creation du schema (fichier unique cine_pass_schema.sql^)...
type schema\cine_pass_schema.sql | docker exec -i %CONTAINER% psql -U %USER% -d %DB%
if errorlevel 1 (
    echo ERREUR: schema a echoue. Verifiez Docker et le nom du conteneur %CONTAINER%
    pause
    exit /b 1
)

echo.
echo [2/2] Insertion des donnees de test (seed^)...
type schema\seed_data.sql | docker exec -i %CONTAINER% psql -U %USER% -d %DB%
if errorlevel 1 (
    echo ERREUR: seed a echoue.
    pause
    exit /b 1
)

echo.
echo OK — Base propre. Vous pouvez lancer le serveur :
echo   dart run bin/main.dart
echo.
pause
