import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../providers/theme_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/premium_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey          = GlobalKey<FormState>();
  final _emailController  = TextEditingController();
  final _passController   = TextEditingController();
  final _nameController   = TextEditingController();

  bool _isLogin          = true;
  bool _obscurePassword  = true;
  UserRole _selectedRole = UserRole.utilisateur;

  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    try {
      if (_isLogin) {
        await auth.signIn(
          email: _emailController.text.trim(),
          password: _passController.text,
        );
      } else {
        await auth.signUp(
          email: _emailController.text.trim(),
          password: _passController.text,
          name:  _nameController.text.trim(),
          role:  _selectedRole,
        );
      }
    } catch (e) {
      if (!mounted) return;
      String msg = e.toString();
      if (msg.startsWith('Exception: ')) msg = msg.substring(11);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(children: [
            const Icon(Icons.error_outline_rounded,
                color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(msg)),
          ]),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth          = context.watch<AuthProvider>();
    final theme         = Theme.of(context);
    final appTheme      = AppTheme.of(context);
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      backgroundColor: appTheme.backgroundColor,
      body: Stack(
        children: [
          // ── Animated gradient background ──────────────────────────────
          _GradientBackground(isDark: appTheme.isDark),

          // ── Dark-mode toggle ──────────────────────────────────────────
          Positioned(
            top: 52,
            right: 16,
            child: SafeArea(
              child: Material(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  onTap: themeProvider.toggleTheme,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Icon(
                      themeProvider.isDarkMode
                          ? Icons.light_mode_rounded
                          : Icons.dark_mode_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ),
          ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.2),

          // ── Main content ──────────────────────────────────────────────
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // App logo
                    Hero(
                      tag: 'app-logo',
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.asset(
                          'assets/images/DevMob.png',
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                        .animate()
                        .scale(begin: const Offset(0.6, 0.6),
                            duration: 600.ms, curve: Curves.easeOutBack)
                        .fadeIn(),

                    const SizedBox(height: 28),

                    // Glass form card
                    AnimatedSize(
                      duration: AppTheme.mediumAnimation,
                      curve: AppTheme.springCurve,
                      child: GlassCard(
                        elevated: true,
                        borderRadius: AppTheme.radiusXLarge,
                        padding: const EdgeInsets.all(28),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Title
                              Text(
                                _isLogin ? 'Bienvenue 👋' : 'Créer un compte',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _isLogin
                                    ? 'Connectez-vous à votre compte'
                                    : 'Inscrivez-vous pour continuer',
                                style: theme.textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 28),

                              // Name (signup only)
                              AnimatedSwitcher(
                                duration: AppTheme.mediumAnimation,
                                transitionBuilder: (child, anim) =>
                                    FadeTransition(
                                  opacity: anim,
                                  child: SizeTransition(
                                    sizeFactor: anim,
                                    axisAlignment: -1,
                                    child: child,
                                  ),
                                ),
                                child: !_isLogin
                                    ? Padding(
                                        key: const ValueKey('name-field'),
                                        padding:
                                            const EdgeInsets.only(bottom: 16),
                                        child: _buildInput(
                                          controller: _nameController,
                                          label: 'Nom complet',
                                          icon: Icons.person_outline_rounded,
                                          validator: (v) => v == null || v.isEmpty
                                              ? 'Nom requis'
                                              : null,
                                        ),
                                      )
                                    : const SizedBox.shrink(
                                        key: ValueKey('name-empty')),
                              ),

                              // Email
                              _buildInput(
                                controller: _emailController,
                                label: 'Email',
                                icon: Icons.email_rounded,
                                keyboard: TextInputType.emailAddress,
                                validator: (v) =>
                                    v != null && v.contains('@')
                                        ? null
                                        : 'Email invalide',
                              ),
                              const SizedBox(height: 16),

                              // Password
                              _buildInput(
                                controller: _passController,
                                label: 'Mot de passe',
                                icon: Icons.lock_outline_rounded,
                                obscure: _obscurePassword,
                                validator: (v) => v != null && v.length >= 6
                                    ? null
                                    : 'Minimum 6 caractères',
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_rounded
                                        : Icons.visibility_rounded,
                                    color: appTheme.textSecondaryColor,
                                    size: 20,
                                  ),
                                  onPressed: () => setState(
                                      () => _obscurePassword = !_obscurePassword),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Role selector (signup only)
                              AnimatedSwitcher(
                                duration: AppTheme.mediumAnimation,
                                transitionBuilder: (child, anim) =>
                                    FadeTransition(
                                  opacity: anim,
                                  child: SizeTransition(
                                    sizeFactor: anim,
                                    axisAlignment: -1,
                                    child: child,
                                  ),
                                ),
                                child: !_isLogin
                                    ? Padding(
                                        key: const ValueKey('role-field'),
                                        padding:
                                            const EdgeInsets.only(bottom: 20),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text('Type de compte',
                                                style: theme.textTheme.titleMedium),
                                            const SizedBox(height: 12),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: _RoleChip(
                                                    title: 'Utilisateur',
                                                    icon: Icons.person_outline_rounded,
                                                    value: UserRole.utilisateur,
                                                    selected: _selectedRole,
                                                    onTap: (v) => setState(
                                                        () => _selectedRole = v),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: _RoleChip(
                                                    title: 'Organisateur',
                                                    icon: Icons.business_rounded,
                                                    value: UserRole.organisateur,
                                                    selected: _selectedRole,
                                                    onTap: (v) => setState(
                                                        () => _selectedRole = v),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      )
                                    : const SizedBox.shrink(
                                        key: ValueKey('role-empty')),
                              ),

                              // Submit button
                              PremiumButton(
                                label: _isLogin
                                    ? 'Se connecter'
                                    : 'S\'inscrire',
                                icon: _isLogin
                                    ? Icons.login_rounded
                                    : Icons.person_add_rounded,
                                isLoading: auth.isLoading,
                                onPressed: auth.isLoading ? null : _submit,
                                gradient: appTheme.heroGradient,
                              ),

                              const SizedBox(height: 16),

                              // Toggle login / register
                              TextButton(
                                onPressed: () {
                                  setState(() => _isLogin = !_isLogin);
                                },
                                child: RichText(
                                  text: TextSpan(
                                    style: theme.textTheme.bodyMedium,
                                    children: [
                                      TextSpan(
                                        text: _isLogin
                                            ? 'Pas de compte ?  '
                                            : 'Déjà un compte ?  ',
                                      ),
                                      TextSpan(
                                        text: _isLogin
                                            ? 'S\'inscrire'
                                            : 'Se connecter',
                                        style: TextStyle(
                                          color: theme.colorScheme.primary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.15),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Input builder ────────────────────────────────────────────────────────
  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboard = TextInputType.text,
    bool obscure = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    final theme = Theme.of(context);
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      obscureText: obscure,
      validator: validator,
      style: TextStyle(
          color: theme.textTheme.bodyLarge?.color, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon,
            color: theme.colorScheme.primary, size: 20),
        suffixIcon: suffixIcon,
      ),
    );
  }
}

// ── Animated gradient background ─────────────────────────────────────────────
class _GradientBackground extends StatelessWidget {
  final bool isDark;
  const _GradientBackground({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base gradient
        Container(
          height: 340,
          decoration: BoxDecoration(
            gradient: AppTheme.of(context).heroGradient,
          ),
        ),
        // Animated orbs
        _AnimatedOrb(top: -80, left: -60, size: 220, delay: 0, opacity: 0.18),
        _AnimatedOrb(top: 60, right: -40, size: 160, delay: 800, opacity: 0.13),
        _AnimatedOrb(top: 180, left: 40, size: 80, delay: 400, opacity: 0.09),
      ],
    );
  }
}

class _AnimatedOrb extends StatelessWidget {
  final double? top, left, right, size, opacity;
  final int delay;

  const _AnimatedOrb({
    this.top, this.left, this.right,
    required this.size,
    required this.delay,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top, left: left, right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(opacity!),
        ),
      )
          .animate(
            delay: Duration(milliseconds: delay),
            onPlay: (c) => c.repeat(reverse: true),
          )
          .moveY(begin: 0, end: 12, duration: 3000.ms, curve: Curves.easeInOut)
          .scale(
            begin: const Offset(1, 1),
            end: const Offset(1.08, 1.08),
            duration: 3000.ms,
            curve: Curves.easeInOut,
          ),
    );
  }
}

// ── Role selector chip ────────────────────────────────────────────────────────
class _RoleChip extends StatefulWidget {
  final String title;
  final IconData icon;
  final UserRole value;
  final UserRole selected;
  final ValueChanged<UserRole> onTap;

  const _RoleChip({
    required this.title,
    required this.icon,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_RoleChip> createState() => _RoleChipState();
}

class _RoleChipState extends State<_RoleChip> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.selected == widget.value;
    final appTheme   = AppTheme.of(context);
    final theme      = Theme.of(context);

    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.94),
      onTapUp:   (_) {
        setState(() => _scale = 1.0);
        widget.onTap(widget.value);
      },
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: () => widget.onTap(widget.value),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 80),
        child: AnimatedContainer(
          duration: AppTheme.fastAnimation,
          curve: AppTheme.springCurve,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            gradient: isSelected ? appTheme.primaryGradient : null,
            color:    isSelected ? null : appTheme.surfaceColor,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            border: Border.all(
              color: isSelected ? Colors.transparent : appTheme.dividerColor,
              width: 1.5,
            ),
            boxShadow: isSelected ? appTheme.buttonShadow : [],
          ),
          child: Column(
            children: [
              Icon(
                widget.icon,
                color: isSelected ? Colors.white : appTheme.textSecondaryColor,
                size: 22,
              ),
              const SizedBox(height: 6),
              Text(
                widget.title,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : theme.textTheme.bodyLarge?.color,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
