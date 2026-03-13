import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';

/// Types de structure alignés sur la BDD : CINEMA | VENUE | ORGANIZER | OTHER
const List<Map<String, String>> _structureTypes = [
  {'value': 'CINEMA', 'label': 'Cinéma'},
  {'value': 'VENUE', 'label': 'Salle de spectacle'},
  {'value': 'ORGANIZER', 'label': 'Organisateur'},
  {'value': 'OTHER', 'label': 'Autre'},
];

class DevenirResponsablePage extends StatefulWidget {
  const DevenirResponsablePage({super.key});

  @override
  State<DevenirResponsablePage> createState() => _DevenirResponsablePageState();
}

class _DevenirResponsablePageState extends State<DevenirResponsablePage> {
  final _formKey = GlobalKey<FormState>();
  final _professionalEmailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _structureNameController = TextEditingController();
  final _structureCityController = TextEditingController();
  final _structureAddressController = TextEditingController();
  final _structureWebsiteController = TextEditingController();
  final _structureSiretController = TextEditingController();
  final _structurePhoneController = TextEditingController();
  final _contactRoleController = TextEditingController();
  final _contactNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _socialLinksController = TextEditingController();

  String _selectedStructureType = 'CINEMA';
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isSubmitting = false;
  bool _submitted = false;

  @override
  void dispose() {
    _professionalEmailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _structureNameController.dispose();
    _structureCityController.dispose();
    _structureAddressController.dispose();
    _structureWebsiteController.dispose();
    _structureSiretController.dispose();
    _structurePhoneController.dispose();
    _contactRoleController.dispose();
    _contactNameController.dispose();
    _descriptionController.dispose();
    _socialLinksController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() != true) return;
    setState(() => _isSubmitting = true);
    try {
      // TODO: appeler l'endpoint backend createDemandeResponsable (email pro, password hashé, autres champs)
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _submitted = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de l\'envoi. Réessayez.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_submitted) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundDark,
        appBar: AppBar(
          title: const Text('Demande envoyée'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.go(AppRouter.home),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.check_circle_outline_rounded,
                  color: AppTheme.accentGreen,
                  size: 80,
                ),
                const SizedBox(height: 24),
                Text(
                  'Votre demande a bien été envoyée.',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.textPrimary,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Vous pourrez vous connecter à votre espace responsable avec votre email professionnel et le mot de passe que vous avez choisi, une fois la demande approuvée.',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: () => context.go(AppRouter.home),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.primaryRed,
                  ),
                  child: const Text('Retour à l\'accueil'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        title: const Text('Devenir responsable'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Gérez les séances et événements de votre cinéma, salle ou structure. Après approbation, vous vous connecterez à l\'espace responsable avec l\'email professionnel et le mot de passe ci-dessous.',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 28),

              // ---------- Section Identifiants espace responsable ----------
              _sectionTitle('Identifiants espace responsable'),
              const SizedBox(height: 12),
              TextFormField(
                controller: _professionalEmailController,
                decoration: InputDecoration(
                  labelText: 'Email professionnel *',
                  hintText: 'ex. contact@moncinema.fr',
                  filled: true,
                  fillColor: AppTheme.cardDark,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Requis';
                  if (!RegExp(r'^[\w.-]+@[\w.-]+\.\w+$').hasMatch(v.trim())) {
                    return 'Email professionnel invalide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Mot de passe *',
                  hintText: 'Min. 8 caractères',
                  filled: true,
                  fillColor: AppTheme.cardDark,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Requis';
                  if (v.length < 8) return 'Min. 8 caractères';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirm,
                decoration: InputDecoration(
                  labelText: 'Confirmer le mot de passe *',
                  filled: true,
                  fillColor: AppTheme.cardDark,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
                validator: (v) {
                  if (v != _passwordController.text) return 'Les mots de passe ne correspondent pas';
                  return null;
                },
              ),
              const SizedBox(height: 28),

              // ---------- Section Structure ----------
              _sectionTitle('Votre structure'),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedStructureType,
                decoration: InputDecoration(
                  labelText: 'Type de structure *',
                  filled: true,
                  fillColor: AppTheme.cardDark,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                dropdownColor: AppTheme.cardDark,
                onChanged: (v) =>
                    setState(() => _selectedStructureType = v ?? 'CINEMA'),
                items: _structureTypes
                    .map((e) => DropdownMenuItem(
                          value: e['value'],
                          child: Text(e['label']!),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _structureNameController,
                decoration: InputDecoration(
                  labelText: 'Nom de la structure *',
                  filled: true,
                  fillColor: AppTheme.cardDark,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Requis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _structureCityController,
                decoration: InputDecoration(
                  labelText: 'Ville *',
                  filled: true,
                  fillColor: AppTheme.cardDark,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Requis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _structureAddressController,
                decoration: InputDecoration(
                  labelText: 'Adresse complète',
                  filled: true,
                  fillColor: AppTheme.cardDark,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _structureWebsiteController,
                decoration: InputDecoration(
                  labelText: 'Site web',
                  hintText: 'https://...',
                  filled: true,
                  fillColor: AppTheme.cardDark,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _structureSiretController,
                decoration: InputDecoration(
                  labelText: 'SIRET',
                  filled: true,
                  fillColor: AppTheme.cardDark,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _structurePhoneController,
                decoration: InputDecoration(
                  labelText: 'Téléphone de la structure',
                  filled: true,
                  fillColor: AppTheme.cardDark,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 28),

              // ---------- Section Contact ----------
              _sectionTitle('Votre contact'),
              const SizedBox(height: 12),
              TextFormField(
                controller: _contactNameController,
                decoration: InputDecoration(
                  labelText: 'Nom du contact',
                  filled: true,
                  fillColor: AppTheme.cardDark,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contactRoleController,
                decoration: InputDecoration(
                  labelText: 'Votre rôle dans la structure',
                  hintText: 'Ex. Gérant, Programmateur',
                  filled: true,
                  fillColor: AppTheme.cardDark,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // ---------- Section Description ----------
              _sectionTitle('Description / projet'),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Présentez votre structure et votre projet *',
                  hintText: 'Décrivez votre activité, votre public, vos objectifs...',
                  filled: true,
                  fillColor: AppTheme.cardDark,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Requis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _socialLinksController,
                decoration: InputDecoration(
                  labelText: 'Liens réseaux sociaux',
                  hintText: 'URLs séparées par des virgules',
                  filled: true,
                  fillColor: AppTheme.cardDark,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignLabelWithHint: true,
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 32),

              Row(
                children: [
                  TextButton(
                    onPressed: _isSubmitting ? null : () => Navigator.of(context).maybePop(),
                    child: const Text('Annuler'),
                  ),
                  const SizedBox(width: 16),
                  FilledButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.primaryRed,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Envoyer ma demande'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppTheme.primaryRed,
            fontWeight: FontWeight.bold,
          ),
    );
  }
}
