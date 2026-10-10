import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/loyalty_model.dart';
import 'logger_service.dart';
import 'notification_service.dart';

/// Service for Loyalty & Rewards Program
class LoyaltyService {
  static final LoyaltyService instance = LoyaltyService._internal();
  factory LoyaltyService() => instance;
  LoyaltyService._internal();

  final CollectionReference _loyaltyAccountsCollection = FirebaseFirestore
      .instance
      .collection('loyalty_accounts');
  final CollectionReference _pointsTransactionsCollection = FirebaseFirestore
      .instance
      .collection('points_transactions');
  // final CollectionReference _rewardsCollection =
  //     FirebaseFirestore.instance.collection('rewards'); // Reserved for future use
  final CollectionReference _referralsCollection = FirebaseFirestore.instance
      .collection('referrals');

  // ==================== LOYALTY TIERS ====================

  final Map<String, Map<String, dynamic>> tiers = {
    'bronze': {
      'name': 'Bronze',
      'minPoints': 0,
      'color': 0xFFCD7F32,
      'benefits': ['Poin 1x', 'Diskon 5%'],
    },
    'silver': {
      'name': 'Silver',
      'minPoints': 1000,
      'color': 0xFFC0C0C0,
      'benefits': ['Poin 1.5x', 'Diskon 10%', 'Priority Support'],
    },
    'gold': {
      'name': 'Gold',
      'minPoints': 5000,
      'color': 0xFFFFD700,
      'benefits': ['Poin 2x', 'Diskon 15%', 'Free Upgrade Sekali'],
    },
    'platinum': {
      'name': 'Platinum',
      'minPoints': 10000,
      'color': 0xFFE5E4E2,
      'benefits': ['Poin 3x', 'Diskon 20%', 'Dedicated Account Manager'],
    },
  };

  // ==================== REWARDS CATALOG ====================

  final List<Map<String, dynamic>> rewardsCatalog = [
    {
      'name': 'Diskon 50rb',
      'description': 'Potongan Rp 50.000 untuk pembayaran bulan depan',
      'pointsCost': 500,
      'category': 'discount',
      'value': 50000,
    },
    {
      'name': 'Diskon 100rb',
      'description': 'Potongan Rp 100.000 untuk pembayaran bulan depan',
      'pointsCost': 1000,
      'category': 'discount',
      'value': 100000,
    },
    {
      'name': 'Free Upgrade 1 Bulan',
      'description': 'Gratis upgrade ke paket lebih tinggi selama 1 bulan',
      'pointsCost': 2000,
      'category': 'upgrade',
      'value': 0,
    },
    {
      'name': 'Cashback 10%',
      'description': 'Cashback 10% dari pembayaran bulan ini (maks 200rb)',
      'pointsCost': 1500,
      'category': 'cashback',
      'value': 200000,
    },
    {
      'name': 'Router Upgrade Gratis',
      'description': 'Upgrade router ke model terbaru tanpa biaya',
      'pointsCost': 3000,
      'category': 'upgrade',
      'value': 0,
    },
  ];

  // ==================== ACCOUNT MANAGEMENT ====================

  /// Get or create loyalty account
  Future<LoyaltyAccount> getOrCreateAccount(String customerId) async {
    try {
      final doc = await _loyaltyAccountsCollection.doc(customerId).get();

      if (doc.exists) {
        return LoyaltyAccount.fromFirestore(doc);
      }

      // Create new account
      final newAccount = LoyaltyAccount(
        customerId: customerId,
        totalPoints: 0,
        lifetimePoints: 0,
        tier: 'bronze',
      );

      await _loyaltyAccountsCollection.doc(customerId).set(newAccount.toJson());

      LoggerService.info('Created new loyalty account for: $customerId');
      return newAccount;
    } catch (e) {
      LoggerService.error('Error getting loyalty account: $e');
      rethrow;
    }
  }

  /// Calculate tier based on lifetime points
  String _calculateTier(int lifetimePoints) {
    if (lifetimePoints >= 10000) return 'platinum';
    if (lifetimePoints >= 5000) return 'gold';
    if (lifetimePoints >= 1000) return 'silver';
    return 'bronze';
  }

  // ==================== POINTS EARNING ====================

  /// Award points for payment
  Future<void> awardPointsForPayment(
    String customerId,
    int paymentAmount,
  ) async {
    try {
      final account = await getOrCreateAccount(customerId);

      // Base: 1 point per 1000 rupiah
      int basePoints = (paymentAmount / 1000).floor();

      // Tier multiplier
      final multiplier = account.tier == 'platinum'
          ? 3
          : account.tier == 'gold'
          ? 2
          : account.tier == 'silver'
          ? 1.5
          : 1;

      final points = (basePoints * multiplier).toInt();

      await addPoints(
        customerId,
        points,
        'earn',
        'Pembayaran tagihan Rp ${paymentAmount ~/ 1000}k',
      );

      LoggerService.info('Awarded $points points to $customerId for payment');
    } catch (e) {
      LoggerService.error('Error awarding points: $e');
    }
  }

  /// Add points to account
  Future<void> addPoints(
    String customerId,
    int points,
    String type,
    String description,
  ) async {
    try {
      final account = await getOrCreateAccount(customerId);

      final newTotalPoints = account.totalPoints + points;
      final newLifetimePoints = account.lifetimePoints + points;
      final newTier = _calculateTier(newLifetimePoints);

      // Update account
      await _loyaltyAccountsCollection.doc(customerId).update({
        'totalPoints': newTotalPoints,
        'lifetimePoints': newLifetimePoints,
        'tier': newTier,
        'lastActivityAt': FieldValue.serverTimestamp(),
      });

      // Record transaction
      await _pointsTransactionsCollection.add({
        'customerId': customerId,
        'points': points,
        'type': type,
        'description': description,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Notify tier upgrade
      if (newTier != account.tier) {
        await NotificationService().showNetworkUpdateNotification(
          title: '🎉 Naik Tier!',
          message: 'Selamat! Anda naik ke tier ${tiers[newTier]!['name']}',
        );
      }

      LoggerService.info('Added $points points to $customerId ($type)');
    } catch (e) {
      LoggerService.error('Error adding points: $e');
      rethrow;
    }
  }

  /// Redeem points for reward
  Future<bool> redeemPoints(
    String customerId,
    int pointsCost,
    String rewardName,
  ) async {
    try {
      final account = await getOrCreateAccount(customerId);

      if (account.totalPoints < pointsCost) {
        LoggerService.warning('Insufficient points for redemption');
        return false;
      }

      // Deduct points
      await _loyaltyAccountsCollection.doc(customerId).update({
        'totalPoints': account.totalPoints - pointsCost,
        'lastActivityAt': FieldValue.serverTimestamp(),
      });

      // Record transaction
      await _pointsTransactionsCollection.add({
        'customerId': customerId,
        'points': -pointsCost,
        'type': 'redeem',
        'description': 'Redeem: $rewardName',
        'createdAt': FieldValue.serverTimestamp(),
      });

      await NotificationService().showNetworkUpdateNotification(
        title: '✅ Reward Ditukar!',
        message: 'Anda berhasil menukar $rewardName',
      );

      LoggerService.info('Redeemed $pointsCost points for $rewardName');
      return true;
    } catch (e) {
      LoggerService.error('Error redeeming points: $e');
      return false;
    }
  }

  // ==================== REFERRAL SYSTEM ====================

  /// Generate referral code
  String generateReferralCode(String customerId) {
    return 'ADN${customerId.substring(0, 6).toUpperCase()}';
  }

  /// Create referral
  Future<bool> createReferral(String referrerId, String referredEmail) async {
    try {
      // In production, check if referred user signed up
      await _referralsCollection.add({
        'referrerId': referrerId,
        'referredEmail': referredEmail,
        'status': 'pending',
        'rewardPoints': 500,
        'createdAt': FieldValue.serverTimestamp(),
      });

      LoggerService.info('Referral created by $referrerId for $referredEmail');
      return true;
    } catch (e) {
      LoggerService.error('Error creating referral: $e');
      return false;
    }
  }

  /// Complete referral and award points
  Future<void> completeReferral(String referralId) async {
    try {
      final doc = await _referralsCollection.doc(referralId).get();
      if (!doc.exists) return;

      final referral = Referral.fromFirestore(doc);

      // Award points to referrer
      await addPoints(
        referral.referrerId,
        referral.rewardPoints,
        'referral',
        'Referral bonus dari teman baru',
      );

      // Update referral status
      await _referralsCollection.doc(referralId).update({
        'status': 'success',
        'completedAt': FieldValue.serverTimestamp(),
      });

      // Increment referral count
      await _loyaltyAccountsCollection.doc(referral.referrerId).update({
        'referralCount': FieldValue.increment(1),
      });

      LoggerService.info('Referral completed: $referralId');
    } catch (e) {
      LoggerService.error('Error completing referral: $e');
    }
  }

  // ==================== QUERY ====================

  /// Get points transaction history
  Future<List<PointsTransaction>> getTransactionHistory(
    String customerId,
  ) async {
    try {
      final querySnapshot = await _pointsTransactionsCollection
          .where('customerId', isEqualTo: customerId)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      return querySnapshot.docs
          .map((doc) => PointsTransaction.fromFirestore(doc))
          .toList();
    } catch (e) {
      LoggerService.error('Error getting transaction history: $e');
      return [];
    }
  }

  /// Get available rewards
  Future<List<Map<String, dynamic>>> getAvailableRewards(
    String customerId,
  ) async {
    try {
      final account = await getOrCreateAccount(customerId);

      return rewardsCatalog.map((reward) {
        return {
          ...reward,
          'canAfford': account.totalPoints >= reward['pointsCost'],
        };
      }).toList();
    } catch (e) {
      LoggerService.error('Error getting rewards: $e');
      return [];
    }
  }
}
