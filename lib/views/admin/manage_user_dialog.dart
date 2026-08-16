import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user.dart';
import '../../providers/admin_provider.dart';
import '../../utils/app_theme.dart';

class ManageUserDialog extends StatefulWidget {
  final User? user; // Include user if editing, null if adding

  const ManageUserDialog({super.key, this.user});

  @override
  State<ManageUserDialog> createState() => _ManageUserDialogState();
}

class _ManageUserDialogState extends State<ManageUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  UserRole _selectedRole = UserRole.utilisateur;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      _nameController.text = widget.user!.name;
      _emailController.text = widget.user!.email;
      _selectedRole = widget.user!.role;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final provider = context.read<AdminProvider>();

    try {
      if (widget.user == null) {
        // Create new user
        await provider.createUser(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          name: _nameController.text.trim(),
          role: _selectedRole,
        );
      } else {
        // Update user
        final updatedUser = widget.user!.copyWith(
          name: _nameController.text.trim(),
          role: _selectedRole,
        );
        await provider.updateUser(updatedUser);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.user == null 
              ? 'Utilisateur créé' 
              : 'Utilisateur mis à jour'
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppTheme.errorColor),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.user != null;

    return AlertDialog(
      title: Text(isEdit ? 'Modifier l\'utilisateur' : 'Ajouter un utilisateur'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nom'),
                validator: (v) => v!.isEmpty ? 'Requis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) => v!.isEmpty || !v.contains('@') ? 'Email invalide' : null,
                enabled: !isEdit, // Email is generally read-only on edit in Firebase Auth easily
              ),
              if (!isEdit) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Mot de passe'),
                  obscureText: true,
                  validator: (v) => v!.length < 6 ? 'Minimum 6 caractères' : null,
                ),
              ],
              const SizedBox(height: 16),
              DropdownButtonFormField<UserRole>(
                value: _selectedRole,
                decoration: const InputDecoration(labelText: 'Rôle'),
                items: UserRole.values.map((role) {
                  return DropdownMenuItem(
                    value: role,
                    child: Text(role.name.toUpperCase()),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedRole = val);
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading 
            ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
            : const Text('Enregistrer'),
        ),
      ],
    );
  }
}
