import 'package:uuid/uuid.dart';

class UuidGenerator {
  static final Uuid _instance = Uuid(); 

  static Uuid get instance {

    return UuidGenerator._instance;
  }
}