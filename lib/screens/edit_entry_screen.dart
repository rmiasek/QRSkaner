import 'package:flutter/material.dart';
import '../models/scan_entry.dart';


class EditEntryScreen extends StatefulWidget {
final ScanEntry? initial;
const EditEntryScreen({super.key, this.initial});


@override
State<EditEntryScreen> createState() => _EditEntryScreenState();
}


class _EditEntryScreenState extends State<EditEntryScreen> {
final _formKey = GlobalKey<FormState>();
late final TextEditingController _valueCtrl;
late final TextEditingController _noteCtrl;


@override
void initState() {
super.initState();
_valueCtrl = TextEditingController(text: widget.initial?.value ?? '');
_noteCtrl = TextEditingController(text: widget.initial?.note ?? '');
}


@override
void dispose() {
_valueCtrl.dispose();
_noteCtrl.dispose();
super.dispose();
}


String? _validateValue(String? v) {
final s = (v ?? '').trim();
if (s.isEmpty) return 'Wartość nie może być pusta';
if (s.length > 2048) return 'Za długie: maks. 2048 znaków';
final looksLikeUrl = RegExp(r'^(https?://)');
if (s.contains(' ') && looksLikeUrl.hasMatch(s)) {
return 'URL nie powinien zawierać spacji';
}
return null;
}

void _submit() {
if (!_formKey.currentState!.validate()) return;
final now = DateTime.now();
final result = ScanEntry(
id: widget.initial?.id ?? now.millisecondsSinceEpoch.toString(),
value: _valueCtrl.text.trim(),
createdAt: widget.initial?.createdAt ?? now,
note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
);
Navigator.pop(context, result);
}


@override
Widget build(BuildContext context) {
final isEdit = widget.initial != null;
return Scaffold(
appBar: AppBar(title: Text(isEdit ? 'Edytuj wpis' : 'Nowy wpis')),
body: Padding(
padding: const EdgeInsets.all(16.0),
child: Form(
key: _formKey,
child: Column(
children: [
TextFormField(
controller: _valueCtrl,
maxLines: 3,
decoration: const InputDecoration(
labelText: 'Treść (z QR lub wpis ręczny)',
border: OutlineInputBorder(),
),
validator: _validateValue,
),
const SizedBox(height: 12),
TextFormField(
controller: _noteCtrl,
decoration: const InputDecoration(
labelText: 'Notatka (opcjonalnie)',
border: OutlineInputBorder(),
),
),
const Spacer(),
SizedBox(
width: double.infinity,
child: FilledButton.icon(
onPressed: _submit,
icon: const Icon(Icons.save),
label: Text(isEdit ? 'Zapisz zmiany' : 'Dodaj'),
),
)
],
),
),
),
);
}
}