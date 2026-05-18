import '../entities/service_item.dart';

abstract class CatalogRepository {
  Future<List<ServiceItem>> getServices();
}
