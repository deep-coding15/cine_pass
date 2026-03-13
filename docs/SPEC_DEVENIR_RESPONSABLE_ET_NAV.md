# Spec : bouton « Devenir responsable », formulaire, navigation et admin

## 1. Bouton « Devenir responsable »

### Emplacement
- **En haut** : dans la **AppBar** (navbar), à droite, visible quand l’utilisateur est **connecté** et **n’est pas déjà admin** (optionnel : afficher aussi pour admin).
- **Comportement au survol** : au passage du curseur (desktop) ou au long press (mobile), afficher un **tooltip** : *« Devenir responsable »*.
- **Comportement au clic** : ouvrir le **formulaire** « Devenir responsable » (page dédiée ou dialog).

### Composants
- **Widget** : `IconButton` ou `TextButton` avec icône (ex. `Icons.badge_outlined` ou `Icons.store_rounded`).
- **Tooltip** : `Tooltip(message: 'Devenir responsable', child: …)`.
- **Action** : navigation vers `/devenir-responsable` (page plein écran) **ou** ouverture d’un **bottom sheet / dialog** contenant le formulaire. La spec choisit une **page dédiée** pour garder un formulaire long lisible et accessible.

---

## 2. Formulaire « Devenir responsable »

### Règle métier
- Réservé aux utilisateurs **connectés** (client). Si non connecté, redirection vers Connexion.
- Une fois la demande envoyée, elle est enregistrée en base dans `cine_pass_responsable_request` avec `status = 'PENDING'`. Un admin pourra **Approuver** ou **Rejeter** plus tard.

### Champs (alignés sur la table `cine_pass_responsable_request`)

| Champ formulaire        | Attribut BDD              | Type   | Obligatoire | Remarque |
|-------------------------|---------------------------|--------|-------------|----------|
| Type de structure       | `structure_type`          | Liste  | Oui         | CINEMA, VENUE, ORGANIZER, OTHER |
| Nom de la structure     | `structure_name`          | Texte  | Oui         | |
| Ville                   | `structure_city`          | Texte  | Oui         | |
| Adresse                 | `structure_address`       | Texte  | Non         | |
| Site web                | `structure_website`       | URL    | Non         | |
| SIRET                   | `structure_siret`         | Texte  | Non         | |
| Téléphone               | `structure_phone`         | Tel    | Non         | |
| Votre rôle dans la structure | `contact_role`   | Texte  | Non         | ex. Gérant, Programmateur |
| Description / projet    | `description`             | Texte long | Oui    | Pourquoi vous, présentation |
| Liens réseaux sociaux   | `social_links`            | Texte  | Non         | URLs séparées par des virgules ou retours à la ligne |

`user_id` = utilisateur connecté (session).  
`status` = 'PENDING', `created_at` = now(). Les champs `decided_at`, `admin_id`, `rejection_reason` sont remplis plus tard par l’admin.

### Composants UI du formulaire
- **Titre** : « Devenir responsable d’événements ».
- **Sous-titre** : courte explication (ex. « Gérer les séances et événements de votre cinéma, salle ou structure. »).
- **Type de structure** : `DropdownButtonFormField<String>` (CINEMA, VENUE, ORGANIZER, OTHER) avec libellés français (Cinéma, Salle de spectacle, Organisateur, Autre).
- **Champs texte** : `TextFormField` avec validation (obligatoire pour nom, ville, description).
- **Description** : `TextFormField` multiligne (3–5 lignes).
- **Bouton** : « Envoyer ma demande » → envoi vers le backend (endpoint à créer) puis message de succès et redirection (ex. vers Profil ou Accueil).
- **Annuler** : lien ou bouton secondaire pour revenir en arrière sans envoyer.

### Base de données (rappel)
- Table **cine_pass_responsable_request** : id, user_id, structure_type, structure_name, structure_city, structure_address, structure_website, structure_siret, structure_phone, contact_role, description, social_links, status, created_at, decided_at, admin_id, rejection_reason.
- Aucune modification de schéma nécessaire pour ce formulaire.

---

## 3. Accueil : tout en « Événements » (sans différencier films / événements)

- Sur l’**accueil**, une seule section type **« À l’affiche »** ou **« Événements »** qui affiche **tout** : films (avec une séance ou le film comme « événement ») + événements (concerts, théâtre, etc.) publiés sur la plateforme.
- **Pas de séparation** visuelle « Films » vs « Événements » sur l’accueil : une seule liste (ou grille) avec éventuellement un **badge** par type (Film, Concert, Théâtre, etc.) pour information.
- Les données viennent de ce que les **responsables d’événement** (et l’admin) ont publié : films + séances en base, événements en base (avec `structure_id` si présent).

---

## 4. Navbar (AppBar) et Sidebar (drawer)

### Navbar
- **Une entrée « Événements »** (au lieu de Films + Événements séparés si on simplifie) **ou** garder **Films** et **Événements** mais la page « Événements » affiche tout (films + events) avec filtres. La spec retient : **une entrée « Événements »** dans la navbar qui mène vers la page de liste unifiée avec recherche et filtres.
- **Bouton « Devenir responsable »** : en haut à droite (quand connecté), avec tooltip « Devenir responsable ».

### Sidebar (drawer)
- **Accueil**, **Événements** (une seule entrée pour la liste unifiée), **Mes billets** (si connecté), **Profil** (si connecté), **Espace admin** (si admin), **Devenir responsable** (si connecté, optionnel en plus du bouton du haut), **FAQ**, **Support**.
- **Section « Rechercher »** : bloc dédié dans la sidebar avec **filtres avancés** :
  - **Type d’événement** : Film, Concert, Théâtre, Festival, Autre (ou liste dérivée de la BDD). Selon le type choisi, les **autres filtres s’adaptent** :
    - **Film** : genre, ville (cinéma), date, cinéma.
    - **Concert / Théâtre** : ville, lieu, date, catégorie.
  - **Lieu** : ville (liste ou champ texte).
  - **Date** : date début / fin ou « à venir ».
  - **Recherche texte** : titre.
- La section « Rechercher » peut être un **lien « Rechercher avec filtres »** qui mène vers la page **Événements** avec le panneau de filtres ouvert ou une page dédiée **Recherche**. Les filtres s’adaptent au **type d’événement** choisi (ex. après avoir choisi « Film », afficher genre, cinéma, date ; après « Concert », afficher lieu, date, catégorie).

### Base de données (filtres)
- **Films** : `cine_pass_film` (genre, etc.) + `cine_pass_seance` (debutAt, salleId) + `cine_pass_cinema` (ville).
- **Événements** : `cine_pass_evenement` (categorie, ville, eventDate, eventTime, structure_id).
- Pas de changement de schéma : on utilise les colonnes existantes pour filtrer (ville, genre, categorie, dates).

---

## 5. Espace Admin global

### Sections à avoir (alignées avec les cas d’utilisation)
- **Tableau de bord** (déjà présent).
- **Films** (CRUD / liste).
- **Séances** (CRUD / liste).
- **Événements** (CRUD / liste).
- **Utilisateurs** (liste, suspension, rôles).
- **Réservations** (liste toutes les réservations).
- **Rapport de statistiques** (déjà présent).
- **Demandes responsable** (nouveau) : liste des demandes avec `status = 'PENDING'`, actions **Approuver** / **Rejeter** (avec motif pour rejet). Après approbation : créer une entrée dans `cine_pass_structure` et une dans `cine_pass_responsable_assignment` (lien user_id + structure_id).

### Actions admin (rappel)
- Approuver une demande → créer Structure + Affectation responsable, mettre à jour la demande (status = 'APPROVED', decided_at, admin_id).
- Rejeter une demande → status = 'REJECTED', decided_at, admin_id, rejection_reason.
- Gérer films, séances, événements, utilisateurs, voir réservations, générer rapports.

### Base de données
- Tables déjà présentes : `cine_pass_responsable_request`, `cine_pass_structure`, `cine_pass_responsable_assignment`. Aucune modification de schéma requise pour cette spec.

---

## 6. Résumé des tâches implémentation

1. **Bouton + formulaire « Devenir responsable »**  
   - AppBar : bouton avec tooltip « Devenir responsable », visible si connecté.  
   - Route `/devenir-responsable` et page avec formulaire (tous les champs ci‑dessus).  
   - Backend : endpoint `createDemandeResponsable(session, body)` (à faire plus tard si pas encore présent).

2. **Navbar**  
   - Remplacer ou compléter par une entrée « Événements » (liste unifiée).  
   - Conserver le bouton « Devenir responsable » en haut.

3. **Sidebar**  
   - Une entrée « Événements » (liste unifiée).  
   - Une section « Rechercher » (lien vers page Événements avec filtres, ou page Recherche).  
   - Filtres avancés qui s’adaptent au type d’événement (Film → genre, ville, date ; Concert/Théâtre → ville, lieu, date).

4. **Accueil**  
   - Une seule section « Événements » ou « À l’affiche » : afficher films + événements dans une même liste (badge type si besoin).

5. **Admin**  
   - Nouvelle section **« Demandes responsable »** dans la sidebar admin.  
   - Nouvelle page **AdminDemandesPage** : liste des demandes PENDING, boutons Approuver / Rejeter (rejet avec champ motif).  
   - Backend : endpoints `getDemandesResponsableEnAttente(session)`, `approuverDemande(session, id)`, `rejeterDemande(session, id, motif)` (à faire si pas encore présents).

---

Tout est aligné avec la base actuelle (cine_pass_responsable_request, cine_pass_structure, cine_pass_responsable_assignment, cine_pass_film, cine_pass_seance, cine_pass_evenement, cine_pass_cinema).
