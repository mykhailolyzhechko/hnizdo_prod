import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hnizdo/models/contact_info.dart';
import 'child_provider.dart';

// Provider to get all contacts for a specific child
final childContactsProvider = Provider.family<List<ContactInfo>, String>((ref, childId) {
  final child = ref.watch(childByIdProvider(childId));
  if (child != null) {
    return child.contactInfo;
  }
  return [];
});

// Provider to get primary contact for a specific child
final primaryContactProvider = Provider.family<ContactInfo?, String>((ref, childId) {
  final contacts = ref.watch(childContactsProvider(childId));
  try {
    return contacts.firstWhere((contact) => contact.isPrimaryContact);
  } catch (e) {
    // Return the first contact if no primary contact is found
    if (contacts.isNotEmpty) {
      return contacts.first;
    }
    return null;
  }
});

// Provider to get filtered contacts by relationship
final filteredContactsByRelationshipProvider = 
    Provider.family<List<ContactInfo>, ({String childId, String relationship})>((
  ref,
  params,
) {
  final contacts = ref.watch(childContactsProvider(params.childId));
  
  if (params.relationship == 'All') {
    return contacts;
  } else {
    return contacts
        .where((contact) => contact.relationship == params.relationship)
        .toList();
  }
});

// Common relationships for filter options
final relationshipTypesProvider = Provider<List<String>>((ref) {
  return ['All', 'Mother', 'Father', 'Guardian', 'Grandparent', 'Other'];
});
