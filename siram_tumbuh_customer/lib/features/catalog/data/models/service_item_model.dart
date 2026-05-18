import '../../domain/entities/service_item.dart';

class ServiceItemModel extends ServiceItem {
  const ServiceItemModel({
    required super.id,
    required super.name,
    required super.description,
    required super.imageUrl,
    super.includedItems,
    required super.price,
  });

  factory ServiceItemModel.fromJson(Map<String, dynamic> json) {
    return ServiceItemModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? json['image_url'] ?? '',
      includedItems: (json['includedItems'] as List?)?.map((e) => Map<String, dynamic>.from(e)).toList() ?? [],
      price: json['price'] != null ? double.parse(json['price'].toString()) : 0.0,
    );
  }
}
