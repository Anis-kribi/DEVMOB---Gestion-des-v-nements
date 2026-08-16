import 'dart:math';

class PaymentService {
  /// Simule le traitement d'un paiement.
  /// Attend 2 secondes, puis retourne un ID de paiement fictif
  /// ou lève une exception s'il y a un problème (simulation).
  Future<String> processPayment({
    required double amount,
    required String cardNumber,
    required String expiryDate,
    required String cvv,
  }) async {
    // Basic validation
    if (cardNumber.replaceAll(' ', '').length != 16) {
      throw Exception('Numéro de carte invalide');
    }
    if (cvv.length != 3) {
      throw Exception('CVV invalide');
    }
    
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // Simulate 5% chance of failure for realism (optional, you can remove this)
    // if (Random().nextDouble() < 0.05) {
    //   throw Exception('Paiement refusé par la banque.');
    // }

    // Generate fake payment ID
    final randomId = List.generate(4, (_) => Random().nextInt(9999).toString().padLeft(4, '0')).join('-');
    return 'pay_$randomId';
  }
}
