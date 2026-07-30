/// Which build a user is running.
///
/// Internal Windows previews are handed out repeatedly, so a colleague
/// reporting a problem has to be able to read *something* off the screen that
/// identifies their copy — and that something has to lead back to a commit.
/// The scheme is a date label here plus a `previa/<label>` git tag on the
/// packaged commit: the label is what a user says out loud, the tag is what
/// turns it back into code.
///
/// **This constant is the single source of truth.** `tool/package_windows.ps1`
/// parses it for the zip name instead of calling `Get-Date`, so the name on
/// disk and the string in Settings cannot disagree, and the script refuses to
/// package when the matching tag already exists — a silent second drop of
/// different code under one label is impossible rather than merely unlikely.
///
/// _Rejected: `package_info_plus` reading `pubspec.yaml`._ Its `1.0.0+1`
/// deliberately does not yet mean what DESIGN.md §8.3 means by v1, so a semver
/// would have to start claiming something untrue. _Rejected: stamping via
/// `--dart-define`._ `flutter run` builds would go anonymous, no test could
/// pin the value, and forgetting the flag once produces an unidentifiable zip.
///
/// Bump this before packaging a drop. A second drop on the same day gets a
/// letter suffix (`2026-07-27b`).
const kBuildLabel = '2026-07-29b';
