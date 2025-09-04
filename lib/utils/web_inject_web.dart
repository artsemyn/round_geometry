// Implementasi khusus Web: sisipkan <script> berisi JS ke DOM
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

Future<void> injectJs(String js) async {
  final script = html.ScriptElement()..text = js;
  html.document.body?.append(script);
  script.remove();
}
