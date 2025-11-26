import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../apiInterface/ApiInterface.dart';

class GoogleWebLoginPage extends StatefulWidget {
  const GoogleWebLoginPage({super.key});

  @override
  State<GoogleWebLoginPage> createState() => _GoogleWebLoginPageState();
}

class _GoogleWebLoginPageState extends State<GoogleWebLoginPage> {
  final _storage = const FlutterSecureStorage();
  late final WebViewController _controller;
  bool _isLoading = true;

  // Your backend’s final redirect:
  // https://cuplix.in/auth/callback?token=...&refreshToken=...
  static const String callbackHost = 'cuplix.in';
  static const String callbackPath = '/auth/callback';

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() => _isLoading = true);
          },
          onPageFinished: (url) {
            setState(() => _isLoading = false);
          },
          onNavigationRequest: (NavigationRequest request) async {
            final uri = Uri.parse(request.url);
            debugPrint('🌐 Nav to: $uri');

            // Match: https://cuplix.in/auth/callback?token=...&refreshToken=...
            if (uri.host == callbackHost && uri.path == callbackPath) {
              final token = uri.queryParameters['token'];
              final refresh = uri.queryParameters['refreshToken'];

              debugPrint('✅ CALLBACK token=$token');
              debugPrint('✅ CALLBACK refreshToken=$refresh');

              if (token != null && refresh != null) {
                // Save as your app tokens
                await _storage.write(key: 'accessToken', value: token);
                await _storage.write(key: 'refreshToken', value: refresh);

                if (!mounted) return NavigationDecision.prevent;

                // Close WebView, return success
                Navigator.of(context).pop(true);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Login callback missing token data'),
                  ),
                );
              }

              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
    // This must be: https://api.cuplix.in/api/auth/google
      ..loadRequest(Uri.parse(ApiInterface.authGoogle));
  }
  static Future<void> startLogin() async {
    final uri = Uri.parse('https://api.cuplix.in/api/auth/google');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $uri');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Continue with Google'),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
