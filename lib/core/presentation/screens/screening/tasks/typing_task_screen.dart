import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:go_router/go_router.dart';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import '../../../../utils/app_router.dart';

class TypingTaskScreen extends StatefulWidget {
  const TypingTaskScreen({super.key});

  @override
  State<TypingTaskScreen> createState() => _TypingTaskScreenState();
}

class _TypingTaskScreenState extends State<TypingTaskScreen> {
  late final WebViewController? _controller;
  bool _isLoading = true;
  final String _iframeId = 'typing-task-iframe';
  html.EventListener? _messageListener;

  @override
  void initState() {
    super.initState();

    if (kIsWeb) {
      // For web platform, register the iframe view
      _registerIframeView();
      _setupMessageListener();
      _controller = null;
    } else {
      // For mobile platforms, use WebViewController
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
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
            onWebResourceError: (WebResourceError error) {
              debugPrint('WebView error: ${error.description}');
            },
          ),
        )
        ..addJavaScriptChannel(
          'FlutterChannel',
          onMessageReceived: (JavaScriptMessage message) {
            if (message.message == 'TYPING_TEST_COMPLETE') {
              _navigateToDashboard();
            }
          },
        )
        ..loadRequest(Uri.parse('assets/typing_game.html'));
    }
  }

  void _setupMessageListener() {
    // Listen for messages from the iframe
    _messageListener = (html.Event event) {
      if (event is html.MessageEvent) {
        final data = event.data;
        if (data is Map && data['type'] == 'TYPING_TEST_COMPLETE') {
          _navigateToDashboard();
        }
      }
    };
    html.window.addEventListener('message', _messageListener);
  }

  void _navigateToDashboard() {
    if (mounted) {
      context.go(AppRouter.dashboard);
    }
  }

  void _registerIframeView() {
    // Register the iframe element for web
    ui_web.platformViewRegistry.registerViewFactory(_iframeId, (int viewId) {
      final iframe = html.IFrameElement()
        ..src = 'typing_game.html'
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%';

      iframe.onLoad.listen((event) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      });

      return iframe;
    });
  }

  @override
  void dispose() {
    if (kIsWeb && _messageListener != null) {
      html.window.removeEventListener('message', _messageListener);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Magical Typing Test'),
        backgroundColor: const Color(0xFF8B7355),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          if (kIsWeb)
            // Use HtmlElementView for web platform
            HtmlElementView(viewType: _iframeId)
          else if (_controller != null)
            // Use WebViewWidget for mobile platforms
            WebViewWidget(controller: _controller),
          if (_isLoading) 
            Container(
              color: const Color(0xFFF5E6D3),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B7355)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
