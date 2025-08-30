import 'package:supabase_flutter/supabase_flutter.dart';

class AppConfig {
  static const supabaseUrl = "https://tfouczcldljsbrbgrntp.supabase.co";
  static const supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRmb3VjemNsZGxqc2JyYmdybnRwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTYzNjE0MTcsImV4cCI6MjA3MTkzNzQxN30.GGWroeTd3yKQCzL2cfSXpVWusTlCUSq6pSiRPFkJq4k";
}

final supabase = Supabase.instance.client;
