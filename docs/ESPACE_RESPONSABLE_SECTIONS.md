# Espace Responsable — Sections et pages

## En place

- **Plan de sièges (événements AVEC_SIEGES)** : dans le détail d’un événement, édition du plan — grille type cinéma, zones (ex. `VIP`), sièges **bloqués**. Les clients ne choisissent pas manuellement : au paiement, le serveur attribue les sièges.
- **Tableau de bord** : indicateurs **30 derniers jours** (CA et nombre de réservations via l’API), compteurs événements / structure ; graphiques en barres et le bloc « par événement » sont des **aperçus visuels** — les totaux détaillés sont dans l’onglet **Rapports**.
- **Ma structure** : structure assignée au responsable ; **modification** des infos (nom, ville, adresse, site, téléphone, description selon API).
- **Mes événements** : liste des événements du responsable, **création / édition / archivage** ; chaque événement = une date et un lieu (pour une autre représentation, créer un nouvel événement).
- **Réservations** : réservations des événements des structures du responsable ; détails et gestion de statut côté API selon implémentation.
- **Rapports** : CA et réservations par période (`getRapportCA`), export PDF.
- **Réclamations** : **non géré** dans l’application (pas de page dédiée).

## Animations

- **AnimatedBackground** sur l’app principale (`MainScaffold`), l’espace responsable (`ResponsableScaffold`) et l’admin (`AdminScaffold`).

## Pistes d’évolution (hors périmètre actuel)

| Idée | Priorité |
|------|----------|
| Page dédiée « détail réservation » (billets, historique) | Moyenne |
| Export PDF réservation depuis la liste | Moyenne |
| Statistiques avancées (taux de remplissage, CA par événement réel dans le dashboard) | Basse |
| Paramètres espace responsable (notifications) | Basse |

## Règles métier rappel

- Un responsable **ne peut pas** ajouter une autre structure que celle qui lui est assignée.
- Les **favoris** événement (cœur) : **utilisateur connecté** uniquement.
- **Approbation « devenir responsable »** : e-mail transactionnel à l’utilisateur si SMTP configuré (sinon log serveur).
