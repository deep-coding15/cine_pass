# Stratégie de monétisation — CinePass

## Modèle retenu : **Commission sur chaque réservation (pourcentage)**

La plateforme CinePass se rémunère en prélevant **un pourcentage du montant de chaque réservation** (billet ou total du panier). C’est le même type de modèle que Eventbrite, Ticketmaster, etc.

### Fonctionnement

- **Client** : paie le prix affiché du billet (ou le total de sa réservation).
- **Plateforme** : garde **X %** de ce montant comme commission.
- **Responsable / Structure** : reçoit le reste (prix du billet − commission CinePass).

### Taux de commission

- Le taux **X %** est configurable dans le backend.
- **Valeur par défaut** : **8 %** (définie dans `cine_pass_server/lib/src/cine_pass/cine_pass_endpoint.dart` → `cinePassCommissionPercent`).
- Ce taux peut être ajusté plus tard (par type d’événement, par structure, ou via configuration).

### Où l’appliquer dans le code

- **Backend** (au moment du traitement du paiement / de la validation de la réservation) :
  - Calculer : `commissionPlateforme = montantTotal × (tauxCommission / 100)`.
  - Enregistrer ce montant (pour stats, facturation, reversement au responsable).
- **Flutter** : pas besoin d’afficher le détail de la commission au client ; le prix affiché reste le prix payé par le client. Optionnel : dans l’espace responsable ou admin, afficher le montant net après commission.

### Résumé

| Acteur        | Rôle |
|---------------|------|
| **Client**    | Paie le prix du billet (TTC). |
| **CinePass**  | Prend X % sur chaque réservation. |
| **Responsable** | Reçoit le montant restant (vente − commission). |

Document créé le 2025-03 — à mettre à jour si le taux ou les règles évoluent.
