import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

/// Opens the production SQLite file under the platform-private docs dir.
///
/// `applyWorkaroundToOpenSqlite3OnOldAndroidVersions` patches Android <11
/// which ships an older sqlite3 without WAL — a no-op on modern devices.
QueryExecutor openConnection() {
  return LazyDatabase(() async {
    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'coriolis_companion_cache.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
