// lib/config.dart
// Central app configuration: Supabase, Functions, Storage, feature flags.
// Catatan: anon key Supabase memang public (dipakai di client).
// JANGAN taruh service_role key di sini.

import 'package:flutter/foundation.dart' show kDebugMode;

class AppConfig {
  final String supabaseUrl;        // ex: https://xxxx.supabase.co
  final String supabaseAnonKey;    
  final String functionsBaseUrl;   // ex: https://xxxx.functions.supabase.co
  final String storageBucketGlb;   // ex: models-glb
  final String storageBucketStl;   // ex: models-stl

  // feature flags / endpoints tambahan
  final String aiEvalPath;         // ex: /grade-essay (Edge Function)
  final String glbToStlPath;       // ex: /glb-to-stl (Edge Function)
  final bool enableInteractive3D;  // ex: true

  const AppConfig({
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.functionsBaseUrl,
    this.storageBucketGlb = 'models-glb',
    this.storageBucketStl = 'models-stl',
    this.aiEvalPath = '/grade-essay',
    this.glbToStlPath = '/glb-to-stl',
    this.enableInteractive3D = true,
  });

  String get aiEvalUrl => '$functionsBaseUrl$aiEvalPath';
  String get glbToStlUrl => '$functionsBaseUrl$glbToStlPath';

  // ---- Environments ----
  // Ganti nilai default di bawah sesuai project-mu.
  static AppConfig dev() => const AppConfig(
        supabaseUrl: 'https://tfouczcldljsbrbgrntp.supabase.co',
        supabaseAnonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRmb3VjemNsZGxqc2JyYmdybnRwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTYzNjE0MTcsImV4cCI6MjA3MTkzNzQxN30.GGWroeTd3yKQCzL2cfSXpVWusTlCUSq6pSiRPFkJq4k',
        functionsBaseUrl: 'https://tfouczcldljsbrbgrntp.functions.supabase.co',
      );

  static AppConfig prod() => const AppConfig(
        supabaseUrl: 'https://tfouczcldljsbrbgrntp.supabase.co',
        supabaseAnonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRmb3VjemNsZGxqc2JyYmdybnRwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTYzNjE0MTcsImV4cCI6MjA3MTkzNzQxN30.GGWroeTd3yKQCzL2cfSXpVWusTlCUSq6pSiRPFkJq4k',
        functionsBaseUrl: 'https://tfouczcldljsbrbgrntp.functions.supabase.co',
      );

  // Auto-pick dev saat debug, prod saat release.
  static AppConfig current() => kDebugMode ? dev() : prod();
}
