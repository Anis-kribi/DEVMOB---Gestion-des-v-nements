import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../models/event.dart';
import '../../models/reservation.dart';
import '../../utils/app_theme.dart';
import '../../widgets/premium_button.dart';

class ReservationConfirmationPage extends StatelessWidget {
  final Event event;
  final Reservation reservation;

  const ReservationConfirmationPage({
    super.key,
    required this.event,
    required this.reservation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appTheme = AppTheme.of(context);
    final dateFormat = DateFormat('dd MMMM yyyy • HH:mm', 'fr_FR');

    return Scaffold(
      backgroundColor: appTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Confirmation',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
            letterSpacing: 0.3,
          ),
        ),
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: Stack(
        children: [
          // ── Gradient hero background ──────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 280,
            child: Container(
              decoration: BoxDecoration(
                gradient: appTheme.heroGradient,
              ),
              child: CustomPaint(
                painter: _BubblePainter(),
              ),
            ),
          ),

          // ── Scrollable content ────────────────────────────────
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),

                  // ── Success badge ─────────────────────────────
                  _SuccessHeader(theme: theme, appTheme: appTheme),

                  const SizedBox(height: 32),

                  // ── Ticket card ───────────────────────────────
                  _buildTicket(theme, appTheme, dateFormat)
                      .animate()
                      .fadeIn(delay: 600.ms, duration: 500.ms)
                      .slideY(
                          begin: 0.15,
                          curve: Curves.easeOutCubic,
                          delay: 600.ms),

                  const SizedBox(height: 24),

                  // ── Info strip ────────────────────────────────
                  _InfoStrip(appTheme: appTheme)
                      .animate()
                      .fadeIn(delay: 750.ms, duration: 400.ms),

                  const SizedBox(height: 32),

                  // ── Primary CTA ───────────────────────────────
                  PremiumButton(
                    label: 'Voir mes réservations',
                    icon: Icons.bookmark_rounded,
                    onPressed: () {
                      Navigator.of(context)
                          .popUntil((route) => route.isFirst);
                    },
                    gradient: appTheme.primaryGradient,
                    height: 56,
                    borderRadius:
                        BorderRadius.circular(AppTheme.radiusFull),
                  )
                      .animate()
                      .fadeIn(delay: 850.ms, duration: 400.ms)
                      .slideY(begin: 0.2, delay: 850.ms),

                  const SizedBox(height: 12),

                  // ── Secondary action ──────────────────────────
                  _SecondaryButton(
                    appTheme: appTheme,
                    onPressed: () => Navigator.pop(context),
                  )
                      .animate()
                      .fadeIn(delay: 950.ms, duration: 400.ms),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // TICKET
  // ─────────────────────────────────────────────────────────────
  Widget _buildTicket(
      ThemeData theme, AppTheme appTheme, DateFormat dateFormat) {
    return Container(
      decoration: BoxDecoration(
        color: appTheme.cardColor,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.18),
            blurRadius: 40,
            spreadRadius: -4,
            offset: const Offset(0, 16),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Column(
          children: [
            // ── Ticket header ─────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
              decoration: BoxDecoration(
                gradient: appTheme.heroGradient,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusFull),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.local_activity_rounded,
                            color: Colors.white70, size: 12),
                        const SizedBox(width: 5),
                        const Text(
                          'BILLET CONFIRMÉ',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    event.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  // Date row
                  _IconInfoRow(
                    icon: Icons.calendar_today_rounded,
                    text: dateFormat.format(event.startDate),
                  ),
                ],
              ),
            ),

            // ── Tear-line separator ───────────────────
            _TearLine(appTheme: appTheme),

            // ── Ticket body ───────────────────────────
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Details grid
                  Row(
                    children: [
                      Expanded(
                        child: _DetailCell(
                          icon: Icons.person_rounded,
                          label: 'Titulaire',
                          value: 'Utilisateur',
                          appTheme: appTheme,
                        ),
                      ),
                      _VerticalDivider(appTheme: appTheme),
                      Expanded(
                        child: _DetailCell(
                          icon: Icons.confirmation_number_rounded,
                          label: 'Billets',
                          value:
                              '${reservation.numberOfTickets}× standard',
                          appTheme: appTheme,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _DetailCell(
                          icon: Icons.payments_rounded,
                          label: 'Total payé',
                          value: reservation.totalPrice > 0
                              ? '${reservation.totalPrice.toStringAsFixed(0)} DT'
                              : 'Gratuit',
                          appTheme: appTheme,
                          valueColor: reservation.totalPrice > 0
                              ? AppTheme.primaryColor
                              : AppTheme.successColor,
                        ),
                      ),
                      if (reservation.paymentId != null) ...[
                        _VerticalDivider(appTheme: appTheme),
                        Expanded(
                          child: _DetailCell(
                            icon: Icons.tag_rounded,
                            label: 'Référence',
                            value: '#${reservation.paymentId}',
                            appTheme: appTheme,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Divider ───────────────────────────
                  Divider(color: appTheme.dividerColor, height: 1),
                  const SizedBox(height: 20),

                  // ── QR code section ───────────────────
                  Row(
                    children: [
                      // QR Mock
                      Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusMedium),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryColor.withOpacity(0.12),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(
                              color: appTheme.dividerColor, width: 1.5),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.qr_code_2_rounded,
                            size: 66,
                            color: Colors.black.withOpacity(0.85),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Présentez ce billet',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: appTheme.textPrimaryColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Scannez le QR code à l\'entrée de l\'événement pour valider votre accès.',
                              style: TextStyle(
                                fontSize: 11,
                                height: 1.5,
                                color: appTheme.textSecondaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// SUCCESS HEADER
// ─────────────────────────────────────────────────────────────────
class _SuccessHeader extends StatelessWidget {
  final ThemeData theme;
  final AppTheme appTheme;
  const _SuccessHeader({required this.theme, required this.appTheme});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Animated success icon with glow ring
        Stack(
          alignment: Alignment.center,
          children: [
            // Outer glow pulse ring
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.successColor.withOpacity(0.08),
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(begin: const Offset(1, 1), end: const Offset(1.15, 1.15),
                duration: 1800.ms, curve: Curves.easeInOut),
            // Icon container
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppTheme.successColor,
                    const Color(0xFF059669),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.successColor.withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: -2,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 38,
              ),
            ).animate().scale(
                duration: 700.ms,
                curve: Curves.elasticOut,
                delay: 200.ms),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          'C\'est confirmé !',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ).animate().fadeIn(delay: 400.ms, duration: 400.ms)
            .slideY(begin: -0.15, delay: 400.ms),
        const SizedBox(height: 6),
        Text(
          'Votre place a bien été réservée.',
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
        ).animate().fadeIn(delay: 500.ms, duration: 400.ms),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// INFO STRIP
// ─────────────────────────────────────────────────────────────────
class _InfoStrip extends StatelessWidget {
  final AppTheme appTheme;
  const _InfoStrip({required this.appTheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.accentColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(color: AppTheme.accentColor.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded,
              color: AppTheme.accentColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Un e-mail de confirmation vous a été envoyé avec tous les détails de votre réservation.',
              style: TextStyle(
                fontSize: 12,
                height: 1.5,
                color: appTheme.textSecondaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// SECONDARY BUTTON
// ─────────────────────────────────────────────────────────────────
class _SecondaryButton extends StatelessWidget {
  final AppTheme appTheme;
  final VoidCallback onPressed;
  const _SecondaryButton(
      {required this.appTheme, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: appTheme.textSecondaryColor,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          side: BorderSide(color: appTheme.dividerColor, width: 1.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.arrow_back_rounded,
              size: 18, color: appTheme.textSecondaryColor),
          const SizedBox(width: 8),
          Text(
            'Retour à l\'événement',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: appTheme.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// TEAR-LINE SEPARATOR  (ticket punch-out effect)
// ─────────────────────────────────────────────────────────────────
class _TearLine extends StatelessWidget {
  final AppTheme appTheme;
  const _TearLine({required this.appTheme});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: Row(
        children: [
          // Left notch
          Container(
            width: 16,
            height: 32,
            decoration: BoxDecoration(
              color: appTheme.backgroundColor,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
          ),
          // Dashed line
          Expanded(
            child: CustomPaint(painter: _DashedLinePainter(appTheme)),
          ),
          // Right notch
          Container(
            width: 16,
            height: 32,
            decoration: BoxDecoration(
              color: appTheme.backgroundColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// DETAIL CELL  (grid item inside ticket)
// ─────────────────────────────────────────────────────────────────
class _DetailCell extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final AppTheme appTheme;
  final Color? valueColor;
  const _DetailCell({
    required this.icon,
    required this.label,
    required this.value,
    required this.appTheme,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 13, color: appTheme.textTertiaryColor),
            const SizedBox(width: 4),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: appTheme.textTertiaryColor,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: valueColor ?? appTheme.textPrimaryColor,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// ICON INFO ROW  (date / location inside ticket header)
// ─────────────────────────────────────────────────────────────────
class _IconInfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _IconInfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 14),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// VERTICAL DIVIDER  (between grid cells)
// ─────────────────────────────────────────────────────────────────
class _VerticalDivider extends StatelessWidget {
  final AppTheme appTheme;
  const _VerticalDivider({required this.appTheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: appTheme.dividerColor,
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// CUSTOM PAINTERS
// ─────────────────────────────────────────────────────────────────

/// Decorative semi-transparent bubbles on hero background
class _BubblePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.05);
    canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.2), 70, paint);
    canvas.drawCircle(Offset(size.width * 0.1, size.height * 0.75), 50, paint);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.05), 35, paint);
    paint.color = Colors.white.withOpacity(0.03);
    canvas.drawCircle(
        Offset(size.width * 0.7, size.height * 0.9), 90, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

/// Dashed line painter for tear-line separator
class _DashedLinePainter extends CustomPainter {
  final AppTheme appTheme;
  _DashedLinePainter(this.appTheme);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = appTheme.dividerColor
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    const dashWidth = 6.0;
    const dashSpace = 5.0;
    double x = 0;
    final y = size.height / 2;
    while (x < size.width) {
      canvas.drawLine(Offset(x, y), Offset(x + dashWidth, y), paint);
      x += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
