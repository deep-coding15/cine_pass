# Checklist validation end-to-end — CinePass

À exécuter dans l’ordre après une installation propre ou avant une recette.

## 1. Environnement

- [ ] **PostgreSQL** démarré, base accessible (même URL que `cine_pass_server/config/development.yaml` ou équivalent).
- [ ] **Réinitialisation schéma** (si besoin d’une base clean) :
  - Exécuter `cine_pass_server/schema/drop_cine_pass_tables.sql` (ou script équivalent du dépôt).
  - Puis `cine_pass_server/schema/cine_pass_schema.sql` et migrations SQL complémentaires (`roles_sync_and_helpers.sql` si utilisé).
- [ ] **Ports libres** : API Serverpod (ex. 8080 selon config), ports internes (ex. 9080/9082) sans ancien `dartvm` bloquant.
- [ ] **Secrets** : `passwords.yaml` (JWT, SMTP si envoi d’e-mails réel, Google si OAuth).
- [ ] **Démarrer le serveur** : depuis `cine_pass_server`, `dart run bin/main.dart` (ou la commande habituelle du projet).
- [ ] **Flutter** : `flutter pub get` dans `cine_pass_flutter`, `dart run build_runner` si nécessaire ; l’URL client pointe vers l’API du serveur.
- [ ] Lancer l’app : `flutter run` (ou web) sur la cible voulue.

## 2. Comptes et rôles

- [ ] **Inscription + e-mail** : créer un compte utilisateur, vérifier la réception du code si SMTP configuré (sinon log serveur « SMTP non configuré »).
- [ ] **Connexion client** : accès catalogue événements, profil, Mes billets.
- [ ] **Devenir responsable** : soumettre une demande (structure, coordonnées). Vérifier qu’une seconde demande / doublon est refusé côté UX ou API selon les règles.
- [ ] **Admin** : se connecter avec un compte **admin** ; menu **Demandes** : la demande apparaît.
- [ ] **Approbation** : approuver la demande → le demandeur reçoit un **e-mail d’approbation** (ou entrée de log en dev sans SMTP). Le compte obtient l’accès **Espace responsable**.
- [ ] **Rejet** (optionnel) : avec une autre demande test, rejeter et vérifier le statut.

## 3. Parcours client (événement)

- [ ] Liste **Événements** / recherche : affichage des cartes.
- [ ] **Détail événement** : infos, favoris si connecté.
- [ ] **Réservation** :
  - Événement **SANS_SIEGES** : parcours jusqu’au paiement (simulé) et confirmation.
  - Événement **AVEC_SIEGES** :  avec plan valide, paiement et **attribution automatique** des sièges .
- [ ] **Mes billets** : la réservation apparaît avec QR / statut **payé**.

## 4. Annulation réservation (règle 2 h)

- [ ] **Plus de 2 h avant** l’événement : depuis Mes billets, **Annuler la réservation** → succès, statut annulé côté API.
- [ ] **Moins de 2 h avant** : le bouton / l’action ne doit pas permettre l’annulation ; le serveur doit refuser si appel direct.
- [ ] Vérifier les **wordings** (pas de promesse de remboursement réel si le backend ne fait qu’une annulation métier).

## 5. Espace responsable

- [ ] Connexion / navigation vers `/responsable` (ou flux « connexion responsable »).
- [ ] **Ma structure** : affichage / **mise à jour** des infos publiques (nom, ville, etc. selon écran).
- [ ] **Mes événements** : créer un événement (mode sièges + config réservation), **modifier**, **archiver** si prévu.
- [ ] **Plan de sièges** (AVEC_SIEGES) : édition, zones, sièges bloqués ; enregistrement OK.
- [ ] **Réservations** : liste des réservations des structures du responsable ; détail / mise à jour de statut si implémenté.
- [ ] **Rapports** : chargement du CA / période sans erreur ; export PDF si activé.
- [ ] **Pas de module « Réclamations »** : aucune entrée menu ni route vers une page réclamations.

## 6. Espace admin

- [ ] Liste **événements / structures** ; actions **bannir / supprimer structure** si prévu.
- [ ] **Demandes responsable** : liste, approbation / rejet.
- [ ] Accès **réservé** : un compte non-admin ne doit pas voir les endpoints admin.

## 7. Non-régression rapide

- [ ] Redémarrage app : splash / onboarding une seule fois selon règles.
- [ ] Déconnexion / reconnexion : rôles (client / responsable / admin) toujours cohérents.
- [ ] Logs serveur : pas d’exception non gérée sur les flux ci-dessus.

---

**Note e-mail approbation responsable** : l’envoi utilise la même configuration **SMTP** que l’auth (voir `email_idp_mailer.dart`). Sans `smtpHost` / `smtpPort` / `smtpUsername` / `smtpPassword` / `smtpFromEmail` dans les secrets, le serveur **journalise** un message d’avertissement à la place de l’envoi réel.
