@echo off
REM =============================================================================
REM CinePass — Reset complet du schéma métier + seed (base propre)
REM À lancer depuis cine_pass_server avec Docker qui tourne.
REM Usage: schema\reset_and_seed.cmd
REM =============================================================================

set CONTAINER=cine_pass_server-postgres-1
set DB=cine_pass
set USER=postgres

echo.
echo [1/3] Suppression des tables metier CinePass...
type schema\drop_cine_pass_tables.sql | docker exec -i %CONTAINER% psql -U %USER% -d %DB%
if errorlevel 1 (
    echo ERREUR: drop a echoue. Verifiez que Docker tourne et que le conteneur s appelle %CONTAINER%
    pause
    exit /b 1
)

echo.
echo [2/3] Creation du schema...
type schema\cine_pass_schema.sql | docker exec -i %CONTAINER% psql -U %USER% -d %DB%
if errorlevel 1 (
    echo ERREUR: schema a echoue.
    pause
    exit /b 1
)

echo.
echo [3/3] Insertion des donnees de test (seed)...
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
