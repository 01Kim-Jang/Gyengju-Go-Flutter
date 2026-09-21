import 'package:flutter/material.dart';

/// 앱 첫 진입 시 한 번, 프로덕션 진행 상황을 알리는 공지 팝업.
void showAnnouncementDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => Dialog(
      backgroundColor: const Color(0xFFFDFBF7),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: Color(0xFFD4AF37), width: 3),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.campaign, color: Color(0xFFD4AF37), size: 48),
            const SizedBox(height: 16),
            const Text(
              '공지사항',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Serif',
                color: Color(0xFF3E2723),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Divider(color: Color(0xFFD7CCC8), thickness: 1),
            const SizedBox(height: 12),
            const Text(
              '현재 앱 프로덕션 진행중입니다.\n앱 등록이 완료되면 이 자리에 앱 주소를 안내해 드릴게요!',
              style: TextStyle(fontSize: 15, color: Color(0xFF5D4037), height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('확인', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
