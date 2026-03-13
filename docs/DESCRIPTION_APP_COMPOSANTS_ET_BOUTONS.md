# CinePass — Description détaillée de l’application

## 1. Ce que tu as compris (à valider)

- **Le RESPONSABLE** crée et gère **ses** événements (concerts, théâtre, etc.) et **ses** structures sur la plateforme. Ce n’est **pas** l’admin qui crée les événements des responsables.
- **L’ADMIN** gère la plateforme au global : films, séances (cinéma), utilisateurs, réservations, statistiques, et **approuve ou rejette** les demandes « Devenir responsable ». Il ne crée pas les événements à la place des responsables.
- Les **événements** affichés sur la plateforme viennent de ce que les **responsables** (et éventuellement l’admin pour les films/séances) ont publié.

---

## 2. Rôles et responsabilités

| Rôle | Ce qu’il fait |
|------|----------------|
| **Client** | Consulte l’accueil, recherche avec filtres, réserve (film ou événement), a des billets, un profil. Peut demander à « Devenir responsable ». |
| **Responsable** | Une fois sa demande approuvée : se connecte avec **email professionnel + mot de passe** (saisis dans le formulaire « Devenir responsable »). Gère **ses structures**, crée/modifie/supprime **ses événements**, voit **les réservations** liées à ses événements. |
| **Admin** | Gère les **films** et **séances** (cinéma), consulte tous les **événements** (créés par les responsables), gère **utilisateurs**, **réservations**, **statistiques**, **demandes responsable** (approuver / rejeter). |

---

## 3. Parcours et écrans (détail des composants)

### 3.1 Partie publique (tout le monde)

#### A. AppBar (navbar en haut)

| Élément | Type | Comportement |
|--------|------|--------------|
| Logo CinePass | Clic | → Accueil |
| Lien « Événements » | Clic | → Page liste unifiée (films + événements) avec filtres |
| Icône Profil (si connecté) | Clic / survol | Menu ou lien vers Profil. **Au survol (tooltip)** : afficher aussi « Devenir responsable » (ou un second bouton dédié avec tooltip « Devenir responsable »). |
| Bouton « Devenir responsable » | IconButton ou TextButton + Tooltip | Visible **si connecté**. Tooltip : « Devenir responsable ». Clic → **Formulaire « Devenir responsable »** (page `/devenir-responsable`). |
| Connexion / Inscription | Si non connecté | Liens vers Connexion et Inscription |

#### B. Sidebar (drawer)

| Entrée | Action |
|--------|--------|
| Accueil | → `/` |
| Événements | → Page liste unifiée (même que navbar) |
| **Rechercher avec filtres** | → Même page Événements avec **panneau de filtres** ouvert (ou page dédiée Recherche). Filtres qui **s’adaptent au type** (voir § 3.1 C). |
| Mes billets | Si connecté → `/billets` |
| Profil | Si connecté → `/profil` |
| Devenir responsable | Si connecté → `/devenir-responsable` |
| Espace admin | Si admin → `/admin` |
| Espace responsable | Si responsable → `/responsable` |
| FAQ | → `/faq` |
| Support | → `/support` |

#### C. Page « Événements » (liste unifiée + recherche)

- **Contenu** : une seule liste (ou grille) avec **films** (séances) + **événements** (concerts, théâtre, etc.) publiés sur la plateforme. Option : badge par type (Film, Concert, Théâtre, etc.).
- **Panneau de filtres (avancés)** :
  - **Type d’événement** (obligatoire ou par défaut « Tous ») : Film, Concert, Théâtre, Festival, Autre (valeurs venant de la BDD, ex. `cine_pass_evenement.categorie` + type « film » pour les séances).
  - **Selon le type choisi**, les autres filtres s’adaptent :
    - **Si Film** : Ville (cinéma), Genre, Date (séance), Cinéma.
    - **Si Concert / Théâtre / etc.** : Ville, Lieu, Date, Catégorie.
  - **Lieu** : ville (liste ou autocomplete).
  - **Date** : date début / fin ou « À venir ».
  - **Recherche texte** : titre.
- **Boutons** : « Appliquer les filtres », « Réinitialiser ». Chaque carte/linge ouvre le détail (film ou événement) au clic.

#### D. Accueil

- **Une section** type « À l’affiche » ou « Événements » : affiche **tout** (films + événements) sans séparer « Films » / « Événements ». Possibilité d’un badge par type (Film, Concert, Théâtre…). Données = ce que les **responsables** (et la plateforme pour les films/séances) ont publié.

---

### 3.2 Formulaire « Devenir responsable »

- **Route** : `/devenir-responsable`.
- **Accès** : réservé aux utilisateurs **connectés**. Sinon redirection vers Connexion.
- **Règle** : l’utilisateur saisit un **email professionnel** et un **mot de passe** qu’il utilisera **plus tard pour se connecter à son espace responsable** (après approbation).

#### Composants du formulaire (exhaustif)

| Section | Champs | Type | Obligatoire | Remarque |
|---------|--------|------|-------------|----------|
| **Identifiants espace responsable** | Email professionnel | TextFormField, email | Oui | Utilisé pour la connexion à l’espace responsable après approbation. |
| | Mot de passe | TextFormField, mot de passe | Oui | Min. 8 caractères. |
| | Confirmer le mot de passe | TextFormField, mot de passe | Oui | Doit être égal au mot de passe. |
| **Structure** | Type de structure | Dropdown | Oui | CINEMA, VENUE, ORGANIZER, OTHER (libellés : Cinéma, Salle de spectacle, Organisateur, Autre). |
| | Nom de la structure | TextFormField | Oui | |
| | Ville | TextFormField | Oui | |
| | Adresse | TextFormField | Non | |
| | Site web | TextFormField, URL | Non | |
| | SIRET | TextFormField | Non | |
| | Téléphone | TextFormField, tel | Non | |
| **Contact** | Nom du contact | TextFormField | Non | |
| | Rôle dans la structure | TextFormField | Non | ex. Gérant, Programmateur |
| **Description** | Description / projet | TextFormField multiligne | Oui | Présentation, pourquoi vous. |
| | Liens réseaux sociaux | TextFormField multiligne | Non | URLs séparées par virgules ou retours à la ligne |

**Boutons** :
- **« Envoyer ma demande »** : envoi vers le backend (création demande avec hash du mot de passe), message de succès, redirection (ex. Accueil ou Profil). Message du type : « Vous pourrez vous connecter avec votre email professionnel et ce mot de passe une fois votre demande approuvée. »
- **« Annuler »** ou lien Retour : quitter sans envoyer.

**Base de données** : table `cine_pass_responsable_request` (+ colonnes `professional_email`, `password_hash` si migration faite). `user_id` = utilisateur connecté, `status` = 'PENDING'.

---

### 3.3 Connexion espace responsable

- **Route** : `/connexion-responsable` (lien depuis la page Connexion classique).
- **Champs** : **Email professionnel** (celui saisi dans « Devenir responsable »), **Mot de passe**.
- **Bouton** : « Accéder à mon espace responsable » → appel backend login responsable (mock ou réel) → si succès, `auth.isResponsable = true` et redirection vers `/responsable`.
- **Lien** : « Connexion classique » → page Connexion utilisateur.

---

### 3.4 Espace RESPONSABLE (c’est lui qui crée les événements)

**Layout** : scaffold avec **sidebar** (style vert / thème responsable) et zone de contenu.

#### Sidebar responsable

| Entrée | Route | Description |
|--------|--------|-------------|
| Tableau de bord | `/responsable` | Résumé : mes structures, mes événements, réservations. |
| Mes structures | `/responsable/structures` | Liste des structures qui lui sont affectées. |
| Mes événements | `/responsable/events` | Liste des **événements qu’il a créés** (ou de ses structures). |
| Réservations | `/responsable/reservations` | Réservations liées à **ses** événements (ou structures). |
| Retour à l’app | Clic | → Accueil app grand public. |

---

#### Page : Tableau de bord responsable (`/responsable`)

| Composant | Détail |
|-----------|--------|
| Titre | « Tableau de bord » |
| Message | « Bienvenue, [nom ou email] » (AuthState). |
| Cartes cliquables | **Mes structures** (lien vers `/responsable/structures`), **Mes événements** (vers `/responsable/events`), **Réservations** (vers `/responsable/reservations`). Chaque carte peut afficher un compteur (nombre de structures, d’événements, de réservations). |

---

#### Page : Mes structures (`/responsable/structures`)

| Composant | Détail |
|-----------|--------|
| Titre | « Mes structures » |
| Bouton | **« Ajouter une structure »** (si autorisé par la règle métier — sinon les structures viennent de l’approbation admin uniquement). |
| Liste | Pour chaque structure : **nom**, **type** (CINEMA / VENUE / ORGANIZER), **ville**, **adresse**. |
| Actions par ligne | **Modifier** (ouvre dialog ou page édition), éventuellement **Voir** (détail). Pas de suppression si la structure est liée à des événements ou à une demande approuvée (à définir). |

**Backend** : endpoint du type `getMyStructures(session)` (filtré par `user_id` via `cine_pass_responsable_assignment`).

---

#### Page : Mes événements (`/responsable/events`)

| Composant | Détail |
|-----------|--------|
| Titre | « Mes événements » |
| Bouton | **« Créer un événement »** → ouvre un formulaire (dialog ou page) pour créer un événement **lié à une de ses structures** (titre, catégorie, lieu, adresse, ville, date, heure, places, prix, etc.). |
| Liste | Pour chaque événement : **titre**, **catégorie**, **structure** (nom), **date/heure**, **places** (vendues / total), **ville**. |
| Actions par ligne | **Modifier** (éditer l’événement), **Supprimer** (avec confirmation). |

**Backend** : `getMyEvents(session)` (événements dont `structure_id` ∈ structures du responsable), `createEvent`, `updateEvent`, `deleteEvent` (avec vérification structure).

---

#### Page : Réservations responsable (`/responsable/reservations`)

| Composant | Détail |
|-----------|--------|
| Titre | « Réservations » |
| Liste | Réservations dont l’événement (ou la séance liée à sa structure) appartient au responsable : **numéro de résa**, **titre événement** (ou film/séance), **client** (email ou id), **nombre de billets**, **montant total**, **date**. |
| Actions | Optionnel : **Exporter**, **Filtrer par événement / date**. Pas de bouton « Créer » (les réservations viennent des clients). |

**Backend** : `getReservationsForMyStructures(session)` (réservations sur ses événements ou séances de ses cinémas).

---

### 3.5 Espace ADMIN (global)

**Layout** : scaffold avec **sidebar admin** (rouge / thème admin) et zone de contenu.

#### Sidebar admin

| Entrée | Route | Description |
|--------|--------|-------------|
| Tableau de bord | `/admin` | Vue d’ensemble : films, événements, séances, utilisateurs (compteurs). |
| Films | `/admin/films` | Liste des films (CRUD). |
| Séances | `/admin/seances` | Liste des séances (CRUD). |
| Événements | `/admin/events` | **Liste de tous les événements** de la plateforme (créés par les responsables + éventuellement admin). Lecture / modération possible ; pas forcément CRUD par l’admin si seul le responsable crée. |
| Utilisateurs | `/admin/users` | Liste utilisateurs, rôles, suspension. |
| Réservations | `/admin/reservations` | Toutes les réservations. |
| Rapport / Stats | `/admin/stats` | Statistiques (dates, CA, réservations, etc.). |
| **Demandes responsable** | `/admin/demandes` | Liste des demandes avec `status = 'PENDING'`, actions Approuver / Rejeter. |

---

#### Page : Tableau de bord admin (`/admin`)

| Composant | Détail |
|-----------|--------|
| Cartes | Films actifs, Événements à venir, Séances planifiées, Utilisateurs inscrits (compteurs). |
| Blocs | Derniers films, Prochains événements (liste courte). |

---

#### Page : Films admin (`/admin/films`)

| Composant | Détail |
|-----------|--------|
| Bouton | **« Nouveau film »** → dialog ou page **Ajouter un film** (titre, genre, durée, synopsis, réalisateur, casting, dates, audience, etc.). |
| Liste / tableau | Films avec colonnes : Titre, Genre, Durée, Synopsis (court), Réalisateur, Dates, Audience. |
| Actions par ligne | **Modifier**, **Supprimer** (avec confirmation). |

---

#### Page : Séances admin (`/admin/seances`)

| Composant | Détail |
|-----------|--------|
| Bouton | **« Nouvelle séance »** → dialog **Ajouter une séance** (film, cinéma, salle, date, heure, langue, type 2D/3D, prix). |
| Tableau | Film, Cinéma, Salle, Date/Heure, Langue, Type, Prix, Places (occupées / total). |
| Actions par ligne | **Modifier**, **Supprimer**. |

---

#### Page : Événements admin (`/admin/events`)

| Composant | Détail |
|-----------|--------|
| Contenu | **Liste de tous les événements** de la plateforme (créés par les **responsables**). Colonnes : Événement (titre), Catégorie, Structure (nom), Ville, Date/Heure, Prix, Places. |
| Actions | **Voir** (détail), éventuellement **Modifier** / **Désactiver** si l’admin a un rôle de modération. Pas de bouton « Créer un événement » si la règle est : seul le responsable crée ses événements. (Si tu veux que l’admin puisse aussi en créer, on ajoute « Nouvel événement ».) |

---

#### Page : Utilisateurs admin (`/admin/users`)

| Composant | Détail |
|-----------|--------|
| Cartes | Total utilisateurs, Admins, Actifs. |
| Tableau | Utilisateur (nom), Email, Rôle (client / responsable / admin), Statut, Date création. |
| Actions par ligne | **Permissions** (changer rôle), **Bloquer** / Débloquer, **Voir** (détail). |

---

#### Page : Réservations admin (`/admin/reservations`)

| Composant | Détail |
|-----------|--------|
| Tableau | N° résa, Utilisateur, Titre (film/événement), Lieu/Salle, Date séance, Billets, Montant, Statut, Date résa. |
| Filtres optionnels | Par date, par événement, par statut. |

---

#### Page : Rapport / Stats admin (`/admin/stats`)

| Composant | Détail |
|-----------|--------|
| Champs | **Date de début**, **Date de fin** (DatePicker). |
| Bouton | **« Générer le rapport »** → affichage de cartes / tableau (réservations, CA, films, événements sur la période). |

---

#### Page : Demandes responsable (`/admin/demandes`)

| Composant | Détail |
|-----------|--------|
| Titre | « Demandes responsable » |
| Liste | Demandes avec `status = 'PENDING'` : **nom structure**, **type** (CINEMA/VENUE/ORGANIZER), **ville**, **email demandeur** (ou email pro), **date demande**. |
| Actions par ligne | **Approuver** → crée `cine_pass_structure` + `cine_pass_responsable_assignment`, met la demande en APPROVED, `decided_at`, `admin_id`. **Rejeter** → ouvre champ **Motif de rejet**, puis met la demande en REJECTED, `rejection_reason`, `decided_at`, `admin_id`. |

---

## 4. Base de données (rappel)

- **Films / séances** : `cine_pass_film`, `cine_pass_seance`, `cine_pass_cinema`, `cine_pass_salle`, `cine_pass_siege`.
- **Événements** : `cine_pass_evenement` (avec `structure_id` optionnel → lié au responsable).
- **Réservations** : `cine_pass_reservation` (seance_id ou evenement_id), `cine_pass_billet`, `cine_pass_paiement`.
- **Responsables** : `cine_pass_responsable_request` (demande ; + `professional_email`, `password_hash` si migration), `cine_pass_structure`, `cine_pass_responsable_assignment` (user_id ↔ structure_id).
- **Rôles** : `cine_pass_user_role` (client | responsable | admin).

---

## 5. Récap à valider

- **Responsable** = crée et gère **ses** événements et **ses** structures ; connexion avec **email pro + mot de passe** (saisis dans « Devenir responsable »).
- **Admin** = gère films, séances, utilisateurs, réservations, stats, **demandes responsable** (approuver/rejeter) ; voit tous les événements mais ne les crée pas à la place des responsables (sauf si tu veux lui laisser la possibilité).
- **Accueil** = une seule section « À l’affiche » (films + événements), sans séparer Films / Événements.
- **Navbar** = bouton « Devenir responsable » en haut (avec tooltip au survol sur le profil ou sur le bouton).
- **Sidebar** = entrée « Rechercher avec filtres » → page Événements avec filtres qui **s’adaptent au type** (Film → genre, ville, date ; Concert/Théâtre → ville, lieu, date, catégorie).
- **Formulaire « Devenir responsable »** = exhaustif, avec **email pro**, **mot de passe**, **confirmation mot de passe**, puis structure, contact, description (comme dans le tableau § 3.2).

Dis-moi **OK** si tout correspond à ce que tu veux, ou indique les corrections (par page ou par bouton) et j’adapterai le doc et l’implémentation en conséquence.
