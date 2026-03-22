import 'dart:convert';

import 'package:cine_pass_client/cine_pass_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BilletsCacheStore {
  static const _key = 'billets_cache_v1';

  Future<void> saveBillets(List<BilletGroupResponse> billets) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = billets.map((b) => b.toJson()).toList();
    await prefs.setString(_key, jsonEncode(payload));
  }

  Future<List<BilletGroupResponse>> loadBillets() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return const [];

    final decoded = jsonDecode(raw);
    if (decoded is! List) return const [];

    return decoded
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .map(BilletGroupResponse.fromJson)
        .toList();
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
