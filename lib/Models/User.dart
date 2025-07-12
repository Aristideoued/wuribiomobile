import 'dart:typed_data';

class User {
  int? id;
  String firstName;
  String lastName;
  String? photoPath;
  Uint8List? fingerprintData;
  DateTime createdAt;
  DateTime? lastLogin;

  User({
    this.id,
    required this.firstName,
    required this.lastName,
    this.photoPath,
    this.fingerprintData,
    required this.createdAt,
    this.lastLogin,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'photoPath': photoPath,
      'fingerprintData': fingerprintData,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      photoPath: map['photoPath'],
      fingerprintData: map['fingerprintData'],
      createdAt: DateTime.parse(map['createdAt']),
      lastLogin: map['lastLogin'] != null ? DateTime.parse(map['lastLogin']) : null,
    );
  }
}
