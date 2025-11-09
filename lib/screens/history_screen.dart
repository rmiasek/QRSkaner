import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // debugPrint
import 'package:go_router/go_router.dart';
import '../models/scan_entry.dart';
import '../services/storage_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _storage = StorageService();
  List<ScanEntry> _entries = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    debugPrint('[History] initState');
    _load();
  }

  Future<void> _load() async {
    debugPrint('[History] _load()…');
    final data = await _storage.load();
    debugPrint('[History] _load(): ${data.length} entries');
    setState(() {
      _entries = data;
      _loading = false;
    });
  }

  Future<void> _save() async {
    debugPrint('[History] _save(): entries=${_entries.length}');
    await _storage.save(_entries);
    setState(() {});
  }

  Future<void> _onAddFromScan() async {
    debugPrint('[History] _onAddFromScan -> /scan');
    final result = await context.push<String>('/scan');
    debugPrint('[History] _onAddFromScan <- "$result"');
    if (result == null || result.trim().isEmpty) return;
    final entry = ScanEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      value: result.trim(),
      createdAt: DateTime.now(),
    );
    _entries.insert(0, entry);
    await _save();
  }

  Future<void> _onAddManual() async {
    debugPrint('[History] _onAddManual -> /edit');
    final created = await context.push<ScanEntry>('/edit');
    debugPrint('[History] _onAddManual <- created=${created != null}');
    if (created == null) return;
    _entries.insert(0, created);
    await _save();
  }

  Future<void> _onEdit(ScanEntry e) async {
    debugPrint('[History] _onEdit -> /edit id=${e.id}');
    final updated = await context.push<ScanEntry>('/edit', extra: e);
    debugPrint('[History] _onEdit <- updated=${updated != null}');
    if (updated == null) return;
    final idx = _entries.indexWhere((x) => x.id == e.id);
    if (idx == -1) return;
    _entries[idx] = updated;
    await _save();
  }

  Future<void> _onDelete(ScanEntry e) async {
    debugPrint('[History] _onDelete? id=${e.id}');
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Usunąć wpis?'),
        content: Text('"${e.value}" zostanie usunięty z historii.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Anuluj')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Usuń')),
        ],
      ),
    );
    debugPrint('[History] _onDelete -> confirmed=$ok');
    if (ok != true) return;
    _entries.removeWhere((x) => x.id == e.id);
    await _save();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('[History] build() loading=$_loading count=${_entries.length}');
    return Scaffold(
      appBar: AppBar(
        title: Text('Historia (${_entries.length})'),
        actions: [
          IconButton(onPressed: _onAddFromScan, icon: const Icon(Icons.qr_code_scanner)),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _entries.isEmpty
          ? RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          children: const [
            SizedBox(height: 200),
            Center(child: Text('Brak skanów. Użyj przycisku skanowania.')),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _load,
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          itemBuilder: (_, i) {
            final e = _entries[i];
            return ListTile(
              title: Text(e.value, maxLines: 2, overflow: TextOverflow.ellipsis),
              subtitle: Text(
                '${e.createdAt.toLocal()}${e.note == null || e.note!.isEmpty ? '' : '  •  ${e.note}'}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () => _onEdit(e),
              onLongPress: () => _onDelete(e),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _onDelete(e),
                tooltip: 'Usuń',
              ),
            );
          },
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemCount: _entries.length,
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _onAddManual,
        icon: const Icon(Icons.add),
        label: const Text('Dodaj ręcznie'),
      ),
    );
  }
}