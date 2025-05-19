class ContactInfo {
  final String name;
  final String relationship;  // e.g., "Mother", "Father", "Guardian"
  final String phoneNumber;
  final String? alternativePhoneNumber;
  final String? email;
  final bool isPrimaryContact;

  ContactInfo({
    required this.name,
    required this.relationship,
    required this.phoneNumber,
    this.alternativePhoneNumber,
    this.email,
    this.isPrimaryContact = false,
  });

  factory ContactInfo.fromMap(Map<String, dynamic> map) {
    return ContactInfo(
      name: map['name'] ?? '',
      relationship: map['relationship'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      alternativePhoneNumber: map['alternativePhoneNumber'],
      email: map['email'],
      isPrimaryContact: map['isPrimaryContact'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'relationship': relationship,
      'phoneNumber': phoneNumber,
      'alternativePhoneNumber': alternativePhoneNumber,
      'email': email,
      'isPrimaryContact': isPrimaryContact,
    };
  }
}