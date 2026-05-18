class User {
  final int id;
  final String name;
  final String email;
  final String role;
  final String wa;
  final String alamat;
  final String firestoreId;
  
  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.wa = '',
    this.alamat = '',
    this.firestoreId = '',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'role': role,
    'wa': wa,
    'alamat': alamat,
    'firestoreId': firestoreId,
  };

  factory User.fromMap(Map<String, dynamic> map) => User(
    id: map['id'] ?? 0,
    name: map['name'] ?? '',
    email: map['email'] ?? '',
    role: map['role'] ?? '',
    wa: map['wa'] ?? '',
    alamat: map['alamat'] ?? '',
    firestoreId: map['firestoreId'] ?? '',
  );
}
