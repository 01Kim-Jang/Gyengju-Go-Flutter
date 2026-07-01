import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;

class MarkerGenerator {
  static Future<Uint8List> createPokestopMarker({String? imageUrl}) async {
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
      Rect.fromCenter(center: const Offset(size / 2, size - 15), width: 40, height: 15),
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
          final ui.Codec codec = await ui.instantiateImageCodec(response.bodyBytes);
          final ui.FrameInfo frameInfo = await codec.getNextFrame();
          final ui.Image image = frameInfo.image;

          // Clip to circle
          canvas.save();
          Path clipPath = Path()..addOval(Rect.fromCircle(center: const Offset(size / 2, size / 2 - 20), radius: radius - 4));
          canvas.clipPath(clipPath);

          // Calculate destination rect to cover the circle
          final Rect destRect = Rect.fromCircle(center: const Offset(size / 2, size / 2 - 20), radius: radius - 4);
          final Size imageSize = Size(image.width.toDouble(), image.height.toDouble());
          
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
        canvas.drawCircle(const Offset(size / 2, size / 2 - 20), radius - 4, paint);
      }
    } else {
      // Empty center (default Pokestop)
      paint.color = Colors.white;
      canvas.drawCircle(const Offset(size / 2, size / 2 - 20), radius - 4, paint);
      
      // Inner small circle
      paint.color = const Color(0xFF29B6F6);
      canvas.drawCircle(const Offset(size / 2, size / 2 - 20), radius / 2, paint);
    }

    final ui.Image markerAsImage = await pictureRecorder.endRecording().toImage(size.toInt(), size.toInt());
    final ByteData? byteData = await markerAsImage.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }
}
