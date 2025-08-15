import 'package:uuid/uuid.dart';

class UuidGenerator {
  static final Uuid instance = Uuid(); 

  // static Uuid get instance {
  //   UuidGenerator._uuidGenerator ??= Uuid();

  //   return UuidGenerator._uuidGenerator!;
  // }
}