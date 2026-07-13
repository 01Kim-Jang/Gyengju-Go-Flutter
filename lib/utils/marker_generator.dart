import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../data/preloaded_spots.dart';

class MarkerGenerator {
  static Future<Uint8List> createPokestopMarker({
    required String title,
    String? imageUrl,
    bool isGlowing = false,
  }) async {
    const double size = 150.0;
    const double radius = 50.0;

    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint()..isAntiAlias = true;

    // Draw the stick (pole)
    paint.color = Colors.white;
    paint.strokeWidth = 6.0;
    canvas.drawLine(
      const Offset(size / 2, size / 2),
      const Offset(size / 2, size - 20),
      paint,
    );

    // Draw base shadow/circle
    paint.color = Colors.black26;
    paint.style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(
        center: const Offset(size / 2, size - 15),
        width: 40,
        height: 15,
      ),
      paint,
    );

    // Draw outer ring (Pokestop Blue)
    paint.color = Colors.white;
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(size / 2, size / 2 - 20), radius + 8, paint);

    paint.color = const Color(0xFF29B6F6); // Light Blue
    canvas.drawCircle(const Offset(size / 2, size / 2 - 20), radius + 4, paint);

    // Draw inner content
    if (imageUrl != null && imageUrl.isNotEmpty) {
      try {
        ui.Image image;
        if (imageUrl.startsWith('assets/')) {
          final ByteData bytes = await rootBundle.load(imageUrl);
          final ui.Codec codec = await ui.instantiateImageCodec(
            bytes.buffer.asUint8List(),
          );
          final ui.FrameInfo frameInfo = await codec.getNextFrame();
          image = frameInfo.image;
        } else {
          final response = await http.get(Uri.parse(imageUrl)).timeout(const Duration(seconds: 5));
          if (response.statusCode == 200) {
            final ui.Codec codec = await ui.instantiateImageCodec(
              response.bodyBytes,
            );
            final ui.FrameInfo frameInfo = await codec.getNextFrame();
            image = frameInfo.image;
          } else {
            throw Exception('Failed network image download (HTTP ${response.statusCode})');
          }
        }

        // Clip to circle
        canvas.save();
        Path clipPath = Path()
          ..addOval(
            Rect.fromCircle(
              center: const Offset(size / 2, size / 2 - 20),
              radius: radius - 4,
            ),
          );
        canvas.clipPath(clipPath);

        // Calculate destination rect to cover the circle
        final Rect destRect = Rect.fromCircle(
          center: const Offset(size / 2, size / 2 - 20),
          radius: radius - 4,
        );
        final Size imageSize = Size(
          image.width.toDouble(),
          image.height.toDouble(),
        );

        // Source rect for cropping center of image
        double scale = destRect.width / imageSize.width;
        if (imageSize.height * scale < destRect.height) {
          scale = destRect.height / imageSize.height;
        }
        final double srcWidth = destRect.width / scale;
        final double srcHeight = destRect.height / scale;
        final Rect srcRect = Rect.fromLTWH(
          (imageSize.width - srcWidth) / 2,
          (imageSize.height - srcHeight) / 2,
          srcWidth,
          srcHeight,
        );

        canvas.drawImageRect(image, srcRect, destRect, Paint());
        canvas.restore();
      } catch (e) {
        print("Failed to load image for marker ($imageUrl): $e");
        // Fallback to empty center if image fails
        paint.color = Colors.white;
        canvas.drawCircle(
          const Offset(size / 2, size / 2 - 20),
          radius - 4,
          paint,
        );
      }
    } else {
      // Empty center (default Pokestop)
      paint.color = Colors.white;
      canvas.drawCircle(
        const Offset(size / 2, size / 2 - 20),
        radius - 4,
        paint,
      );

      // Inner small circle
      paint.color = const Color(0xFF29B6F6);
      canvas.drawCircle(
        const Offset(size / 2, size / 2 - 20),
        radius / 2,
        paint,
      );
    }

    final ui.Image markerAsImage = await pictureRecorder.endRecording().toImage(
      size.toInt(),
      size.toInt(),
    );
    final ByteData? byteData = await markerAsImage.toByteData(
      format: ui.ImageByteFormat.png,
    );
    return byteData!.buffer.asUint8List();
  }

  static Future<Uint8List> createPlayerMarker(String assetPath) async {
    final ByteData bytes = await rootBundle.load(assetPath);
    final ui.Codec codec = await ui.instantiateImageCodec(
      bytes.buffer.asUint8List(),
      targetWidth: 150, // Match the base size of Pokestops
    );
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    final ByteData? resizedBytes = await frameInfo.image.toByteData(format: ui.ImageByteFormat.png);
    return resizedBytes!.buffer.asUint8List();
  }

  static Future<Map<String, dynamic>> createPokestopMarkerRaw({
    String? imageUrl,
  }) async {
    const double size = 150.0;
    const double radius = 50.0;

    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint()..isAntiAlias = true;

    // Draw the stick (pole)
    paint.color = Colors.white;
    paint.strokeWidth = 6.0;
    canvas.drawLine(
      const Offset(size / 2, size / 2),
      const Offset(size / 2, size - 20),
      paint,
    );

    // Draw base shadow/circle
    paint.color = Colors.black26;
    paint.style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(
        center: const Offset(size / 2, size - 15),
        width: 40,
        height: 15,
      ),
      paint,
    );

    // Draw outer ring (Pokestop Blue)
    paint.color = Colors.white;
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(size / 2, size / 2 - 20), radius + 8, paint);

    paint.color = const Color(0xFF29B6F6); // Light Blue
    canvas.drawCircle(const Offset(size / 2, size / 2 - 20), radius + 4, paint);

    // Draw inner content
    if (imageUrl != null && imageUrl.isNotEmpty) {
      try {
        final response = await http.get(Uri.parse(imageUrl));
        if (response.statusCode == 200) {
          final ui.Codec codec = await ui.instantiateImageCodec(
            response.bodyBytes,
          );
          final ui.FrameInfo frameInfo = await codec.getNextFrame();
          final ui.Image image = frameInfo.image;

          // Clip to circle
          canvas.save();
          Path clipPath = Path()
            ..addOval(
              Rect.fromCircle(
                center: const Offset(size / 2, size / 2 - 20),
                radius: radius - 4,
              ),
            );
          canvas.clipPath(clipPath);

          // Calculate destination rect to cover the circle
          final Rect destRect = Rect.fromCircle(
            center: const Offset(size / 2, size / 2 - 20),
            radius: radius - 4,
          );
          final Size imageSize = Size(
            image.width.toDouble(),
            image.height.toDouble(),
          );

          // Source rect for cropping center of image
          double scale = destRect.width / imageSize.width;
          if (imageSize.height * scale < destRect.height) {
            scale = destRect.height / imageSize.height;
          }
          final double srcWidth = destRect.width / scale;
          final double srcHeight = destRect.height / scale;
          final Rect srcRect = Rect.fromLTWH(
            (imageSize.width - srcWidth) / 2,
            (imageSize.height - srcHeight) / 2,
            srcWidth,
            srcHeight,
          );

          canvas.drawImageRect(image, srcRect, destRect, Paint());
          canvas.restore();
        }
      } catch (e) {
        print("Failed to load image for marker: $e");
        // Fallback to empty center if image fails
        paint.color = Colors.white;
        canvas.drawCircle(
          const Offset(size / 2, size / 2 - 20),
          radius - 4,
          paint,
        );
      }
    } else {
      // Empty center (default Pokestop)
      paint.color = Colors.white;
      canvas.drawCircle(
        const Offset(size / 2, size / 2 - 20),
        radius - 4,
        paint,
      );

      // Inner small circle
      paint.color = const Color(0xFF29B6F6);
      canvas.drawCircle(
        const Offset(size / 2, size / 2 - 20),
        radius / 2,
        paint,
      );
    }

    final ui.Image markerAsImage = await pictureRecorder.endRecording().toImage(
      size.toInt(),
      size.toInt(),
    );
    final ByteData? byteData = await markerAsImage.toByteData(
      format: ui.ImageByteFormat.rawRgba,
    );
    return {
      'bytes': byteData!.buffer.asUint8List(),
      'width': size.toInt(),
      'height': size.toInt(),
    };
  }

  static String? getLocalImagePath(String title, {String? mapX, String? mapY}) {
    String koTitle = title;
    
    // 1. Resolve Korean title using coordinates (since they are stable across translations)
    if (mapX != null && mapY != null) {
      double? endX = double.tryParse(mapX);
      double? endY = double.tryParse(mapY);
      if (endX != null && endY != null) {
        for (var spot in PreloadedSpots.data['ko']!) {
          double? spotX = double.tryParse(spot['mapX'] ?? '');
          double? spotY = double.tryParse(spot['mapY'] ?? '');
          if (spotX != null && spotY != null) {
            double diff = (spotX - endX).abs() + (spotY - endY).abs();
            if (diff < 0.0001) {
              koTitle = spot['title'] ?? title;
              break;
            }
          }
        }
      }
    } else {
      // 2. Fallback: Find index in active translated list and retrieve the same index in the 'ko' list
      bool foundIndex = false;
      for (var lang in ['en', 'ja', 'zh-chs']) {
        final list = PreloadedSpots.data[lang];
        if (list == null) continue;
        for (int i = 0; i < list.length; i++) {
          if (list[i]['title'] == title) {
            if (i < PreloadedSpots.data['ko']!.length) {
              koTitle = PreloadedSpots.data['ko']![i]['title'] ?? title;
              foundIndex = true;
              break;
            }
          }
        }
        if (foundIndex) break;
      }
    }

    final clean = koTitle
        .replaceAll(RegExp(r'\([^)]*\)'), '')
        .replaceAll(RegExp(r'\[[^\]]*\]'), '')
        .replaceAll('경주, ', '')
        .replaceAll('경주 ', '')
        .trim()
        .toLowerCase();

    if (clean.contains('첨성대')) return 'assets/images/spots/경주_첨성대.jpg';
    if (clean.contains('동궁과 월지') || clean.contains('안압지') || clean.contains('雁鴨池') || clean.contains('东宫')) return 'assets/images/spots/동궁과_월지.jpg';
    if (clean.contains('불국사')) return 'assets/images/spots/경주_불국사.jpg';
    if (clean.contains('석굴암')) return 'assets/images/spots/경주_석굴암_석굴.jpg';
    if (clean.contains('대릉원')) return 'assets/images/spots/경주_대릉원.jpg';
    if (clean.contains('황리단길')) return 'assets/images/spots/신라_역사_여행.jpg';
    if (clean.contains('계림')) return 'assets/images/spots/경주_계림.jpg';
    if (clean.contains('월성')) return 'assets/images/spots/경주_월성.jpg';
    if (clean.contains('박물관')) return 'assets/images/spots/국립경주박물관.jpg';
    if (clean.contains('황룡사')) return 'assets/images/spots/경주_황룡사지.jpg';
    if (clean.contains('분황사')) return 'assets/images/spots/분황사.jpg';
    if (clean.contains('오릉')) return 'assets/images/spots/경주_오릉.jpg';
    if (clean.contains('선덕여왕릉')) return 'assets/images/spots/선덕여왕릉.jpg';
    if (clean.contains('월정교') && clean.contains('교촌')) return 'assets/images/spots/경주_교촌한옥마을_–_월정교_–_남산자락도로.jpg';
    if (clean.contains('월정교')) return 'assets/images/spots/월정교.jpg';
    if (clean.contains('mcy') || clean.contains('파크')) return 'assets/images/spots/MCY_파크.jpg';
    if (clean.contains('해국길') || clean.contains('감포')) return 'assets/images/spots/경주_감포_해국길.jpg';
    if (clean.contains('국민힐링파크')) return 'assets/images/spots/경주_국민힐링파크.jpg';
    if (clean.contains('나정')) return 'assets/images/spots/경주_나정.jpg';
    if (clean.contains('도리마을')) return 'assets/images/spots/경주_도리마을.jpg';
    if (clean.contains('삼릉숲')) return 'assets/images/spots/경주_삼릉숲.jpg';
    if (clean.contains('주상절리')) return 'assets/images/spots/경주_양남_주상절리_전망대.jpg';
    if (clean.contains('옥산서원')) return 'assets/images/spots/경주_옥산서원.jpg';
    if (clean.contains('포석정')) return 'assets/images/spots/경주_포석정지.jpg';
    if (clean.contains('설화따라')) return 'assets/images/spots/전설따라_설화따라-경주시.jpg';
    if (clean.contains('문무')) return 'assets/images/spots/경주_문무대왕릉.jpg';
    if (clean.contains('신라 역사 여행')) return 'assets/images/spots/경주_신라_역사_여행.jpg';
    
    // 16 newly downloaded real spots from Wikimedia Commons
    if (clean.contains('괘릉')) return 'assets/images/spots/경주_괘릉.jpg';
    if (clean.contains('감은사지')) return 'assets/images/spots/감은사지.jpg';
    if (clean.contains('무열왕릉')) return 'assets/images/spots/경주_무열왕릉.jpg';
    if (clean.contains('김유신')) return 'assets/images/spots/경주_김유신묘.jpg';
    if (clean.contains('알영정')) return 'assets/images/spots/경주_알영정.jpg';
    if (clean.contains('양동마을')) return 'assets/images/spots/경주_양동마을.jpg';
    if (clean.contains('남산')) return 'assets/images/spots/경주_경주남산.jpg';
    if (clean.contains('답사길')) return 'assets/images/spots/경주_천년고도_도심_답사길.jpg';
    if (clean.contains('교촌마을') || (clean.contains('교촌') && !clean.contains('월정교'))) return 'assets/images/spots/교촌마을.jpg';
    if (clean.contains('토함산')) return 'assets/images/spots/경주_토함산.jpg';
    if (clean.contains('보문정')) return 'assets/images/spots/경주_보문정.jpg';
    if (clean.contains('보문관광')) return 'assets/images/spots/경주_보문관광단지.jpg';
    if (clean.contains('세심마을')) return 'assets/images/spots/경주_세심마을.jpg';
    if (clean.contains('도다리')) return 'assets/images/spots/경주_도다리.jpg';
    if (clean.contains('막걸리')) return 'assets/images/spots/경주_막걸리.jpg';

    return null;
  }
}
