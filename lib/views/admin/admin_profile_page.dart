import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/app_theme.dart';

class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({super.key});

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  bool _isLoading = false;

  // ─── Edit Name ───
  void _showEditNameDialog(BuildContext context, String currentName) {
    final ctrl = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Modifier le nom'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Nom complet',
            prefixIcon: Icon(Icons.person_outline),
          ),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = ctrl.text.trim();
              if (newName.isEmpty) return;
              Navigator.pop(ctx);
              await _runWithLoading(() async {
                await context.read<AuthProvider>().updateName(newName);
              });
              if (mounted) {
                _showSnack('Nom mis à jour avec succès ✓', success: true);
              }
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  // ─── Edit Email ───
  void _showEditEmailDialog(BuildContext context, String currentEmail) {
    final emailCtrl = TextEditingController(text: currentEmail);
    final passCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Modifier l\'email'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: emailCtrl,
                autofocus: true,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Nouvel email',
                  prefixIcon: Icon(Icons.email_rounded),
                ),
                validator: (v) =>
                    (v == null || !v.contains('@')) ? 'Email invalide' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: passCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Mot de passe actuel',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                validator: (v) =>
                    (v == null || v.length < 6) ? 'Mot de passe requis' : null,
              ),
              const SizedBox(height: 8),
              Text(
                'Un email de vérification sera envoyé à la nouvelle adresse.',
                style: TextStyle(
                  fontSize: 11,
                  color: AppTheme.of(context).textSecondaryColor,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(ctx);
              await _runWithLoading(() async {
                await context.read<AuthProvider>().updateEmail(
                      emailCtrl.text.trim(),
                      passCtrl.text,
                    );
              });
              if (mounted) {
                _showSnack(
                  'Email mis à jour. Vérifiez votre boîte mail ✓',
                  success: true,
                );
              }
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  // ─── Edit Password ───
  void _showEditPasswordDialog(BuildContext context) {
    final currentPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Changer le mot de passe'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: currentPassCtrl,
                  obscureText: obscureCurrent,
                  decoration: InputDecoration(
                    labelText: 'Mot de passe actuel',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(obscureCurrent
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () => setDialogState(
                          () => obscureCurrent = !obscureCurrent),
                    ),
                  ),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Requis' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: newPassCtrl,
                  obscureText: obscureNew,
                  decoration: InputDecoration(
                    labelText: 'Nouveau mot de passe',
                    prefixIcon: const Icon(Icons.lock_reset),
                    suffixIcon: IconButton(
                      icon: Icon(
                          obscureNew ? Icons.visibility_off : Icons.visibility),
                      onPressed: () =>
                          setDialogState(() => obscureNew = !obscureNew),
                    ),
                  ),
                  validator: (v) =>
                      (v == null || v.length < 6)
                          ? 'Min 6 caractères'
                          : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: confirmPassCtrl,
                  obscureText: obscureConfirm,
                  decoration: InputDecoration(
                    labelText: 'Confirmer le mot de passe',
                    prefixIcon: const Icon(Icons.lock_reset),
                    suffixIcon: IconButton(
                      icon: Icon(obscureConfirm
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () => setDialogState(
                          () => obscureConfirm = !obscureConfirm),
                    ),
                  ),
                  validator: (v) => (v != newPassCtrl.text)
                      ? 'Les mots de passe ne correspondent pas'
                      : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                Navigator.pop(ctx);
                await _runWithLoading(() async {
                  await context.read<AuthProvider>().updatePassword(
                        currentPassCtrl.text,
                        newPassCtrl.text,
                      );
                });
                if (mounted) {
                  _showSnack('Mot de passe modifié avec succès ✓',
                      success: true);
                }
              },
              child: const Text('Changer'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _runWithLoading(Future<void> Function() fn) async {
    setState(() => _isLoading = true);
    try {
      await fn();
    } catch (e) {
      if (mounted) {
        _showSnack(e.toString().replaceFirst('Exception: ', ''),
            success: false);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg, {required bool success}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: success ? Colors.green.shade600 : AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appTheme = AppTheme.of(context);
    final authProvider = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: appTheme.backgroundColor,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // ─── Gradient Header ───
              SliverAppBar(
                expandedHeight: 220,
                pinned: true,
                backgroundColor: theme.colorScheme.primary,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration:
                        BoxDecoration(gradient: appTheme.primaryGradient),
                    child: Stack(
                      children: [
                        // Decorative circles
                        Positioned(
                          top: -50,
                          right: -40,
                          child: Container(
                            width: 180,
                            height: 180,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.07),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -30,
                          left: -20,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.05),
                            ),
                          ),
                        ),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 44),
                              // Avatar
                              Container(
                                width: 82,
                                height: 82,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.2),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.45),
                                    width: 3,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.admin_panel_settings,
                                  size: 42,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                user?.name ?? 'Admin',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(
                                      AppTheme.radiusXLarge),
                                ),
                                child: const Text(
                                  '🛡️ Administrateur',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ─── Body ───
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Info Section ──
                      _sectionTitle('Informations du compte', theme),
                      const SizedBox(height: 10),
                      _card(
                        appTheme: appTheme,
                        children: [
                          _editableRow(
                            icon: Icons.person_outline,
                            label: 'Nom complet',
                            value: user?.name ?? '-',
                            appTheme: appTheme,
                            theme: theme,
                            onEdit: () => _showEditNameDialog(
                                context, user?.name ?? ''),
                          ),
                          _divider(appTheme),
                          _editableRow(
                            icon: Icons.email_rounded,
                            label: 'Email',
                            value: user?.email ?? '-',
                            appTheme: appTheme,
                            theme: theme,
                            onEdit: () => _showEditEmailDialog(
                                context, user?.email ?? ''),
                          ),
                          _divider(appTheme),
                          _editableRow(
                            icon: Icons.lock_outline,
                            label: 'Mot de passe',
                            value: '••••••••',
                            appTheme: appTheme,
                            theme: theme,
                            onEdit: () => _showEditPasswordDialog(context),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // ── Preferences ──
                      _sectionTitle('Préférences', theme),
                      const SizedBox(height: 10),
                      _card(
                        appTheme: appTheme,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            child: Row(
                              children: [
                                // Icon container
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(
                                        AppTheme.radiusSmall),
                                  ),
                                  child: Icon(
                                    themeProvider.isDarkMode
                                        ? Icons.dark_mode
                                        : Icons.light_mode,
                                    color: AppTheme.primaryColor,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Mode sombre',
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                                fontWeight: FontWeight.w600),
                                      ),
                                      Text(
                                        themeProvider.isDarkMode
                                            ? 'Activé'
                                            : 'Désactivé',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: appTheme.textSecondaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Switch.adaptive(
                                  value: themeProvider.isDarkMode,
                                  onChanged: (_) =>
                                      themeProvider.toggleTheme(),
                                  activeColor: AppTheme.primaryColor,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // ── Danger Zone ──
                      _sectionTitle('Actions', theme),
                      const SizedBox(height: 10),
                      _card(
                        appTheme: appTheme,
                        children: [
                          InkWell(
                            onTap: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Déconnexion'),
                                  content: const Text(
                                      'Voulez-vous vraiment vous déconnecter ?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, false),
                                      child: const Text('Annuler'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, true),
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              AppTheme.errorColor),
                                      child: const Text('Déconnecter'),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true && mounted) {
                                await authProvider.signOut();
                              }
                            },
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusLarge),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: AppTheme.errorColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(
                                          AppTheme.radiusSmall),
                                    ),
                                    child: Icon(Icons.logout,
                                        color: AppTheme.errorColor, size: 20),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Se déconnecter',
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.errorColor,
                                          ),
                                        ),
                                        Text(
                                          'Déconnexion de votre compte',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: appTheme.textSecondaryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(Icons.chevron_right,
                                      color: appTheme.textSecondaryColor),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black38,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  // ─── Helpers ───

  Widget _sectionTitle(String title, ThemeData theme) => Text(
        title,
        style: theme.textTheme.headlineSmall
            ?.copyWith(fontWeight: FontWeight.w700),
      );

  Widget _divider(AppTheme appTheme) =>
      Divider(color: appTheme.dividerColor, height: 1, indent: 16);

  Widget _card({required AppTheme appTheme, required List<Widget> children}) =>
      Container(
        decoration: BoxDecoration(
          color: appTheme.cardColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          border:
              Border.all(color: appTheme.dividerColor.withOpacity(0.5)),
          boxShadow: appTheme.cardShadow,
        ),
        child: Column(children: children),
      );

  Widget _editableRow({
    required IconData icon,
    required String label,
    required String value,
    required AppTheme appTheme,
    required ThemeData theme,
    required VoidCallback onEdit,
  }) {
    return InkWell(
      onTap: onEdit,
      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius:
                    BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: Icon(icon, color: AppTheme.primaryColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                        fontSize: 12,
                        color: appTheme.textSecondaryColor),
                  ),
                  Text(
                    value,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            Icon(Icons.edit_rounded,
                size: 18, color: appTheme.textSecondaryColor),
          ],
        ),
      ),
    );
  }
}
