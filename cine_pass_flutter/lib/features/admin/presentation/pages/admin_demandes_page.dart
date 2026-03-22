import 'package:cine_pass_client/cine_pass_client.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../main.dart';

/// Page admin : liste des demandes "Devenir responsable" (PENDING) avec actions Approuver / Rejeter.
class AdminDemandesPage extends StatefulWidget {
  const AdminDemandesPage({super.key});

  @override
  State<AdminDemandesPage> createState() => _AdminDemandesPageState();
}

class _AdminDemandesPageState extends State<AdminDemandesPage> {
  bool _loading = true;
  List<DemandeResponsableResponse> _demandes = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final list = await client.cinePass.getDemandesEnAttente();
      if (!mounted) return;
      setState(() {
        _demandes = list;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _demandes = [];
        _loading = false;
      });
    }
  }

  Future<void> _approuver(String id) async {
    try {
      final ok = await client.cinePass.approuverDemande(id);
      if (!mounted) return;
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Demande approuvée.'),
            backgroundColor: AppTheme.accentGreen,
          ),
        );
        setState(() => _demandes.removeWhere((d) => d.id == id));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Échec de l\'approbation.')),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur réseau.')),
      );
    }
  }

  void _voirDetails(DemandeResponsableResponse d) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        title: Text(d.structureName),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 480,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _dLine('Type de structure', _labelType(d.structureType)),
                _dLine('Ville', d.structureCity),
                _dLine('Adresse', d.structureAddress),
                _dLine('Site web', d.structureWebsite),
                _dLine('SIRET', d.structureSiret),
                _dLine('Téléphone structure', d.structurePhone),
                _dLine('Rôle du contact', d.contactRole),
                _dLine('Description du projet', d.description),
                _dLine('Réseaux / liens', d.socialLinks),
                const Divider(height: 24),
                _dLine('Compte (email connexion)', d.userEmail),
                _dLine('Nom profil', d.userName),
                _dLine('Email pro (responsable)', d.professionalEmail),
                _dLine('ID utilisateur', d.userId),
                _dLine('Reçue le', d.createdAt),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _dLine(String label, String? value) {
    final v = (value ?? '').trim();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppTheme.textSecondary.withValues(alpha: 0.9),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 2),
          SelectableText(
            v.isEmpty ? '—' : v,
            style: const TextStyle(color: AppTheme.textPrimary),
          ),
        ],
      ),
    );
  }

  void _rejeter(String id) {
    showDialog(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController();
        return AlertDialog(
          backgroundColor: AppTheme.cardDark,
          title: const Text('Rejeter la demande'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Motif du rejet',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () async {
                final reason = controller.text.trim().isEmpty
                    ? 'Non précisé'
                    : controller.text.trim();
                Navigator.pop(ctx);
                try {
                  final ok = await client.cinePass.rejeterDemande(id, reason);
                  if (!mounted) return;
                  if (ok) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Demande rejetée.'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    setState(() => _demandes.removeWhere((d) => d.id == id));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Demande introuvable ou déjà traitée.',
                        ),
                      ),
                    );
                  }
                } catch (_) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Erreur réseau.')),
                  );
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primaryRed,
              ),
              child: const Text('Rejeter'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Demandes responsable',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Approuver ou rejeter les demandes pour devenir responsable d\'une structure.',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            if (_loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(color: AppTheme.primaryRed),
                ),
              )
            else if (_demandes.isEmpty)
              Card(
                color: AppTheme.cardDark,
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.inbox_rounded,
                          size: 64,
                          color: AppTheme.textSecondary.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Aucune demande en attente',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _demandes.length,
                itemBuilder: (context, index) {
                  final d = _demandes[index];
                  return Card(
                    color: AppTheme.cardDark,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      title: Text(
                        d.structureName,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            '${_labelType(d.structureType)} • ${d.structureCity}',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                          if ((d.userName ?? '').isNotEmpty)
                            Text(
                              d.userName!,
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            onPressed: () => _voirDetails(d),
                            child: const Text('Détails'),
                          ),
                          TextButton(
                            onPressed: () => _rejeter(d.id),
                            child: const Text('Rejeter'),
                          ),
                          const SizedBox(width: 8),
                          FilledButton(
                            onPressed: () => _approuver(d.id),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppTheme.accentGreen,
                            ),
                            child: const Text('Approuver'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  String _labelType(String type) {
    switch (type) {
      case 'CINEMA':
        return 'Cinéma';
      case 'VENUE':
        return 'Salle de spectacle';
      case 'ORGANIZER':
        return 'Organisateur';
      default:
        return type;
    }
  }
}
