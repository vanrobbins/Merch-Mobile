import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'providers/projects_provider.dart';
import 'providers/editor_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final projectsProvider = ProjectsProvider();
  await projectsProvider.load();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: projectsProvider),
        ChangeNotifierProvider(create: (_) => EditorProvider()),
      ],
      child: const MerchMobileApp(),
    ),
  );
}
