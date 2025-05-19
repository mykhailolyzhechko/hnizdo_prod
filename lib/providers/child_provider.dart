import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hnizdo/models/child.dart';
import 'package:hnizdo/models/contact_info.dart';
import 'auth_provider.dart';

// Provider for Firebase Database reference
final databaseProvider = Provider<DatabaseReference>((ref) {
  return FirebaseDatabase.instance.ref();
});

// Children Provider
class ChildrenNotifier extends StateNotifier<Map<String, Child>> {
  final DatabaseReference _database;
  late StreamSubscription<DatabaseEvent> _subscription;

  ChildrenNotifier(this._database) : super({}) {
    _init();
  }

  void _init() {
    _subscription = _database
        .child('children')
        .onValue
        .listen(
          (event) {
            if (event.snapshot.value != null) {
              try {
                final data = Map<String, dynamic>.from(
                  event.snapshot.value as Map,
                );

                final Map<String, Child> children = {};
                
                data.forEach((key, value) {
                  try {
                    if (value is Map) {
                      final childData = Map<String, dynamic>.from(value as Map);
                      childData['id'] = key; // Ensure ID is included
                      
                      final child = Child.fromMap(childData);
                      children[key] = child;
                    }
                  } catch (e) {
                    print("ChildrenNotifier: Error processing child $key: $e");
                  }
                });
                
                print("ChildrenNotifier: Total children processed: ${children.length}");
                state = children;
              } catch (e) {
                print("ChildrenNotifier: Error converting snapshot value to Map: $e");
              }
            } else {
              state = {};
            }
          },
          onError: (error) {
            print("ChildrenNotifier: Error fetching children: $error");
          },
        );
  }

  Future<void> addChild({
    required String fullName,
    String? photoUrl,
    required List<ContactInfo> contactInfo,
    required DateTime dateOfBirth,
    String? notes,
    required String groupId,
    String status = 'Active',
  }) async {
    try {
      final newChildRef = _database.child('children').push();

      final childData = {
        'fullName': fullName,
        'photoUrl': photoUrl,
        'contactInfo': contactInfo.map((contact) => contact.toMap()).toList(),
        'dateOfBirth': dateOfBirth.millisecondsSinceEpoch,
        'notes': notes ?? '',
        'groupId': groupId,
        'status': status,
        'createdAt': ServerValue.timestamp,
      };

      await newChildRef.set(childData);
    } catch (e) {
      print("Error adding child: $e");
      rethrow;
    }
  }

  Future<void> updateChild({
    required String childId,
    String? fullName,
    String? photoUrl,
    List<ContactInfo>? contactInfo,
    DateTime? dateOfBirth,
    String? notes,
    String? groupId,
    String? status,
  }) async {
    try {
      final updates = <String, dynamic>{};
      
      if (fullName != null) updates['fullName'] = fullName;
      if (photoUrl != null) updates['photoUrl'] = photoUrl;
      if (contactInfo != null) {
        updates['contactInfo'] = contactInfo.map((contact) => contact.toMap()).toList();
      }
      if (dateOfBirth != null) {
        updates['dateOfBirth'] = dateOfBirth.millisecondsSinceEpoch;
      }
      if (notes != null) updates['notes'] = notes;
      if (groupId != null) updates['groupId'] = groupId;
      if (status != null) updates['status'] = status;
      
      updates['updatedAt'] = ServerValue.timestamp;

      await _database.child('children').child(childId).update(updates);
    } catch (e) {
      print("Error updating child: $e");
      rethrow;
    }
  }

  Future<void> deleteChild(String childId) async {
    try {
      await _database.child('children').child(childId).remove();
    } catch (e) {
      print("Error deleting child: $e");
      rethrow;
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final childrenProvider = StateNotifierProvider<ChildrenNotifier, Map<String, Child>>(
  (ref) {
    final database = ref.watch(databaseProvider);
    return ChildrenNotifier(database);
  },
);

// Filtered Children Provider by Group
final filteredChildrenByGroupProvider = Provider.family<List<Child>, String>((
  ref,
  groupId,
) {
  final children = ref.watch(childrenProvider);

  if (groupId.isEmpty) {
    return children.values.toList();
  } else {
    return children.values
        .where((child) => child.groupId == groupId)
        .toList();
  }
});

// Filtered Children Provider by Status
final filteredChildrenByStatusProvider = Provider.family<List<Child>, String>((
  ref,
  status,
) {
  final children = ref.watch(childrenProvider);

  if (status == 'All') {
    return children.values.toList();
  } else {
    return children.values
        .where((child) => child.status == status)
        .toList();
  }
});

// Child statistics provider
final childStatisticsProvider = Provider<Map<String, int>>((ref) {
  final children = ref.watch(childrenProvider);

  final Map<String, int> statistics = {
    'total': children.length,
    'active': 0,
    'inactive': 0,
  };

  for (final child in children.values) {
    final status = child.status.toLowerCase();
    if (status == 'active') {
      statistics['active'] = (statistics['active'] ?? 0) + 1;
    }
    if (status == 'inactive') {
      statistics['inactive'] = (statistics['inactive'] ?? 0) + 1;
    }
  }

  return statistics;
});

// Get Child By Id
final childByIdProvider = Provider.family<Child?, String>((ref, childId) {
  final children = ref.watch(childrenProvider);
  return children[childId];
});
