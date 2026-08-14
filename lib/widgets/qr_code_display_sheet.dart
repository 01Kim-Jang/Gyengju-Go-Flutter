import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../utils/translations.dart';

// gyeongjugo:friend:{CODE} 또는 gyeongjugo:party:{CODE} 형태의 payload를
// QR로 보여주고, 사람이 직접 읽고 입력할 수 있도록 원본 코드 텍스트도 함께 표시.
class QrCodeDisplaySheet extends StatelessWidget {
  final String title;
  final String payload;
  final String rawCode;
  final String currentLang;

  const QrCodeDisplaySheet({
    super.key,
    required this.title,
    required this.payload,
    required this.rawCode,
    required this.currentLang,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F3864)),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFD4AF37), width: 2),
            ),
            child: QrImageView(
              data: payload,
              size: 200,
              backgroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: rawCode));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(AppTranslations.get(currentLang, 'code_copied')), duration: const Duration(seconds: 2)),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F7),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    rawCode,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                      color: Color(0xFF1F3864),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Icon(Icons.copy, size: 18, color: Colors.grey),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
