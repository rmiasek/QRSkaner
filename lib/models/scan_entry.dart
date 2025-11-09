class ScanEntry {
final String id;
String value;
DateTime createdAt;
String? note;


ScanEntry({
required this.id,
required this.value,
required this.createdAt,
this.note,
});


factory ScanEntry.fromMap(Map<String, dynamic> map) => ScanEntry(
id: map['id'] as String,
value: map['value'] as String,
createdAt: DateTime.parse(map['createdAt'] as String),
note: map['note'] as String?,
);


Map<String, dynamic> toMap() => {
'id': id,
'value': value,
'createdAt': createdAt.toIso8601String(),
'note': note,
};
}