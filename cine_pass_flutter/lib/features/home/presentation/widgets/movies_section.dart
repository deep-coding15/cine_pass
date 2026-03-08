import 'package:cine_pass_client/cine_pass_client.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../main.dart';
import '../../../films/presentation/widgets/film_card.dart';

class MoviesSection extends StatefulWidget {
  const MoviesSection({super.key});

  @override
  State<MoviesSection> createState() => _MoviesSectionState();
}

class _MoviesSectionState extends State<MoviesSection> {
  List<FilmResponse> _films = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final films = await client.cinePass.getFilms();
      if (!mounted) return;
      setState(() => _films = films.take(6).toList());
    } catch (_) {
      if (!mounted) return;
      setState(() => _films = []);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Films à l'affiche",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppTheme.textPrimary,
                ),
              ),
              TextButton.icon(
                onPressed: () => context.go(AppRouter.films),
                icon: const Icon(
                  Icons.arrow_forward_rounded,
                  size: 18,
                  color: AppTheme.textSecondary,
                ),
                label: const Text('Voir tous les films'),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 295,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _films.length,
            itemBuilder: (context, index) {
              final film = _films[index];
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: SizedBox(
                  width: 160,
                  child: FilmCard(film: film),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
