import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.headset_rounded, color: AppTheme.primaryRed, size: 32),
              const SizedBox(width: 12),
              Text(
                'Support client',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Nous sommes là pour vous aider',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 28),
          LayoutBuilder(
            builder: (context, constraints) {
              final useRow = constraints.maxWidth > 700;
              final contactSection = Column(
                children: [
                  _ContactCard(
                    icon: Icons.email_outlined,
                    title: 'Email',
                    description:
                        'Envoyez-nous un email, nous répondons sous 24h',
                    child: SelectableText(
                      'support@cinepass.com',
                      style: TextStyle(
                        color: AppTheme.accentGreen,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _ContactCard(
                    icon: Icons.phone_outlined,
                    title: 'Téléphone',
                    description: 'Du lundi au vendredi, 9h-18h',
                    child: SelectableText(
                      '+33 1 23 45 67 89',
                      style: TextStyle(
                        color: AppTheme.accentGreen,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _ContactCard(
                    icon: Icons.chat_bubble_outline_rounded,
                    title: 'Chat en direct',
                    description: 'Discutez avec notre équipe',
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.chat_rounded, size: 18),
                      label: const Text('Démarrer une conversation'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.accentGreen,
                      ),
                    ),
                  ),
                ],
              );
              final formSection = Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _MessageForm(),
                  const SizedBox(height: 24),
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
                          'Questions fréquentes',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: AppTheme.textPrimary),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Consultez notre FAQ pour trouver rapidement des réponses aux questions les plus courantes.',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton.icon(
                          onPressed: () => context.go(AppRouter.faq),
                          icon: const Icon(Icons.help_outline, size: 20),
                          label: const Text('Voir la FAQ'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
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
                          'Horaires d\'ouverture',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: AppTheme.textPrimary),
                        ),
                        const SizedBox(height: 12),
                        _OpeningRow(
                          day: 'Lundi - Vendredi',
                          hours: '9h00 - 18h00',
                        ),
                        _OpeningRow(day: 'Samedi', hours: '10h00 - 16h00'),
                        _OpeningRow(day: 'Dimanche', hours: 'Fermé'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              );
              if (useRow) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: contactSection),
                    const SizedBox(width: 24),
                    SizedBox(width: 380, child: formSection),
                  ],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  contactSection,
                  const SizedBox(height: 24),
                  formSection,
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.child,
  });

  final IconData icon;
  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.textSecondary, size: 28),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _OpeningRow extends StatelessWidget {
  const _OpeningRow({required this.day, required this.hours});

  final String day;
  final String hours;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            day,
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
          Text(
            hours,
            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _MessageForm extends StatefulWidget {
  @override
  State<_MessageForm> createState() => _MessageFormState();
}

class _MessageFormState extends State<_MessageForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Message envoyé ! Nous vous répondrons sous 24h.',
          ),
          backgroundColor: AppTheme.accentGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
      _nameController.clear();
      _emailController.clear();
      _subjectController.clear();
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: AppTheme.surfaceDark,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      labelStyle: const TextStyle(color: AppTheme.textSecondary),
    );
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Envoyez-nous un message',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameController,
              decoration: inputDecoration.copyWith(
                labelText: 'Nom complet',
                hintText: 'Votre nom',
              ),
              style: const TextStyle(color: AppTheme.textPrimary),
              validator: (v) => v?.trim().isEmpty == true ? 'Requis' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: inputDecoration.copyWith(
                labelText: 'Email',
                hintText: 'votre@email.com',
              ),
              style: const TextStyle(color: AppTheme.textPrimary),
              validator: (v) {
                if (v?.trim().isEmpty == true) return 'Requis';
                if (v != null && !v.contains('@')) return 'Email invalide';
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _subjectController,
              decoration: inputDecoration.copyWith(
                labelText: 'Sujet',
                hintText: 'Objet de votre message',
              ),
              style: const TextStyle(color: AppTheme.textPrimary),
              validator: (v) => v?.trim().isEmpty == true ? 'Requis' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _messageController,
              maxLines: 4,
              decoration: inputDecoration.copyWith(
                labelText: 'Message',
                hintText: 'Décrivez votre demande...',
              ),
              style: const TextStyle(color: AppTheme.textPrimary),
              validator: (v) => v?.trim().isEmpty == true ? 'Requis' : null,
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _submit,
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primaryRed,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
              ),
              child: const Text('Envoyer le message'),
            ),
          ],
        ),
      ),
    );
  }
}
