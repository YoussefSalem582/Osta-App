import 'package:flutter/widgets.dart';
import 'package:osta/app.dart';
import 'package:osta/core/di/injection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const OstaApp());
}
