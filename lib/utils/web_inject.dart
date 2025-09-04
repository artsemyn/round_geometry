// Gunakan conditional export: di Web pakai implementasi 'web',
// di platform lain pakai 'stub' (no-op).
export 'web_inject_stub.dart'
  if (dart.library.html) 'web_inject_web.dart';
