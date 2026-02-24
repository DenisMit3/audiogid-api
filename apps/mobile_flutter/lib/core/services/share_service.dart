import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_flutter/core/api/api_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'package:share_plus/share_plus.dart';

part 'share_service.g.dart';

class TrustedContact {
  final String id;
  final String name;
  final String phone;

  TrustedContact({required this.id, required this.name, required this.phone});

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'phone': phone};

  factory TrustedContact.fromJson(Map<String, dynamic> json) => TrustedContact(
        id: json['id'],
        name: json['name'],
        phone: json['phone'],
      );
}

@riverpod
class TrustedContacts extends _$TrustedContacts {
  @override
  Future<List<TrustedContact>> build() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('trusted_contacts') ?? [];
    return raw.map((e) => TrustedContact.fromJson(jsonDecode(e))).toList();
  }

  Future<void> add(String name, String phone) async {
    final prefs = await SharedPreferences.getInstance();
    final list = state.value ?? [];
    final newContact =
        TrustedContact(id: const Uuid().v4(), name: name, phone: phone);
    final newList = [...list, newContact];

    await prefs.setStringList('trusted_contacts',
        newList.map((e) => jsonEncode(e.toJson())).toList());
    state = AsyncData(newList);
  }

  Future<void> remove(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final list = state.value ?? [];
    final newList = list.where((c) => c.id != id).toList();

    await prefs.setStringList('trusted_contacts',
        newList.map((e) => jsonEncode(e.toJson())).toList());
    state = AsyncData(newList);
  }
}

@riverpod
ShareService shareService(Ref ref) {
  return ShareService(ref);
}

class ShareService {
  final Ref _ref;

  ShareService(this._ref);

  Future<String> createTripShareLink(double lat, double lon,
      {int ttl = 3600}) async {
    final dio = _ref.read(dioProvider);
    final response = await dio.post('/public/share/trip', data: {
      'lat': lat,
      'lon': lon,
      'ttl_seconds': ttl,
    });
    return response.data['share_url'];
  }

  Future<void> shareTrip(double lat, double lon) async {
    final url = await createTripShareLink(lat, lon);
    await Share.share('????? ?? ???? ?????????: $url');
  }

  Future<void> sendSos(double lat, double lon) async {
    final contacts = await _ref.read(trustedContactsProvider.future);
    if (contacts.isEmpty) {
      throw Exception("??? ?????????? ?????????");
    }

    final mapsLink = "https://maps.google.com/?q=$lat,$lon";
    // Attempt to get a shorter tracking link if possible, but SOS needs speed.
    // We send Maps link directly.

    final message = "SOS! ??? ????? ??????. ??? ??????????: $mapsLink";

    final phones = contacts.map((c) => c.phone).join(',');

    // Android supports comma, iOS might only pick the first or show a picker.
    // Ideally we iterate if simpler.
    final uri = Uri.parse('sms:$phones?body=${Uri.encodeComponent(message)}');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw Exception("?? ??????? ??????? SMS");
    }
  }
}
