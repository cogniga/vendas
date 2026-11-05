import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sales/app.dart';
import 'package:sales/core/config/ambiente.dart';
import 'package:sales/core/config/supabase_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Ambiente.carregar();
  await inicializarSupabase();
  runApp(const ProviderScope(child: BalcaoRevendaApp()));
}
