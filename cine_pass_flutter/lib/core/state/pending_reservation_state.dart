import 'package:flutter/foundation.dart';

/// Réservation en attente (utilisateur non connecté a cliqué Réserver/Continuer).
/// Après connexion, on restaure dans [ReservationState] et on redirige vers type de billet.
class PendingReservationState extends ChangeNotifier {
  static PendingReservationState? _instance;
  static PendingReservationState get instance => _instance ??= PendingReservationState._();

  PendingReservationState._();

  bool _hasPending = false;
  bool _isFilm = true;

  // Film
  String? _filmId;
  String? _filmTitle;
  String? _seanceId;
  String? _cinemaName;
  String? _cinemaLocation;
  String? _room;
  String? _dateTime;
  String? _format;
  String? _type;
  double _pricePerSeat = 0;
  int _quantity = 1;
  List<String>? _availableOptionsFilm;

  // Event
  String? _eventId;
  String? _eventTitle;
  String? _eventLocation;
  String? _eventDateTime;
  double _eventPricePerTicket = 0;
  List<String>? _availableOptionsEvent;

  bool get hasPending => _hasPending;
  bool get isFilm => _isFilm;

  void setPendingFilm({
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
    _hasPending = true;
    _isFilm = true;
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
    _quantity = quantity;
    _availableOptionsFilm = availableOptions;
    _eventId = null;
    _eventTitle = null;
    _eventLocation = null;
    _eventDateTime = null;
    _eventPricePerTicket = 0;
    _availableOptionsEvent = null;
    notifyListeners();
  }

  void setPendingEvent({
    required String eventId,
    required String eventTitle,
    required String eventLocation,
    required String eventDateTime,
    required int quantity,
    required double pricePerTicket,
    List<String>? availableOptions,
  }) {
    _hasPending = true;
    _isFilm = false;
    _eventId = eventId;
    _eventTitle = eventTitle;
    _eventLocation = eventLocation;
    _eventDateTime = eventDateTime;
    _quantity = quantity;
    _eventPricePerTicket = pricePerTicket;
    _availableOptionsEvent = availableOptions;
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
    _availableOptionsFilm = null;
    notifyListeners();
  }

  void clear() {
    _hasPending = false;
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
    _quantity = 1;
    _availableOptionsFilm = null;
    _eventId = null;
    _eventTitle = null;
    _eventLocation = null;
    _eventDateTime = null;
    _eventPricePerTicket = 0;
    _availableOptionsEvent = null;
    notifyListeners();
  }

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
  int get quantity => _quantity;
  List<String>? get availableOptionsFilm => _availableOptionsFilm;
  String? get eventId => _eventId;
  String? get eventTitle => _eventTitle;
  String? get eventLocation => _eventLocation;
  String? get eventDateTime => _eventDateTime;
  double get eventPricePerTicket => _eventPricePerTicket;
  List<String>? get availableOptionsEvent => _availableOptionsEvent;
}
