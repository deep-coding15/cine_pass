# CinePass — Description de l’application, état actuel et suite

## 1. Description de l’application

**CinePass** est une application de **réservation de billets** pour :

- **Films** (séances en cinéma)  
- **Événements** (concerts, théâtre, spectacles, etc.)

Elle s’adresse à **4 types d’acteurs** :

| Acteur | Rôle |
|--------|------|
| **Visiteur** | Consulte films et événements, peut s’inscrire ou se connecter. |
| **Client** | Connecté : réserve, paie, consulte « Mes billets », favoris, profil. Peut demander à devenir responsable. |
| **Responsable d’événement** | Après approbation admin : gère une **structure** (cinéma, salle, organisateur), crée/modifie des événements et séances, définit options et tarifs, voit les réservations de sa structure. |
| **Administrateur global** | Gère utilisateurs, structures, événements, séances ; approuve ou rejette les **demandes de responsable** ; consulte réservations et rapports. |

**Flux principal (client)** :  
Consultation catalogue → Choix séance/événement → Sièges (film) / options (événement) → Type de billet et options → Paiement → **Réservation confirmée** → Billets visibles dans « Mes billets » (avec QR code).

**Règle métier** : une réservation n’est créée qu’**après paiement réussi** (statuts réservation : **confirmed** / **cancelled** uniquement).

---

## 2. Ce qui est déjà en place

### Backend (Serverpod)

- **Base de données** : schéma complet (films, cinémas, salles, sièges, séances, événements, réservations, billets, paiements, favoris, FAQ, rôles, **structures**, **demandes responsable**, **affectations responsable**).
- **Endpoints CinePass** : `getFilms`, `getFilmById`, `getSeancesForFilm`, `getCinemas`, `getEvents`, `getEventById`, `getCities`, `getGenres`, `getEventCategories`.
- **Auth Serverpod** : présent (email, JWT, etc.) mais **non utilisé** par le front pour la connexion réelle.

### Frontend (Flutter)

- **Catalogue** : accueil, liste films, liste événements, détail film, détail événement, **données venant du backend** (API).
- **Parcours de réservation (UI)** : choix séance → sièges (film) → type de billet + options → page paiement (formulaire carte) → page confirmation. **Aucun appel API** : tout est en état local (`ReservationState`), rien n’est enregistré en base.
- **Mes billets** : page avec **données mock** (`MockBilletsData`), pas d’appel API.
- **Auth** : écrans Connexion / Inscription, mais **auth mock** (`AuthState.loginAsUser` / `loginAsAdmin`), pas de vraie connexion Serverpod.
- **Profil, Préférences, FAQ, Support** : écrans présents.
- **Espace admin (UI)** : dashboard, films, séances, événements, utilisateurs, réservations, stats ; **données partiellement mock / partiellement API** (films/events depuis API). Pas de création réelle en base côté backend pour admin.
- **Pas d’espace Responsable** : pas d’écran « Demander à devenir responsable », pas d’« Espace responsable », pas de lien avec les structures.

---

## 3. Ce qui manque (à faire)

### Priorité 1 — Chaîne réservation → paiement → billets (réelle)

| Élément | Où | Détail |
|---------|-----|--------|
| **Créer réservation en BDD** | Backend | Endpoint (ou méthode) : après **paiement réussi**, créer une ligne dans `cine_pass_reservation` (statut `confirmed`), avec `user_id`, `seance_id` ou `evenement_id`, `numero`, `total_amount`, etc. |
| **Créer billets en BDD** | Backend | Après création de la réservation : insérer les lignes dans `cine_pass_billet` (une par place / type), avec options (parking, popcorn, boisson) et lien `reservation_id` (et `siege_id` si film). |
| **Enregistrer le paiement** | Backend | Insérer dans `cine_pass_paiement` (lien `reservation_id`, montant, méthode, statut `paid`). |
| **Appels depuis le front** | Flutter | Page paiement : après validation du formulaire (ou simulation succès), appeler le backend pour « confirmer paiement » → backend crée réservation + billets + paiement, retourne numéro de réservation (et éventuellement liste de billets). |
| **Mes billets depuis la BDD** | Backend + Flutter | Endpoint type `getBilletsByUser(session)` (avec auth) ; page « Mes billets » appelle cet endpoint et affiche les vrais billets (avec QR code basé sur `billet.id` ou numéro unique). |

Sans ça, l’app ne « persiste » aucune réservation ni aucun billet.

### Priorité 2 — Authentification réelle

| Élément | Où | Détail |
|---------|-----|--------|
| **Connexion / Inscription** | Flutter + Serverpod | Utiliser l’auth Serverpod (email + mot de passe) : appeler les endpoints d’inscription/connexion, stocker le token, exposer l’utilisateur connecté. |
| **Session et protection des écrans** | Flutter | Remplacer `AuthState` mock par l’état dérivé du token Serverpod ; exiger connexion pour Réservation, Mes billets, Profil, Admin (et plus tard Responsable). |
| **Rôle admin / responsable** | Backend + Flutter | S’appuyer sur `cine_pass_user_role` (et éventuellement `cine_pass_responsable_assignment`) pour exposer le rôle (client / admin / responsable) et afficher ou non l’espace admin / responsable. |

### Priorité 3 — Espace Responsable et demandes

| Élément | Où | Détail |
|---------|-----|--------|
| **Formulaire « Demander à devenir responsable »** | Flutter | Page ou modal : type de structure (cinéma, salle, organisateur), nom, ville, adresse, description, etc. → envoi au backend. |
| **Backend demandes** | Backend | Endpoints : `createDemandeResponsable(session, données)`, `getMesDemandesResponsable(session)`, `getDemandesEnAttente(session)` (admin), `approuverDemande(session, id)`, `rejeterDemande(session, id, motif)`. Persistance dans `cine_pass_responsable_request` et création de `cine_pass_structure` + `cine_pass_responsable_assignment` à l’approbation. |
| **Espace Responsable (UI)** | Flutter | Réservé aux utilisateurs ayant au moins une affectation responsable : tableau de bord, création/édition d’événements (et séances si cinéma), définition des options supplémentaires et tarifs, consultation des réservations de sa structure. |
| **Admin : gestion des demandes** | Flutter | Dans l’espace admin : liste des demandes « en attente », boutons Approuver / Rejeter avec motif. |

### Priorité 4 — Admin (CRUD réel)

| Élément | Où | Détail |
|---------|-----|--------|
| **Création / modification en BDD** | Backend | Endpoints (protégés admin) : créer/modifier/supprimer films, séances, événements, et éventuellement cinémas/salles. Les écrans admin appellent ces endpoints au lieu de mocks. |
| **Utilisateurs et rôles** | Backend + Flutter | Liste des utilisateurs (depuis Serverpod auth + `cine_pass_user_role`), suspension, attribution des rôles (admin / responsable). |
| **Rapports / stats** | Backend + Flutter | Endpoints pour statistiques (ventes, taux de remplissage, etc.) ; écran admin « Stats / Rapports » qui consomme ces données. |

### Priorité 5 — Détails et confort

- **Favoris** : persistance en BDD (déjà en schéma), endpoints + liaison depuis le front.
- **FAQ** : chargement depuis la BDD si ce n’est pas déjà fait.
- **Email de confirmation** : envoi d’un email après création de réservation (optionnel, selon temps disponible).

---

## 4. Par où commencer (ordre recommandé)

1. **Backend : chaîne réservation → billets**  
   - Un endpoint du type `confirmPayment(session, seanceId OU evenementId, siegesIds[], options[], montant, methode)` qui :  
     - vérifie que l’utilisateur est connecté ;  
     - crée la réservation (statut `confirmed`) ;  
     - crée les billets associés ;  
     - crée l’entrée paiement ;  
     - retourne numéro de réservation (+ liste billets si utile).  
   - Ne pas créer de réservation « en attente » : uniquement après paiement réussi (donc pas de statut `pending` côté réservation).

2. **Flutter : brancher le paiement sur le backend**  
   - Depuis la page Paiement, après « Paiement réussi » (réel ou simulé), appeler `confirmPayment` avec les infos déjà en `ReservationState`.  
   - Sur succès : afficher la page Confirmation avec le numéro retourné ; vider ou réinitialiser l’état de réservation.

3. **Backend : récupérer les billets de l’utilisateur**  
   - Endpoint `getBilletsByUser(session)` (ou `getReservationsWithBillets`) qui lit `cine_pass_reservation` + `cine_pass_billet` pour l’utilisateur connecté.

4. **Flutter : Mes billets depuis l’API**  
   - Remplacer `MockBilletsData` par l’appel à `getBilletsByUser` ; afficher les vrais billets et le QR code (ex. `CINEPASS-${billet.id}`).

5. **Authentification réelle**  
   - Brancher Connexion / Inscription sur Serverpod ; utiliser le token pour les appels protégés (réservation, billets, admin, responsable).  
   - Adapter le menu / la navigation selon le rôle (client / admin / responsable).

6. **Demandes responsable + espace responsable**  
   - Backend : endpoints demandes + approbation ; création structure et affectation à l’approbation.  
   - Flutter : formulaire « Devenir responsable », page « Mes demandes », puis espace responsable (tableau de bord, événements, options, tarifs, réservations).

7. **Admin : CRUD et demandes**  
   - Endpoints CRUD films/séances/événements (et utilisateurs si besoin).  
   - Flutter : écrans admin qui appellent ces endpoints ; écran de gestion des demandes responsable (liste, approuver, rejeter).

En résumé : **commencer par « réservation + billets + paiement réels » (backend + appels depuis la page paiement et Mes billets)**, puis **auth réelle**, puis **responsable et admin** en s’appuyant sur les tables déjà présentes (structures, demandes, affectations).

---

## 5. Résumé en une phrase

**CinePass** permet de consulter films et événements, de réserver et payer (après connexion), de voir ses billets (QR code), et prévoit un rôle **Responsable** (gestion de structures et d’événements après approbation admin) et un **Administrateur global** ; aujourd’hui, le catalogue et le parcours de réservation (UI) sont en place, mais **réservation, paiement et billets ne sont pas encore persistés**, l’**auth est en mock**, et l’**espace responsable + gestion des demandes** restent à développer — en commençant par la chaîne **paiement → création réservation/billets en BDD** et l’affichage **Mes billets** depuis l’API.
