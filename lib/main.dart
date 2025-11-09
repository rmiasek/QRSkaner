import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'models/scan_entry.dart';
import 'screens/home_screen.dart';
import 'screens/scan_screen.dart';
import 'screens/history_screen.dart';
import 'screens/edit_entry_screen.dart';
import 'services/storage_service.dart';


void main() {
WidgetsFlutterBinding.ensureInitialized();
runApp(const MyApp());
}


class MyApp extends StatefulWidget {
const MyApp({super.key});


@override
State<MyApp> createState() => _MyAppState();
}


class _MyAppState extends State<MyApp> {
final _storage = StorageService();
List<ScanEntry> _entries = [];
bool _initialized = false;


late final GoRouter _router = GoRouter(
routes: [
GoRoute(
path: '/',
builder: (context, state) => const HomeScreen(),
),
GoRoute(
path: '/scan',
builder: (context, state) => const ScanScreen(),
),
GoRoute(
path: '/history',
builder: (context, state) => HistoryScreen(key: UniqueKey()),
),
GoRoute(
path: '/edit',
builder: (context, state) {
final extra = state.extra;
return EditEntryScreen(initial: extra is ScanEntry ? extra : null);
},
),
],
);


@override
void initState() {
super.initState();
_bootstrap();
}

Future<void> _bootstrap() async {
_entries = await _storage.load();
setState(() => _initialized = true);
}

@override
Widget build(BuildContext context) {
return MaterialApp.router(
title: 'Skaner QR',
theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
routerConfig: _router,
);
}
}