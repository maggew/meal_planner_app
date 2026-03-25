import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:meal_planner/core/security/certificate_pins.dart';

/// Creates HTTP clients that only trust pinned Root CAs.
///
/// In debug mode, pinning is disabled so proxies (Charles, mitmproxy) work.
class PinnedHttpClientFactory {
  PinnedHttpClientFactory._();

  /// [http.Client] for Supabase REST calls (passed to Supabase.initialize).
  static http.Client createSupabaseClient() {
    if (kDebugMode) return http.Client();
    return IOClient(_buildHttpClient(CertificatePins.supabaseRootCaPems));
  }

  /// [HttpClient] for Dio adapter (Supabase Edge Functions via Firebase auth).
  static HttpClient createSupabaseHttpClient() {
    if (kDebugMode) return HttpClient();
    return _buildHttpClient(CertificatePins.supabaseRootCaPems);
  }

  static HttpClient _buildHttpClient(List<String> rootCaPems) {
    final context = SecurityContext(withTrustedRoots: false);
    for (final pem in rootCaPems) {
      context.setTrustedCertificatesBytes(utf8.encode(pem));
    }
    return HttpClient(context: context);
  }
}
