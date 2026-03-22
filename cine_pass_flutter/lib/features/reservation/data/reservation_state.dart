import 'package:cine_pass_client/cine_pass_client.dart';
import 'package:flutter/foundation.dart';

/// Choix par billet (film: Normal/VIP + options; événement: type serveur + options payantes config).
class EventTicketChoice {
  EventTicketChoice({
    this.isVip = false,
    this.optionParking = false,
    this.optionPopcorn = false,
    this.optionBoisson = false,
    this.eventTypeCode = 'STANDARD',
    Set<String>? eventPayantOptionCodes,
  }) : eventPayantOptionCodes = eventPayantOptionCodes ?? {};
  bool isVip;
  bool optionParking;
  bool optionPopcorn;
  bool optionBoisson;

  /// Code type billet événement (STANDARD, VIP, etc.) — aligné sur la config organisateur.
  String eventTypeCode;

  /// Options payantes sélectionnées (codes en majuscules).
  Set<String> eventPayantOptionCodes;
}

/// État partagé de la réservation en cours (film ou événement).
class ReservationState extends ChangeNotifier {
  static final ReservationState _instance = ReservationState._();
  static ReservationState get instance => _instance;

  ReservationState._();

  bool _isEvent = false;
  String? _filmId;
  String? _filmTitle;
  String? _seanceId;
  String? _cinemaName;
  String? _cinemaLocation;
  String? _room;
  String? _dateTime;
  String? _format; // VF, VO
  String? _type; // 2D, 3D, IMAX
  double _pricePerSeat = 0;
  List<String> _selectedSeats = [];
  String? _eventId;
  String? _eventTitle;
  String? _eventLocation;
  String? _eventDateTime;
  int _eventQuantity = 1;
  double _eventPricePerTicket = 0;
  String? _reservationNumber;
  String _ticketType = 'normal'; // 'normal' | 'vip'
  bool _optionParking = false;
  bool _optionPopcorn = false;
  bool _optionBoisson = false; // 1 boisson gazeuse offerte
  List<EventTicketChoice> _eventTickets =
      []; // un par place pour les événements
  List<EventTicketChoice> _filmTickets =
      []; // un par place pour les films (même logique qu'événements)
  List<String> _eventAvailableOptions =
      []; // options définies par l'admin pour l'événement
  List<String> _seanceAvailableOptions =
      []; // options définies par l'admin pour la séance (film)
  EventReservationConfigResponse? _eventReservationConfig;
  static const double _priceParking = 3.0;
  static const double _pricePopcorn = 5.0;
  static const double _priceBoisson = 2.0;

  bool get isEvent => _isEvent;
  String? get filmId => _filmId;
  String? get filmTitle => _filmTitle;
  String? get seanceId => _seanceId;
  String? get cinemaName => _cinemaName;
  String? get cinemaLocation => _cinemaLocation;
  String? get room => _room;
  String? get dateTime => _dateTime;
  String? get format => _format;
  String? get type => _type;
  double get pricePerSeat => _pricePerSeat;
  List<String> get selectedSeats => List.unmodifiable(_selectedSeats);
  String? get eventId => _eventId;
  String? get eventTitle => _eventTitle;
  String? get eventLocation => _eventLocation;
  String? get eventDateTime => _eventDateTime;
  int get eventQuantity => _eventQuantity;
  double get eventPricePerTicket => _eventPricePerTicket;
  String? get reservationNumber => _reservationNumber;
  String get ticketType => _ticketType;
  bool get optionParking => _optionParking;
  bool get optionPopcorn => _optionPopcorn;
  bool get optionBoisson => _optionBoisson;
  double get extrasTotal =>
      (_optionParking ? _priceParking : 0) +
      (_optionPopcorn ? _pricePopcorn : 0) +
      (_optionBoisson ? _priceBoisson : 0);

  /// VIP inclut parking, popcorn, siège prioritaire, 1 boisson — pas de suppléments à ajouter.
  double get extrasTotalForDisplay => ticketType == 'vip' ? 0 : extrasTotal;
  double get basePricePerSeat =>
      _ticketType == 'vip' ? _pricePerSeat * 1.5 : _pricePerSeat;

  List<EventTicketChoice> get eventTickets => List.unmodifiable(_eventTickets);
  List<EventTicketChoice> get filmTickets => List.unmodifiable(_filmTickets);
  List<String> get eventAvailableOptions =>
      List.unmodifiable(_eventAvailableOptions);
  List<String> get seanceAvailableOptions =>
      List.unmodifiable(_seanceAvailableOptions);
  EventReservationConfigResponse? get eventReservationConfig =>
      _eventReservationConfig;

  double get totalFilm {
    if (_filmTickets.isNotEmpty) {
      double sum = 0;
      for (final t in _filmTickets) {
        final base = t.isVip ? _pricePerSeat * 1.5 : _pricePerSeat;
        final opts = t.isVip
            ? 0.0
            : (t.optionParking ? _priceParking : 0) +
                  (t.optionPopcorn ? _pricePopcorn : 0) +
                  (t.optionBoisson ? _priceBoisson : 0);
        sum += base + opts;
      }
      return sum;
    }
    if (_selectedSeats.isEmpty) return 0;
    final base =
        (_ticketType == 'vip' ? _pricePerSeat * 1.5 : _pricePerSeat) *
        _selectedSeats.length;
    return base + (_ticketType == 'vip' ? 0 : extrasTotal);
  }

  double get totalEvent {
    final cfg = _eventReservationConfig;
    if (cfg != null && cfg.ticketTypes.isNotEmpty) {
      var sum = 0.0;
      for (final ticket in _eventTickets) {
        final typeCfg = _findTicketTypeConfig(cfg, ticket.eventTypeCode);
        if (typeCfg == null) continue;
        var line = typeCfg.price;
        for (final oc in ticket.eventPayantOptionCodes) {
          for (final o in typeCfg.options) {
            if (o.optionCode.toUpperCase() != oc.toUpperCase()) continue;
            if (!o.active || o.included) continue;
            line += o.price;
            break;
          }
        }
        sum += line;
      }
      return sum;
    }
    var fallbackSum = 0.0;
    for (final t in _eventTickets) {
      final base = t.isVip ? _eventPricePerTicket * 1.5 : _eventPricePerTicket;
      final opts = t.isVip
          ? 0.0
          : (t.optionParking ? _priceParking : 0) +
                (t.optionPopcorn ? _pricePopcorn : 0) +
                (t.optionBoisson ? _priceBoisson : 0);
      fallbackSum += base + opts;
    }
    return fallbackSum;
  }

  EventTicketTypeConfigResponse? _findTicketTypeConfig(
    EventReservationConfigResponse cfg,
    String code,
  ) {
    final u = code.toUpperCase();
    for (final t in cfg.ticketTypes) {
      if (t.code.toUpperCase() == u) return t;
    }
    return null;
  }

  String _firstActiveEventTypeCode(EventReservationConfigResponse cfg) {
    for (final t in cfg.ticketTypes) {
      if (t.active) return t.code;
    }
    return cfg.ticketTypes.isNotEmpty ? cfg.ticketTypes.first.code : 'STANDARD';
  }

  /// Peut-on assigner ce type au billet [index] sans dépasser les quotas restants ?
  bool canAssignEventTicketType(int index, String newTypeCode) {
    final cfg = _eventReservationConfig;
    if (cfg == null) return true;
    final newU = newTypeCode.toUpperCase();
    final counts = <String, int>{};
    for (final t in cfg.ticketTypes) {
      counts[t.code.toUpperCase()] = 0;
    }
    for (var j = 0; j < _eventTickets.length; j++) {
      final c = (j == index ? newU : _eventTickets[j].eventTypeCode)
          .toUpperCase();
      counts[c] = (counts[c] ?? 0) + 1;
    }
    for (final t in cfg.ticketTypes) {
      final c = t.code.toUpperCase();
      final n = counts[c] ?? 0;
      if (n > t.remaining) return false;
    }
    return true;
  }

  void setFilmReservation({
    required String filmId,
    required String filmTitle,
    required String seanceId,
    required String cinemaName,
    required String cinemaLocation,
    required String room,
    required String dateTime,
    String? format,
    String? type,
    required double pricePerSeat,
    required int quantity,
    List<String>? availableOptions,
  }) {
    _isEvent = false;
    _filmId = filmId;
    _filmTitle = filmTitle;
    _seanceId = seanceId;
    _cinemaName = cinemaName;
    _cinemaLocation = cinemaLocation;
    _room = room;
    _dateTime = dateTime;
    _format = format;
    _type = type;
    _pricePerSeat = pricePerSeat;
    _seanceAvailableOptions =
        availableOptions ?? ['parking', 'popcorn', 'boisson'];
    _filmTickets = List.generate(
      quantity,
      (_) => EventTicketChoice(isVip: false),
    );
    _selectedSeats = [];
    _eventId = null;
    _eventTitle = null;
    _eventQuantity = 1;
    _eventPricePerTicket = 0;
    _eventTickets = [];
    _eventAvailableOptions = [];
    notifyListeners();
  }

  void setFilmTicketVip(int index, bool isVip) {
    if (index < 0 || index >= _filmTickets.length) return;
    _filmTickets[index].isVip = isVip;
    notifyListeners();
  }

  void setFilmTicketOption(int index, String option, bool value) {
    if (index < 0 || index >= _filmTickets.length) return;
    switch (option) {
      case 'parking':
        _filmTickets[index].optionParking = value;
        break;
      case 'popcorn':
        _filmTickets[index].optionPopcorn = value;
        break;
      case 'boisson':
        _filmTickets[index].optionBoisson = value;
        break;
    }
    notifyListeners();
  }

  void setEventReservation({
    required String eventId,
    required String eventTitle,
    required String eventLocation,
    required String eventDateTime,
    required int quantity,
    required double pricePerTicket,
    List<String>? availableOptions,
    EventReservationConfigResponse? reservationConfig,
  }) {
    _isEvent = true;
    _eventId = eventId;
    _eventTitle = eventTitle;
    _eventLocation = eventLocation;
    _eventDateTime = eventDateTime;
    _eventQuantity = quantity;
    _eventPricePerTicket = pricePerTicket;
    _eventReservationConfig = reservationConfig;
    _eventAvailableOptions =
        availableOptions ?? ['parking', 'popcorn', 'boisson'];
    final defaultType = reservationConfig != null
        ? _firstActiveEventTypeCode(reservationConfig)
        : 'STANDARD';
    _eventTickets = List.generate(
      quantity,
      (_) => EventTicketChoice(
        isVip: false,
        eventTypeCode: defaultType,
      ),
    );
    _filmId = null;
    _filmTickets = [];
    _selectedSeats = [];
    _seanceAvailableOptions = [];
    notifyListeners();
  }

  /// Si la config arrive après coup (ex. fetch API sur l’écran types de billets).
  void applyEventReservationConfig(EventReservationConfigResponse cfg) {
    _eventReservationConfig = cfg;
    final def = _firstActiveEventTypeCode(cfg);
    for (final t in _eventTickets) {
      if (_findTicketTypeConfig(cfg, t.eventTypeCode) == null) {
        t.eventTypeCode = def;
      }
      final tc = _findTicketTypeConfig(cfg, t.eventTypeCode);
      if (tc != null) {
        t.eventPayantOptionCodes.removeWhere(
          (o) => !tc.options.any(
            (opt) =>
                opt.optionCode.toUpperCase() == o.toUpperCase() &&
                opt.active &&
                !opt.included,
          ),
        );
      }
    }
    notifyListeners();
  }

  void setEventTicketVip(int index, bool isVip) {
    if (index < 0 || index >= _eventTickets.length) return;
    _eventTickets[index].isVip = isVip;
    notifyListeners();
  }

  void setEventTicketTypeCode(int index, String code) {
    if (index < 0 || index >= _eventTickets.length) return;
    final upper = code.toUpperCase();
    if (!canAssignEventTicketType(index, upper)) return;
    _eventTickets[index].eventTypeCode = upper;
    _eventTickets[index].eventPayantOptionCodes.removeWhere((o) {
      final cfg = _eventReservationConfig;
      if (cfg == null) return true;
      final tc = _findTicketTypeConfig(cfg, upper);
      if (tc == null) return true;
      return !tc.options.any(
        (opt) =>
            opt.optionCode.toUpperCase() == o.toUpperCase() &&
            opt.active &&
            !opt.included,
      );
    });
    notifyListeners();
  }

  void setEventTicketPayantOption(
    int index,
    String optionCode,
    bool value,
  ) {
    if (index < 0 || index >= _eventTickets.length) return;
    final u = optionCode.toUpperCase();
    if (value) {
      _eventTickets[index].eventPayantOptionCodes.add(u);
    } else {
      _eventTickets[index].eventPayantOptionCodes.remove(u);
    }
    notifyListeners();
  }

  void setEventTicketOption(int index, String option, bool value) {
    if (index < 0 || index >= _eventTickets.length) return;
    switch (option) {
      case 'parking':
        _eventTickets[index].optionParking = value;
        break;
      case 'popcorn':
        _eventTickets[index].optionPopcorn = value;
        break;
      case 'boisson':
        _eventTickets[index].optionBoisson = value;
        break;
    }
    notifyListeners();
  }

  void setSelectedSeats(List<String> seats) {
    _selectedSeats = List.from(seats);
    notifyListeners();
  }

  void setReservationNumber(String number) {
    _reservationNumber = number;
    notifyListeners();
  }

  void setTicketType(String type) {
    _ticketType = type == 'vip' ? 'vip' : 'normal';
    notifyListeners();
  }

  void setOptionParking(bool value) {
    _optionParking = value;
    notifyListeners();
  }

  void setOptionPopcorn(bool value) {
    _optionPopcorn = value;
    notifyListeners();
  }

  void setOptionBoisson(bool value) {
    _optionBoisson = value;
    notifyListeners();
  }

  void clear() {
    _filmId = null;
    _filmTitle = null;
    _seanceId = null;
    _cinemaName = null;
    _cinemaLocation = null;
    _room = null;
    _dateTime = null;
    _format = null;
    _type = null;
    _pricePerSeat = 0;
    _selectedSeats = [];
    _eventId = null;
    _eventTitle = null;
    _eventLocation = null;
    _eventDateTime = null;
    _eventQuantity = 1;
    _eventPricePerTicket = 0;
    _eventTickets = [];
    _filmTickets = [];
    _eventAvailableOptions = [];
    _seanceAvailableOptions = [];
    _reservationNumber = null;
    _ticketType = 'normal';
    _optionParking = false;
    _optionPopcorn = false;
    _optionBoisson = false;
    _eventReservationConfig = null;
    notifyListeners();
  }
}
