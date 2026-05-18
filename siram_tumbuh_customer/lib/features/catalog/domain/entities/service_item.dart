class ServiceItem {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final List<Map<String, dynamic>> includedItems;
  final double price;

  const ServiceItem({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    this.includedItems = const [],
    required this.price,
  });
}
