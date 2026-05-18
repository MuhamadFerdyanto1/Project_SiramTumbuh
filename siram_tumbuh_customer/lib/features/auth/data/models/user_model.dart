import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.role,
    super.wa,
    super.alamat,
    super.firestoreId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'customer',
      wa: json['wa'] as String? ?? '',
      alamat: json['alamat'] as String? ?? '',
      firestoreId: json['firestoreId'] as String? ?? '',
    );
  }

  /// Create from a Firestore document snapshot
  factory UserModel.fromFirestore(String docId, Map<String, dynamic> data) {
    return UserModel(
      id: 0,
      name: data['nama'] as String? ?? '',
      email: data['email'] as String? ?? '',
      role: 'customer',
      wa: data['wa'] as String? ?? '',
      alamat: data['alamat'] as String? ?? '',
      firestoreId: docId,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'wa': wa,
      'alamat': alamat,
      'firestoreId': firestoreId,
    };
  }
}
