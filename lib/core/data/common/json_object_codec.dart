import 'dart:collection';
import 'dart:convert';

String encodeJsonObject(Map<String, dynamic> value) {
  return jsonEncode(_normalizeObject(value));
}

Map<String, dynamic> decodeJsonObject(Object? value) {
  if (value == null) {
    return const {};
  }

  final Object? decoded;
  if (value is String) {
    final clean = value.trim();
    if (clean.isEmpty) {
      return const {};
    }
    decoded = jsonDecode(clean);
  } else {
    decoded = value;
  }

  if (decoded is! Map) {
    throw ArgumentError('El valor JSON debe ser un objeto.');
  }

  return Map.unmodifiable(_normalizeObject(decoded));
}

Map<String, dynamic> _normalizeObject(Map<dynamic, dynamic> value) {
  final normalized = SplayTreeMap<String, dynamic>();

  for (final entry in value.entries) {
    final key = entry.key;
    if (key is! String || key.isEmpty) {
      throw ArgumentError('Las claves JSON deben ser textos no vacíos.');
    }
    normalized[key] = _normalizeValue(entry.value);
  }

  return normalized;
}

Object? _normalizeValue(Object? value) {
  if (value == null || value is String || value is bool || value is num) {
    return value;
  }
  if (value is Map) {
    return _normalizeObject(value);
  }
  if (value is List) {
    return List.unmodifiable(value.map(_normalizeValue));
  }

  throw ArgumentError('El objeto contiene un valor que no es JSON válido.');
}
