import 'package:cine_pass_client/cine_pass_client.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../main.dart';

InputDecoration _d(String h) => InputDecoration(
  hintText: h,
  filled: true,
  fillColor: AppTheme.surfaceDark,
  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
);

class ResponsableStructureItem {
  const ResponsableStructureItem({required this.id, required this.name});
  final String id;
  final String name;
}

class EventRepr {
  EventRepr({
    required this.date,
    required this.timeStr,
    required this.lieu,
    required this.ville,
    required this.adresse,
  });
  DateTime date;
  String timeStr;
  String lieu;
  String ville;
  String adresse;
}

class _Choice {
  const _Choice(this.id, this.label);
  final String id;
  final String label;
}

const _choices = <_Choice>[
  _Choice('film', 'Film'),
  _Choice('festival', 'Festival'),
  _Choice('standup', 'Stand-up'),
  _Choice('concert', 'Concert'),
  _Choice('theatre', 'Théâtre'),
  _Choice('autre', 'Autre'),
];

const _filmGenres = <String>[
  'Action',
  'Comédie',
  'Drame',
  'Thriller',
  'Animation',
  'Documentaire',
  'Science-fiction',
  'Romance',
  'Horreur',
  'Aventure',
];

const _commonLanguages = <String>[
  'Français',
  'Anglais',
  'Arabe',
  'Espagnol',
  'Italien',
  'Allemand',
];

class ResponsableAddEventDialog extends StatefulWidget {
  const ResponsableAddEventDialog({
    super.key,
    required this.structures,
    this.editEventId,
    this.onSaved,
  });
  final List<ResponsableStructureItem> structures;

  /// Si renseigné, préremplit le formulaire comme à la création et enregistre via [updateEvent].
  final String? editEventId;
  final VoidCallback? onSaved;
  @override
  State<ResponsableAddEventDialog> createState() =>
      _ResponsableAddEventDialogState();
}

class _ResponsableAddEventDialogState extends State<ResponsableAddEventDialog> {
  final _form = GlobalKey<FormState>();
  int _step = 0;
  bool _saving = false;
  String? _structureId;
  String _kind = 'concert';
  String _mode = 'SANS_SIEGES';
  bool _adjacent = true;
  bool _vip = false;
  bool _loadingEdit = false;

  /// Chargement de l’événement à éditer impossible (éviter une création par erreur).
  String? _editLoadError;
  List<String> _editingSeriesIds = [];
  late final Map<String, TextEditingController> _paidPriceControllers;
  final List<({TextEditingController label})> _customVipRows = [];
  final List<({TextEditingController label, TextEditingController price})>
  _customStandardPaidRows = [];
  String _seatNumbering = 'ALPHA_NUM';
  final _seatRows = TextEditingController(text: '10');
  final _seatCols = TextEditingController(text: '10');
  final _seatVipRows = TextEditingController(text: '2');

  final _title = TextEditingController();
  final _desc = TextEditingController();
  final _other = TextEditingController();
  final _poster = TextEditingController();
  final _price = TextEditingController(text: '35.00');
  final _max = TextEditingController(text: '8');
  final _stdPrice = TextEditingController(text: '35.00');
  final _stdQuota = TextEditingController(text: '300');
  final _vipPrice = TextEditingController(text: '60.00');
  final _vipQuota = TextEditingController(text: '30');
  final _vipIncludedOptions = TextEditingController(
    text: '',
  );
  final _paidStandardOptions = TextEditingController(
    text: '',
  );

  final _filmSynopsis = TextEditingController();
  final _filmDirector = TextEditingController();
  final _filmDuration = TextEditingController();
  String _filmGenre = 'Action';
  String _filmOriginalLanguage = 'Français';
  String _eventLanguage = 'Français';
  final _festivalTheme = TextEditingController();
  final _festivalEdition = TextEditingController();
  final _festivalProgram = TextEditingController();
  final _standupMain = TextEditingController();
  final _standupGuests = TextEditingController();
  final _standupLang = TextEditingController(text: 'Français');
  final _concertArtist = TextEditingController();
  final _concertGenre = TextEditingController();
  final _concertOpening = TextEditingController();
  final _theatreAuthor = TextEditingController();
  final _theatreDirector = TextEditingController();
  final _theatreTroupe = TextEditingController();

  void _syncDisplayedBasePrice() {
    final normalized = _stdPrice.text.trim();
    if (_price.text != normalized) {
      _price.text = normalized;
    }
  }

  final List<EventRepr> _reprs = [];
  final Map<String, String> _vipIncludedCatalog = const {
    'SIEGE_VIP': 'Siège VIP',
    'ACCES_PRIORITAIRE': 'Accès prioritaire',
    'BOISSON': 'Boisson offerte',
    'PARKING': 'Parking inclus',
    'MEET_GREET': 'Meet & Greet',
  };
  final Map<String, double> _standardPaidCatalog = const {
    'PARKING': 20.0,
    'SNACK': 8.0,
    'BOISSON': 5.0,
    'PHOTO': 15.0,
  };
  final Set<String> _selectedVipIncluded = {'SIEGE_VIP', 'ACCES_PRIORITAIRE'};
  final Set<String> _selectedStandardPaid = {'PARKING', 'SNACK'};

  Future<void> _pickPosterFromPc() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    final bytes = file.bytes;
    if (bytes == null || bytes.isEmpty) return;
    final mime = _guessImageMime(file.name, bytes);
    final b64 = base64Encode(bytes);
    final dataUrl = 'data:$mime;base64,$b64';
    if (!mounted) return;
    setState(() {
      _poster.text = dataUrl;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Affiche importée depuis votre PC.'),
        backgroundColor: AppTheme.accentGreen,
      ),
    );
  }

  String _guessImageMime(String name, Uint8List bytes) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.gif')) return 'image/gif';
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
    if (bytes.length >= 4 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47) {
      return 'image/png';
    }
    return 'image/jpeg';
  }

  void _clearCustomRows() {
    for (final r in _customVipRows) {
      r.label.dispose();
    }
    for (final r in _customStandardPaidRows) {
      r.label.dispose();
      r.price.dispose();
    }
    _customVipRows.clear();
    _customStandardPaidRows.clear();
  }

  String _timeStrFromEvent(String time) {
    final t = time.trim();
    if (t.isEmpty || t == '--') return '20:00';
    // Éviter d'interpréter une date ISO (ex. 2026-03-28) comme une heure.
    if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(t)) {
      return '20:00';
    }
    final d = DateTime.tryParse(t);
    if (d != null) {
      return '${d.hour.toString().padLeft(2, '0')}:'
          '${d.minute.toString().padLeft(2, '0')}';
    }
    final m = RegExp(r'\b(\d{1,2}):(\d{2})\b').firstMatch(t);
    if (m != null) {
      return '${m.group(1)!.padLeft(2, '0')}:${m.group(2)}';
    }
    return '20:00';
  }

  void _applyKindFromCategory(String category) {
    final c = category.trim().toLowerCase();
    if (c == 'film') {
      _kind = 'film';
    } else if (c == 'festival') {
      _kind = 'festival';
    } else if (c == 'stand-up' || c == 'standup') {
      _kind = 'standup';
    } else if (c == 'concert') {
      _kind = 'concert';
    } else if (c == 'théâtre' || c == 'theatre') {
      _kind = 'theatre';
    } else {
      _kind = 'autre';
      _other.text = category;
    }
  }

  /// Reprend les lignes « Clé: valeur » générées par [_fullDescription] pour préremplir les champs.
  void _hydrateDescriptionFields(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      _desc.clear();
      return;
    }
    final descLines = <String>[];
    for (final line in raw.split('\n')) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) {
        descLines.add('');
        continue;
      }
      final colon = trimmed.indexOf(':');
      if (colon <= 0 || colon >= trimmed.length - 1) {
        descLines.add(trimmed);
        continue;
      }
      final key = trimmed.substring(0, colon).trim();
      final val = trimmed.substring(colon + 1).trim();
      if (_applyStoredDescriptionKey(key, val)) continue;
      descLines.add(trimmed);
    }
    while (descLines.isNotEmpty && descLines.last.trim().isEmpty) {
      descLines.removeLast();
    }
    _desc.text = descLines.join('\n').trim();
  }

  bool _applyStoredDescriptionKey(String key, String val) {
    if (val.isEmpty) return false;
    switch (key) {
      case 'Genre musical':
        _concertGenre.text = val;
        return true;
      case 'Genre':
        if (_kind == 'film') {
          _filmGenre = _filmGenres.contains(val) ? val : _filmGenres.first;
        }
        return true;
      case 'Langue originale':
        if (_commonLanguages.contains(val)) {
          _filmOriginalLanguage = val;
        }
        return true;
      case 'Synopsis':
        _filmSynopsis.text = val;
        return true;
      case 'Réalisateur':
        _filmDirector.text = val;
        return true;
      case 'Durée':
        final m = RegExp(r'(\d+)').firstMatch(val);
        if (m != null) _filmDuration.text = m.group(1)!;
        return true;
      case 'Thématique':
        _festivalTheme.text = val;
        return true;
      case 'Édition':
        _festivalEdition.text = val;
        return true;
      case 'Programme':
        _festivalProgram.text = val;
        return true;
      case 'Humoriste principal':
        _standupMain.text = val;
        return true;
      case 'Guests':
        _standupGuests.text = val;
        return true;
      case 'Langue':
        if (_kind == 'standup') {
          _standupLang.text = val;
          return true;
        }
        return false;
      case 'Artiste/Groupe':
        _concertArtist.text = val;
        return true;
      case 'Première partie':
        _concertOpening.text = val;
        return true;
      case 'Auteur':
        _theatreAuthor.text = val;
        return true;
      case 'Metteur en scène':
        _theatreDirector.text = val;
        return true;
      case 'Troupe':
        _theatreTroupe.text = val;
        return true;
      case 'Langue événement':
        if (_kind == 'film') {
          if (_commonLanguages.contains(val)) {
            _filmOriginalLanguage = val;
          }
        } else if (_commonLanguages.contains(val)) {
          _eventLanguage = val;
        }
        return true;
      default:
        return false;
    }
  }

  Future<void> _loadEditData() async {
    final id = widget.editEventId;
    if (id == null) return;
    setState(() => _loadingEdit = true);
    try {
      final ev = await client.cinePass.getEventById(id);
      if (ev == null || !mounted) return;
      final all = await client.cinePass.getMyEvents();
      var series =
          all
              .where(
                (e) =>
                    e.title.trim().toLowerCase() ==
                        ev.title.trim().toLowerCase() &&
                    e.category.trim().toLowerCase() ==
                        ev.category.trim().toLowerCase(),
              )
              .toList()
            ..sort((a, b) => a.date.compareTo(b.date));
      if (!series.any((x) => x.id == ev.id)) {
        series = [...series, ev]..sort((a, b) => a.date.compareTo(b.date));
      }
      _editingSeriesIds = series.map((e) => e.id).toList();

      _clearCustomRows();
      _selectedVipIncluded.clear();
      _selectedStandardPaid.clear();

      _title.text = ev.title;
      _applyKindFromCategory(ev.category);
      _hydrateDescriptionFields(ev.description);
      _poster.text = ev.posterUrl ?? '';
      _price.text = ev.price.toStringAsFixed(2);

      if (ev.filmGenre != null && ev.filmGenre!.isNotEmpty) {
        final g = ev.filmGenre!;
        _filmGenre = _filmGenres.contains(g) ? g : _filmGenres.first;
      }
      if (ev.filmDirector != null) _filmDirector.text = ev.filmDirector!;
      if (ev.festivalTheme != null) _festivalTheme.text = ev.festivalTheme!;
      if (ev.standupMainArtist != null) {
        _standupMain.text = ev.standupMainArtist!;
      }
      if (ev.concertArtist != null) _concertArtist.text = ev.concertArtist!;
      if (ev.concertMusicGenre != null && ev.concertMusicGenre!.isNotEmpty) {
        _concertGenre.text = ev.concertMusicGenre!;
      }
      if (ev.theatreAuthor != null) _theatreAuthor.text = ev.theatreAuthor!;
      if (ev.eventLanguage != null && ev.eventLanguage!.isNotEmpty) {
        _eventLanguage = ev.eventLanguage!;
        _filmOriginalLanguage = ev.eventLanguage!;
      }

      _reprs.clear();
      for (final s in series) {
        final d = DateTime.tryParse(s.date) ?? DateTime.now();
        _reprs.add(
          EventRepr(
            date: d,
            timeStr: _timeStrFromEvent(s.time),
            lieu: s.location,
            ville: s.city,
            adresse: s.address ?? '',
          ),
        );
      }

      EventReservationConfigResponse? cfg;
      try {
        cfg = await client.cinePass.getEventReservationConfig(id);
      } catch (_) {
        cfg = null;
      }
      if (cfg != null && mounted) {
        _mode = cfg.reservationMode;
        _adjacent = cfg.adjacentBestEffort;
        _max.text = cfg.maxTicketsPerOrder.toString();
        _vip = false;
        for (final t in cfg.ticketTypes) {
          final tc = t.code.toUpperCase();
          if (tc == 'STANDARD') {
            _stdPrice.text = t.price.toStringAsFixed(2);
            _stdQuota.text = t.quota.toString();
          }
          if (tc == 'VIP') {
            _vip = true;
            _vipPrice.text = t.price.toStringAsFixed(2);
            _vipQuota.text = t.quota.toString();
          }
          for (final o in t.options) {
            if (o.included) {
              if (tc == 'VIP') {
                if (_vipIncludedCatalog.containsKey(o.optionCode)) {
                  _selectedVipIncluded.add(o.optionCode);
                } else if (o.optionCode.startsWith('CUSTOM_VIP')) {
                  _customVipRows.add(
                    (label: TextEditingController(text: o.label)),
                  );
                }
              }
            } else {
              if (tc == 'STANDARD') {
                if (_standardPaidCatalog.containsKey(o.optionCode)) {
                  _selectedStandardPaid.add(o.optionCode);
                  _paidPriceControllers[o.optionCode]?.text = o.price
                      .toStringAsFixed(0);
                } else if (o.optionCode.startsWith('CUSTOM_PAID')) {
                  _customStandardPaidRows.add(
                    (
                      label: TextEditingController(text: o.label),
                      price: TextEditingController(
                        text: o.price.toStringAsFixed(0),
                      ),
                    ),
                  );
                }
              }
            }
          }
        }
        _syncDisplayedBasePrice();
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _editLoadError = 'Erreur lors du chargement des données.';
        });
      }
    } finally {
      if (mounted) setState(() => _loadingEdit = false);
    }
  }

  @override
  void initState() {
    _paidPriceControllers = {
      for (final e in _standardPaidCatalog.entries)
        e.key: TextEditingController(text: e.value.toStringAsFixed(0)),
    };
    super.initState();
    _syncDisplayedBasePrice();
    _stdPrice.addListener(_syncDisplayedBasePrice);
    if (widget.structures.isNotEmpty) _structureId = widget.structures.first.id;
    if (widget.editEventId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadEditData());
    }
  }

  @override
  void dispose() {
    _stdPrice.removeListener(_syncDisplayedBasePrice);
    for (final c in _paidPriceControllers.values) {
      c.dispose();
    }
    for (final r in _customVipRows) {
      r.label.dispose();
    }
    for (final r in _customStandardPaidRows) {
      r.label.dispose();
      r.price.dispose();
    }
    for (final c in [
      _title,
      _desc,
      _other,
      _poster,
      _price,
      _max,
      _stdPrice,
      _stdQuota,
      _vipPrice,
      _vipQuota,
      _vipIncludedOptions,
      _paidStandardOptions,
      _filmSynopsis,
      _filmDirector,
      _filmDuration,
      _festivalTheme,
      _festivalEdition,
      _festivalProgram,
      _standupMain,
      _standupGuests,
      _standupLang,
      _concertArtist,
      _concertGenre,
      _concertOpening,
      _theatreAuthor,
      _theatreDirector,
      _theatreTroupe,
      _seatRows,
      _seatCols,
      _seatVipRows,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  String _category() => _kind == 'autre'
      ? (_other.text.trim().isEmpty ? 'Autre' : _other.text.trim())
      : _choices.firstWhere((e) => e.id == _kind).label;

  String? _fullDescription() {
    final lines = <String>[];
    if (_kind == 'film') {
      lines.add('Genre: $_filmGenre');
      lines.add('Langue originale: $_filmOriginalLanguage');
      if (_filmSynopsis.text.trim().isNotEmpty)
        lines.add('Synopsis: ${_filmSynopsis.text.trim()}');
      if (_filmDirector.text.trim().isNotEmpty)
        lines.add('Réalisateur: ${_filmDirector.text.trim()}');
      if (_filmDuration.text.trim().isNotEmpty)
        lines.add('Durée: ${_filmDuration.text.trim()} min');
    } else if (_kind == 'festival') {
      if (_festivalTheme.text.trim().isNotEmpty)
        lines.add('Thématique: ${_festivalTheme.text.trim()}');
      if (_festivalEdition.text.trim().isNotEmpty)
        lines.add('Édition: ${_festivalEdition.text.trim()}');
      if (_festivalProgram.text.trim().isNotEmpty)
        lines.add('Programme: ${_festivalProgram.text.trim()}');
    } else if (_kind == 'standup') {
      if (_standupMain.text.trim().isNotEmpty)
        lines.add('Humoriste principal: ${_standupMain.text.trim()}');
      if (_standupGuests.text.trim().isNotEmpty)
        lines.add('Guests: ${_standupGuests.text.trim()}');
      if (_standupLang.text.trim().isNotEmpty)
        lines.add('Langue: ${_standupLang.text.trim()}');
    } else if (_kind == 'concert') {
      if (_concertArtist.text.trim().isNotEmpty)
        lines.add('Artiste/Groupe: ${_concertArtist.text.trim()}');
      if (_concertGenre.text.trim().isNotEmpty)
        lines.add('Genre musical: ${_concertGenre.text.trim()}');
      if (_concertOpening.text.trim().isNotEmpty)
        lines.add('Première partie: ${_concertOpening.text.trim()}');
    } else if (_kind == 'theatre') {
      if (_theatreAuthor.text.trim().isNotEmpty)
        lines.add('Auteur: ${_theatreAuthor.text.trim()}');
      if (_theatreDirector.text.trim().isNotEmpty)
        lines.add('Metteur en scène: ${_theatreDirector.text.trim()}');
      if (_theatreTroupe.text.trim().isNotEmpty)
        lines.add('Troupe: ${_theatreTroupe.text.trim()}');
    }
    final languageForEvent = _kind == 'film'
        ? _filmOriginalLanguage.trim()
        : _eventLanguage.trim();
    if (languageForEvent.isNotEmpty) {
      lines.add('Langue événement: $languageForEvent');
    }
    final base = _desc.text.trim();
    if (lines.isEmpty) return base.isEmpty ? null : base;
    return base.isEmpty ? lines.join('\n') : '$base\n\n${lines.join('\n')}';
  }

  /// JSON pour les colonnes des tables `cine_pass_event_*_details` (fiable, sans parser la description).
  String? _eventTypedDetailsJson() {
    switch (_kind) {
      case 'film':
        return jsonEncode({
          'filmGenre': _filmGenre,
          'synopsis': _filmSynopsis.text.trim(),
          'director': _filmDirector.text.trim(),
          'durationMin': int.tryParse(_filmDuration.text.trim()),
          'originalLanguage': _filmOriginalLanguage,
          'eventLanguage': _filmOriginalLanguage.trim().isNotEmpty
              ? _filmOriginalLanguage
              : _eventLanguage,
        });
      case 'festival':
        return jsonEncode({
          'theme': _festivalTheme.text.trim(),
          'edition': _festivalEdition.text.trim(),
          'program': _festivalProgram.text.trim(),
          'eventLanguage': _eventLanguage,
        });
      case 'standup':
        return jsonEncode({
          'mainArtist': _standupMain.text.trim(),
          'guests': _standupGuests.text.trim(),
          'language': _standupLang.text.trim(),
          'eventLanguage': _eventLanguage,
        });
      case 'concert':
        return jsonEncode({
          'artist': _concertArtist.text.trim(),
          'musicGenre': _concertGenre.text.trim(),
          'openingAct': _concertOpening.text.trim(),
          'eventLanguage': _eventLanguage,
        });
      case 'theatre':
        return jsonEncode({
          'author': _theatreAuthor.text.trim(),
          'stageDirector': _theatreDirector.text.trim(),
          'troupe': _theatreTroupe.text.trim(),
          'eventLanguage': _eventLanguage,
        });
      default:
        // Type « Autre » + types inconnus : alimente `cine_pass_event_other_details.custom_fields_json`.
        return jsonEncode({
          'eventLanguage': _eventLanguage,
          if (_kind == 'autre' && _other.text.trim().isNotEmpty)
            'customCategoryLabel': _other.text.trim(),
        });
    }
  }

  void _next() {
    if (_form.currentState?.validate() != true) return;
    if (_kind == 'autre' && _other.text.trim().isEmpty) return;
    if (_reprs.isEmpty) {
      _reprs.add(
        EventRepr(
          date: DateTime.now().add(const Duration(days: 7)),
          timeStr: '20:00',
          lieu: '',
          ville: '',
          adresse: '',
        ),
      );
    }
    setState(() => _step = 1);
  }

  int _computePlacesTotal() {
    final stdQ = int.tryParse(_stdQuota.text) ?? 300;
    final vipQ = _vip ? (int.tryParse(_vipQuota.text) ?? 0) : 0;
    return stdQ + vipQ;
  }

  void _fillOptionLists({
    required List<String> optionTicketTypeCodes,
    required List<String> optionCodes,
    required List<String> optionLabels,
    required List<double> optionPrices,
    required List<bool> optionIncluded,
  }) {
    for (final code in _selectedVipIncluded) {
      if (code.isEmpty) continue;
      optionTicketTypeCodes.add('VIP');
      optionCodes.add(code);
      optionLabels.add(_vipIncludedCatalog[code] ?? code.replaceAll('_', ' '));
      optionPrices.add(0.0);
      optionIncluded.add(true);
    }
    var customVipIdx = 0;
    for (final row in _customVipRows) {
      final lab = row.label.text.trim();
      if (lab.isEmpty) continue;
      optionTicketTypeCodes.add('VIP');
      optionCodes.add('CUSTOM_VIP_$customVipIdx');
      optionLabels.add(lab);
      optionPrices.add(0.0);
      optionIncluded.add(true);
      customVipIdx++;
    }

    for (final code in _selectedStandardPaid) {
      final label = code
          .toLowerCase()
          .split('_')
          .map((s) => s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}')
          .join(' ');
      final ctl = _paidPriceControllers[code];
      final price =
          double.tryParse(
            (ctl?.text ?? '').replaceAll(',', '.'),
          ) ??
          _standardPaidCatalog[code] ??
          0;
      optionTicketTypeCodes.add('STANDARD');
      optionCodes.add(code);
      optionLabels.add(label);
      optionPrices.add(price);
      optionIncluded.add(false);
    }
    var customPaidIdx = 0;
    for (final row in _customStandardPaidRows) {
      final lab = row.label.text.trim();
      if (lab.isEmpty) continue;
      final price = double.tryParse(row.price.text.replaceAll(',', '.')) ?? 0;
      optionTicketTypeCodes.add('STANDARD');
      optionCodes.add('CUSTOM_PAID_$customPaidIdx');
      optionLabels.add(lab);
      optionPrices.add(price);
      optionIncluded.add(false);
      customPaidIdx++;
    }
  }

  Future<void> _submit() async {
    if (_editingSeriesIds.isNotEmpty) {
      await _submitEdit();
      return;
    }
    await _submitCreate();
  }

  Future<void> _submitCreate() async {
    if (_reprs.any((r) => r.lieu.trim().isEmpty || r.ville.trim().isEmpty)) {
      return;
    }
    if (_structureId == null || _structureId!.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Aucune structure sélectionnée. Sélectionnez une structure avant de créer.',
            ),
            backgroundColor: AppTheme.primaryRed,
          ),
        );
      }
      return;
    }
    setState(() => _saving = true);
    final stdP = double.tryParse(_stdPrice.text.replaceAll(',', '.')) ?? 35;
    final stdQ = int.tryParse(_stdQuota.text) ?? 300;
    final codes = <String>['STANDARD'];
    final labels = <String>['Standard'];
    final prices = <double>[stdP];
    final quotas = <int>[stdQ];
    if (_vip) {
      final vq = int.tryParse(_vipQuota.text) ?? 0;
      if (vq > 0) {
        codes.add('VIP');
        labels.add('VIP');
        prices.add(
          double.tryParse(_vipPrice.text.replaceAll(',', '.')) ?? (stdP + 20),
        );
        quotas.add(vq);
      }
    }
    final optionTicketTypeCodes = <String>[];
    final optionCodes = <String>[];
    final optionLabels = <String>[];
    final optionPrices = <double>[];
    final optionIncluded = <bool>[];
    _fillOptionLists(
      optionTicketTypeCodes: optionTicketTypeCodes,
      optionCodes: optionCodes,
      optionLabels: optionLabels,
      optionPrices: optionPrices,
      optionIncluded: optionIncluded,
    );

    var okCount = 0;
    String? failReason;
    try {
      for (final r in _reprs) {
        final created = await client.cinePass.createEvent(
          titre: _title.text.trim(),
          categorie: _category(),
          description: _fullDescription(),
          lieu: r.lieu.trim(),
          adresse: r.adresse.trim().isEmpty ? null : r.adresse.trim(),
          ville: r.ville.trim(),
          eventDate: r.date,
          eventTimeStr: r.timeStr.trim().isEmpty ? '20:00' : r.timeStr.trim(),
          placesTotal: _computePlacesTotal(),
          prixBase: double.tryParse(_price.text.replaceAll(',', '.')) ?? 35,
          posterColor: null,
          posterUrl: _poster.text.trim().isEmpty ? null : _poster.text.trim(),
          structureId: _structureId,
        );
        if (created == null) {
          failReason = 'createEvent a retourné null (droits ou données invalides).';
          break;
        }
        final cfg = await client.cinePass.setEventReservationConfig(
          eventId: created.id,
          reservationMode: _mode,
          maxTicketsPerOrder: int.tryParse(_max.text) ?? 8,
          adjacentBestEffort: _adjacent,
          ticketTypeCodes: codes,
          ticketTypeLabels: labels,
          ticketTypePrices: prices,
          ticketTypeQuotas: quotas,
          optionTicketTypeCodes: optionTicketTypeCodes,
          optionCodes: optionCodes,
          optionLabels: optionLabels,
          optionPrices: optionPrices,
          optionIncluded: optionIncluded,
        );
        if (!cfg) {
          failReason =
              'Configuration réservation refusée pour "${created.title}" (droits/structure/options).';
          break;
        }
        if (_mode == 'AVEC_SIEGES') {
          final seatPlan = _buildSeatPlan();
          final seatOk = await client.cinePass.setEventSeatPlan(
            eventId: created.id,
            seatLabels: seatPlan.$1,
            seatRowIndices: seatPlan.$2,
            seatColIndices: seatPlan.$3,
            seatBlocked: seatPlan.$4,
            seatZones: seatPlan.$5,
          );
          if (!seatOk) {
            failReason =
                'Plan de sièges refusé pour "${created.title}" (mode AVEC_SIEGES / structure / labels).';
            break;
          }
        }
        okCount++;
      }
      if (!mounted) return;
      if (okCount == _reprs.length) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              okCount > 1 ? '$okCount événements créés.' : 'Événement créé.',
            ),
            backgroundColor: AppTheme.accentGreen,
          ),
        );
        widget.onSaved?.call();
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Création interrompue ($okCount/${_reprs.length}). '
              '${failReason ?? 'Vérifiez les données/serveur.'}',
            ),
            backgroundColor: AppTheme.primaryRed,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur serveur: $e'),
            backgroundColor: AppTheme.primaryRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _submitEdit() async {
    if (_reprs.any((r) => r.lieu.trim().isEmpty || r.ville.trim().isEmpty)) {
      return;
    }
    if (_reprs.length != _editingSeriesIds.length) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Pour modifier, gardez le même nombre de séances (dates/lieux).',
          ),
          backgroundColor: AppTheme.primaryRed,
        ),
      );
      return;
    }
    setState(() => _saving = true);
    final stdP = double.tryParse(_stdPrice.text.replaceAll(',', '.')) ?? 35;
    final stdQ = int.tryParse(_stdQuota.text) ?? 300;
    final codes = <String>['STANDARD'];
    final labels = <String>['Standard'];
    final prices = <double>[stdP];
    final quotas = <int>[stdQ];
    if (_vip) {
      final vq = int.tryParse(_vipQuota.text) ?? 0;
      if (vq > 0) {
        codes.add('VIP');
        labels.add('VIP');
        prices.add(
          double.tryParse(_vipPrice.text.replaceAll(',', '.')) ?? (stdP + 20),
        );
        quotas.add(vq);
      }
    }
    final optionTicketTypeCodes = <String>[];
    final optionCodes = <String>[];
    final optionLabels = <String>[];
    final optionPrices = <double>[];
    final optionIncluded = <bool>[];
    _fillOptionLists(
      optionTicketTypeCodes: optionTicketTypeCodes,
      optionCodes: optionCodes,
      optionLabels: optionLabels,
      optionPrices: optionPrices,
      optionIncluded: optionIncluded,
    );

    var okCount = 0;
    try {
      for (var i = 0; i < _reprs.length; i++) {
        final r = _reprs[i];
        final id = _editingSeriesIds[i];
        final updated = await client.cinePass.updateEvent(
          id: id,
          titre: _title.text.trim(),
          categorie: _category(),
          description: _fullDescription(),
          lieu: r.lieu.trim(),
          adresse: r.adresse.trim().isEmpty ? null : r.adresse.trim(),
          ville: r.ville.trim(),
          eventDate: r.date,
          eventTimeStr: r.timeStr.trim().isEmpty ? '20:00' : r.timeStr.trim(),
          placesTotal: _computePlacesTotal(),
          prixBase: double.tryParse(_price.text.replaceAll(',', '.')) ?? 35,
          posterUrl: _poster.text.trim().isEmpty ? null : _poster.text.trim(),
          eventTypedDetailsJson: _eventTypedDetailsJson(),
        );
        if (updated == null) break;
        final cfg = await client.cinePass.setEventReservationConfig(
          eventId: id,
          reservationMode: _mode,
          maxTicketsPerOrder: int.tryParse(_max.text) ?? 8,
          adjacentBestEffort: _adjacent,
          ticketTypeCodes: codes,
          ticketTypeLabels: labels,
          ticketTypePrices: prices,
          ticketTypeQuotas: quotas,
          optionTicketTypeCodes: optionTicketTypeCodes,
          optionCodes: optionCodes,
          optionLabels: optionLabels,
          optionPrices: optionPrices,
          optionIncluded: optionIncluded,
        );
        if (!cfg) break;
        // Édition : on ne rappelle pas setEventSeatPlan (la grille du formulaire ne
        // reflète pas le plan réel ; réécrire ferait souvent échouer la transaction).
        okCount++;
      }
      if (!mounted) return;
      if (okCount == _reprs.length) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              okCount > 1
                  ? '$okCount séances mises à jour.'
                  : 'Événement mis à jour.',
            ),
            backgroundColor: AppTheme.accentGreen,
          ),
        );
        widget.onSaved?.call();
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Mise à jour interrompue. Vérifiez les données ou vos droits.',
            ),
            backgroundColor: AppTheme.primaryRed,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur serveur: $e'),
            backgroundColor: AppTheme.primaryRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  (List<String>, List<int>, List<int>, List<bool>, List<String>)
  _buildSeatPlan() {
    final rows = (int.tryParse(_seatRows.text.trim()) ?? 10).clamp(1, 40);
    final cols = (int.tryParse(_seatCols.text.trim()) ?? 10).clamp(1, 40);
    final vipRows = (int.tryParse(_seatVipRows.text.trim()) ?? 0).clamp(
      0,
      rows,
    );
    final labels = <String>[];
    final rowIndices = <int>[];
    final colIndices = <int>[];
    final blocked = <bool>[];
    final zones = <String>[];
    var seq = 1;
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        String label;
        switch (_seatNumbering) {
          case 'NUMERIC':
            label = '$seq';
            break;
          case 'ROW_SEAT':
            label = 'R${r + 1}-S${c + 1}';
            break;
          case 'ALPHA_NUM':
          default:
            final rowLetter = String.fromCharCode(65 + (r % 26));
            label = '$rowLetter${c + 1}';
        }
        labels.add(label);
        rowIndices.add(r);
        colIndices.add(c);
        blocked.add(false);
        zones.add(r < vipRows ? 'VIP' : '');
        seq++;
      }
    }
    return (labels, rowIndices, colIndices, blocked, zones);
  }

  Widget _responsivePair({
    required Widget left,
    required Widget right,
    double breakpoint = 420,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < breakpoint;
        if (stacked) {
          return Column(
            children: [
              left,
              const SizedBox(height: 10),
              right,
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: left),
            const SizedBox(width: 10),
            Expanded(child: right),
          ],
        );
      },
    );
  }

  Widget _specific() {
    switch (_kind) {
      case 'film':
        return Column(
          children: [
            TextFormField(
              controller: _filmSynopsis,
              maxLines: 3,
              decoration: _d('Synopsis'),
              style: const TextStyle(color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 10),
            _responsivePair(
              left: DropdownButtonFormField<String>(
                key: ValueKey<String>(_filmGenre),
                initialValue: _filmGenre,
                decoration: _d('Genre du film'),
                dropdownColor: AppTheme.cardDark,
                items: _filmGenres
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (v) => setState(() => _filmGenre = v ?? _filmGenre),
              ),
              right: TextFormField(
                controller: _filmDirector,
                decoration: _d('Réalisateur'),
                style: const TextStyle(color: AppTheme.textPrimary),
              ),
            ),
            const SizedBox(height: 10),
            _responsivePair(
              left: TextFormField(
                controller: _filmDuration,
                decoration: _d('Durée (min)'),
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppTheme.textPrimary),
              ),
              right: DropdownButtonFormField<String>(
                key: ValueKey<String>(_filmOriginalLanguage),
                initialValue: _filmOriginalLanguage,
                decoration: _d('Langue originale'),
                dropdownColor: AppTheme.cardDark,
                items: _commonLanguages
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (v) => setState(
                  () => _filmOriginalLanguage = v ?? _filmOriginalLanguage,
                ),
              ),
            ),
          ],
        );
      case 'festival':
        return Column(
          children: [
            TextFormField(
              controller: _festivalTheme,
              decoration: _d('Thématique'),
              style: const TextStyle(color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 10),
            _responsivePair(
              left: TextFormField(
                controller: _festivalEdition,
                decoration: _d('Édition'),
                style: const TextStyle(color: AppTheme.textPrimary),
              ),
              right: TextFormField(
                controller: _festivalProgram,
                decoration: _d('Programme'),
                style: const TextStyle(color: AppTheme.textPrimary),
              ),
            ),
          ],
        );
      case 'standup':
        return Column(
          children: [
            TextFormField(
              controller: _standupMain,
              decoration: _d('Humoriste principal'),
              style: const TextStyle(color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 10),
            _responsivePair(
              left: TextFormField(
                controller: _standupGuests,
                decoration: _d('Guests'),
                style: const TextStyle(color: AppTheme.textPrimary),
              ),
              right: TextFormField(
                controller: _standupLang,
                decoration: _d('Langue'),
                style: const TextStyle(color: AppTheme.textPrimary),
              ),
            ),
          ],
        );
      case 'concert':
        return Column(
          children: [
            TextFormField(
              controller: _concertArtist,
              decoration: _d('Artiste/Groupe'),
              style: const TextStyle(color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 10),
            _responsivePair(
              left: TextFormField(
                controller: _concertGenre,
                decoration: _d('Genre musical'),
                style: const TextStyle(color: AppTheme.textPrimary),
              ),
              right: TextFormField(
                controller: _concertOpening,
                decoration: _d('Première partie'),
                style: const TextStyle(color: AppTheme.textPrimary),
              ),
            ),
          ],
        );
      case 'theatre':
        return Column(
          children: [
            TextFormField(
              controller: _theatreAuthor,
              decoration: _d('Auteur'),
              style: const TextStyle(color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 10),
            _responsivePair(
              left: TextFormField(
                controller: _theatreDirector,
                decoration: _d('Metteur en scène'),
                style: const TextStyle(color: AppTheme.textPrimary),
              ),
              right: TextFormField(
                controller: _theatreTroupe,
                decoration: _d('Troupe / compagnie'),
                style: const TextStyle(color: AppTheme.textPrimary),
              ),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.cardDark,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 760),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.editEventId != null
                        ? 'Modifier l\'événement'
                        : 'Créer un événement',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.close,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _chip(0, 'Infos'),
                  const SizedBox(width: 8),
                  _chip(1, 'Dates/Lieux'),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _loadingEdit
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.accentGreen,
                        ),
                      )
                    : _editLoadError != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            _editLoadError!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppTheme.primaryRed,
                            ),
                          ),
                        ),
                      )
                    : SingleChildScrollView(
                        child: _step == 0 ? _formStep() : _reprStep(),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(int i, String l) {
    final a = _step == i;
    return GestureDetector(
      onTap: () {
        if (i == 0)
          setState(() => _step = 0);
        else
          _next();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: a ? AppTheme.accentGreen : AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'Étape ${i + 1}: $l',
          style: TextStyle(color: a ? Colors.white : AppTheme.textSecondary),
        ),
      ),
    );
  }

  Widget _formStep() {
    return Form(
      key: _form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.structures.isNotEmpty)
            DropdownButtonFormField<String>(
              key: ValueKey<String>(_structureId ?? 'none'),
              initialValue: _structureId,
              decoration: _d('Structure'),
              dropdownColor: AppTheme.cardDark,
              items: widget.structures
                  .map(
                    (s) => DropdownMenuItem(value: s.id, child: Text(s.name)),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _structureId = v),
            ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _title,
            decoration: _d('Titre'),
            style: const TextStyle(color: AppTheme.textPrimary),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Requis' : null,
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            key: ValueKey<String>(_kind),
            initialValue: _kind,
            decoration: _d('Type'),
            dropdownColor: AppTheme.cardDark,
            items: _choices
                .map((e) => DropdownMenuItem(value: e.id, child: Text(e.label)))
                .toList(),
            onChanged: (v) => setState(() => _kind = v ?? 'concert'),
          ),
          if (_kind == 'autre') ...[
            const SizedBox(height: 10),
            TextFormField(
              controller: _other,
              decoration: _d('Précisez la catégorie'),
              style: const TextStyle(color: AppTheme.textPrimary),
            ),
          ],
          const SizedBox(height: 10),
          _specific(),
          const SizedBox(height: 10),
          if (_kind != 'film') ...[
            DropdownButtonFormField<String>(
              key: ValueKey<String>(_eventLanguage),
              initialValue: _eventLanguage,
              decoration: _d('Langue de l’événement'),
              dropdownColor: AppTheme.cardDark,
              items: _commonLanguages
                  .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                  .toList(),
              onChanged: (v) =>
                  setState(() => _eventLanguage = v ?? _eventLanguage),
            ),
            const SizedBox(height: 10),
          ],
          TextFormField(
            controller: _desc,
            maxLines: 3,
            decoration: _d('Description générale'),
            style: const TextStyle(color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            key: ValueKey<String>(_mode),
            initialValue: _mode,
            decoration: _d('Mode réservation'),
            dropdownColor: AppTheme.cardDark,
            items: const [
              DropdownMenuItem(
                value: 'SANS_SIEGES',
                child: Text('Sans sièges'),
              ),
              DropdownMenuItem(
                value: 'AVEC_SIEGES',
                child: Text('Avec sièges'),
              ),
            ],
            onChanged: (v) => setState(() => _mode = v ?? 'SANS_SIEGES'),
          ),
          if (_mode == 'AVEC_SIEGES') ...[
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              key: ValueKey<String>(_seatNumbering),
              initialValue: _seatNumbering,
              decoration: _d('Type de numérotation des sièges'),
              dropdownColor: AppTheme.cardDark,
              items: const [
                DropdownMenuItem(
                  value: 'ALPHA_NUM',
                  child: Text('Alpha-numérique (A1, A2, B1...)'),
                ),
                DropdownMenuItem(
                  value: 'NUMERIC',
                  child: Text('Numérique (1, 2, 3...)'),
                ),
                DropdownMenuItem(
                  value: 'ROW_SEAT',
                  child: Text('Rang-Siège (R1-S1, R1-S2...)'),
                ),
              ],
              onChanged: (v) =>
                  setState(() => _seatNumbering = v ?? 'ALPHA_NUM'),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _seatRows,
                    decoration: _d('Rangs'),
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: AppTheme.textPrimary),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _seatCols,
                    decoration: _d('Sièges / rang'),
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: AppTheme.textPrimary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _seatVipRows,
              decoration: _d('Rangs VIP (depuis le début)'),
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppTheme.textPrimary),
            ),
          ],
          const SizedBox(height: 8),
          TextFormField(
            controller: _max,
            decoration: _d('Max billets / commande'),
            keyboardType: TextInputType.number,
            style: const TextStyle(color: AppTheme.textPrimary),
          ),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _stdPrice,
                  decoration: _d('Prix STANDARD'),
                  style: const TextStyle(color: AppTheme.textPrimary),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  controller: _stdQuota,
                  decoration: _d('Quota STANDARD'),
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: AppTheme.textPrimary),
                ),
              ),
            ],
          ),
          SwitchListTile(
            value: _vip,
            onChanged: (v) => setState(() => _vip = v),
            title: const Text(
              'Activer VIP',
              style: TextStyle(color: AppTheme.textPrimary, fontSize: 13),
            ),
            contentPadding: EdgeInsets.zero,
          ),
          if (_vip)
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _vipPrice,
                    decoration: _d('Prix VIP'),
                    style: const TextStyle(color: AppTheme.textPrimary),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _vipQuota,
                    decoration: _d('Quota VIP'),
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: AppTheme.textPrimary),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 10),
          const SizedBox(height: 4),
          const Text(
            'Options incluses VIP',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
          ),
          ..._vipIncludedCatalog.entries.map(
            (e) => CheckboxListTile(
              value: _selectedVipIncluded.contains(e.key),
              onChanged: (v) {
                setState(() {
                  if (v == true) {
                    _selectedVipIncluded.add(e.key);
                  } else {
                    _selectedVipIncluded.remove(e.key);
                  }
                  _vipIncludedOptions.text = _selectedVipIncluded.join(',');
                });
              },
              title: Text(
                e.value,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 13,
                ),
              ),
              contentPadding: EdgeInsets.zero,
              dense: true,
            ),
          ),
          ...List.generate(
            _customVipRows.length,
            (i) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _customVipRows[i].label,
                      decoration: _d('Option VIP incluse (libellé)'),
                      style: const TextStyle(color: AppTheme.textPrimary),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _customVipRows[i].label.dispose();
                        _customVipRows.removeAt(i);
                      });
                    },
                    icon: const Icon(Icons.close, color: AppTheme.primaryRed),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () {
                setState(() {
                  _customVipRows.add((label: TextEditingController()));
                });
              },
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Ajouter une option VIP incluse'),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Options payantes STANDARD (prix modifiables, MAD)',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
          ),
          ..._standardPaidCatalog.entries.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Checkbox(
                    value: _selectedStandardPaid.contains(e.key),
                    onChanged: (v) {
                      setState(() {
                        if (v == true) {
                          _selectedStandardPaid.add(e.key);
                        } else {
                          _selectedStandardPaid.remove(e.key);
                        }
                        _paidStandardOptions.text = _selectedStandardPaid
                            .map(
                              (code) =>
                                  '$code:$code:${_standardPaidCatalog[code]}',
                            )
                            .join(',');
                      });
                    },
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      e.key,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 72,
                    child: TextFormField(
                      controller: _paidPriceControllers[e.key],
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        isDense: true,
                        hintText: 'Prix',
                        filled: true,
                        fillColor: AppTheme.surfaceDark,
                      ),
                      style: const TextStyle(color: AppTheme.textPrimary),
                    ),
                  ),
                  const Text(
                    ' MAD',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ...List.generate(
            _customStandardPaidRows.length,
            (i) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _customStandardPaidRows[i].label,
                      decoration: _d('Libellé option payante'),
                      style: const TextStyle(color: AppTheme.textPrimary),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 72,
                    child: TextFormField(
                      controller: _customStandardPaidRows[i].price,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: AppTheme.surfaceDark,
                        hintText: 'Prix',
                      ),
                      style: const TextStyle(color: AppTheme.textPrimary),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _customStandardPaidRows[i].label.dispose();
                        _customStandardPaidRows[i].price.dispose();
                        _customStandardPaidRows.removeAt(i);
                      });
                    },
                    icon: const Icon(Icons.close, color: AppTheme.primaryRed),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () {
                setState(() {
                  _customStandardPaidRows.add(
                    (
                      label: TextEditingController(),
                      price: TextEditingController(text: '0'),
                    ),
                  );
                });
              },
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Ajouter une option payante'),
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _price,
            decoration: _d('Prix de base affiché'),
            readOnly: true,
            enabled: false,
            style: const TextStyle(color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 6),
          Text(
            'Prix de base = prix du billet STANDARD. Capacité = somme des quotas STANDARD + VIP.',
            style: TextStyle(
              color: AppTheme.textSecondary.withValues(alpha: 0.9),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _poster,
            decoration: _d('URL affiche (optionnel)'),
            style: const TextStyle(color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickPosterFromPc,
                  icon: const Icon(Icons.upload_file_rounded, size: 18),
                  label: const Text('Ajouter une affiche depuis le PC'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: _next,
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.accentGreen,
            ),
            child: const Text('Suivant: dates et lieux'),
          ),
        ],
      ),
    );
  }

  Widget _reprStep() {
    final lockReprCount = _editingSeriesIds.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          lockReprCount
              ? 'Chaque bloc = une séance du même titre. Pour une seule date, modifiez '
                    'les champs ou utilisez « Modifier la séance » sur la fiche détail.'
              : 'Chaque bloc correspond à une représentation.',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 12),
        ...List.generate(
          _reprs.length,
          (i) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _ReprCard(
              repr: _reprs[i],
              indexLabel: '${i + 1}',
              canDelete: !lockReprCount && _reprs.length > 1,
              onDelete: () => setState(() => _reprs.removeAt(i)),
              onChanged: () => setState(() {}),
            ),
          ),
        ),
        if (!lockReprCount)
          OutlinedButton.icon(
            onPressed: () => setState(
              () => _reprs.add(
                EventRepr(
                  date: DateTime.now().add(const Duration(days: 7)),
                  timeStr: '20:00',
                  lieu: '',
                  ville: '',
                  adresse: '',
                ),
              ),
            ),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Ajouter date/lieu'),
          ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _step = 0),
                child: const Text('Retour'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton(
                onPressed: _saving ? null : _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.accentGreen,
                ),
                child: _saving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        widget.editEventId != null ? 'Enregistrer' : 'Créer',
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ReprCard extends StatefulWidget {
  const _ReprCard({
    required this.repr,
    required this.indexLabel,
    required this.canDelete,
    required this.onDelete,
    required this.onChanged,
  });
  final EventRepr repr;
  final String indexLabel;
  final bool canDelete;
  final VoidCallback onDelete;
  final VoidCallback onChanged;
  @override
  State<_ReprCard> createState() => _ReprCardState();
}

class _ReprCardState extends State<_ReprCard> {
  late final TextEditingController _time;
  late final TextEditingController _lieu;
  late final TextEditingController _ville;
  late final TextEditingController _adresse;

  @override
  void initState() {
    super.initState();
    _time = TextEditingController(text: widget.repr.timeStr);
    _lieu = TextEditingController(text: widget.repr.lieu);
    _ville = TextEditingController(text: widget.repr.ville);
    _adresse = TextEditingController(text: widget.repr.adresse);
    for (final c in [_time, _lieu, _ville, _adresse]) {
      c.addListener(_sync);
    }
  }

  void _sync() {
    widget.repr.timeStr = _time.text;
    widget.repr.lieu = _lieu.text;
    widget.repr.ville = _ville.text;
    widget.repr.adresse = _adresse.text;
  }

  @override
  void dispose() {
    _sync();
    _time.dispose();
    _lieu.dispose();
    _ville.dispose();
    _adresse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.repr;
    return Card(
      color: AppTheme.surfaceDark,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  'Représentation ${widget.indexLabel}',
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (widget.canDelete)
                  IconButton(
                    onPressed: widget.onDelete,
                    icon: const Icon(
                      Icons.delete_outline,
                      color: AppTheme.primaryRed,
                    ),
                  ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final d = await showDatePicker(
                        context: context,
                        initialDate: r.date,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2040),
                      );
                      if (d != null) {
                        setState(() => r.date = d);
                        widget.onChanged();
                      }
                    },
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: Text('${r.date.day}/${r.date.month}/${r.date.year}'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _time,
                    decoration: _d('HH:mm'),
                    style: const TextStyle(color: AppTheme.textPrimary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _lieu,
              decoration: _d('Lieu'),
              style: const TextStyle(color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _ville,
              decoration: _d('Ville'),
              style: const TextStyle(color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _adresse,
              maxLines: 2,
              decoration: _d('Adresse (optionnel)'),
              style: const TextStyle(color: AppTheme.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}
