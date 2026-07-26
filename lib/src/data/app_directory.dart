import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// The one directory every piece of on-device state lives under: the Drift
/// database, the `media/` folder, and the base that a `.chronus` bundle's
/// relative paths resolve against. All three must agree on it, so they all
/// resolve it through here rather than each calling `path_provider` directly.
///
/// **iOS uses the documents directory.** DESIGN.md §2 leans on it being what
/// iCloud/iTunes backs up — for a local-first app with no accounts, that
/// automatic backup is the only safety net short of the manual bundle.
///
/// **Windows deliberately does not.** `getApplicationDocumentsDirectory()`
/// returns the *redirected* Documents folder, and OneDrive's Known Folder Move
/// (on by default in most Microsoft 365 setups) places that inside a sync root.
/// A sync client that uploads a live SQLite file and its `-wal` sidecar
/// mid-write can corrupt the database, and can hold a lock while the app has
/// the file open — so app-private state goes to Application Support
/// (`%APPDATA%\Roaming\<company>\<product>`), which is never redirected.
/// Windows data safety is the manual `.chronus` bundle instead.
Future<Directory> appDataDirectory() {
  if (Platform.isWindows) return getApplicationSupportDirectory();
  return getApplicationDocumentsDirectory();
}
