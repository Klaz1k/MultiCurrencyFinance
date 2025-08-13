import 'package:uuid/uuid.dart';

class UuidGenerator {
  static late final Uuid? _uuidGenerator; 

  static Uuid get instance {
    UuidGenerator._uuidGenerator ??= Uuid();

    return UuidGenerator._uuidGenerator!;
  }
}