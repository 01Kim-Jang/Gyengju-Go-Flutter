import 'dart:convert';
import 'dart:js_interop';
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

const _kViewType = 'kakao-web-map-iframe';
bool _viewTypeRegistered = false;

/// kakao_map_plugin은 webview_flutter로 지도를 그리는데, webview_flutter는
/// Flutter 웹을 지원하지 않는다. 대신 실제 호스팅된 web/kakao_map.html을
/// iframe으로 띄우고 postMessage로 데이터를 주고받는다 — blob: URL이 아니라
/// 진짜 같은 오리진 페이지라서 Kakao의 도메인 검증도 정상 통과한다.
class KakaoWebMap extends StatefulWidget {
  const KakaoWebMap({
    super.key,
    required this.spots,
    required this.displayNames,
    this.targetTitle,
    this.routeCoordinates,
    this.navigationMode,
    this.myLocation,
    required this.onMarkerTap,
    this.onControllerReady,
  });

  final List<Map<String, dynamic>> spots;
  final Map<String, String> displayNames;
  final String? targetTitle;
  final List<List<double>>? routeCoordinates;
  final String? navigationMode;
  final Map<String, double>? myLocation;
  final void Function(String title) onMarkerTap;
  final void Function(void Function(double lat, double lng, {int? level}) panTo)? onControllerReady;

  @override
  State<KakaoWebMap> createState() => _KakaoWebMapState();
}

class _KakaoWebMapState extends State<KakaoWebMap> {
  web.HTMLIFrameElement? _iframe;
  JSFunction? _messageListener;
  bool _ready = false;

  @override
  void initState() {
    super.initState();

    if (!_viewTypeRegistered) {
      _viewTypeRegistered = true;
      ui_web.platformViewRegistry.registerViewFactory(_kViewType, (int viewId) {
        final iframe = web.HTMLIFrameElement()
          ..src = 'kakao_map.html'
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '100%';
        _iframe = iframe;
        return iframe;
      });
    }

    _messageListener = ((web.Event event) => _handleMessage(event)).toJS;
    web.window.addEventListener('message', _messageListener);

    widget.onControllerReady?.call(_panTo);
  }

  void _handleMessage(web.Event event) {
    final msg = event as web.MessageEvent;
    if (_iframe == null || msg.source != _iframe!.contentWindow) return;
    if (!msg.data.isA<JSString>()) return;

    Map<String, dynamic> decoded;
    try {
      decoded = jsonDecode((msg.data as JSString).toDart) as Map<String, dynamic>;
    } catch (_) {
      return;
    }

    switch (decoded['type']) {
      case 'ready':
        _ready = true;
        _sendUpdate();
        break;
      case 'markerTap':
        final title = decoded['title'];
        if (title is String) widget.onMarkerTap(title);
        break;
    }
  }

  void _panTo(double lat, double lng, {int? level}) {
    _postToIframe({
      'type': 'panTo',
      'lat': lat,
      'lng': lng,
      if (level != null) 'level': level,
    });
  }

  void _sendUpdate() {
    if (!_ready) return;
    _postToIframe({
      'type': 'update',
      'spots': widget.spots,
      'displayNames': widget.displayNames,
      'targetTitle': widget.targetTitle,
      'route': widget.routeCoordinates,
      'navigationMode': widget.navigationMode,
      'myLocation': widget.myLocation,
    });
  }

  void _postToIframe(Map<String, dynamic> payload) {
    final win = _iframe?.contentWindow;
    if (win == null) return;
    win.postMessage(jsonEncode(payload).toJS, '*'.toJS);
  }

  @override
  void didUpdateWidget(covariant KakaoWebMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sendUpdate();
  }

  @override
  void dispose() {
    if (_messageListener != null) {
      web.window.removeEventListener('message', _messageListener);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const HtmlElementView(viewType: _kViewType);
  }
}
