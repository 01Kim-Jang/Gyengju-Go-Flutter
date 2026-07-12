import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class InAppRouteWebView extends StatefulWidget {
  final String url;
  final String title;

  const InAppRouteWebView({super.key, required this.url, required this.title});

  @override
  State<InAppRouteWebView> createState() => _InAppRouteWebViewState();
}

class _InAppRouteWebViewState extends State<InAppRouteWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(
        'Mozilla/5.0 (iPhone; CPU iPhone OS 16_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.5 Mobile/15E148 Safari/604.1'
      ) // Sets a standard mobile browser user agent to ensure Kakao Mobile Web renders correctly
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            // Prevent redirecting out to App Store/Play Store installation pages
            if (request.url.startsWith('market://') || 
                request.url.startsWith('itms-apps://') || 
                request.url.contains('play.google.com') ||
                request.url.contains('apps.apple.com')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFD4AF37),
              ),
            ),
        ],
      ),
    );
  }
}
