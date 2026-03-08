import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';

class FaqPage extends StatelessWidget {
  const FaqPage({super.key});

  static const _items = [
    _FaqItem(
      question: 'Comment réserver mes billets de cinéma ?',
      answer:
          'Pour réserver vos billets, parcourez notre sélection de films, choisissez une séance, sélectionnez vos sièges et procédez au paiement. Vous recevrez un billet électronique avec un QR code à présenter à l\'entrée.',
    ),
    _FaqItem(
      question: 'Puis-je annuler ou modifier ma réservation ?',
      answer:
          'Vous pouvez annuler ou modifier votre réservation jusqu\'à 2 heures avant le début de la séance, depuis la page "Mes billets". Au-delà, les billets ne sont plus modifiables.',
    ),
    _FaqItem(
      question: 'Comment utiliser mon billet électronique ?',
      answer:
          'Votre billet s\'affiche dans "Mes billets" avec un QR code. Présentez ce QR code sur votre smartphone à l\'entrée de la salle pour être scanné.',
    ),
    _FaqItem(
      question: 'Que faire si je perds mon billet ?',
      answer:
          'Vos billets restent disponibles dans votre compte, onglet "Mes billets". Vous pouvez les réafficher à tout moment. En cas de problème, contactez le support.',
    ),
    _FaqItem(
      question: 'Les prix des billets sont-ils les mêmes partout ?',
      answer:
          'Les tarifs peuvent varier selon les cinémas et les séances (2D, 3D, IMAX, etc.). Le prix affiché au moment du choix de la séance est le prix final.',
    ),
    _FaqItem(
      question: 'Comment réserver pour un événement spécial ?',
      answer:
          'Rendez-vous dans la section "Événements" pour voir les concerts, spectacles et événements. Sélectionnez la quantité de billets et validez votre réservation.',
    ),
    _FaqItem(
      question: 'Puis-je réserver plusieurs places ?',
      answer:
          'Oui. Lors de la sélection des sièges, choisissez autant de places que nécessaire. Le tarif s\'adapte au nombre de billets.',
    ),
    _FaqItem(
      question: 'Dois-je créer un compte pour réserver ?',
      answer:
          'Oui, un compte est nécessaire pour réserver et retrouver vos billets. L\'inscription est rapide et gratuite.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.help_outline_rounded, color: AppTheme.accentGreen, size: 32),
              const SizedBox(width: 12),
              Text(
                'Foire aux questions',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppTheme.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Trouvez rapidement des réponses à vos questions',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 32),
          ..._items.asMap().entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _FaqTile(
                question: entry.value.question,
                answer: entry.value.answer,
                initialExpanded: entry.key == 0,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.cardDark,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vous n\'avez pas trouvé votre réponse ?',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.textPrimary),
                ),
                const SizedBox(height: 8),
                Text(
                  'Notre équipe support est là pour vous aider. Contactez-nous via la page Support.',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => context.go(AppRouter.support),
                  icon: const Icon(Icons.support_agent, size: 20),
                  label: const Text('Contacter le support'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.primaryRed,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqItem {
  const _FaqItem({required this.question, required this.answer});
  final String question;
  final String answer;
}

class _FaqTile extends StatefulWidget {
  const _FaqTile({required this.question, required this.answer, this.initialExpanded = false});

  final String question;
  final String answer;
  final bool initialExpanded;

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initialExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.question,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(
                      _expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                      color: AppTheme.textSecondary,
                      size: 28,
                    ),
                  ],
                ),
                if (_expanded) ...[
                  const SizedBox(height: 12),
                  Text(
                    widget.answer,
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 14, height: 1.4),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
