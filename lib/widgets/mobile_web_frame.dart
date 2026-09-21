import 'dart:math' as math;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

/// Desktop browser에서 앱을 모바일(세로) 비율로 보이게 감싸는 셸.
/// 좁은 뷰포트(실제 모바일/좁은 창)에서는 풀사이즈로 둔다.
class MobileWebFrame extends StatelessWidget {
  const MobileWebFrame({super.key, required this.child});

  final Widget child;

  static const double _phoneWidth = 390;
  static const double _phoneMaxHeight = 844;
  static const double _wideBreakpoint = 520;

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return child;

    return LayoutBuilder(
      builder: (context, constraints) {
        final useFrame =
            constraints.maxWidth >= _wideBreakpoint && constraints.maxHeight > 500;
        if (!useFrame) return child;

        final phoneHeight = math.min(
          _phoneMaxHeight,
          constraints.maxHeight * 0.94,
        );

        return ColoredBox(
          color: const Color(0xFF1C1410),
          child: Center(
            child: Container(
              width: _phoneWidth,
              height: phoneHeight,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: const Color(0xFFD4AF37), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.45),
                    blurRadius: 40,
                    offset: const Offset(0, 18),
                  ),
                ],
              ),
              clipBehavior: Clip.none,
              child: MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  size: Size(_phoneWidth, phoneHeight),
                  padding: const EdgeInsets.only(top: 12, bottom: 8),
                  viewPadding: const EdgeInsets.only(top: 12, bottom: 8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(26),
                  child: child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
