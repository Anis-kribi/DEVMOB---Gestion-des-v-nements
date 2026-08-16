import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';
import '../../utils/app_theme.dart';

class EditProfileDialog extends StatefulWidget {
  const EditProfileDialog({super.key});

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    _nameController = TextEditingController(text: auth.user?.name);
    _emailController = TextEditingController(text: auth.user?.email);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    final authProvider = context.read<AuthProvider>();
    final authService = context.read<AuthService>();
    final user = authProvider.user;

    if (user == null) return;

    final newName = _nameController.text.trim();
    final newEmail = _emailController.text.trim();
    final currentPassword = _currentPasswordController.text;
    final newPassword = _newPasswordController.text;

    final nameChanged = newName != user.name && newName.isNotEmpty;
    final emailChanged = newEmail != user.email && newEmail.isNotEmpty;
    final passwordChanged = newPassword.isNotEmpty;

    if (!emailChanged && !passwordChanged && !nameChanged) {
      Navigator.pop(context);
      return; // nothing changed
    }

    try {
      if (emailChanged || passwordChanged) {
        if (currentPassword.isEmpty) {
          throw Exception("Le mot de passe actuel est requis pour changer l'email ou le mot de passe.");
        }
      }

      // 1. Update Name
      if (nameChanged) {
        await authProvider.updateName(newName);
      }

      // 2. Update Email and/or Password
      if (emailChanged) {
        await authProvider.updateEmail(newEmail, currentPassword);
      }

      if (passwordChanged) {
        await authProvider.updatePassword(currentPassword, newPassword);
      }
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profil mis à jour avec succès'),
          backgroundColor: Colors.green.shade700,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      String errorMsg = e.toString();
      if (errorMsg.startsWith('Exception: ')) {
        errorMsg = errorMsg.substring(11);
      }
      setState(() => _errorMsg = errorMsg);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appTheme = AppTheme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: appTheme.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.edit, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Éditer le profil',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (_errorMsg != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.errorColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.errorColor.withOpacity(0.5)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: AppTheme.errorColor, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(_errorMsg!,
                              style: const TextStyle(color: AppTheme.errorColor, fontSize: 13)),
                        ),
                      ],
                    ),
                  ),

                // Name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom complet',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) => val == null || val.isEmpty ? 'Champ requis' : null,
                ),
                const SizedBox(height: 16),

                // Email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Nouvel Email',
                    prefixIcon: Icon(Icons.email_rounded),
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Champ requis';
                    if (!val.contains('@')) return 'Email invalide';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // New Password
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: _obscureNew,
                  decoration: InputDecoration(
                    labelText: 'Nouveau mot de passe (optionnel)',
                    prefixIcon: const Icon(Icons.lock_reset),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureNew ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscureNew = !_obscureNew),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                const Divider(),
                const SizedBox(height: 8),
                Text(
                  'Sécurité requise',
                  style: TextStyle(fontSize: 13, color: appTheme.textSecondaryColor, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                // Current Password (used for re-auth)
                TextFormField(
                  controller: _currentPasswordController,
                  obscureText: _obscureCurrent,
                  decoration: InputDecoration(
                    labelText: 'Mot de passe actuel',
                    helperText: "Nécessaire si vous changez d'email ou mot de passe",
                    helperMaxLines: 2,
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureCurrent ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscureCurrent = !_obscureCurrent),
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                      child: const Text('Annuler'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20, height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Enregistrer'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
