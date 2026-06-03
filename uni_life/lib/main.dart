import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'data/datasources/database_helper.dart';
import 'data/seed_data.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('it_IT', null);
  await DatabaseHelper.instance.database;
  await NotificationService.instance.init();

  // Popola il DB con dati di esempio al primo avvio.
  // Idempotente: se il DB è già popolato non fa nulla.
  await SeedData.seedIfEmpty();

  runApp(const UniLifeApp());
}
