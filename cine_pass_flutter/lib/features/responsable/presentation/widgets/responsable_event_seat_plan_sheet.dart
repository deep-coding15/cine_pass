import 'package:cine_pass_client/cine_pass_client.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../main.dart';

class _SeatDraft {
  _SeatDraft({
    required this.label,
    required this.rowIndex,
    required this.colIndex,
    this.blocked = false,
    this.zone = '',
  });

  String label;
  int rowIndex;
  int colIndex;
  bool blocked;
  String zone;
}

/// Éditeur du plan de sièges (événement AVEC_SIEGES).
Future<void> showResponsableEventSeatPlanSheet({
  required BuildContext context,
  required String eventId,
  VoidCallback? onSaved,
}) async {
  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => _ResponsableEventSeatPlanDialog(
      eventId: eventId,
      onSaved: onSaved,
    ),
  );
}

class _ResponsableEventSeatPlanDialog extends StatefulWidget {
  const _ResponsableEventSeatPlanDialog({
    required this.eventId,
    this.onSaved,
  });

  final String eventId;
  final VoidCallback? onSaved;

  @override
  State<_ResponsableEventSeatPlanDialog> createState() =>
      _ResponsableEventSeatPlanDialogState();
}

class _ResponsableEventSeatPlanDialogState
    extends State<_ResponsableEventSeatPlanDialog> {
  bool _loading = true;
  bool _saving = false;
  String? _error;
  final List<_SeatDraft> _drafts = [];
  final _freeTextController = TextEditingController();
  final _vipRowsController = TextEditingController(text: '2');

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _freeTextController.dispose();
    _vipRowsController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final plan = await client.cinePass.getEventSeatPlan(widget.eventId);
      if (!mounted) return;
      _drafts.clear();
      if (plan != null) {
        for (final s in plan.seats) {
          _drafts.add(
            _SeatDraft(
              label: s.label,
              rowIndex: s.rowIndex,
              colIndex: s.colIndex,
              blocked: s.blocked,
              zone: s.zone,
            ),
          );
        }
      }
      setState(() => _loading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = '$e';
      });
    }
  }

  void _applyClassicCinemaGrid() {
    final vipRows = int.tryParse(_vipRowsController.text.trim()) ?? 0;
    const aisleCols = {4, 9};
    _drafts.clear();
    for (var r = 0; r < 10; r++) {
      final letter = String.fromCharCode(65 + r);
      var colUi = 0;
      for (var c = 1; c <= 12; c++) {
        if (aisleCols.contains(c)) continue;
        final zone = r < vipRows ? 'VIP' : '';
        _drafts.add(
          _SeatDraft(
            label: '$letter$c',
            rowIndex: r,
            colIndex: colUi,
            blocked: false,
            zone: zone,
          ),
        );
        colUi++;
      }
    }
    setState(() {});
  }

  void _applyFreeText() {
    final lines = _freeTextController.text.split(RegExp(r'[\r\n]+'));
    final seen = <String>{};
    _drafts.clear();
    var i = 0;
    for (final raw in lines) {
      final lab = raw.trim();
      if (lab.isEmpty) continue;
      final k = lab.toLowerCase();
      if (seen.contains(k)) continue;
      seen.add(k);
      const cols = 8;
      _drafts.add(
        _SeatDraft(
          label: lab,
          rowIndex: i ~/ cols,
          colIndex: i % cols,
          blocked: false,
          zone: '',
        ),
      );
      i++;
    }
    setState(() {});
  }

  void _clearAll() {
    _drafts.clear();
    setState(() {});
  }

  Future<void> _save() async {
    if (_drafts.isEmpty) {
      final okEmpty = await showDialog<bool>(
        context: context,
        builder: (x) => AlertDialog(
          title: const Text('Plan vide'),
          content: const Text(
            'Enregistrer un plan vide ? Les clients ne pourront pas réserver de sièges tant qu’aucun siège n’est défini.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(x, false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(x, true),
              child: const Text('Confirmer'),
            ),
          ],
        ),
      );
      if (okEmpty != true) return;
    }

    setState(() => _saving = true);
    try {
      final ok = await client.cinePass.setEventSeatPlan(
        eventId: widget.eventId,
        seatLabels: _drafts.map((e) => e.label).toList(),
        seatRowIndices: _drafts.map((e) => e.rowIndex).toList(),
        seatColIndices: _drafts.map((e) => e.colIndex).toList(),
        seatBlocked: _drafts.map((e) => e.blocked).toList(),
        seatZones: _drafts.map((e) => e.zone).toList(),
      );
      if (!mounted) return;
      if (ok) {
        widget.onSaved?.call();
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Plan de sièges enregistré.'),
            backgroundColor: AppTheme.accentGreen,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Échec de l’enregistrement (droits ou données invalides).'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.cardDark,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720, maxHeight: 640),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(Icons.event_seat_rounded, color: AppTheme.accentGreen),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Plan de sièges & numérotation',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _saving ? null : () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    color: AppTheme.textSecondary,
                  ),
                ],
              ),
              const Text(
                'Les libellés (ex. A1, Fosse-12) sont ceux vus par le client. La zone restreint le type de billet (vide = tous, VIP = billets VIP uniquement).',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 16),
              if (_loading)
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(color: AppTheme.accentGreen),
                  ),
                )
              else ...[
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(_error!, style: const TextStyle(color: Colors.redAccent)),
                  ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _applyClassicCinemaGrid,
                      icon: const Icon(Icons.grid_on_rounded, size: 18),
                      label: const Text('Grille A–J × 1–12 (allées)'),
                    ),
                    OutlinedButton.icon(
                      onPressed: _clearAll,
                      icon: const Icon(Icons.clear_all_rounded, size: 18),
                      label: const Text('Tout effacer'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    SizedBox(
                      width: 180,
                      child: TextField(
                        controller: _vipRowsController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Rangs VIP (depuis A)',
                          filled: true,
                          fillColor: AppTheme.surfaceDark,
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Ex. 2 = rangs A et B réservés aux billets VIP.',
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _freeTextController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Liste libre (une étiquette par ligne)',
                    filled: true,
                    fillColor: AppTheme.surfaceDark,
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _applyFreeText,
                    child: const Text('Importer la liste'),
                  ),
                ),
                Expanded(
                  child: _drafts.isEmpty
                      ? const Center(
                          child: Text(
                            'Aucun siège. Utilisez la grille ou la liste.',
                            style: TextStyle(color: AppTheme.textSecondary),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _drafts.length,
                          itemBuilder: (context, index) {
                            final d = _drafts[index];
                            return Card(
                              color: AppTheme.surfaceDark,
                              margin: const EdgeInsets.only(bottom: 6),
                              child: ListTile(
                                title: Text(
                                  d.label,
                                  style: const TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(
                                  'Rang ${d.rowIndex} · col ${d.colIndex}'
                                  '${d.zone.isEmpty ? '' : ' · zone ${d.zone}'}',
                                  style: const TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextButton(
                                      onPressed: () async {
                                        final ctrl = TextEditingController(text: d.zone);
                                        try {
                                          final z = await showDialog<String>(
                                            context: context,
                                            builder: (x) => AlertDialog(
                                              title: const Text('Zone (ex. VIP)'),
                                              content: TextField(
                                                controller: ctrl,
                                                decoration: const InputDecoration(
                                                  hintText: 'Vide = tout type de billet',
                                                ),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.pop(x),
                                                  child: const Text('Annuler'),
                                                ),
                                                FilledButton(
                                                  onPressed: () =>
                                                      Navigator.pop(x, ctrl.text.trim()),
                                                  child: const Text('OK'),
                                                ),
                                              ],
                                            ),
                                          );
                                          if (z != null) {
                                            setState(() => d.zone = z);
                                          }
                                        } finally {
                                          ctrl.dispose();
                                        }
                                      },
                                      child: const Text('Zone'),
                                    ),
                                    Switch(
                                      value: d.blocked,
                                      onChanged: (v) {
                                        setState(() => d.blocked = v);
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: AppTheme.primaryRed,
                                      ),
                                      onPressed: () {
                                        setState(() => _drafts.removeAt(index));
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _saving ? null : () => Navigator.pop(context),
                      child: const Text('Fermer'),
                    ),
                    const SizedBox(width: 12),
                    FilledButton(
                      onPressed: _saving ? null : _save,
                      style: FilledButton.styleFrom(backgroundColor: AppTheme.accentGreen),
                      child: _saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Enregistrer le plan'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
