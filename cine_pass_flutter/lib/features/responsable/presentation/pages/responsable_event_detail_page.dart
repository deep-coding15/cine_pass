import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cine_pass_client/cine_pass_client.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../main.dart';
import '../widgets/responsable_add_event_dialog.dart';

/// Données affichées pour un événement responsable (détail + créneaux / lieu).
class ResponsableEventDetailData {
  const ResponsableEventDetailData({
    required this.id,
    required this.title,
    required this.category,
    required this.structureName,
    required this.date,
    required this.placesTotal,
    required this.placesLeft,
    this.description,
    this.address,
    required this.seances,
    this.archived = false,
  });

  final String id;
  final String title;
  final String category;
  final String structureName;
  final String date;
  final int placesTotal;
  final int placesLeft;
  final String? description;
  final String? address;
  final List<ResponsableSeanceItem> seances;

  /// Archivé : masqué du catalogue public, visible ici pour le responsable.
  final bool archived;
}

class ResponsableSeanceItem {
  const ResponsableSeanceItem({
    required this.id,
    required this.dateStr,
    required this.timeStr,
    required this.lieu,
  });

  final String id;
  final String dateStr;
  final String timeStr;
  final String lieu;
}

String _timeStrForSeanceEdit(String time) {
  final d = DateTime.tryParse(time);
  if (d != null) {
    return '${d.hour.toString().padLeft(2, '0')}:'
        '${d.minute.toString().padLeft(2, '0')}';
  }
  final m = RegExp(r'(\d{1,2}:\d{2})').firstMatch(time);
  if (m != null) return m.group(1)!;
  if (time.length >= 5) return time.substring(0, 5);
  return '20:00';
}

InputDecoration _seanceDialogFieldDecoration(String label) => InputDecoration(
  labelText: label,
  labelStyle: const TextStyle(color: AppTheme.textSecondary),
  filled: true,
  fillColor: AppTheme.surfaceDark,
  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
);

/// Page responsable : détail d’un événement (lieu, date, plan de sièges, archivage, etc.).
class ResponsableEventDetailPage extends StatefulWidget {
  const ResponsableEventDetailPage({super.key, required this.eventId});

  final String eventId;

  @override
  State<ResponsableEventDetailPage> createState() =>
      _ResponsableEventDetailPageState();
}

class _ResponsableEventDetailPageState
    extends State<ResponsableEventDetailPage> {
  bool _loading = true;
  ResponsableEventDetailData? _event;
  EventReservationConfigResponse? _reservationConfig;
  bool _savingConfig = false;

  Future<void> _openEditEventDialog(ResponsableEventDetailData e) async {
    final myStructure = await client.cinePass.getMyStructure();
    if (!mounted) return;
    final structures = myStructure != null
        ? [
            ResponsableStructureItem(
              id: myStructure.id.uuid,
              name: myStructure.name,
            ),
          ]
        : <ResponsableStructureItem>[];
    if (structures.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aucune structure assignée.'),
          backgroundColor: AppTheme.primaryRed,
        ),
      );
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (ctx) => ResponsableAddEventDialog(
        structures: structures,
        editEventId: e.id,
        onSaved: () {},
      ),
    );
    if (!mounted) return;
    await _load();
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final ev = await client.cinePass.getEventById(widget.eventId);
      if (!mounted) return;
      if (ev == null) {
        setState(() {
          _event = null;
          _loading = false;
        });
        return;
      }
      final structureName = await client.cinePass.getMyStructure().then(
        (s) => s?.name ?? '',
      );
      final myEvents = await client.cinePass.getMyEvents();
      var sameSeries =
          myEvents
              .where(
                (x) =>
                    x.title.trim().toLowerCase() ==
                        ev.title.trim().toLowerCase() &&
                    x.category.trim().toLowerCase() ==
                        ev.category.trim().toLowerCase(),
              )
              .toList()
            ..sort((a, b) => a.date.compareTo(b.date));
      if (!sameSeries.any((x) => x.id == ev.id)) {
        sameSeries = [...sameSeries, ev]
          ..sort((a, b) => a.date.compareTo(b.date));
      }
      if (!mounted) return;
      setState(() {
        _event = ResponsableEventDetailData(
          id: ev.id,
          title: ev.title,
          category: ev.category,
          structureName: structureName,
          date: ev.date,
          placesTotal: ev.placesTotal,
          placesLeft: ev.placesLeft,
          description: ev.description,
          address: ev.address ?? ev.location,
          archived: ev.archived == true,
          seances: sameSeries
              .map(
                (s) => ResponsableSeanceItem(
                  id: s.id,
                  dateStr: s.date,
                  timeStr: s.time,
                  lieu: s.location,
                ),
              )
              .toList(),
        );
        _loading = false;
      });
      await _loadReservationConfig();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _event = null;
        _loading = false;
      });
    }
  }

  Future<void> _editSeance(
    ResponsableSeanceItem s,
    ResponsableEventDetailData parent,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final ev = await client.cinePass.getEventById(s.id);
      if (!mounted) return;
      if (ev == null) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Séance introuvable.'),
            backgroundColor: AppTheme.primaryRed,
          ),
        );
        return;
      }
      var pickedDate = DateTime.tryParse(ev.date) ?? DateTime.now();
      final timeCtrl = TextEditingController(
        text: _timeStrForSeanceEdit(ev.time),
      );
      final lieuCtrl = TextEditingController(text: ev.location);
      final villeCtrl = TextEditingController(text: ev.city);
      final addrCtrl = TextEditingController(text: ev.address ?? '');

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) {
          return StatefulBuilder(
            builder: (ctx, setDlg) {
              return AlertDialog(
                backgroundColor: AppTheme.cardDark,
                title: const Text('Modifier la séance'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          'Date',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                        subtitle: Text(
                          '${pickedDate.year.toString().padLeft(4, '0')}-'
                          '${pickedDate.month.toString().padLeft(2, '0')}-'
                          '${pickedDate.day.toString().padLeft(2, '0')}',
                          style: const TextStyle(color: AppTheme.textPrimary),
                        ),
                        trailing: const Icon(Icons.calendar_today_rounded),
                        onTap: () async {
                          final d = await showDatePicker(
                            context: ctx,
                            initialDate: pickedDate,
                            firstDate: DateTime.now().subtract(
                              const Duration(days: 365),
                            ),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365 * 3),
                            ),
                          );
                          if (d != null) setDlg(() => pickedDate = d);
                        },
                      ),
                      TextField(
                        controller: timeCtrl,
                        decoration: _seanceDialogFieldDecoration(
                          'Heure (HH:mm)',
                        ),
                        style: const TextStyle(color: AppTheme.textPrimary),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: lieuCtrl,
                        decoration: _seanceDialogFieldDecoration('Lieu'),
                        style: const TextStyle(color: AppTheme.textPrimary),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: villeCtrl,
                        decoration: _seanceDialogFieldDecoration('Ville'),
                        style: const TextStyle(color: AppTheme.textPrimary),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: addrCtrl,
                        decoration: _seanceDialogFieldDecoration(
                          'Adresse (optionnel)',
                        ),
                        style: const TextStyle(color: AppTheme.textPrimary),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: const Text('Annuler'),
                  ),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.accentGreen,
                    ),
                    onPressed: () => Navigator.of(ctx).pop(true),
                    child: const Text('Enregistrer'),
                  ),
                ],
              );
            },
          );
        },
      );

      final timeStr = timeCtrl.text.trim();
      final lieu = lieuCtrl.text.trim();
      final ville = villeCtrl.text.trim();
      final adresse = addrCtrl.text.trim();
      timeCtrl.dispose();
      lieuCtrl.dispose();
      villeCtrl.dispose();
      addrCtrl.dispose();

      if (confirmed != true || !mounted) return;
      if (lieu.isEmpty || ville.isEmpty) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Lieu et ville sont obligatoires.'),
            backgroundColor: AppTheme.primaryRed,
          ),
        );
        return;
      }
      final t = timeStr.isEmpty ? '20:00' : timeStr;
      final updated = await client.cinePass.updateEvent(
        id: s.id,
        lieu: lieu,
        ville: ville,
        adresse: adresse.isEmpty ? null : adresse,
        eventDate: pickedDate,
        eventTimeStr: t.length >= 5 ? t.substring(0, 5) : t,
      );
      if (!mounted) return;
      if (updated != null) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Séance mise à jour.'),
            backgroundColor: AppTheme.accentGreen,
          ),
        );
        await _load();
      } else {
        messenger.showSnackBar(
          const SnackBar(
            content: Text(
              'Mise à jour impossible : droits ou erreur serveur.',
            ),
            backgroundColor: AppTheme.primaryRed,
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de la modification de la séance.'),
          backgroundColor: AppTheme.primaryRed,
        ),
      );
    }
  }

  Future<void> _deleteSeance(
    ResponsableSeanceItem s,
    ResponsableEventDetailData parent,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        title: const Text('Supprimer cette séance ?'),
        content: Text(
          'Date : ${s.dateStr} ${s.timeStr}\n'
          'Les réservations liées peuvent empêcher la suppression.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppTheme.primaryRed),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    try {
      final ok = await client.cinePass.deleteEvent(s.id);
      if (!mounted) return;
      if (ok) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Séance supprimée.'),
            backgroundColor: AppTheme.accentGreen,
          ),
        );
        if (parent.seances.length <= 1) {
          router.go('/responsable/events');
        } else {
          await _load();
        }
      } else {
        messenger.showSnackBar(
          const SnackBar(
            content: Text(
              'Suppression impossible : réservations actives, droits, ou erreur.',
            ),
            backgroundColor: AppTheme.primaryRed,
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Erreur réseau.'),
          backgroundColor: AppTheme.primaryRed,
        ),
      );
    }
  }

  Future<void> _loadReservationConfig() async {
    try {
      final config = await client.cinePass.getEventReservationConfig(
        widget.eventId,
      );
      if (!mounted) return;
      setState(() {
        _reservationConfig = config;
      });
    } catch (_) {}
  }

  Future<void> _showReservationConfigDialog() async {
    final current = _reservationConfig;
    if (current == null) return;

    final mode = ValueNotifier<String>(current.reservationMode);
    final maxPerOrderController = TextEditingController(
      text: current.maxTicketsPerOrder.toString(),
    );
    final adjacentBestEffortEnabled = ValueNotifier<bool>(
      current.adjacentBestEffort,
    );

    final standard =
        current.ticketTypes
            .where((t) => t.code.toUpperCase() == 'STANDARD')
            .isNotEmpty
        ? current.ticketTypes.firstWhere(
            (t) => t.code.toUpperCase() == 'STANDARD',
          )
        : null;
    final vip =
        current.ticketTypes
            .where((t) => t.code.toUpperCase() == 'VIP')
            .isNotEmpty
        ? current.ticketTypes.firstWhere((t) => t.code.toUpperCase() == 'VIP')
        : null;

    final standardPriceController = TextEditingController(
      text: (standard?.price ?? (_event?.placesTotal != null ? 0 : 0))
          .toStringAsFixed(2),
    );
    final standardQuotaController = TextEditingController(
      text: (standard?.quota ?? (_event?.placesTotal ?? 100)).toString(),
    );
    final vipEnabled = ValueNotifier<bool>(vip != null);
    final vipPriceController = TextEditingController(
      text: (vip?.price ?? 0).toStringAsFixed(2),
    );
    final vipQuotaController = TextEditingController(
      text: (vip?.quota ?? 0).toString(),
    );

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppTheme.cardDark,
          title: const Text('Configuration réservation'),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mode de réservation',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  ValueListenableBuilder<String>(
                    valueListenable: mode,
                    builder: (context, value, child) => SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(
                          value: 'SANS_SIEGES',
                          label: Text('Sans sièges'),
                        ),
                        ButtonSegment(
                          value: 'AVEC_SIEGES',
                          label: Text('Avec sièges'),
                        ),
                      ],
                      selected: {value},
                      onSelectionChanged: (s) => mode.value = s.first,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: maxPerOrderController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Max billets par commande',
                      filled: true,
                      fillColor: AppTheme.surfaceDark,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ValueListenableBuilder<bool>(
                    valueListenable: adjacentBestEffortEnabled,
                    builder: (context, enabled, child) => CheckboxListTile(
                      value: enabled,
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Favoriser les sièges adjacents (best effort)',
                      ),
                      onChanged: (v) =>
                          adjacentBestEffortEnabled.value = v ?? true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Billet STANDARD',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: standardPriceController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Prix',
                            filled: true,
                            fillColor: AppTheme.surfaceDark,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: standardQuotaController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Quota',
                            filled: true,
                            fillColor: AppTheme.surfaceDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ValueListenableBuilder<bool>(
                    valueListenable: vipEnabled,
                    builder: (context, enabled, child) => CheckboxListTile(
                      value: enabled,
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Activer billet VIP'),
                      onChanged: (v) => vipEnabled.value = v ?? false,
                    ),
                  ),
                  ValueListenableBuilder<bool>(
                    valueListenable: vipEnabled,
                    builder: (context, enabled, child) => AnimatedOpacity(
                      duration: const Duration(milliseconds: 120),
                      opacity: enabled ? 1 : 0.5,
                      child: IgnorePointer(
                        ignoring: !enabled,
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: vipPriceController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                decoration: const InputDecoration(
                                  labelText: 'Prix VIP',
                                  filled: true,
                                  fillColor: AppTheme.surfaceDark,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: vipQuotaController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Quota VIP',
                                  filled: true,
                                  fillColor: AppTheme.surfaceDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: _savingConfig
                  ? null
                  : () async {
                      final maxPerOrder =
                          int.tryParse(maxPerOrderController.text.trim()) ?? 8;
                      final stdPrice = double.tryParse(
                        standardPriceController.text.trim().replaceAll(
                          ',',
                          '.',
                        ),
                      );
                      final stdQuota = int.tryParse(
                        standardQuotaController.text.trim(),
                      );
                      final vipPrice =
                          double.tryParse(
                            vipPriceController.text.trim().replaceAll(',', '.'),
                          ) ??
                          0;
                      final vipQuota =
                          int.tryParse(vipQuotaController.text.trim()) ?? 0;
                      if (stdPrice == null ||
                          stdQuota == null ||
                          stdQuota <= 0 ||
                          stdPrice < 0) {
                        if (!ctx.mounted) return;
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          const SnackBar(
                            content: Text('Valeurs STANDARD invalides.'),
                          ),
                        );
                        return;
                      }
                      setState(() => _savingConfig = true);
                      try {
                        final ticketCodes = <String>['STANDARD'];
                        final ticketLabels = <String>['Standard'];
                        final ticketPrices = <double>[stdPrice];
                        final ticketQuotas = <int>[stdQuota];
                        if (vipEnabled.value && vipQuota > 0) {
                          ticketCodes.add('VIP');
                          ticketLabels.add('VIP');
                          ticketPrices.add(vipPrice);
                          ticketQuotas.add(vipQuota);
                        }

                        final ok = await client.cinePass
                            .setEventReservationConfig(
                              eventId: widget.eventId,
                              reservationMode: mode.value,
                              maxTicketsPerOrder: maxPerOrder,
                              adjacentBestEffort:
                                  adjacentBestEffortEnabled.value,
                              ticketTypeCodes: ticketCodes,
                              ticketTypeLabels: ticketLabels,
                              ticketTypePrices: ticketPrices,
                              ticketTypeQuotas: ticketQuotas,
                              optionTicketTypeCodes: const [],
                              optionCodes: const [],
                              optionLabels: const [],
                              optionPrices: const [],
                              optionIncluded: const [],
                            );
                        if (!mounted) return;
                        if (ok) {
                          await _loadReservationConfig();
                          if (!ctx.mounted) return;
                          Navigator.of(ctx).pop(true);
                        } else {
                          if (!ctx.mounted) return;
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Échec de sauvegarde de la configuration.',
                              ),
                            ),
                          );
                        }
                      } finally {
                        if (mounted) setState(() => _savingConfig = false);
                      }
                    },
              child: const Text('Enregistrer'),
            ),
          ],
        );
      },
    );

    if (saved == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Configuration de réservation enregistrée.'),
          backgroundColor: AppTheme.accentGreen,
        ),
      );
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.accentGreen),
      );
    }
    if (_event == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.textSecondary.withValues(alpha: 0.8),
            ),
            const SizedBox(height: 16),
            Text(
              'Événement introuvable',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => context.go('/responsable/events'),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Retour à la liste'),
            ),
          ],
        ),
      );
    }
    final e = _event!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => context.go('/responsable/events'),
                icon: const Icon(Icons.arrow_back_rounded),
                tooltip: 'Retour',
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  e.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            color: AppTheme.cardDark,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: AppTheme.accentGreen.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.event_rounded,
                          color: AppTheme.accentGreen,
                          size: 36,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.accentGreen.withValues(
                                  alpha: 0.2,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                e.category,
                                style: const TextStyle(
                                  color: AppTheme.accentGreen,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Structure / Lieu : ${e.structureName}',
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 15,
                              ),
                            ),
                            if (e.address != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                e.address!,
                                style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                            const SizedBox(height: 8),
                            Text(
                              '${e.date} • ${e.placesTotal - e.placesLeft}/${e.placesTotal} places réservées',
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (e.description != null && e.description!.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    const Divider(color: AppTheme.textSecondary, height: 1),
                    const SizedBox(height: 16),
                    Text(
                      'Description',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      e.description!,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  const Divider(color: AppTheme.textSecondary, height: 1),
                  const SizedBox(height: 16),
                  Text(
                    'Séances',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...e.seances.map(
                    (s) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Material(
                        color: AppTheme.surfaceDark,
                        borderRadius: BorderRadius.circular(8),
                        clipBehavior: Clip.antiAlias,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.schedule_rounded,
                                color: AppTheme.accentGreen,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${s.dateStr} ${s.timeStr}',
                                      style: const TextStyle(
                                        color: AppTheme.textPrimary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      s.lieu,
                                      style: const TextStyle(
                                        color: AppTheme.textSecondary,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () => _editSeance(s, e),
                                icon: const Icon(
                                  Icons.edit_outlined,
                                  size: 20,
                                  color: AppTheme.textSecondary,
                                ),
                                tooltip: 'Modifier la séance',
                              ),
                              IconButton(
                                onPressed: () => _deleteSeance(s, e),
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  size: 20,
                                  color: AppTheme.primaryRed,
                                ),
                                tooltip: 'Supprimer la séance',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            color: AppTheme.cardDark,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Réservation',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: AppTheme.textPrimary,
                            ),
                      ),
                      const Spacer(),
                      FilledButton.icon(
                        onPressed: _reservationConfig == null
                            ? null
                            : _showReservationConfigDialog,
                        icon: const Icon(Icons.tune_rounded, size: 18),
                        label: const Text('Configurer'),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppTheme.accentGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (_reservationConfig == null)
                    const Text(
                      'Chargement de la configuration...',
                      style: TextStyle(color: AppTheme.textSecondary),
                    )
                  else ...[
                    Text(
                      'Mode: ${_reservationConfig!.reservationMode == 'AVEC_SIEGES' ? 'Avec sièges' : 'Sans sièges'}',
                      style: const TextStyle(color: AppTheme.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Max par commande: ${_reservationConfig!.maxTicketsPerOrder}',
                      style: const TextStyle(color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 8),
                    ..._reservationConfig!.ticketTypes.map(
                      (t) => Text(
                        '- ${t.label}: ${t.price.toStringAsFixed(2)} MAD (quota ${t.quota}, reste ${t.remaining})',
                        style: const TextStyle(color: AppTheme.textSecondary),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton.icon(
                onPressed: () => _openEditEventDialog(e),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.accentGreen,
                ),
                icon: const Icon(Icons.edit_rounded, size: 20),
                label: const Text('Modifier l\'événement'),
              ),
              if (e.archived)
                OutlinedButton.icon(
                  onPressed: () async {
                    var ok = false;
                    try {
                      ok = await client.cinePass.unarchiveEvent(e.id);
                    } catch (_) {
                      ok = false;
                    }
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          ok
                              ? 'Événement republié dans le catalogue public.'
                              : 'Désarchivage impossible : vérifiez la connexion et vos droits.',
                        ),
                        backgroundColor: ok
                            ? AppTheme.accentGreen
                            : AppTheme.primaryRed,
                      ),
                    );
                    if (ok) await _load();
                  },
                  icon: const Icon(Icons.unarchive_rounded, size: 20),
                  label: const Text('Désarchiver'),
                )
              else
                OutlinedButton.icon(
                  onPressed: () async {
                    var ok = false;
                    try {
                      ok = await client.cinePass.archiveEvent(e.id);
                    } catch (_) {
                      ok = false;
                    }
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          ok
                              ? 'Événement archivé (plus visible sur l’accueil / À l’affiche).'
                              : 'Archivage impossible : vérifiez la connexion et vos droits.',
                        ),
                        backgroundColor: ok
                            ? AppTheme.accentGreen
                            : AppTheme.primaryRed,
                      ),
                    );
                    if (ok) {
                      context.go('/responsable/events');
                    }
                  },
                  icon: const Icon(Icons.archive_rounded, size: 20),
                  label: const Text('Archiver'),
                ),
              OutlinedButton.icon(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: AppTheme.cardDark,
                      title: const Text('Supprimer cet événement ?'),
                      content: const Text(
                        'Cette action est irréversible.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: const Text('Annuler'),
                        ),
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppTheme.primaryRed,
                          ),
                          onPressed: () => Navigator.of(ctx).pop(true),
                          child: const Text('Supprimer'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true && context.mounted) {
                    final messenger = ScaffoldMessenger.of(context);
                    final router = GoRouter.of(context);
                    try {
                      final ok = await client.cinePass.deleteEvent(e.id);
                      if (ok) {
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('Événement supprimé.'),
                            backgroundColor: AppTheme.accentGreen,
                          ),
                        );
                        router.go('/responsable/events');
                      } else {
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Suppression impossible : réservations actives '
                              '(autre qu’annulé/remboursé), droits insuffisants, '
                              'ou erreur serveur.',
                            ),
                            backgroundColor: AppTheme.primaryRed,
                          ),
                        );
                      }
                    } catch (_) {
                      messenger.showSnackBar(
                        const SnackBar(content: Text('Erreur réseau.')),
                      );
                    }
                  }
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryRed,
                  side: const BorderSide(color: AppTheme.primaryRed),
                ),
                icon: const Icon(Icons.delete_outline_rounded, size: 20),
                label: const Text('Supprimer'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
