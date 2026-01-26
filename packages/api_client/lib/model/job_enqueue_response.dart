//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.12

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class JobEnqueueResponse {
  /// Returns a new [JobEnqueueResponse] instance.
  JobEnqueueResponse({
    this.jobId,
    this.status,
    this.traceId,
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? jobId;

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
  String? traceId;

  @override
  bool operator ==(Object other) => identical(this, other) || other is JobEnqueueResponse &&
    other.jobId == jobId &&
    other.status == status &&
    other.traceId == traceId;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (jobId == null ? 0 : jobId!.hashCode) +
    (status == null ? 0 : status!.hashCode) +
    (traceId == null ? 0 : traceId!.hashCode);

  @override
  String toString() => 'JobEnqueueResponse[jobId=$jobId, status=$status, traceId=$traceId]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.jobId != null) {
      json[r'job_id'] = this.jobId;
    } else {
      json[r'job_id'] = null;
    }
    if (this.status != null) {
      json[r'status'] = this.status;
    } else {
      json[r'status'] = null;
    }
    if (this.traceId != null) {
      json[r'trace_id'] = this.traceId;
    } else {
      json[r'trace_id'] = null;
    }
    return json;
  }

  /// Returns a new [JobEnqueueResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static JobEnqueueResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "JobEnqueueResponse[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "JobEnqueueResponse[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return JobEnqueueResponse(
        jobId: mapValueOfType<String>(json, r'job_id'),
        status: mapValueOfType<String>(json, r'status'),
        traceId: mapValueOfType<String>(json, r'trace_id'),
      );
    }
    return null;
  }

  static List<JobEnqueueResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <JobEnqueueResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = JobEnqueueResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, JobEnqueueResponse> mapFromJson(dynamic json) {
    final map = <String, JobEnqueueResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = JobEnqueueResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of JobEnqueueResponse-objects as value to a dart map
  static Map<String, List<JobEnqueueResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<JobEnqueueResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = JobEnqueueResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

