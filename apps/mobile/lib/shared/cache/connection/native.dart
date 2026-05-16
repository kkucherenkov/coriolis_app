import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

/// Opens the production SQLite file under the platform-private docs dir.
///
/// `applyWorkaroundToOpenSqlite3OnOldAndroidVersions` patches a library-loading
/// failure on Android < API 23 (Android 6) where `dlopen` without an absolute
/// path fails — a no-op on API 23+ and on all other platforms.
QueryExecutor openConnection() {
  return LazyDatabase(() async {
    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }
    final dir = await getApplicationSupportDirectory();
    final file = File(p.join(dir.path, 'coriolis_companion_cache.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
