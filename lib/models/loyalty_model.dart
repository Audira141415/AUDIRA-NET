import 'package:cloud_firestore/cloud_firestore.dart';

/// Customer loyalty points
class LoyaltyAccount {
  final String customerId;
  final int totalPoints;
  final int lifetimePoints;
  final String tier; // bronze, silver, gold, platinum
  final int referralCount;
  final DateTime? lastActivityAt;

  LoyaltyAccount({
    required this.customerId,
    required this.totalPoints,
    required this.lifetimePoints,
    required this.tier,
    this.referralCount = 0,
    this.lastActivityAt,
  });

  factory LoyaltyAccount.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LoyaltyAccount(
      customerId: doc.id,
      totalPoints: data['totalPoints'] ?? 0,
      lifetimePoints: data['lifetimePoints'] ?? 0,
      tier: data['tier'] ?? 'bronze',
      referralCount: data['referralCount'] ?? 0,
      lastActivityAt: data['lastActivityAt'] != null
          ? (data['lastActivityAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalPoints': totalPoints,
      'lifetimePoints': lifetimePoints,
      'tier': tier,
      'referralCount': referralCount,
      'lastActivityAt':
          lastActivityAt != null ? Timestamp.fromDate(lastActivityAt!) : null,
    };
  }
}

/// Points transaction history
class PointsTransaction {
  final String id;
  final String customerId;
  final int points;
  final String type; // earn, redeem, bonus, referral
  final String description;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  PointsTransaction({
    required this.id,
    required this.customerId,
    required this.points,
    required this.type,
    required this.description,
    required this.createdAt,
    this.metadata,
  });

  factory PointsTransaction.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PointsTransaction(
      id: doc.id,
      customerId: data['customerId'] ?? '',
      points: data['points'] ?? 0,
      type: data['type'] ?? '',
      description: data['description'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      metadata: data['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'points': points,
      'type': type,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'metadata': metadata,
    };
  }
}

/// Reward catalog
class Reward {
  final String id;
  final String name;
  final String description;
  final int pointsCost;
  final String category; // discount, upgrade, cashback, voucher
  final String? imageUrl;
  final bool isActive;
  final int? stockLimit;
  final DateTime? expiryDate;

  Reward({
    required this.id,
    required this.name,
    required this.description,
    required this.pointsCost,
    required this.category,
    this.imageUrl,
    this.isActive = true,
    this.stockLimit,
    this.expiryDate,
  });

  factory Reward.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Reward(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      pointsCost: data['pointsCost'] ?? 0,
      category: data['category'] ?? '',
      imageUrl: data['imageUrl'],
      isActive: data['isActive'] ?? true,
      stockLimit: data['stockLimit'],
      expiryDate: data['expiryDate'] != null
          ? (data['expiryDate'] as Timestamp).toDate()
          : null,
    );
  }
}

/// Referral tracking
class Referral {
  final String id;
  final String referrerId; // Who referred
  final String referredId; // Who got referred
  final String status; // pending, success, expired
  final int rewardPoints;
  final DateTime createdAt;
  final DateTime? completedAt;

  Referral({
    required this.id,
    required this.referrerId,
    required this.referredId,
    required this.status,
    this.rewardPoints = 500,
    required this.createdAt,
    this.completedAt,
  });

  factory Referral.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Referral(
      id: doc.id,
      referrerId: data['referrerId'] ?? '',
      referredId: data['referredId'] ?? '',
      status: data['status'] ?? 'pending',
      rewardPoints: data['rewardPoints'] ?? 500,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      completedAt: data['completedAt'] != null
          ? (data['completedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'referrerId': referrerId,
      'referredId': referredId,
      'status': status,
      'rewardPoints': rewardPoints,
      'createdAt': Timestamp.fromDate(createdAt),
      'completedAt':
          completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    };
  }
}
