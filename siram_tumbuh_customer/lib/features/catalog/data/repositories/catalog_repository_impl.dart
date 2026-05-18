import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/service_item.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../datasources/catalog_remote_data_source.dart';

class CatalogRepositoryImpl implements CatalogRepository {
  final CatalogRemoteDataSource remoteDataSource;

  CatalogRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<ServiceItem>> getServices() async {
    return await remoteDataSource.getServices();
  }
}

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  final remoteDataSource = ref.watch(catalogRemoteDataSourceProvider);
  return CatalogRepositoryImpl(remoteDataSource);
});
