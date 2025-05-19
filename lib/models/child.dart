import 'package:hnizdo/models/contact_info.dart';

class Child {
  final String id;
  final String fullName;
  final String? photoUrl;
  final List<ContactInfo> contactInfo;
  final DateTime dateOfBirth;
  final String notes;
  final String groupId;  // To associate with a kindergarten group
  final String status;   // e.g., "Active", "Inactive"

  Child({
    required this.id,
    required this.fullName,
    this.photoUrl,
    required this.contactInfo,
    required this.dateOfBirth,
    this.notes = '',
    required this.groupId,
    this.status = 'Active',
  });

  factory Child.fromMap(Map<String, dynamic> map) {
    List<ContactInfo> contacts = [];
    if (map['contactInfo'] != null) {
      try {
        final contactsList = List<dynamic>.from(map['contactInfo']);
        contacts = contactsList
            .map((contact) => ContactInfo.fromMap(Map<String, dynamic>.from(contact)))
            .toList();
      } catch (e) {
        print('Error parsing contactInfo: $e');
      }
    }

    // Parse dateOfBirth from milliseconds
    DateTime dob;
    try {
      if (map['dateOfBirth'] is int) {
        dob = DateTime.fromMillisecondsSinceEpoch(map['dateOfBirth']);
      } else {
        dob = DateTime.now();
      }
    } catch (e) {
      print('Error parsing dateOfBirth: $e');
      dob = DateTime.now();
    }

    return Child(
      id: map['id'] ?? '',
      fullName: map['fullName'] ?? '',
      photoUrl: map['photoUrl'],
      contactInfo: contacts,
      dateOfBirth: dob,
      notes: map['notes'] ?? '',
      groupId: map['groupId'] ?? '',
      status: map['status'] ?? 'Active',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'photoUrl': photoUrl,
      'contactInfo': contactInfo.map((contact) => contact.toMap()).toList(),
      'dateOfBirth': dateOfBirth.millisecondsSinceEpoch,
      'notes': notes,
      'groupId': groupId,
      'status': status,
    };
  }
}
