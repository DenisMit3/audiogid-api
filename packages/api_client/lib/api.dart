//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.12

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

library openapi.api;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';

part 'api_client.dart';
part 'api_helper.dart';
part 'api_exception.dart';
part 'auth/authentication.dart';
part 'auth/api_key_auth.dart';
part 'auth/oauth.dart';
part 'auth/http_basic_auth.dart';
part 'auth/http_bearer_auth.dart';

part 'api/account_api.dart';
part 'api/admin_api.dart';
part 'api/auth_api.dart';
part 'api/billing_api.dart';
part 'api/ingestion_api.dart';
part 'api/media_api.dart';
part 'api/offline_api.dart';
part 'api/ops_api.dart';
part 'api/public_api.dart';

part 'model/batch_purchase_request.dart';
part 'model/batch_purchase_response.dart';
part 'model/build_offline_bundle202_response.dart';
part 'model/build_offline_bundle_request.dart';
part 'model/city.dart';
part 'model/email_login.dart';
part 'model/entitlement_grant_read.dart';
part 'model/get_deletion_status200_response.dart';
part 'model/get_ops_commit200_response.dart';
part 'model/google_purchase_item.dart';
part 'model/ingestion_run_read.dart';
part 'model/job_enqueue_response.dart';
part 'model/login_sms_init200_response.dart';
part 'model/logout200_response.dart';
part 'model/media.dart';
part 'model/narration.dart';
part 'model/offline_job_read.dart';
part 'model/offline_job_read_result.dart';
part 'model/ops_config_check_get200_response.dart';
part 'model/ops_config_check_get200_response_yookassa.dart';
part 'model/ops_health_response.dart';
part 'model/phone_init.dart';
part 'model/phone_verify.dart';
part 'model/poi_detail.dart';
part 'model/poi_source.dart';
part 'model/presign_request.dart';
part 'model/presign_response.dart';
part 'model/purchase_verify_response.dart';
part 'model/refresh_req.dart';
part 'model/request_deletion202_response.dart';
part 'model/request_deletion_request.dart';
part 'model/restore_item_result.dart';
part 'model/restore_job_read.dart';
part 'model/restore_job_read_result.dart';
part 'model/restore_purchases_request.dart';
part 'model/telegram_login.dart';
part 'model/token_response.dart';
part 'model/tour_snippet.dart';
part 'model/user.dart';
part 'model/verify_apple_receipt_request.dart';
part 'model/verify_google_purchase_request.dart';


/// An [ApiClient] instance that uses the default values obtained from
/// the OpenAPI specification file.
var defaultApiClient = ApiClient();

const _delimiters = {'csv': ',', 'ssv': ' ', 'tsv': '\t', 'pipes': '|'};
const _dateEpochMarker = 'epoch';
const _deepEquality = DeepCollectionEquality();
final _dateFormatter = DateFormat('yyyy-MM-dd');
final _regList = RegExp(r'^List<(.*)>$');
final _regSet = RegExp(r'^Set<(.*)>$');
final _regMap = RegExp(r'^Map<String,(.*)>$');

bool _isEpochMarker(String? pattern) => pattern == _dateEpochMarker || pattern == '/$_dateEpochMarker/';
