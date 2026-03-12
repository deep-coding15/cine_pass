import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Page admin : liste des demandes "Devenir responsable" (PENDING) avec actions Approuver / Rejeter.
/// TODO: brancher sur les endpoints backend getDemandesEnAttente, approuverDemande, rejeterDemande.
class AdminDemandesPage extends StatefulWidget {
  const AdminDemandesPage({super.key});

  @override
  State<AdminDemandesPage> createState() => _AdminDemandesPageState();
}

class _AdminDemandesPageState extends State<AdminDemandesPage> {
  bool _loading = true;
  final List<_MockDemande> _demandes = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() {
      _demandes.addAll([
        _MockDemande(
          id: '1',
          structureType: 'CINEMA',
          structureName: 'Cinéma Le Central',
          structureCity: 'Lyon',
          demandeurEmail: 'contact@lecentral.fr',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        _MockDemande(
          id: '2',
          structureType: 'VENUE',
          structureName: 'Salle des Fêtes',
          structureCity: 'Paris',
          demandeurEmail: 'salle@fetes.fr',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ]);
      _loading = false;
    });
  }

  void _approuver(String id) {
    // TODO: appeler backend approuverDemande(session, id)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Demande $id approuvée (mock).'),
        backgroundColor: AppTheme.accentGreen,
      ),
    );
    setState(() => _demandes.removeWhere((d) => d.id == id));
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
              onPressed: () {
                // TODO: appeler backend rejeterDemande(session, id, controller.text)
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Demande rejetée (mock).'),
                    backgroundColor: Colors.orange,
                  ),
                );
                setState(() => _demandes.removeWhere((d) => d.id == id));
              },
              style: FilledButton.styleFrom(backgroundColor: AppTheme.primaryRed),
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
                          Text(
                            d.demandeurEmail,
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

class _MockDemande {
  final String id;
  final String structureType;
  final String structureName;
  final String structureCity;
  final String demandeurEmail;
  final DateTime createdAt;

  _MockDemande({
    required this.id,
    required this.structureType,
    required this.structureName,
    required this.structureCity,
    required this.demandeurEmail,
    required this.createdAt,
  });
}
