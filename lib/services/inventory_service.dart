import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/inventory_model.dart';
import 'logger_service.dart';

/// Service for Inventory Management
class InventoryService {
  static final InventoryService instance = InventoryService._internal();
  factory InventoryService() => instance;
  InventoryService._internal();

  final CollectionReference _inventoryCollection =
      FirebaseFirestore.instance.collection('inventory');
  final CollectionReference _stockRequestsCollection =
      FirebaseFirestore.instance.collection('stock_requests');
  final CollectionReference _stockLevelsCollection =
      FirebaseFirestore.instance.collection('stock_levels');

  // ==================== INVENTORY CATEGORIES ====================

  final List<Map<String, dynamic>> categories = [
    {'id': 'modem', 'name': 'Modem', 'icon': 'router'},
    {'id': 'router', 'name': 'Router', 'icon': 'wifi'},
    {'id': 'cable', 'name': 'Kabel', 'icon': 'cable'},
    {'id': 'tools', 'name': 'Peralatan', 'icon': 'build'},
    {'id': 'ont', 'name': 'ONT', 'icon': 'device_hub'},
  ];

  // ==================== INVENTORY ITEMS ====================

  /// Add new inventory item
  Future<String> addItem({
    required String name,
    required String category,
    required String barcode,
    required String serialNumber,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final itemData = {
        'name': name,
        'category': category,
        'barcode': barcode,
        'serialNumber': serialNumber,
        'status': 'available',
        'location': 'warehouse',
        'createdAt': FieldValue.serverTimestamp(),
        'metadata': metadata,
      };

      final docRef = await _inventoryCollection.add(itemData);

      // Update stock level
      await _updateStockLevel(category, name, 1);

      LoggerService.info('Inventory item added: ${docRef.id} - $name');
      return docRef.id;
    } catch (e) {
      LoggerService.error('Error adding inventory item: $e');
      rethrow;
    }
  }

  /// Assign item to teknisi
  Future<void> assignItem(
    String itemId,
    String teknisiId,
    String teknisiName,
  ) async {
    try {
      await _inventoryCollection.doc(itemId).update({
        'status': 'assigned',
        'assignedTo': teknisiId,
        'location': 'teknisi_$teknisiName',
        'assignedAt': FieldValue.serverTimestamp(),
      });

      LoggerService.info('Item $itemId assigned to $teknisiName');
    } catch (e) {
      LoggerService.error('Error assigning item: $e');
      rethrow;
    }
  }

  /// Return item to warehouse
  Future<void> returnItem(String itemId) async {
    try {
      await _inventoryCollection.doc(itemId).update({
        'status': 'available',
        'assignedTo': null,
        'location': 'warehouse',
        'assignedAt': null,
        'returnedAt': FieldValue.serverTimestamp(),
      });

      LoggerService.info('Item $itemId returned to warehouse');
    } catch (e) {
      LoggerService.error('Error returning item: $e');
      rethrow;
    }
  }

  /// Mark item as broken
  Future<void> markAsBroken(String itemId, String reason) async {
    try {
      await _inventoryCollection.doc(itemId).update({
        'status': 'broken',
        'metadata.brokenReason': reason,
        'metadata.brokenAt': FieldValue.serverTimestamp(),
      });

      LoggerService.info('Item $itemId marked as broken');
    } catch (e) {
      LoggerService.error('Error marking item as broken: $e');
      rethrow;
    }
  }

  // ==================== QUERY INVENTORY ====================

  /// Get all inventory items
  Future<List<InventoryItem>> getAllItems({String? category, String? status}) async {
    try {
      Query query = _inventoryCollection.orderBy('createdAt', descending: true);

      if (category != null) {
        query = query.where('category', isEqualTo: category);
      }

      if (status != null) {
        query = query.where('status', isEqualTo: status);
      }

      final querySnapshot = await query.get();

      return querySnapshot.docs
          .map((doc) => InventoryItem.fromFirestore(doc))
          .toList();
    } catch (e) {
      LoggerService.error('Error getting inventory items: $e');
      return [];
    }
  }

  /// Get items assigned to teknisi
  Future<List<InventoryItem>> getTeknisiItems(String teknisiId) async {
    try {
      final querySnapshot = await _inventoryCollection
          .where('assignedTo', isEqualTo: teknisiId)
          .get();

      return querySnapshot.docs
          .map((doc) => InventoryItem.fromFirestore(doc))
          .toList();
    } catch (e) {
      LoggerService.error('Error getting teknisi items: $e');
      return [];
    }
  }

  /// Search item by barcode
  Future<InventoryItem?> findByBarcode(String barcode) async {
    try {
      final querySnapshot = await _inventoryCollection
          .where('barcode', isEqualTo: barcode)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return null;

      return InventoryItem.fromFirestore(querySnapshot.docs.first);
    } catch (e) {
      LoggerService.error('Error finding item by barcode: $e');
      return null;
    }
  }

  // ==================== STOCK REQUESTS ====================

  /// Create stock request
  Future<String> createStockRequest({
    required String teknisiId,
    required String teknisiName,
    required List<RequestItem> items,
    String? notes,
  }) async {
    try {
      final requestData = {
        'teknisiId': teknisiId,
        'teknisiName': teknisiName,
        'items': items.map((i) => i.toJson()).toList(),
        'status': 'pending',
        'notes': notes,
        'createdAt': FieldValue.serverTimestamp(),
      };

      final docRef = await _stockRequestsCollection.add(requestData);

      LoggerService.info('Stock request created: ${docRef.id} by $teknisiName');
      return docRef.id;
    } catch (e) {
      LoggerService.error('Error creating stock request: $e');
      rethrow;
    }
  }

  /// Approve stock request
  Future<void> approveStockRequest(String requestId, String adminId) async {
    try {
      await _stockRequestsCollection.doc(requestId).update({
        'status': 'approved',
        'processedAt': FieldValue.serverTimestamp(),
        'processedBy': adminId,
      });

      LoggerService.info('Stock request approved: $requestId');
    } catch (e) {
      LoggerService.error('Error approving stock request: $e');
      rethrow;
    }
  }

  /// Reject stock request
  Future<void> rejectStockRequest(
    String requestId,
    String adminId,
    String reason,
  ) async {
    try {
      await _stockRequestsCollection.doc(requestId).update({
        'status': 'rejected',
        'processedAt': FieldValue.serverTimestamp(),
        'processedBy': adminId,
        'notes': reason,
      });

      LoggerService.info('Stock request rejected: $requestId');
    } catch (e) {
      LoggerService.error('Error rejecting stock request: $e');
      rethrow;
    }
  }

  /// Get stock requests
  Future<List<StockRequest>> getStockRequests({String? status, String? teknisiId}) async {
    try {
      Query query = _stockRequestsCollection.orderBy('createdAt', descending: true);

      if (status != null) {
        query = query.where('status', isEqualTo: status);
      }

      if (teknisiId != null) {
        query = query.where('teknisiId', isEqualTo: teknisiId);
      }

      final querySnapshot = await query.get();

      return querySnapshot.docs
          .map((doc) => StockRequest.fromFirestore(doc))
          .toList();
    } catch (e) {
      LoggerService.error('Error getting stock requests: $e');
      return [];
    }
  }

  // ==================== STOCK LEVELS ====================

  /// Update stock level
  Future<void> _updateStockLevel(
    String category,
    String itemName,
    int change,
  ) async {
    try {
      final id = '${category}_$itemName'.replaceAll(' ', '_').toLowerCase();
      final doc = await _stockLevelsCollection.doc(id).get();

      if (doc.exists) {
        final current = (doc.data() as Map<String, dynamic>)['currentStock'] ?? 0;
        await _stockLevelsCollection.doc(id).update({
          'currentStock': current + change,
        });
      } else {
        await _stockLevelsCollection.doc(id).set({
          'category': category,
          'itemName': itemName,
          'currentStock': change,
          'minimumStock': 5,
          'maximumStock': 100,
          'location': 'warehouse',
        });
      }
    } catch (e) {
      LoggerService.error('Error updating stock level: $e');
    }
  }

  /// Get stock levels
  Future<List<StockLevel>> getStockLevels() async {
    try {
      final querySnapshot = await _stockLevelsCollection.get();

      return querySnapshot.docs
          .map((doc) => StockLevel.fromFirestore(doc))
          .toList();
    } catch (e) {
      LoggerService.error('Error getting stock levels: $e');
      return [];
    }
  }

  /// Get low stock items
  Future<List<StockLevel>> getLowStockItems() async {
    try {
      final levels = await getStockLevels();
      return levels.where((level) => level.isLowStock).toList();
    } catch (e) {
      LoggerService.error('Error getting low stock items: $e');
      return [];
    }
  }

  // ==================== STATISTICS ====================

  /// Get inventory statistics
  Future<Map<String, dynamic>> getInventoryStats() async {
    try {
      final items = await getAllItems();

      final stats = {
        'total': items.length,
        'available': items.where((i) => i.status == 'available').length,
        'assigned': items.where((i) => i.status == 'assigned').length,
        'maintenance': items.where((i) => i.status == 'maintenance').length,
        'broken': items.where((i) => i.status == 'broken').length,
      };

      // Count by category
      for (var category in categories) {
        final count = items.where((i) => i.category == category['id']).length;
        stats[category['id']] = count;
      }

      return stats;
    } catch (e) {
      LoggerService.error('Error getting inventory stats: $e');
      return {};
    }
  }
}
