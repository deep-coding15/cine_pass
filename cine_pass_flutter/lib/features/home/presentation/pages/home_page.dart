import 'package:flutter/material.dart';

import '../widgets/home_hero.dart';
import '../widgets/movies_section.dart';
import '../widgets/events_section.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: HomeHero(),
          ),
          const SizedBox(height: 48),
          const MoviesSection(),
          const SizedBox(height: 48),
          const EventsSection(),
        ],
      ),
    );
  }
}
