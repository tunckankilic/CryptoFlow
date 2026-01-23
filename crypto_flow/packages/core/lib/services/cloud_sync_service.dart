import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../error/failures.dart';

/// Service for syncing user data (portfolio, watchlist, alerts) to Firebase Firestore
class CloudSyncService {
  final FirebaseFirestore _firestore;

  CloudSyncService({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Get user document reference
  DocumentReference _userDoc(String uid) =>
      _firestore.collection('users').doc(uid);

  /// Get user data collection reference
  CollectionReference _userDataCollection(String uid) =>
      _userDoc(uid).collection('data');

  // ==================== Portfolio Sync ====================

  /// Sync portfolio holdings to the cloud
  Future<Either<Failure, void>> syncPortfolio({
    required String userId,
    required List<Map<String, dynamic>> holdings,
  }) async {
    try {
      await _userDataCollection(userId).doc('portfolio').set({
        'holdings': holdings,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to sync portfolio: $e'));
    }
  }

  /// Fetch portfolio holdings from the cloud
  Future<Either<Failure, List<Map<String, dynamic>>>> fetchPortfolio({
    required String userId,
  }) async {
    try {
      final doc = await _userDataCollection(userId).doc('portfolio').get();

      if (!doc.exists) {
        return const Right([]);
      }

      final data = doc.data() as Map<String, dynamic>?;
      if (data == null || data['holdings'] == null) {
        return const Right([]);
      }

      final holdings = (data['holdings'] as List)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();

      return Right(holdings);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to fetch portfolio: $e'));
    }
  }

  // ==================== Watchlist Sync ====================

  /// Sync watchlist items to the cloud
  Future<Either<Failure, void>> syncWatchlist({
    required String userId,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      await _userDataCollection(userId).doc('watchlist').set({
        'items': items,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to sync watchlist: $e'));
    }
  }

  /// Fetch watchlist items from the cloud
  Future<Either<Failure, List<Map<String, dynamic>>>> fetchWatchlist({
    required String userId,
  }) async {
    try {
      final doc = await _userDataCollection(userId).doc('watchlist').get();

      if (!doc.exists) {
        return const Right([]);
      }

      final data = doc.data() as Map<String, dynamic>?;
      if (data == null || data['items'] == null) {
        return const Right([]);
      }

      final items = (data['items'] as List)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();

      return Right(items);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to fetch watchlist: $e'));
    }
  }

  // ==================== Alerts Sync ====================

  /// Sync price alerts to the cloud
  Future<Either<Failure, void>> syncAlerts({
    required String userId,
    required List<Map<String, dynamic>> alerts,
  }) async {
    try {
      await _userDataCollection(userId).doc('alerts').set({
        'alerts': alerts,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to sync alerts: $e'));
    }
  }

  /// Fetch price alerts from the cloud
  Future<Either<Failure, List<Map<String, dynamic>>>> fetchAlerts({
    required String userId,
  }) async {
    try {
      final doc = await _userDataCollection(userId).doc('alerts').get();

      if (!doc.exists) {
        return const Right([]);
      }

      final data = doc.data() as Map<String, dynamic>?;
      if (data == null || data['alerts'] == null) {
        return const Right([]);
      }

      final alerts = (data['alerts'] as List)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();

      return Right(alerts);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to fetch alerts: $e'));
    }
  }

  // ==================== Full Sync ====================

  /// Perform a full sync of all user data
  Future<Either<Failure, void>> performFullSync({
    required String userId,
    required List<Map<String, dynamic>> holdings,
    required List<Map<String, dynamic>> watchlistItems,
    required List<Map<String, dynamic>> alerts,
  }) async {
    try {
      final batch = _firestore.batch();

      // Portfolio
      batch.set(_userDataCollection(userId).doc('portfolio'), {
        'holdings': holdings,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Watchlist
      batch.set(_userDataCollection(userId).doc('watchlist'), {
        'items': watchlistItems,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Alerts
      batch.set(_userDataCollection(userId).doc('alerts'), {
        'alerts': alerts,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to perform full sync: $e'));
    }
  }

  /// Fetch all user data from the cloud
  Future<Either<Failure, Map<String, List<Map<String, dynamic>>>>>
      fetchAllData({
    required String userId,
  }) async {
    try {
      final results = await Future.wait([
        fetchPortfolio(userId: userId),
        fetchWatchlist(userId: userId),
        fetchAlerts(userId: userId),
      ]);

      // Check for any failures
      for (final result in results) {
        if (result.isLeft()) {
          return Left(result.fold(
            (failure) => failure,
            (_) => const ServerFailure(message: 'Unknown error'),
          ));
        }
      }

      return Right({
        'holdings': results[0].getOrElse(() => []),
        'watchlist': results[1].getOrElse(() => []),
        'alerts': results[2].getOrElse(() => []),
      });
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to fetch all data: $e'));
    }
  }

  /// Get the last sync timestamp for a user
  Future<DateTime?> getLastSyncTime({required String userId}) async {
    try {
      final doc = await _userDoc(userId).get();

      if (!doc.exists) return null;

      final data = doc.data() as Map<String, dynamic>?;
      final timestamp = data?['lastSyncAt'] as Timestamp?;

      return timestamp?.toDate();
    } catch (e) {
      return null;
    }
  }

  /// Update the last sync timestamp
  Future<void> updateLastSyncTime({required String userId}) async {
    try {
      await _userDoc(userId).set({
        'lastSyncAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      // Silently fail - this is not critical
    }
  }
}
