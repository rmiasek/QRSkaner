import 'dart:convert';
import 'package:flutter/foundation.dart'; // debugPrint
import 'package:shared_preferences/shared_preferences.dart';
import '../models/scan_entry.dart';

class StorageService {
  static const _key = 'scan_entries_v1';

  Future<List<ScanEntry>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    debugPrint('[StorageService] load(): raw length=${raw?.length ?? 0}');
    if (raw == null) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        debugPrint('[StorageService] load(): decoded is not List');
        return [];
      }
      final list = decoded
          .map((e) => ScanEntry.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList()
          .cast<ScanEntry>();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      debugPrint('[StorageService] load(): entries=${list.length}');
      return list;
    } catch (e) {
      debugPrint('[StorageService] load(): ERROR $e');
      return [];
    }
  }

  Future<void> save(List<ScanEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = entries.map((e) => e.toMap()).toList();
    final payload = jsonEncode(jsonList);
    debugPrint('[StorageService] save(): entries=${entries.length}, bytes=${payload.length}');
    await prefs.setString(_key, payload);
  }
}
