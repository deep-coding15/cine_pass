import 'package:flutter/material.dart';
import '../../../events/presentation/pages/event_detail_page.dart';

class FilmDetailPage extends StatefulWidget {
  const FilmDetailPage({super.key, required this.filmId});

  final String filmId;

  @override
  State<FilmDetailPage> createState() => _FilmDetailPageState();
}

class _FilmDetailPageState extends State<FilmDetailPage> {
  @override
  Widget build(BuildContext context) {
    // Backward-compatible route: /films/:id now points to event detail.
    return EventDetailPage(eventId: widget.filmId);
  }
}
