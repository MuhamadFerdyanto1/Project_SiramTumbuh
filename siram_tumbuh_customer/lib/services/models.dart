// Models for User/Auth
class UserModel {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? address;
  final String? city;
  final String? avatar;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.address,
    this.city,
    this.avatar,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      avatar: json['avatar'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'city': city,
      'avatar': avatar,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class AuthResponse {
  final String token;
  final String refreshToken;
  final UserModel user;

  AuthResponse({
    required this.token,
    required this.refreshToken,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String,
      refreshToken: json['refresh_token'] as String,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}

class ServiceModel {
  final int id;
  final String name;
  final String description;
  final double price;
  final String? image;
  final double rating;
  final int reviewCount;
  final String category;

  ServiceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.image,
    required this.rating,
    required this.reviewCount,
    required this.category,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      image: json['image'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['review_count'] as int? ?? 0,
      category: json['category'] as String,
    );
  }
}

class ProjectModel {
  final int id;
  final String title;
  final String description;
  final String status; // pending, in_progress, completed, cancelled
  final double budget;
  final DateTime startDate;
  final DateTime? endDate;
  final String? image;
  final double progressPercentage;
  final int serviceId;

  ProjectModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.budget,
    required this.startDate,
    this.endDate,
    this.image,
    required this.progressPercentage,
    required this.serviceId,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      status: json['status'] as String,
      budget: (json['budget'] as num).toDouble(),
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'] as String)
          : null,
      image: json['image'] as String?,
      progressPercentage: (json['progress_percentage'] as num?)?.toDouble() ?? 0.0,
      serviceId: json['service_id'] as int,
    );
  }
}
