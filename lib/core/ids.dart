import 'package:uuid/uuid.dart';

const Uuid _uuid = Uuid();

/// Generates a random unique id for persisted records.
String newId() => _uuid.v4();
