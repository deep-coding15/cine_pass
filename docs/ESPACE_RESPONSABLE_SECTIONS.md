# Espace Responsable — Sections et pages

## En place

- **Tableau de bord** : cartes Ma structure, Mes événements, Réservations (compteurs + navigation).
- **Ma structure** : affichage de la structure que le responsable représente (type "about us"), sans possibilité d’en ajouter une autre. Infos : nom, type, ville, adresse, site, téléphone, description.
- **Mes événements** : liste des événements du responsable, création / édition.
- **Réservations** : liste des réservations avec actions de gestion : **Voir détails**, **Voir les billets** (à brancher), **Gérer le statut** (annulation / remboursement à brancher), **Exporter PDF** (à brancher).

## À brancher côté backend

- `getMyStructure(session)` : renvoyer la structure assignée au responsable (via `cine_pass_responsable_assignment` + `cine_pass_structure`), ou les infos de la demande approuvée.
- `getReservationsForMyStructures(session)` : renvoyer les réservations des événements liés aux structures du responsable (événements dont `structureId` ∈ structures du responsable).

## Sections / pages éventuellement manquantes

| Section / page | Description | Priorité |
|----------------|-------------|----------|
| **Détail réservation (page dédiée)** | Page complète avec billets associés, statut, historique. Actuellement seul le bottom sheet "Voir détails" existe. | Moyenne |
| **Export PDF réservation** | Action "Exporter PDF" dans le détail réservation (billet / reçu). | Moyenne |
| **Modifier ma structure** | Édition limitée des infos "about us" (description, site, téléphone) sans changer la structure assignée. | Basse |
| **Statistiques responsable** | Chiffres (réservations par événement, taux de remplissage, CA). | Basse |
| **Paramètres espace responsable** | Notifications, préférences d’affichage. | Basse |

## Règles métier vérifiées

- Le responsable **ne peut pas ajouter** une structure différente de celle qu’il représente (pas de bouton "Ajouter une structure" sur Ma structure).
- Les **favoris événement** (cœur) ne s’affichent **que pour un utilisateur connecté** (détail événement).
- **Animations de fond** : appliquées sur l’app principale (`MainScaffold`), l’espace responsable (`ResponsableScaffold`) et l’espace admin (`AdminScaffold`) via `AnimatedBackground`.
