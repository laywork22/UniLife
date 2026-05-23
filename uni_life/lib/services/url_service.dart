import 'package:url_launcher/url_launcher.dart';

/// Apertura link esterni ai materiali del corso (IS-1.2).
class UrlService {
  UrlService._();
  static final UrlService instance = UrlService._();

  Future<bool> open(String raw) async {
    final uri = Uri.tryParse(raw);
    if (uri == null) return false;
    if (!await canLaunchUrl(uri)) return false;
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
