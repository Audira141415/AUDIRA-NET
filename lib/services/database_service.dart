import 'dart:developer' as developer;
import 'package:sqflite/sqflite.dart';
import '../utils/logger.dart';
import 'package:path/path.dart';
import '../utils/password_helper.dart';
import 'logger_service.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('audira.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 16, // Add billing and alert tables
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    // Upgrading database structure

    // Add billing and alert tables for v15 -> v16
    if (oldVersion == 15 && newVersion == 16) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS promotions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          customerId TEXT NOT NULL,
          promoType TEXT NOT NULL,
          discountPercent REAL NOT NULL,
          validUntil TEXT NOT NULL,
          isActive INTEGER DEFAULT 1,
          createdAt TEXT NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS payment_plans (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          customerId TEXT NOT NULL,
          planName TEXT NOT NULL,
          monthlyAmount INTEGER NOT NULL,
          durationMonths INTEGER NOT NULL,
          remainingMonths INTEGER NOT NULL,
          isActive INTEGER DEFAULT 1,
          createdAt TEXT NOT NULL
        )
      ''');
      return;
    }

    // Add internetNumber to customers for v14 -> v15
    if (oldVersion == 14 && newVersion == 15) {
      await db.execute('ALTER TABLE customers ADD COLUMN internetNumber TEXT');
      return;
    }

    // Add tickets table for v13 -> v14
    if (oldVersion == 13 && newVersion == 14) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS tickets (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          customerId INTEGER NOT NULL,
          subject TEXT NOT NULL,
          description TEXT NOT NULL,
          priority TEXT NOT NULL,
          status TEXT NOT NULL,
          createdAt TEXT NOT NULL,
          updatedAt TEXT NOT NULL,
          FOREIGN KEY (customerId) REFERENCES customers (id) ON DELETE CASCADE
        )
      ''');
      return;
    }

    // Add photo fields for v12 -> v13
    if (oldVersion == 12 && newVersion == 13) {
      await db.execute(
        'ALTER TABLE support_tickets ADD COLUMN photoBeforePath TEXT',
      );
      await db.execute(
        'ALTER TABLE support_tickets ADD COLUMN photoAfterPath TEXT',
      );
      return;
    }

    // Add progressNotes field for v11 -> v12
    if (oldVersion == 11 && newVersion == 12) {
      await db.execute(
        'ALTER TABLE support_tickets ADD COLUMN progressNotes TEXT',
      );
      return;
    }

    // Force recreation for v10 -> v11 (fix teknisi users)
    if (oldVersion == 10 && newVersion == 11) {
      await db.execute('DROP TABLE IF EXISTS checkins');
      await db.execute('DROP TABLE IF EXISTS rewards');
      await db.execute('DROP TABLE IF EXISTS installations');
      await db.execute('DROP TABLE IF EXISTS support_tickets');
      await db.execute('DROP TABLE IF EXISTS speed_tests');
      await db.execute('DROP TABLE IF EXISTS bills');
      await db.execute('DROP TABLE IF EXISTS payments');
      await db.execute('DROP TABLE IF EXISTS customers');
      await db.execute('DROP TABLE IF EXISTS users');

      // Recreate everything
      await _createDB(db, newVersion);
      return;
    }

    // Upgrade from v8 to v9: Add zone support
    if (oldVersion == 8 && newVersion == 9) {
      // Upgrading v8 -> v9: Adding zone support
      await db.execute('ALTER TABLE users ADD COLUMN zone TEXT');
      await db.execute('ALTER TABLE support_tickets ADD COLUMN zone TEXT');
      // Set default zones
      await db.execute(
        '''UPDATE users SET zone = "Jakarta Pusat" WHERE role = "teknisi"''',
      );
      await db.execute(
        '''UPDATE support_tickets SET zone = "Jakarta Pusat" WHERE zone IS NULL''',
      );
      return;
    }

    // For major version changes, recreate all tables
    if (oldVersion < 8) {
      // Major upgrade detected - recreating all tables

      // Drop all existing tables
      await db.execute('DROP TABLE IF EXISTS checkins');
      await db.execute('DROP TABLE IF EXISTS rewards');
      await db.execute('DROP TABLE IF EXISTS installations');
      await db.execute('DROP TABLE IF EXISTS support_tickets');
      await db.execute('DROP TABLE IF EXISTS speed_tests');
      await db.execute('DROP TABLE IF EXISTS payments');
      await db.execute('DROP TABLE IF EXISTS bills');
      await db.execute('DROP TABLE IF EXISTS customers');
      await db.execute('DROP TABLE IF EXISTS users');

      // Recreate everything
      await _createDB(db, newVersion);
      return;
    }
  }

  Future<void> _createDB(Database db, int version) async {
    // Creating database version
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';

    // Tabel Users
    await db.execute('''
      CREATE TABLE users (
        id $idType,
        email $textType UNIQUE,
        password $textType,
        name $textType,
        phone TEXT,
        role $textType,
        zone TEXT,
        isActive $intType DEFAULT 1,
        createdAt $textType,
        updatedAt $textType
      )
    ''');

    // Tabel Customers (relasi dengan users)
    await db.execute('''
      CREATE TABLE customers (
        id $idType,
        userId INTEGER NOT NULL,
        customerId $textType UNIQUE,
        internetNumber TEXT,
        address TEXT,
        packageId INTEGER,
        packageName TEXT,
        speed INTEGER,
        price INTEGER,
        status $textType,
        installDate TEXT,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // Tabel Installations
    await db.execute('''
      CREATE TABLE IF NOT EXISTS installations (
        id $idType,
        customerName $textType,
        phone $textType,
        address $textType,
        packageName $textType,
        speed INTEGER NOT NULL,
        price INTEGER NOT NULL,
        scheduledDate $textType,
        scheduledTime $textType,
        status $textType,
        notes TEXT,
        teknisiId INTEGER,
        latitude REAL,
        longitude REAL,
        createdAt $textType,
        completedAt TEXT,
        FOREIGN KEY (teknisiId) REFERENCES users (id) ON DELETE SET NULL
      )
    ''');

    // Insert users dengan hashed passwords
    await db.insert('users', {
      'email': 'admin@audiranet.com',
      'password': PasswordHelper.hashPassword('admin123'),
      'name': 'Admin Audira',
      'phone': '081234567890',
      'role': 'admin',
      'isActive': 1,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    });

    await db.insert('users', {
      'email': 'teknisi@audiranet.com',
      'password': PasswordHelper.hashPassword('teknisi123'),
      'name': 'Teknisi Support',
      'phone': '081234567899',
      'role': 'teknisi',
      'zone': 'Batam Center',
      'isActive': 1,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    });

    await db.insert('users', {
      'email': 'teknisi_batamcenter@audiranet.com',
      'password': PasswordHelper.hashPassword('teknisi123'),
      'name': 'Teknisi Batam Center',
      'phone': '081234567801',
      'role': 'teknisi',
      'zone': 'Batam Center',
      'isActive': 1,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    });

    await db.insert('users', {
      'email': 'teknisi_piayu@audiranet.com',
      'password': PasswordHelper.hashPassword('teknisi123'),
      'name': 'Teknisi Piayu',
      'phone': '081234567802',
      'role': 'teknisi',
      'zone': 'Piayu',
      'isActive': 1,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    });

    await db.insert('users', {
      'email': 'teknisi_baloi@audiranet.com',
      'password': PasswordHelper.hashPassword('teknisi123'),
      'name': 'Teknisi Baloi',
      'phone': '081234567803',
      'role': 'teknisi',
      'zone': 'Baloi',
      'isActive': 1,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    });

    await db.insert('users', {
      'email': 'budi@email.com',
      'password': PasswordHelper.hashPassword('123456'),
      'name': 'Budi Santoso',
      'phone': '081234567891',
      'role': 'customer',
      'isActive': 1,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    });

    await db.insert('users', {
      'email': 'siti@email.com',
      'password': PasswordHelper.hashPassword('123456'),
      'name': 'Siti Rahayu',
      'phone': '081234567892',
      'role': 'customer',
      'isActive': 1,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    });

    // Insert customers
    await db.insert('customers', {
      'userId': 3,
      'customerId': 'ADN-2025-001',
      'address': 'Jl. Merdeka No. 123, Jakarta',
      'packageId': 1,
      'packageName': '50 Mbps - Unlimited',
      'speed': 50,
      'price': 350000,
      'status': 'active',
      'installDate': '2025-01-15',
    });

    await db.insert('customers', {
      'userId': 4,
      'customerId': 'ADN-2025-002',
      'address': 'Jl. Sudirman No. 456, Jakarta',
      'packageId': 2,
      'packageName': '30 Mbps - Unlimited',
      'speed': 30,
      'price': 250000,
      'status': 'active',
      'installDate': '2025-02-01',
    });

    // Seed installations
    await db.insert('installations', {
      'customerName': 'Andi Wijaya',
      'phone': '081234567890',
      'address': 'Jl. Sudirman No. 45, Jakarta Pusat',
      'packageName': '100 Mbps - Premium',
      'speed': 100,
      'price': 500000,
      'scheduledDate': '2025-11-15',
      'scheduledTime': '09:00',
      'status': 'scheduled',
      'notes': 'Instalasi baru - Perlu router baru',
      'latitude': -6.2088,
      'longitude': 106.8456,
      'createdAt': DateTime.now().toIso8601String(),
    });

    await db.insert('installations', {
      'customerName': 'Sari Indah',
      'phone': '081345678901',
      'address': 'Jl. Thamrin No. 78, Jakarta Pusat',
      'packageName': '30 Mbps - Basic',
      'speed': 30,
      'price': 250000,
      'scheduledDate': '2025-11-16',
      'scheduledTime': '10:00',
      'status': 'scheduled',
      'notes': 'Instalasi baru - Apartemen lantai 15',
      'latitude': -6.1751,
      'longitude': 106.8650,
      'createdAt': DateTime.now().toIso8601String(),
    });

    await db.insert('installations', {
      'customerName': 'Dewi Lestari',
      'phone': '081456789012',
      'address': 'Jl. Kuningan No. 23, Jakarta Selatan',
      'packageName': '100 Mbps - Premium',
      'speed': 100,
      'price': 500000,
      'scheduledDate': '2025-11-17',
      'scheduledTime': '11:00',
      'status': 'scheduled',
      'notes': 'Instalasi rumah 2 lantai',
      'latitude': -6.1862,
      'longitude': 106.8063,
      'createdAt': DateTime.now().toIso8601String(),
    });

    // Database created and seeded with demo data

    // Create additional tables
    await _createNewTables(db);
    await _createCheckInsAndRewardsTables(db);

    // All database tables created successfully
  }

  Future<void> _createNewTables(Database db) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';

    // Tabel Bills (Tagihan)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS bills (
        id $idType,
        customerId INTEGER NOT NULL,
        billMonth $textType,
        amount INTEGER NOT NULL,
        dueDate $textType,
        status $textType,
        paidDate TEXT,
        createdAt $textType,
        FOREIGN KEY (customerId) REFERENCES customers (id) ON DELETE CASCADE
      )
    ''');

    // Tabel Payments (Pembayaran)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS payments (
        id $idType,
        billId INTEGER NOT NULL,
        customerId INTEGER NOT NULL,
        amount INTEGER NOT NULL,
        paymentMethod $textType,
        paymentStatus $textType,
        transactionId TEXT,
        paidAt $textType,
        FOREIGN KEY (billId) REFERENCES bills (id) ON DELETE CASCADE,
        FOREIGN KEY (customerId) REFERENCES customers (id) ON DELETE CASCADE
      )
    ''');

    // Tabel Speed Tests
    await db.execute('''
      CREATE TABLE IF NOT EXISTS speed_tests (
        id $idType,
        customerId INTEGER NOT NULL,
        downloadSpeed REAL NOT NULL,
        uploadSpeed REAL NOT NULL,
        latency REAL NOT NULL,
        connectionType $textType,
        testDate $textType,
        FOREIGN KEY (customerId) REFERENCES customers (id) ON DELETE CASCADE
      )
    ''');

    // Tabel Tickets (untuk mock data)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS tickets (
        id $idType,
        customerId INTEGER NOT NULL,
        subject $textType,
        description TEXT NOT NULL,
        priority $textType,
        status $textType,
        createdAt $textType,
        updatedAt $textType,
        FOREIGN KEY (customerId) REFERENCES customers (id) ON DELETE CASCADE
      )
    ''');

    // Tabel Support Tickets
    await db.execute('''
      CREATE TABLE IF NOT EXISTS support_tickets (
        id $idType,
        customerId INTEGER NOT NULL,
        ticketId $textType UNIQUE,
        subject $textType,
        description TEXT NOT NULL,
        status $textType,
        priority $textType,
        zone TEXT,
        teknisiId INTEGER,
        assignedAt TEXT,
        progressNotes TEXT,
        photoBeforePath TEXT,
        photoAfterPath TEXT,
        createdAt $textType,
        updatedAt $textType,
        resolvedAt TEXT,
        FOREIGN KEY (customerId) REFERENCES customers (id) ON DELETE CASCADE,
        FOREIGN KEY (teknisiId) REFERENCES users (id) ON DELETE SET NULL
      )
    ''');

    // Seed mock support tickets
    await db.insert('support_tickets', {
      'customerId': 1,
      'ticketId': 'TKT-2025-001',
      'subject': 'Gangguan koneksi internet',
      'description': 'Internet sering putus-putus, terutama saat malam hari',
      'status': 'open',
      'priority': 'high',
      'zone': 'Batam Center',
      'createdAt': '2025-11-14T10:30:00.000',
      'updatedAt': '2025-11-14T10:30:00.000',
    });

    await db.insert('support_tickets', {
      'customerId': 2,
      'ticketId': 'TKT-2025-002',
      'subject': 'Request upgrade paket',
      'description': 'Ingin upgrade dari 30 Mbps ke 50 Mbps',
      'status': 'open',
      'priority': 'medium',
      'zone': 'Piayu',
      'createdAt': '2025-11-13T15:20:00.000',
      'updatedAt': '2025-11-14T09:15:00.000',
    });

    await db.insert('support_tickets', {
      'customerId': 1,
      'ticketId': 'TKT-2025-003',
      'subject': 'Instalasi perangkat tambahan',
      'description': 'Minta dipasang access point tambahan di lantai 2',
      'status': 'open',
      'priority': 'low',
      'zone': 'Baloi',
      'createdAt': '2025-11-12T11:45:00.000',
      'updatedAt': '2025-11-13T16:30:00.000',
    });

    await db.insert('support_tickets', {
      'customerId': 2,
      'ticketId': 'TKT-2025-004',
      'subject': 'Modem tidak menyala',
      'description':
          'Modem mati total, lampu indikator tidak menyala sama sekali',
      'status': 'open',
      'priority': 'high',
      'zone': 'Batam Center',
      'createdAt': '2025-11-14T08:00:00.000',
      'updatedAt': '2025-11-14T08:00:00.000',
    });

    await db.insert('support_tickets', {
      'customerId': 1,
      'ticketId': 'TKT-2025-005',
      'subject': 'Kecepatan tidak sesuai paket',
      'description': 'Paket 50 Mbps tapi kecepatan hanya 20 Mbps',
      'status': 'open',
      'priority': 'medium',
      'zone': 'Piayu',
      'createdAt': '2025-11-14T14:20:00.000',
      'updatedAt': '2025-11-14T14:20:00.000',
    });

    // New tables created and seeded with demo data
  }

  Future<void> _createCheckInsAndRewardsTables(Database db) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';

    // Tabel Check-ins (Daily Check-in Teknisi)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS checkins (
        id $idType,
        teknisiId INTEGER NOT NULL,
        checkInDate $textType,
        checkInTime $textType,
        photoPath TEXT NOT NULL,
        points INTEGER DEFAULT 10,
        streak INTEGER DEFAULT 1,
        bonusPoints INTEGER DEFAULT 0,
        createdAt $textType,
        FOREIGN KEY (teknisiId) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // Tabel Rewards/Badges
    await db.execute('''
      CREATE TABLE IF NOT EXISTS rewards (
        id $idType,
        teknisiId INTEGER NOT NULL,
        type $textType,
        title $textType,
        description TEXT NOT NULL,
        points INTEGER NOT NULL,
        earnedAt $textType,
        FOREIGN KEY (teknisiId) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // Tabel Maintenance Schedule
    await db.execute('''
      CREATE TABLE IF NOT EXISTS maintenance_schedules (
        id $idType,
        title $textType,
        description TEXT NOT NULL,
        maintenanceType $textType,
        scheduledDate $textType,
        startTime $textType,
        endTime $textType,
        affectedAreas TEXT,
        status $textType,
        priority $textType,
        notificationSent INTEGER DEFAULT 0,
        createdAt $textType,
        updatedAt $textType
      )
    ''');

    // Insert demo maintenance schedules
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    final nextWeek = now.add(const Duration(days: 7));

    await db.insert('maintenance_schedules', {
      'title': 'Pemeliharaan Rutin Jaringan Area Barat',
      'description':
          'Pemeliharaan dan upgrade perangkat jaringan untuk meningkatkan kualitas layanan di area Jakarta Barat.',
      'maintenanceType': 'network',
      'scheduledDate': tomorrow.toIso8601String().split('T')[0],
      'startTime': '02:00',
      'endTime': '06:00',
      'affectedAreas': 'Jakarta Barat, Tangerang',
      'status': 'scheduled',
      'priority': 'high',
      'notificationSent': 0,
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
    });

    await db.insert('maintenance_schedules', {
      'title': 'Update Server Database',
      'description':
          'Pembaruan sistem database untuk peningkatan performa dan keamanan.',
      'maintenanceType': 'server',
      'scheduledDate': nextWeek.toIso8601String().split('T')[0],
      'startTime': '00:00',
      'endTime': '04:00',
      'affectedAreas': 'Semua Area',
      'status': 'scheduled',
      'priority': 'medium',
      'notificationSent': 0,
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
    });

    // Insert demo check-ins for testing gamification
    final currentDate = DateTime.now();
    for (int i = 0; i < 10; i++) {
      final checkInDate = currentDate.subtract(Duration(days: i));
      await db.insert('checkins', {
        'teknisiId': 2, // teknisi ID
        'checkInDate': checkInDate.toIso8601String().split('T')[0],
        'checkInTime': '08:${30 + i}:00',
        'photoPath':
            '/storage/emulated/0/AudiraApp/checkin_${checkInDate.millisecondsSinceEpoch}.jpg',
        'points': 10 + (i % 3 * 5),
        'streak': i + 1,
        'bonusPoints': i % 3 == 0 ? 5 : 0,
        'createdAt': checkInDate.toIso8601String(),
      });
    }

    // Check-ins and Rewards tables created
  }

  // Login user
  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      LoggerService.dbInfo('🗃️ DatabaseService.login() called with:');
      LoggerService.dbInfo('   Email: $email');
      LoggerService.dbInfo('   Password: $password');

      final db = await instance.database;

      // Cari user berdasarkan email saja
      final userCheck = await db.query(
        'users',
        where: 'email = ? AND isActive = 1',
        whereArgs: [email],
      );

      LoggerService.dbInfo('   Users found: ${userCheck.length}');

      if (userCheck.isEmpty) {
        LoggerService.dbInfo('   🔄 Checking if database is empty...');

        // Check if database is completely empty
        final allUsers = await db.query('users');
        if (allUsers.isEmpty) {
          LoggerService.dbError(
            '   ❌ Database is completely empty! Force populating...',
          );
          await forcePopulateDefaultUsers();

          // Try query again after population
          final retryUserCheck = await db.query(
            'users',
            where: 'email = ? AND isActive = 1',
            whereArgs: [email],
          );

          if (retryUserCheck.isNotEmpty) {
            LoggerService.dbInfo(
              '   ✅ User found after population: ${retryUserCheck.length}',
            );
            final user = retryUserCheck.first;
            final storedPassword = user['password'] as String;
            LoggerService.dbInfo(
              '   User found: ${user['name']} (${user['role']})',
            );
            LoggerService.dbInfo(
              '   Stored password: "$storedPassword" ($storedPassword.length chars)',
            );

            bool passwordMatch = false;
            if (storedPassword.length == 64) {
              LoggerService.dbInfo('   Using hashed password verification...');
              passwordMatch = PasswordHelper.verifyPassword(
                password,
                storedPassword,
              );
              LoggerService.dbInfo(
                '   Hash verification result: $passwordMatch',
              );
            } else {
              LoggerService.dbInfo('   Using plain text verification...');
              passwordMatch = (password == storedPassword);
              LoggerService.dbInfo(
                '   Plain text verification result: $passwordMatch',
              );
            }

            if (passwordMatch) {
              LoggerService.dbInfo('   ✅ Login successful after population');
              return user;
            } else {
              LoggerService.dbInfo('   ❌ Password mismatch after population');
              return null;
            }
          } else {
            LoggerService.dbInfo('   ❌ User still not found after population');
            return null;
          }
        } else {
          LoggerService.dbInfo('No user found with email: $email');

          // Debug: Show some example users
          LoggerService.dbInfo('   🔍 Sample users in database:');
          for (int i = 0; i < allUsers.length && i < 10; i++) {
            final user = allUsers[i];
            LoggerService.dbInfo(
              '     User ${i + 1}: ${user['email']} (${user['role']})',
            );
          }

          // Check if target user exists but inactive
          final userInactive = await db.query(
            'users',
            where: 'email = ?',
            whereArgs: [email],
          );

          if (userInactive.isNotEmpty) {
            final user = userInactive.first;
            LoggerService.dbInfo('   🔍 Found target user but inactive:');
            LoggerService.dbInfo('Database operation completed');
            LoggerService.dbInfo('Database operation completed');
            LoggerService.dbInfo('Database operation completed');
            LoggerService.dbInfo('Database operation completed');

            if (user['isActive'] == 0) {
              LoggerService.dbInfo('   🔧 FIXING: Activating user...');
              await db.update(
                'users',
                {'isActive': 1},
                where: 'email = ?',
                whereArgs: [email],
              );
              LoggerService.dbInfo('   ✅ User activated, retrying login...');

              // Retry login
              return login(email, password);
            }
          } else {
            LoggerService.dbInfo('   ❌ Target user does not exist at all');
            LoggerService.dbInfo(
              '   🔧 Creating missing user with complete data...',
            );

            // Create user first
            final userId = await db.insert('users', {
              'email': email,
              'password': PasswordHelper.hashPassword(password),
              'name': email == 'budi@email.com' ? 'Budi Santoso' : 'Customer',
              'phone': '081234567891',
              'role': 'customer',
              'isActive': 1,
              'createdAt': DateTime.now().toIso8601String(),
              'updatedAt': DateTime.now().toIso8601String(),
            });

            LoggerService.dbInfo('   ✅ User created with ID: $userId');

            // Create customer data for the user
            if (email == 'budi@email.com') {
              final customerId = 'ADN-2025-001';
              await db.insert('customers', {
                'userId': userId,
                'customerId': customerId,
                'internetNumber': 'INT-2025-001',
                'address': 'Jl. Merdeka No. 123, Jakarta Pusat',
                'packageName': '50 Mbps - Unlimited',
                'speed': 50,
                'price': 350000,
                'status': 'active',
                'installDate': '2025-01-15',
              });

              LoggerService.dbInfo('   ✅ Customer data created: $customerId');

              // Create sample bills
              await db.insert('bills', {
                'customerId': 1, // Customer table ID
                'billMonth': 'November 2025',
                'amount': 350000,
                'dueDate': '2025-11-30',
                'status': 'unpaid',
                'createdAt': DateTime.now().toIso8601String(),
              });

              await db.insert('bills', {
                'customerId': 1,
                'billMonth': 'Oktober 2025',
                'amount': 350000,
                'dueDate': '2025-10-31',
                'status': 'paid',
                'paidDate': '2025-10-25',
                'createdAt': DateTime.now()
                    .subtract(Duration(days: 30))
                    .toIso8601String(),
              });

              LoggerService.dbInfo('   ✅ Sample bills created');
            }

            LoggerService.dbInfo('   🔄 Retrying login with complete data...');
            return login(email, password);
          }

          return null;
        }
      }

      final user = userCheck.first;
      final storedPassword = user['password'] as String;
      LoggerService.dbInfo('   User found: ${user['name']} (${user['role']})');
      LoggerService.dbInfo(
        '   Stored password length: ${storedPassword.length} chars',
      );

      // Verify password - support both plain text (untuk backward compatibility)
      // dan hashed password
      bool passwordMatch = false;

      // Cek apakah password di database sudah di-hash (64 karakter = SHA-256)
      if (storedPassword.length == 64) {
        LoggerService.dbInfo('   Using hashed password verification...');
        // Password sudah di-hash, gunakan verifyPassword
        passwordMatch = PasswordHelper.verifyPassword(password, storedPassword);
        LoggerService.dbInfo('   Hash verification result: $passwordMatch');
      } else {
        LoggerService.dbInfo('   Using plain text verification...');
        // Password masih plain text (untuk backward compatibility)
        passwordMatch = (password == storedPassword);
        LoggerService.dbInfo(
          '   Plain text verification result: $passwordMatch',
        );
      }

      if (passwordMatch) {
        LoggerService.dbInfo('   ✅ Login successful');
        // Login successful
        return user;
      } else {
        LoggerService.dbInfo('   ❌ Password mismatch');
        // Password mismatch
        return null;
      }
    } catch (e) {
      LoggerService.dbInfo('   💥 Database login ERROR: $e');
      // Error during login
      return null;
    }
  }

  // Get all installations
  Future<List<Map<String, dynamic>>> getAllInstallations() async {
    final db = await instance.database;
    return await db.query(
      'installations',
      orderBy: 'scheduledDate ASC, scheduledTime ASC',
    );
  }

  // Count installations by status
  Future<int> countInstallationsByStatus(String status) async {
    final db = await instance.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM installations WHERE status = ?',
      [status],
    );
    return result.first['count'] as int;
  }

  // Get all support tickets
  Future<List<Map<String, dynamic>>> getAllTickets() async {
    final db = await instance.database;

    return await db.rawQuery('''
      SELECT t.*, c.customerId, u.name, u.phone
      FROM support_tickets t
      JOIN customers c ON t.customerId = c.id
      JOIN users u ON c.userId = u.id
      ORDER BY t.createdAt DESC
    ''');
  }

  // Check daily check-in status
  Future<bool> hasCheckedInToday(int teknisiId) async {
    final db = await instance.database;
    final today = DateTime.now().toIso8601String().split('T')[0];

    final result = await db.query(
      'checkins',
      where: 'teknisiId = ? AND checkInDate = ?',
      whereArgs: [teknisiId, today],
    );

    return result.isNotEmpty;
  }

  // Save daily check-in
  Future<void> saveCheckIn(int teknisiId, String photoPath) async {
    try {
      final db = await instance.database;
      final now = DateTime.now();
      final today = now.toIso8601String().split('T')[0];

      await db.insert('checkins', {
        'teknisiId': teknisiId,
        'checkInDate': today,
        'checkInTime':
            '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:00',
        'photoPath': photoPath,
        'points': 10,
        'streak': 1,
        'bonusPoints': 0,
        'createdAt': now.toIso8601String(),
      });
    } catch (e) {
      // Error saving check-in
      rethrow;
    }
  }

  // Get leaderboard
  Future<List<Map<String, dynamic>>> getLeaderboard({int limit = 20}) async {
    final db = await instance.database;

    return await db.rawQuery('''
      SELECT 
        u.name,
        u.id as userId,
        SUM(c.points + c.bonusPoints) as totalPoints,
        COUNT(c.id) as totalCheckins,
        MAX(c.streak) as maxStreak
      FROM users u
      LEFT JOIN checkins c ON u.id = c.teknisiId
      WHERE u.role = 'teknisi'
      GROUP BY u.id, u.name
      ORDER BY totalPoints DESC, totalCheckins DESC
      LIMIT $limit
    ''');
  }

  // Get check-in history
  Future<List<Map<String, dynamic>>> getCheckInHistory(
    int teknisiId, {
    int limit = 90,
  }) async {
    final db = await instance.database;

    return await db.query(
      'checkins',
      where: 'teknisiId = ?',
      whereArgs: [teknisiId],
      orderBy: 'checkInDate DESC, checkInTime DESC',
      limit: limit,
    );
  }

  // Additional methods needed by the app
  Future<List<Map<String, dynamic>>> getBillsByCustomerId(
    int customerId,
  ) async {
    final db = await instance.database;
    return await db.query(
      'bills',
      where: 'customerId = ?',
      whereArgs: [customerId],
    );
  }

  Future<List<Map<String, dynamic>>> getTicketsByCustomerId(
    int customerId,
  ) async {
    final db = await instance.database;
    return await db.query(
      'support_tickets',
      where: 'customerId = ?',
      whereArgs: [customerId],
    );
  }

  Future<int> createTicket(
    int customerId,
    String subject,
    String description,
    String priority,
    String? zone,
  ) async {
    try {
      final db = await instance.database;
      final ticketCount = (await db.query('support_tickets')).length + 1;
      final ticketId =
          'TKT-${DateTime.now().year}-${ticketCount.toString().padLeft(3, '0')}';

      return await db.insert('support_tickets', {
        'customerId': customerId,
        'ticketId': ticketId,
        'subject': subject,
        'description': description,
        'status': 'open',
        'priority': priority,
        'zone': zone,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Error creating ticket
      rethrow;
    }
  }

  Future<int> createInstallation(Map<String, dynamic> data) async {
    try {
      final db = await instance.database;
      return await db.insert('installations', data);
    } catch (e) {
      // Error creating installation
      rethrow;
    }
  }

  Future<void> deleteInstallation(int id) async {
    try {
      final db = await instance.database;
      await db.delete('installations', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      // Error deleting installation
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getAllSpeedTests() async {
    final db = await instance.database;
    return await db.rawQuery('''
      SELECT st.*, u.name as customerName
      FROM speed_tests st
      JOIN customers c ON st.customerId = c.id
      JOIN users u ON c.userId = u.id
      ORDER BY st.testDate DESC
    ''');
  }

  Future<List<Map<String, dynamic>>> getRewardsByTeknisiId(
    int teknisiId,
  ) async {
    final db = await instance.database;
    return await db.query(
      'rewards',
      where: 'teknisiId = ?',
      whereArgs: [teknisiId],
    );
  }

  Future<int> getTeknisiRank(int teknisiId) async {
    final leaderboard = await getLeaderboard();
    for (int i = 0; i < leaderboard.length; i++) {
      if (leaderboard[i]['userId'] == teknisiId) {
        return i + 1;
      }
    }
    return leaderboard.length + 1;
  }

  Future<Map<String, int>> getInstallationStats() async {
    final scheduled = await countInstallationsByStatus('scheduled');
    final completed = await countInstallationsByStatus('completed');
    final total = scheduled + completed;

    return {'scheduled': scheduled, 'completed': completed, 'total': total};
  }

  Future<Map<String, dynamic>> createCheckIn(
    int teknisiId,
    String photoPath,
  ) async {
    await saveCheckIn(teknisiId, photoPath);
    return {'success': true, 'points': 10, 'streak': 1};
  }

  Future<List<Map<String, dynamic>>> getInstallationsByDate(String date) async {
    final db = await instance.database;
    return await db.query(
      'installations',
      where: 'scheduledDate = ?',
      whereArgs: [date],
    );
  }

  Future<void> resetDatabase() async {
    final db = await instance.database;
    await db.execute('DELETE FROM checkins');
    await db.execute('DELETE FROM rewards');
    await db.execute('DELETE FROM support_tickets');
    await db.execute('DELETE FROM installations');
    await db.execute('DELETE FROM bills');
    await db.execute('DELETE FROM payments');
    await db.execute('DELETE FROM speed_tests');

    // Database reset completed
  }

  Future<void> updateInstallationStatus(
    int id,
    String status, {
    String? completedAt,
  }) async {
    final db = await instance.database;
    final data = {'status': status};
    if (completedAt != null) {
      data['completedAt'] = completedAt;
    }
    await db.update('installations', data, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateTicketStatus(
    String ticketId,
    String status, {
    String? resolvedAt,
    String? progressNotes,
    String? photoBeforePath,
    String? photoAfterPath,
  }) async {
    final db = await instance.database;
    final data = {
      'status': status,
      'updatedAt': DateTime.now().toIso8601String(),
    };
    if (resolvedAt != null) {
      data['resolvedAt'] = resolvedAt;
    }
    if (progressNotes != null) {
      data['progressNotes'] = progressNotes;
    }
    if (photoBeforePath != null) {
      data['photoBeforePath'] = photoBeforePath;
    }
    if (photoAfterPath != null) {
      data['photoAfterPath'] = photoAfterPath;
    }
    await db.update(
      'support_tickets',
      data,
      where: 'ticketId = ?',
      whereArgs: [ticketId],
    );
  }

  // Assign ticket to teknisi (pickup)
  Future<void> assignTicketToTeknisi(int ticketId, int teknisiId) async {
    try {
      final db = await instance.database;
      await db.update(
        'support_tickets',
        {
          'teknisiId': teknisiId,
          'assignedAt': DateTime.now().toIso8601String(),
          'status': 'in_progress',
          'updatedAt': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [ticketId],
      );
    } catch (e) {
      // Error assigning ticket
      rethrow;
    }
  }

  // Get tickets assigned to specific teknisi
  Future<List<Map<String, dynamic>>> getTicketsByTeknisiId(
    int teknisiId,
  ) async {
    final db = await instance.database;
    return await db.rawQuery(
      '''
      SELECT t.*, c.customerId, u.name, u.phone
      FROM support_tickets t
      JOIN customers c ON t.customerId = c.id
      JOIN users u ON c.userId = u.id
      WHERE t.teknisiId = ?
      ORDER BY t.createdAt DESC
    ''',
      [teknisiId],
    );
  }

  // Get unassigned tickets (available for pickup)
  Future<List<Map<String, dynamic>>> getUnassignedTickets() async {
    final db = await instance.database;
    return await db.rawQuery('''
      SELECT t.*, c.customerId, u.name as customerName, u.phone
      FROM support_tickets t
      JOIN customers c ON t.customerId = c.id
      JOIN users u ON c.userId = u.id
      WHERE t.teknisiId IS NULL AND t.status != 'resolved'
      ORDER BY 
        CASE t.priority
          WHEN 'high' THEN 1
          WHEN 'medium' THEN 2
          WHEN 'low' THEN 3
        END,
        t.createdAt ASC
    ''');
  }

  // Get unassigned tickets filtered by zone
  Future<List<Map<String, dynamic>>> getUnassignedTicketsByZone(
    String zone,
  ) async {
    final db = await instance.database;
    return await db.rawQuery(
      '''
      SELECT t.*, c.customerId, u.name as customerName, u.phone
      FROM support_tickets t
      JOIN customers c ON t.customerId = c.id
      JOIN users u ON c.userId = u.id
      WHERE t.teknisiId IS NULL AND t.status != 'resolved' AND t.zone = ?
      ORDER BY 
        CASE t.priority
          WHEN 'high' THEN 1
          WHEN 'medium' THEN 2
          WHEN 'low' THEN 3
        END,
        t.createdAt ASC
    ''',
      [zone],
    );
  }

  // Get all tickets filtered by zone
  Future<List<Map<String, dynamic>>> getTicketsByZone(String zone) async {
    final db = await instance.database;
    return await db.rawQuery(
      '''
      SELECT t.*, c.customerId, u.name as customerName, u.phone
      FROM support_tickets t
      JOIN customers c ON t.customerId = c.id
      JOIN users u ON c.userId = u.id
      WHERE t.zone = ?
      ORDER BY t.createdAt DESC
    ''',
      [zone],
    );
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await instance.database;
    final results = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return results.isNotEmpty ? results.first : null;
  }

  // Get all teknisi
  Future<List<Map<String, dynamic>>> getAllTeknisi() async {
    final db = await instance.database;
    return await db.query(
      'users',
      where: 'role = ?',
      whereArgs: ['teknisi'],
      orderBy: 'zone ASC, name ASC',
    );
  }

  // Get teknisi by zone
  Future<List<Map<String, dynamic>>> getTeknisiByZone(String zone) async {
    final db = await instance.database;
    return await db.query(
      'users',
      where: 'role = ? AND zone = ?',
      whereArgs: ['teknisi', zone],
      orderBy: 'name ASC',
    );
  }

  // Add new teknisi
  Future<int> addTeknisi(Map<String, dynamic> teknisiData) async {
    final db = await instance.database;
    return await db.insert('users', {
      ...teknisiData,
      'role': 'teknisi',
      'isActive': 1,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  // Update teknisi
  Future<int> updateTeknisi(int id, Map<String, dynamic> teknisiData) async {
    final db = await instance.database;
    return await db.update(
      'users',
      {...teknisiData, 'updatedAt': DateTime.now().toIso8601String()},
      where: 'id = ? AND role = ?',
      whereArgs: [id, 'teknisi'],
    );
  }

  // Delete teknisi
  Future<int> deleteTeknisi(int id) async {
    final db = await instance.database;
    return await db.delete(
      'users',
      where: 'id = ? AND role = ?',
      whereArgs: [id, 'teknisi'],
    );
  }

  // Get all available zones (distinct from teknisi)
  Future<List<String>> getAllZones() async {
    final db = await instance.database;
    final results = await db.rawQuery('''
      SELECT DISTINCT zone 
      FROM users 
      WHERE role = 'teknisi' AND zone IS NOT NULL
      ORDER BY zone ASC
    ''');
    return results.map((row) => row['zone'] as String).toList();
  }

  Future<int> register(Map<String, dynamic> userData) async {
    try {
      final db = await instance.database;

      // Hash password sebelum insert
      if (userData.containsKey('password')) {
        final plainPassword = userData['password'] as String;
        userData['password'] = PasswordHelper.hashPassword(plainPassword);
      }

      return await db.insert('users', userData);
    } catch (e) {
      // Error during register
      rethrow;
    }
  }

  Future<int> addCustomer(Map<String, dynamic> customerData) async {
    try {
      final db = await instance.database;
      return await db.insert('customers', customerData);
    } catch (e) {
      // Error adding customer
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getAllCustomers() async {
    final db = await instance.database;
    return await db.rawQuery('''
      SELECT c.id, u.name, u.email, u.phone, c.address
      FROM customers c
      JOIN users u ON c.userId = u.id
      WHERE u.isActive = 1
      ORDER BY u.name ASC
    ''');
  }

  Future<void> saveSpeedTest(Map<String, dynamic> testData) async {
    try {
      final db = await instance.database;
      await db.insert('speed_tests', testData);
    } catch (e) {
      // Error saving speed test
      rethrow;
    }
  }

  Future<int> createPayment(Map<String, dynamic> paymentData) async {
    try {
      final db = await instance.database;
      return await db.insert('payments', paymentData);
    } catch (e) {
      // Error creating payment
      rethrow;
    }
  }

  // Generate Mock Data for ISP Dashboard
  Future<void> generateMockCustomers({int count = 50}) async {
    final db = await instance.database;

    Logger.debug('🔄 Generating $count mock customers...');

    final firstNames = [
      'Budi',
      'Siti',
      'Ahmad',
      'Rina',
      'Joko',
      'Dewi',
      'Andi',
      'Maya',
      'Rudi',
      'Sri',
      'Hendra',
      'Lina',
      'Agus',
      'Tuti',
      'Bambang',
      'Nur',
      'Dani',
      'Indah',
      'Eko',
      'Fitri',
      'Hadi',
      'Wati',
      'Rahmat',
      'Sari',
      'Yanto',
      'Putri',
      'Joni',
      'Ayu',
      'Guntur',
      'Ratna',
    ];

    final lastNames = [
      'Santoso',
      'Wijaya',
      'Putra',
      'Kurniawan',
      'Setiawan',
      'Pratama',
      'Cahaya',
      'Utomo',
      'Saputra',
      'Lestari',
      'Permata',
      'Budiman',
      'Hakim',
      'Pranoto',
      'Gunawan',
      'Raharjo',
      'Atmaja',
      'Wibowo',
    ];

    final streets = [
      'Jl. Sudirman',
      'Jl. Thamrin',
      'Jl. Gatot Subroto',
      'Jl. Kuningan',
      'Jl. Senopati',
      'Jl. Menteng',
      'Jl. Kemang',
      'Jl. Kebayoran',
      'Jl. Melawai',
      'Jl. Cipete',
      'Jl. Fatmawati',
      'Jl. TB Simatupang',
      'Jl. Casablanca',
      'Jl. Rasuna Said',
      'Jl. Pejaten',
      'Jl. Cilandak',
    ];

    final areas = [
      'Jakarta Pusat',
      'Jakarta Selatan',
      'Jakarta Barat',
      'Jakarta Timur',
      'Jakarta Utara',
    ];

    for (int i = 0; i < count; i++) {
      final firstName = firstNames[i % firstNames.length];
      final lastName = lastNames[i % lastNames.length];
      final fullName = '$firstName $lastName';
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final email =
          '${firstName.toLowerCase()}.${lastName.toLowerCase()}.$timestamp.$i@email.com';
      final phoneNumber = 1000000000 + i + timestamp % 100000;
      final phone = '08${phoneNumber.toString().substring(0, 10)}';
      final street = streets[i % streets.length];
      final area = areas[i % areas.length];
      final address = '$street No. ${10 + i}, $area';

      // Create user
      final userId = await db.insert('users', {
        'name': fullName,
        'email': email,
        'phone': phone,
        'password': PasswordHelper.hashPassword('password123'),
        'role': 'customer',
        'isActive': 1,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      });

      // Create customer
      final customerId = await db.insert('customers', {
        'userId': userId,
        'customerId': 'CUST${(1000 + userId).toString()}',
        'internetNumber':
            '1116${DateTime.now().year}${(userId).toString().padLeft(4, '0')}',
        'address': address,
        'packageName': i % 3 == 0
            ? '100 Mbps'
            : i % 3 == 1
            ? '50 Mbps'
            : '20 Mbps',
        'speed': i % 3 == 0
            ? 100
            : i % 3 == 1
            ? 50
            : 20,
        'price': i % 3 == 0
            ? 500000
            : i % 3 == 1
            ? 300000
            : 150000,
        'status': 'active',
        'installDate': DateTime.now()
            .subtract(Duration(days: i * 30))
            .toIso8601String(),
      });

      // Create bills for last 3 months
      for (int month = 0; month < 3; month++) {
        final billDate = DateTime.now().subtract(Duration(days: 30 * month));
        final billId = await db.insert('bills', {
          'customerId': customerId,
          'billMonth':
              '${billDate.year}-${billDate.month.toString().padLeft(2, '0')}',
          'amount': i % 3 == 0
              ? 500000
              : i % 3 == 1
              ? 300000
              : 150000,
          'dueDate': billDate.add(const Duration(days: 15)).toIso8601String(),
          'status': month == 0 && i % 4 == 0 ? 'unpaid' : 'paid',
          'createdAt': billDate.toIso8601String(),
        });

        // Create payment if paid
        if (month > 0 || i % 4 != 0) {
          await db.insert('payments', {
            'billId': billId,
            'customerId': customerId,
            'amount': i % 3 == 0
                ? 500000
                : i % 3 == 1
                ? 300000
                : 150000,
            'paymentMethod': i % 5 == 0
                ? 'Transfer Bank'
                : i % 5 == 1
                ? 'E-Wallet'
                : i % 5 == 2
                ? 'Virtual Account'
                : i % 5 == 3
                ? 'Tunai'
                : 'QRIS',
            'paymentStatus': 'paid',
            'transactionId':
                'TRX${DateTime.now().millisecondsSinceEpoch}$billId',
            'paidAt': billDate
                .subtract(Duration(days: 5 - month))
                .toIso8601String(),
          });
        }
      }
    }

    Logger.success('✅ Successfully generated $count customers with payments');
  }

  Future<void> generateMockTickets({int count = 20}) async {
    final db = await instance.database;

    Logger.debug('🔄 Generating $count mock tickets...');

    // Get existing customers
    final customers = await db.query('customers', limit: 30);
    if (customers.isEmpty) {
      Logger.warning('⚠️ No customers found, skipping ticket generation');
      return;
    }

    Logger.debug(
      '📋 Found ${customers.length} customers for ticket generation',
    );

    final subjects = [
      'Internet lambat',
      'Koneksi terputus',
      'Tidak bisa akses internet',
      'Lampu modem merah',
      'Speed tidak sesuai paket',
      'Ping tinggi saat gaming',
      'WiFi tidak terdeteksi',
      'Minta upgrade paket',
      'Gangguan di area',
      'Modem mati total',
    ];

    final descriptions = [
      'Sejak tadi malam internet sangat lambat, tolong dicek',
      'Koneksi sering putus-putus, sudah restart modem tetap sama',
      'Tidak bisa browsing sama sekali, mohon bantuan',
      'Lampu indikator di modem warna merah, kenapa ya?',
      'Paket 100Mbps tapi speed test cuma 50Mbps',
      'Ping ke server game sangat tinggi, tidak bisa main game',
      'WiFi tidak muncul di list, sudah coba restart',
      'Mau upgrade dari paket 20Mbps ke 50Mbps',
      'Di komplek saya banyak yang komplain internet mati',
      'Modem tiba-tiba mati dan tidak bisa nyala lagi',
    ];

    final priorities = ['low', 'medium', 'high'];
    final statuses = ['open', 'in_progress', 'resolved', 'closed'];

    for (int i = 0; i < count; i++) {
      final customer = customers[i % customers.length];
      final customerId = customer['id'] as int;
      final createdDate = DateTime.now().subtract(Duration(days: i * 2));

      await db.insert('tickets', {
        'customerId': customerId,
        'subject': subjects[i % subjects.length],
        'description': descriptions[i % descriptions.length],
        'priority': priorities[i % priorities.length],
        'status': i < 5 ? 'open' : statuses[i % statuses.length],
        'createdAt': createdDate.toIso8601String(),
        'updatedAt': createdDate.add(Duration(hours: i % 24)).toIso8601String(),
      });
    }

    Logger.success('✅ Successfully generated $count tickets');
  }

  Future<void> clearMockData() async {
    final db = await instance.database;

    Logger.debug('🗑️ Clearing all mock data...');

    // Delete in correct order (respecting foreign keys)
    await db.delete('payments');
    await db.delete('bills');
    await db.delete('tickets');
    await db.delete('speed_tests');
    await db.delete('installations');
    await db.delete('support_tickets');
    await db.delete('customers');
    await db.delete('users', where: 'role = ?', whereArgs: ['customer']);

    Logger.success('✅ All mock data cleared successfully');
  }

  // Force populate database with default users if empty
  Future<void> forcePopulateDefaultUsers() async {
    final db = await instance.database;

    // Check if users table is empty
    final userCount = await db.rawQuery('SELECT COUNT(*) as count FROM users');
    final count = userCount.first['count'] as int;

    if (count == 0) {
      Logger.info('📦 Database is empty, populating with default users...');

      // Insert admin
      await db.insert('users', {
        'email': 'admin@audiranet.com',
        'password': PasswordHelper.hashPassword('admin123'),
        'name': 'Admin Audira',
        'phone': '081234567890',
        'role': 'admin',
        'isActive': 1,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      });

      // Insert teknisi
      await db.insert('users', {
        'email': 'teknisi@audiranet.com',
        'password': PasswordHelper.hashPassword('teknisi123'),
        'name': 'Teknisi Support',
        'phone': '081234567899',
        'role': 'teknisi',
        'zone': 'Batam Center',
        'isActive': 1,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      });

      // Insert customers
      await db.insert('users', {
        'email': 'budi@email.com',
        'password': PasswordHelper.hashPassword('123456'),
        'name': 'Budi Santoso',
        'phone': '081234567891',
        'role': 'customer',
        'isActive': 1,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      });

      await db.insert('users', {
        'email': 'siti@email.com',
        'password': PasswordHelper.hashPassword('123456'),
        'name': 'Siti Rahayu',
        'phone': '081234567892',
        'role': 'customer',
        'isActive': 1,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      });

      Logger.success('✅ Default users populated successfully!');
    } else {
      Logger.info('📋 Database already has $count users');
    }
  }

  Future<Map<String, int>> getMockDataCount() async {
    final db = await instance.database;

    final customersResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM users WHERE role = ?',
      ['customer'],
    );
    final paymentsResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM payments',
    );
    final ticketsResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM tickets',
    );

    return {
      'customers': customersResult.first['count'] as int? ?? 0,
      'payments': paymentsResult.first['count'] as int? ?? 0,
      'tickets': ticketsResult.first['count'] as int? ?? 0,
    };
  }

  // CUSTOMER DATA MANAGEMENT METHODS (yang belum ada)

  /// Mengambil data customer berdasarkan user ID
  Future<Map<String, dynamic>?> getCustomerByUserId(String userId) async {
    try {
      final db = await database;
      LoggerService.dbInfo(
        '🔍 DatabaseService.getCustomerByUserId called with userId: $userId',
      );

      final List<Map<String, dynamic>> maps = await db.query(
        'customers',
        where: 'userId = ?',
        whereArgs: [userId],
      );

      LoggerService.dbInfo(
        '🔍 DatabaseService.getCustomerByUserId called with userId: $userId',
      );

      if (maps.isNotEmpty) {
        return maps.first;
      }
      return null;
    } catch (e) {
      LoggerService.dbInfo('❌ Error getCustomerByUserId: $e');
      return null;
    }
  }

  // MAINTENANCE SCHEDULE METHODS

  /// Get all maintenance schedules
  Future<List<Map<String, dynamic>>> getMaintenanceSchedules({
    String? status,
    DateTime? fromDate,
  }) async {
    try {
      final db = await database;

      String whereClause = '';
      List<dynamic> whereArgs = [];

      if (status != null) {
        whereClause = 'status = ?';
        whereArgs.add(status);
      }

      if (fromDate != null) {
        if (whereClause.isNotEmpty) whereClause += ' AND ';
        whereClause += 'scheduledDate >= ?';
        whereArgs.add(fromDate.toIso8601String().split('T')[0]);
      }

      final List<Map<String, dynamic>> maps = await db.query(
        'maintenance_schedules',
        where: whereClause.isNotEmpty ? whereClause : null,
        whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
        orderBy: 'scheduledDate ASC, startTime ASC',
      );

      return maps;
    } catch (e) {
      developer.log(
        'Error getting maintenance schedules: $e',
        name: 'DatabaseService',
      );
      return [];
    }
  }

  /// Get upcoming maintenance (next 7 days)
  Future<List<Map<String, dynamic>>> getUpcomingMaintenance() async {
    final now = DateTime.now();
    return getMaintenanceSchedules(status: 'scheduled', fromDate: now);
  }

  /// Create new maintenance schedule
  Future<int> createMaintenanceSchedule(Map<String, dynamic> data) async {
    try {
      final db = await database;
      final now = DateTime.now().toIso8601String();

      final id = await db.insert('maintenance_schedules', {
        ...data,
        'createdAt': now,
        'updatedAt': now,
      });

      return id;
    } catch (e) {
      print('Error creating maintenance schedule: $e');
      return -1;
    }
  }

  /// Update maintenance schedule status
  Future<bool> updateMaintenanceStatus(int id, String status) async {
    try {
      final db = await database;
      final count = await db.update(
        'maintenance_schedules',
        {'status': status, 'updatedAt': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [id],
      );

      return count > 0;
    } catch (e) {
      print('Error updating maintenance status: $e');
      return false;
    }
  }

  /// Mark notification as sent
  Future<bool> markMaintenanceNotificationSent(int id) async {
    try {
      final db = await database;
      final count = await db.update(
        'maintenance_schedules',
        {'notificationSent': 1},
        where: 'id = ?',
        whereArgs: [id],
      );

      return count > 0;
    } catch (e) {
      print('Error marking notification sent: $e');
      return false;
    }
  }

  /// Membuat tagihan baru
  Future<String?> createBill(Map<String, dynamic> billData) async {
    try {
      final db = await database;
      LoggerService.dbInfo(
        '🧾 DatabaseService.createBill called with data: $billData',
      );

      final id = await db.insert('bills', billData);
      LoggerService.dbInfo('✅ Bill created with ID: $id');

      return id.toString();
    } catch (e) {
      LoggerService.dbInfo('❌ Error createBill: $e');
      return null;
    }
  }

  /// Mengambil semua data instalasi berdasarkan customer ID
  Future<List<Map<String, dynamic>>> getInstallationsByCustomerId(
    String customerId,
  ) async {
    try {
      final db = await database;
      LoggerService.dbInfo('Database operation completed');

      final List<Map<String, dynamic>> maps = await db.query(
        'installations',
        where: 'customer_id = ?',
        whereArgs: [customerId],
        orderBy: 'installation_date DESC',
      );

      LoggerService.dbInfo('Database operation completed');
      return maps;
    } catch (e) {
      LoggerService.dbInfo('❌ Error getInstallationsByCustomerId: $e');
      return [];
    }
  }

  /// Update customer data
  Future<bool> updateCustomer(
    String customerId,
    Map<String, dynamic> customerData,
  ) async {
    try {
      final db = await database;
      LoggerService.dbInfo('Database operation completed');

      final result = await db.update(
        'customers',
        customerData,
        where: 'id = ?',
        whereArgs: [customerId],
      );

      LoggerService.dbInfo('✅ Customer update result: $result rows affected');
      return result > 0;
    } catch (e) {
      LoggerService.dbInfo('❌ Error updateCustomer: $e');
      return false;
    }
  }
}
