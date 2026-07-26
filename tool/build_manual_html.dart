// Dev tool: renders docs/MANUAL-*.md into self-contained HTML manuals.
//
//   dart run tool/build_manual_html.dart
//
// Writes docs/MANUAL-pt.html and docs/MANUAL-en.html, which ARE committed and
// are what ships inside the Windows zip.
//
// Why HTML rather than the markdown itself: the manual is illustrated, and a
// .md double-clicked on a stock Windows PC opens in Notepad, where the images
// are just link text. The HTML opens in any browser with the screenshots
// visible.
//
// Self-contained on purpose: every screenshot is inlined as a base64 data URI,
// so a manual is one file an employee can copy or email with nothing to keep
// alongside it. That is also why the zip no longer carries manual/images/.
//
// Verifies its own output before writing: every in-page anchor must resolve to
// a heading id, and every image must have been inlined. A manual that silently
// lost its screenshots or its table of contents is worse than no manual.

import 'dart:convert';
import 'dart:io';

import 'package:markdown/markdown.dart' as md;
import 'package:path/path.dart' as p;

/// (source, output, human label for messages).
const _manuals = [
  ('docs/MANUAL-pt.md', 'docs/MANUAL-pt.html', 'Portuguese'),
  ('docs/MANUAL-en.md', 'docs/MANUAL-en.html', 'English'),
];

void main(List<String> args) {
  final repo = _repoRoot();
  var failed = false;

  for (final (source, output, label) in _manuals) {
    final file = File(p.join(repo, source));
    if (!file.existsSync()) {
      stderr.writeln('MISSING: $source');
      failed = true;
      continue;
    }

    final result = _render(
      markdown: file.readAsStringSync(),
      docsDir: p.join(repo, 'docs'),
    );

    for (final problem in result.problems) {
      stderr.writeln('  $label: $problem');
      failed = true;
    }

    File(p.join(repo, output)).writeAsStringSync(result.html);
    final kb = (result.html.length / 1024).round();
    stdout.writeln('$output  ($kb KB, ${result.imagesInlined} images inlined)');
  }

  if (failed) {
    stderr.writeln('\nManual generation had problems (see above).');
    exit(1);
  }
  stdout.writeln('\nDone. Both manuals are self-contained single files.');
}

String _repoRoot() {
  // Run from anywhere: walk up until pubspec.yaml appears.
  var dir = Directory.current;
  while (!File(p.join(dir.path, 'pubspec.yaml')).existsSync()) {
    final parent = dir.parent;
    if (parent.path == dir.path) {
      throw StateError('Could not find the repo root (no pubspec.yaml above ${Directory.current.path}).');
    }
    dir = parent;
  }
  return dir.path;
}

typedef _Result = ({String html, int imagesInlined, List<String> problems});

_Result _render({required String markdown, required String docsDir}) {
  final problems = <String>[];

  // gitHubWeb gives tables, fenced code and heading ids in one set, matching
  // how the .md already reads on GitHub.
  var body = md.markdownToHtml(
    markdown,
    extensionSet: md.ExtensionSet.gitHubWeb,
  );

  body = _rewriteHeadingIds(body);

  // The markdown package percent-encodes link targets, so a Portuguese entry
  // arrives as "#2-instala%C3%A7%C3%A3o-..." while the heading id it points at
  // is literal UTF-8. Browsers do fall back to comparing the decoded form, but
  // making the two match exactly removes the dependency on that fallback.
  body = body.replaceAllMapped(
    RegExp(r'href="#([^"]+)"'),
    (m) => 'href="#${Uri.decodeComponent(m[1]!)}"',
  );

  final title = _firstHeading(markdown) ?? 'Chronus';

  // The manuals link each other as .md; in HTML form they must point at the
  // HTML sibling or the link dead-ends for the reader.
  body = body.replaceAllMapped(
    RegExp(r'href="(MANUAL-(?:pt|en))\.md"'),
    (m) => 'href="${m[1]}.html"',
  );

  // Inline every screenshot. Paths in the markdown are relative to docs/.
  var imagesInlined = 0;
  body = body.replaceAllMapped(
    RegExp(r'src="([^"]+)"'),
    (m) {
      final src = m[1]!;
      if (src.startsWith('data:')) return m[0]!;
      final image = File(p.join(docsDir, p.joinAll(src.split('/'))));
      if (!image.existsSync()) {
        problems.add('image not found: $src');
        return m[0]!;
      }
      imagesInlined++;
      final encoded = base64Encode(image.readAsBytesSync());
      return 'src="data:${_mimeFor(src)};base64,$encoded"';
    },
  );

  problems.addAll(_unresolvedAnchors(body));
  if (imagesInlined == 0) problems.add('no images were inlined');

  return (
    html: _document(title: title, body: body),
    imagesInlined: imagesInlined,
    problems: problems,
  );
}

/// Replaces the markdown package's heading ids with GitHub-compatible slugs.
///
/// The package strips non-ASCII outright -- "Instalação" becomes "instalao" --
/// while GitHub keeps the accented letters. The tables of contents were written
/// against GitHub's rules, so every accented Portuguese entry would dead-end.
String _rewriteHeadingIds(String html) {
  final seen = <String, int>{};
  return html.replaceAllMapped(
    RegExp(r'<h([1-6]) id="[^"]*">(.*?)</h\1>', dotAll: true),
    (m) {
      final level = m[1]!;
      final inner = m[2]!;
      var slug = _githubSlug(_stripTags(inner));
      // GitHub disambiguates repeats with -1, -2, ...
      final count = seen.update(slug, (n) => n + 1, ifAbsent: () => 0);
      if (count > 0) slug = '$slug-$count';
      return '<h$level id="$slug">$inner</h$level>';
    },
  );
}

/// GitHub's heading slug: lowercase, drop punctuation, spaces to hyphens,
/// letters of any script preserved.
String _githubSlug(String text) {
  final cleaned = text
      .toLowerCase()
      .replaceAll(RegExp(r'[^\p{L}\p{N} \-]', unicode: true), '');
  return cleaned.trim().replaceAll(RegExp(r'\s+'), '-');
}

String _stripTags(String html) => html
    .replaceAll(RegExp(r'<[^>]+>'), '')
    .replaceAll('&amp;', '&')
    .replaceAll('&lt;', '<')
    .replaceAll('&gt;', '>')
    .trim();

String _mimeFor(String path) {
  switch (p.extension(path).toLowerCase()) {
    case '.png':
      return 'image/png';
    case '.jpg':
    case '.jpeg':
      return 'image/jpeg';
    case '.gif':
      return 'image/gif';
    case '.svg':
      return 'image/svg+xml';
    default:
      return 'application/octet-stream';
  }
}

/// Table-of-contents entries that point at a heading that does not exist.
/// Accented Portuguese slugs are the likely breakage, so this is checked
/// rather than assumed.
List<String> _unresolvedAnchors(String html) {
  final ids = RegExp(r'id="([^"]+)"')
      .allMatches(html)
      .map((m) => m[1]!)
      .toSet();
  final problems = <String>[];
  for (final m in RegExp(r'href="#([^"]+)"').allMatches(html)) {
    final raw = m[1]!;
    if (ids.contains(raw)) continue;
    // Fall back to the percent-decoded form, which is what a browser compares
    // when the literal fragment does not match an id. A malformed escape just
    // means "not decodable" here -- it must not take the whole build down.
    String? decoded;
    try {
      decoded = Uri.decodeComponent(raw);
    } on ArgumentError {
      decoded = null;
    }
    if (decoded == null || !ids.contains(decoded)) {
      problems.add('anchor does not resolve: #$raw');
    }
  }
  return problems;
}

String? _firstHeading(String markdown) {
  for (final line in const LineSplitter().convert(markdown)) {
    if (line.startsWith('# ')) return line.substring(2).trim();
  }
  return null;
}

String _document({required String title, required String body}) {
  return '''<!DOCTYPE html>
<html lang="pt-BR">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>${_escape(title)}</title>
<style>
  :root {
    --fg: #1a1a1a;
    --muted: #5c6470;
    --bg: #ffffff;
    --rule: #dfe3e8;
    --accent: #1f5fa9;
    --code-bg: #f4f6f8;
  }
  @media (prefers-color-scheme: dark) {
    :root {
      --fg: #e6e6e6;
      --muted: #a0a8b4;
      --bg: #16181c;
      --rule: #333840;
      --accent: #7fb3f0;
      --code-bg: #22262c;
    }
  }
  * { box-sizing: border-box; }
  body {
    margin: 0 auto;
    padding: 3rem 1.25rem 6rem;
    max-width: 48rem;
    background: var(--bg);
    color: var(--fg);
    font: 16px/1.65 -apple-system, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
  }
  h1, h2, h3 { line-height: 1.25; margin: 2.5rem 0 0.75rem; }
  h1 { font-size: 2rem; margin-top: 0; }
  h2 { font-size: 1.4rem; padding-top: 1.25rem; border-top: 1px solid var(--rule); }
  h3 { font-size: 1.1rem; }
  p, li { margin: 0.6rem 0; }
  a { color: var(--accent); }
  hr { border: 0; border-top: 1px solid var(--rule); margin: 2rem 0; }
  blockquote {
    margin: 1.25rem 0;
    padding: 0.5rem 1rem;
    border-left: 3px solid var(--accent);
    color: var(--muted);
  }
  code {
    background: var(--code-bg);
    padding: 0.12em 0.35em;
    border-radius: 3px;
    font: 0.875em/1.5 ui-monospace, Consolas, "Courier New", monospace;
  }
  pre {
    background: var(--code-bg);
    padding: 0.9rem 1rem;
    border-radius: 6px;
    overflow-x: auto;
  }
  pre code { background: none; padding: 0; }
  img {
    display: block;
    max-width: 100%;
    height: auto;
    margin: 1.5rem auto;
    border: 1px solid var(--rule);
    border-radius: 6px;
  }
  /* Wide tables scroll inside their own box rather than the page. */
  table {
    display: block;
    width: 100%;
    overflow-x: auto;
    border-collapse: collapse;
    margin: 1.25rem 0;
    font-size: 0.94rem;
  }
  th, td {
    border: 1px solid var(--rule);
    padding: 0.45rem 0.7rem;
    text-align: left;
    vertical-align: top;
  }
  th { background: var(--code-bg); font-weight: 600; }
  @media print {
    body { max-width: none; padding: 0; color: #000; background: #fff; }
    h2 { break-before: auto; }
    img, table, pre { break-inside: avoid; }
  }
</style>
</head>
<body>
$body
</body>
</html>
''';
}

String _escape(String s) => s
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;');
