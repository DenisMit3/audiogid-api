//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.12

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class IngestionRunRead {
  /// Returns a new [IngestionRunRead] instance.
  IngestionRunRead({
    this.id,
    this.citySlug,
    this.startedAt,
    this.finishedAt,
    this.status,
    this.statsJson,
    this.lastError,
    this.traceId,
    this.lastAuditAction,
    this.lastAuditAt,
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? id;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? citySlug;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  DateTime? startedAt;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  DateTime? finishedAt;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? status;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? statsJson;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? lastError;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? traceId;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? lastAuditAction;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  DateTime? lastAuditAt;

  @override
  bool operator ==(Object other) => identical(this, other) || other is IngestionRunRead &&
    other.id == id &&
    other.citySlug == citySlug &&
    other.startedAt == startedAt &&
    other.finishedAt == finishedAt &&
    other.status == status &&
    other.statsJson == statsJson &&
    other.lastError == lastError &&
    other.traceId == traceId &&
    other.lastAuditAction == lastAuditAction &&
    other.lastAuditAt == lastAuditAt;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id == null ? 0 : id!.hashCode) +
    (citySlug == null ? 0 : citySlug!.hashCode) +
    (startedAt == null ? 0 : startedAt!.hashCode) +
    (finishedAt == null ? 0 : finishedAt!.hashCode) +
    (status == null ? 0 : status!.hashCode) +
    (statsJson == null ? 0 : statsJson!.hashCode) +
    (lastError == null ? 0 : lastError!.hashCode) +
    (traceId == null ? 0 : traceId!.hashCode) +
    (lastAuditAction == null ? 0 : lastAuditAction!.hashCode) +
    (lastAuditAt == null ? 0 : lastAuditAt!.hashCode);

  @override
  String toString() => 'IngestionRunRead[id=$id, citySlug=$citySlug, startedAt=$startedAt, finishedAt=$finishedAt, status=$status, statsJson=$statsJson, lastError=$lastError, traceId=$traceId, lastAuditAction=$lastAuditAction, lastAuditAt=$lastAuditAt]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.id != null) {
      json[r'id'] = this.id;
    } else {
      json[r'id'] = null;
    }
    if (this.citySlug != null) {
      json[r'city_slug'] = this.citySlug;
    } else {
      json[r'city_slug'] = null;
    }
    if (this.startedAt != null) {
      json[r'started_at'] = this.startedAt!.toUtc().toIso8601String();
    } else {
      json[r'started_at'] = null;
    }
    if (this.finishedAt != null) {
      json[r'finished_at'] = this.finishedAt!.toUtc().toIso8601String();
    } else {
      json[r'finished_at'] = null;
    }
    if (this.status != null) {
      json[r'status'] = this.status;
    } else {
      json[r'status'] = null;
    }
    if (this.statsJson != null) {
      json[r'stats_json'] = this.statsJson;
    } else {
      json[r'stats_json'] = null;
    }
    if (this.lastError != null) {
      json[r'last_error'] = this.lastError;
    } else {
      json[r'last_error'] = null;
    }
    if (this.traceId != null) {
      json[r'trace_id'] = this.traceId;
    } else {
      json[r'trace_id'] = null;
    }
    if (this.lastAuditAction != null) {
      json[r'last_audit_action'] = this.lastAuditAction;
    } else {
      json[r'last_audit_action'] = null;
    }
    if (this.lastAuditAt != null) {
      json[r'last_audit_at'] = this.lastAuditAt!.toUtc().toIso8601String();
    } else {
      json[r'last_audit_at'] = null;
    }
    return json;
  }

  /// Returns a new [IngestionRunRead] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static IngestionRunRead? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "IngestionRunRead[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "IngestionRunRead[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return IngestionRunRead(
        id: mapValueOfType<String>(json, r'id'),
        citySlug: mapValueOfType<String>(json, r'city_slug'),
        startedAt: mapDateTime(json, r'started_at', r''),
        finishedAt: mapDateTime(json, r'finished_at', r''),
        status: mapValueOfType<String>(json, r'status'),
        statsJson: mapValueOfType<String>(json, r'stats_json'),
        lastError: mapValueOfType<String>(json, r'last_error'),
        traceId: mapValueOfType<String>(json, r'trace_id'),
        lastAuditAction: mapValueOfType<String>(json, r'last_audit_action'),
        lastAuditAt: mapDateTime(json, r'last_audit_at', r''),
      );
    }
    return null;
  }

  static List<IngestionRunRead> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <IngestionRunRead>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = IngestionRunRead.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, IngestionRunRead> mapFromJson(dynamic json) {
    final map = <String, IngestionRunRead>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = IngestionRunRead.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of IngestionRunRead-objects as value to a dart map
  static Map<String, List<IngestionRunRead>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<IngestionRunRead>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = IngestionRunRead.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

