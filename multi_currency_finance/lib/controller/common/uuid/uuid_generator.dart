import 'package:uuid/uuid.dart';

class UuidGenerator {
  static late final Uuid? _instance; 

  static Uuid get instance {
    if (UuidGenerator._instance == null) UuidGenerator._instance == Uuid();

    return UuidGenerator._instance!;
  }
}