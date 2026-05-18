## 📐 Architecture Guide

### Clean Architecture

Proyek ini mengimplementasikan **Clean Architecture** untuk memisahkan concerns dan membuat kode lebih maintainable.

```
Feature/
├── presentation/
│   ├── screens/              # Full-screen UI
│   ├── widgets/              # Reusable UI components
│   ├── providers/            # Riverpod state management
│   └── [feature]_screen.dart
├── data/
│   ├── datasources/
│   │   ├── remote/           # API calls
│   │   └── local/            # Local storage
│   ├── models/               # Data transfer objects
│   └── repositories/         # Implementation
└── domain/
    ├── entities/             # Business models
    ├── repositories/         # Abstract repositories
    └── usecases/             # Business logic
```

### Layer Responsibilities

#### 🎨 Presentation Layer
- Menampilkan UI ke user
- Handle user input
- Manage local UI state
- Tidak boleh berisi business logic

**Files**:
- `screens/`: Full screens
- `widgets/`: Reusable components
- `providers/`: Riverpod providers untuk state management

#### 📦 Data Layer
- Communicate dengan API / Local Storage
- Convert data models
- Implement repositories

**Files**:
- `datasources/`: Remote API calls, Local DB
- `models/`: JSON serializable DTOs
- `repositories/`: Implementation dari domain repositories

#### 💼 Domain Layer
- Pure business logic
- Independent dari framework
- Definitions dari repositories & entities

**Files**:
- `entities/`: Pure data classes
- `repositories/`: Abstract repository interfaces
- `usecases/`: Business logic operations

### State Management dengan Riverpod

Riverpod digunakan untuk manage state di presentation layer.

#### Provider Types

1. **Provider** - Synchronous value
```dart
final userProvider = Provider((ref) => User.empty());
```

2. **FutureProvider** - Async operations
```dart
final usersFutureProvider = FutureProvider((ref) => repository.getUsers());
```

3. **StateNotifierProvider** - Mutable state
```dart
final userStateProvider = StateNotifierProvider((ref) => UserNotifier());
```

4. **StreamProvider** - Real-time data
```dart
final userStreamProvider = StreamProvider((ref) => repository.watchUsers());
```

### Navigation Flow

```
main.dart
    ↓
MyApp (ConsumerWidget)
    ↓
GoRouter (goRouterProvider)
    ↓
Routes defined in app_router.dart
```

Routes structure:
```
/splash → /login → /home
              ↓
              /services
              /booking
              /projects
              /profile
```

### API Communication

```
UI Screen
    ↓
StateNotifier (via FutureProvider)
    ↓
Repository (interface di domain, impl di data)
    ↓
Data Source (Remote atau Local)
    ↓
API Client (Dio) / Local DB
```

### Error Handling

Aplikasi menggunakan custom exceptions dan failures:

```dart
// In data layer
try {
  response = await apiClient.get('/endpoint');
  return Right(model.fromJson(response.data));
} catch (e) {
  return Left(NetworkFailure('Error message'));
}

// In presentation layer
final result = await repository.method();
result.fold(
  (failure) => handle error,
  (success) => handle success,
);
```

### Feature Implementation Example

Untuk menambah fitur baru:

1. **Create feature folder**
```
lib/features/new_feature/
├── presentation/
│   ├── screens/
│   ├── widgets/
│   └── providers/
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
└── domain/
    ├── entities/
    ├── repositories/
    └── usecases/
```

2. **Define entity** (domain layer)
```dart
class Item {
  final int id;
  final String name;
  const Item({required this.id, required this.name});
}
```

3. **Create model** (data layer)
```dart
class ItemModel extends Item {
  const ItemModel({required int id, required String name})
      : super(id: id, name: name);

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: json['id'],
      name: json['name'],
    );
  }
}
```

4. **Implement repository** (data layer)
```dart
class ItemRepositoryImpl implements ItemRepository {
  final ItemDataSource dataSource;
  
  @override
  Future<List<Item>> getItems() async {
    final models = await dataSource.getItems();
    return models.cast<Item>();
  }
}
```

5. **Create provider** (presentation layer)
```dart
final itemsProvider = FutureProvider((ref) {
  final repo = ref.watch(itemRepositoryProvider);
  return repo.getItems();
});
```

6. **Use in screen**
```dart
class ItemsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(itemsProvider);
    
    return itemsAsync.when(
      data: (items) => ListView(...),
      loading: () => CircularProgressIndicator(),
      error: (err, st) => ErrorWidget(),
    );
  }
}
```

### Best Practices

✅ **DO**:
- Keep layers separated
- Use repositories untuk data access
- Handle errors properly
- Use type-safe models
- Document public APIs
- Test business logic in domain layer

❌ **DON'T**:
- Put API calls in UI
- Mix business logic dengan UI
- Skip error handling
- Use dynamic types excessively
- Create god classes
- Hardcode values

---

**Reference**: [Domain-Driven Design](https://www.domainlanguage.com/ddd/)
