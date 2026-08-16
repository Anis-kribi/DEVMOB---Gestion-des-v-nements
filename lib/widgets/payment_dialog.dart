import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../utils/app_theme.dart';
import '../../widgets/premium_button.dart';
import '../../services/payment_service.dart';

class PaymentDialog extends StatefulWidget {
  final double amount;
  
  const PaymentDialog({super.key, required this.amount});

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();
  
  final _paymentService = PaymentService();
  
  bool _isProcessing = false;
  bool _isSuccess = false;
  String? _errorMsg;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isProcessing = true;
      _errorMsg = null;
    });

    try {
      final paymentId = await _paymentService.processPayment(
        amount: widget.amount,
        cardNumber: _cardNumberController.text,
        expiryDate: _expiryDateController.text,
        cvv: _cvvController.text,
      );

      setState(() {
        _isProcessing = false;
        _isSuccess = true;
      });

      // Wait a moment to show the success animation, then return the ID
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) {
        Navigator.of(context).pop(paymentId);
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _errorMsg = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appTheme = AppTheme.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: appTheme.cardColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: AnimatedSize(
          duration: AppTheme.fastAnimation,
          curve: Curves.easeInOut,
          child: _isSuccess
              ? _buildSuccessView(theme)
              : _buildPaymentForm(theme, appTheme),
        ),
      ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9)),
    );
  }

  Widget _buildPaymentForm(ThemeData theme, AppTheme appTheme) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Paiement sécurisé',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (!_isProcessing)
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                  color: appTheme.textSecondaryColor,
                ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Simulated Card preview
          Container(
            height: 160,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2c3e50), Color(0xFF3498db)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.credit_card_rounded, color: Colors.white70, size: 32),
                    Text(
                      'Visia', // Fake brand
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
                Text(
                  _cardNumberController.text.isEmpty
                      ? '•••• •••• •••• ••••'
                      : _cardNumberController.text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    letterSpacing: 2,
                    fontFamily: 'monospace',
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'DEV MOB',
                      style: const TextStyle(color: Colors.white70, letterSpacing: 1),
                    ),
                    Text(
                      _expiryDateController.text.isEmpty ? 'MM/YY' : _expiryDateController.text,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Card Number
          TextFormField(
            controller: _cardNumberController,
            enabled: !_isProcessing,
            keyboardType: TextInputType.number,
            maxLength: 19,
            style: TextStyle(color: appTheme.textPrimaryColor),
            decoration: InputDecoration(
              labelText: 'Numéro de carte',
              hintText: '0000 0000 0000 0000',
              prefixIcon: const Icon(Icons.credit_card),
              counterText: '',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              _CardNumberFormatter(),
            ],
            onChanged: (_) => setState(() {}),
            validator: (v) => v != null && v.replaceAll(' ', '').length == 16 ? null : 'Invalide',
          ),
          
          const SizedBox(height: 16),
          
          // Expiry & CVV
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _expiryDateController,
                  enabled: !_isProcessing,
                  keyboardType: TextInputType.number,
                  maxLength: 5,
                  style: TextStyle(color: appTheme.textPrimaryColor),
                  decoration: InputDecoration(
                    labelText: 'Expiration',
                    hintText: 'MM/YY',
                    counterText: '',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    _ExpiryDateFormatter(),
                  ],
                  onChanged: (_) => setState(() {}),
                  validator: (v) => v != null && v.length == 5 ? null : 'Invalide',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _cvvController,
                  enabled: !_isProcessing,
                  keyboardType: TextInputType.number,
                  maxLength: 3,
                  obscureText: true,
                  style: TextStyle(color: appTheme.textPrimaryColor),
                  decoration: InputDecoration(
                    labelText: 'CVV',
                    hintText: '123',
                    counterText: '',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) => v != null && v.length == 3 ? null : 'Invalide',
                ),
              ),
            ],
          ),
          
          if (_errorMsg != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, color: AppTheme.errorColor, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMsg!,
                      style: const TextStyle(color: AppTheme.errorColor, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn().slideX(begin: 0.1),
          ],
          
          const SizedBox(height: 32),
          
          PremiumButton(
            label: 'Payer ${widget.amount.toStringAsFixed(0)} DT',
            icon: Icons.lock_rounded,
            isLoading: _isProcessing,
            onPressed: _processPayment,
            gradient: appTheme.heroGradient,
            height: 52,
            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildSuccessView(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.successColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: AppTheme.successColor,
              size: 64,
            ),
          ).animate().scale(curve: Curves.elasticOut, duration: 800.ms),
          const SizedBox(height: 24),
          Text(
            'Paiement accepté !',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppTheme.successColor,
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
          const SizedBox(height: 8),
          const Text(
            'Génération de votre billet...',
            style: TextStyle(color: Colors.grey),
          ).animate().fadeIn(delay: 400.ms),
        ],
      ),
    );
  }
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }
    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != text.length) {
        buffer.write(' ');
      }
    }
    var string = buffer.toString();
    return newValue.copyWith(
        text: string,
        selection: TextSelection.collapsed(offset: string.length));
  }
}

class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }
    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 2 == 0 && nonZeroIndex != text.length && nonZeroIndex < 4) {
        buffer.write('/');
      }
    }
    var string = buffer.toString();
    return newValue.copyWith(
        text: string,
        selection: TextSelection.collapsed(offset: string.length));
  }
}
