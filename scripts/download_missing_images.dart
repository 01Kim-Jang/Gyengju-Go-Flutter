import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../lib/data/preloaded_spots.dart';

// Mapping helper that matches clean spot titles to their expected local filenames.
String getSanitizedFilename(String title) {
  final clean = title
      .replaceAll(RegExp(r'\([^)]*\)'), '')
      .replaceAll(RegExp(r'\[[^\]]*\]'), '')
      .replaceAll('경주, ', '')
      .replaceAll('경주 ', '')
      .trim();
  
  if (clean.contains('첨성대')) return '경주_첨성대.jpg';
  if (clean.contains('동궁과 월지') || clean.contains('안압지')) return '동궁과_월지.jpg';
  if (clean.contains('불국사')) return '경주_불국사.jpg';
  if (clean.contains('석굴암')) return '경주_석굴암_석굴.jpg';
  if (clean.contains('대릉원')) return '경주_대릉원.jpg';
  if (clean.contains('황리단길')) return '신라_역사_여행.jpg';
  if (clean.contains('계림')) return '경주_계림.jpg';
  if (clean.contains('월성')) return '경주_월성.jpg';
  if (clean.contains('박물관')) return '국립경주박물관.jpg';
  if (clean.contains('황룡사')) return '경주_황룡사지.jpg';
  if (clean.contains('분황사')) return '분황사.jpg';
  if (clean.contains('오릉')) return '경주_오릉.jpg';
  if (clean.contains('선덕여왕릉')) return '선덕여왕릉.jpg';
  if (clean.contains('월정교') && clean.contains('교촌')) return '경주_교촌한옥마을_–_월정교_–_남산자락도로.jpg';
  if (clean.contains('월정교')) return '월정교.jpg';
  if (clean.contains('mcy') || clean.contains('파크')) return 'MCY_파크.jpg';
  if (clean.contains('해국길') || clean.contains('감포')) return '경주_감포_해국길.jpg';
  if (clean.contains('국민힐링파크')) return '경주_국민힐링파크.jpg';
  if (clean.contains('나정')) return '경주_나정.jpg';
  if (clean.contains('도리마을')) return '경주_도리마을.jpg';
  if (clean.contains('삼릉숲')) return '경주_삼릉숲.jpg';
  if (clean.contains('주상절리')) return '경주_양남_주상절리_전망대.jpg';
  if (clean.contains('옥산서원')) return '경주_옥산서원.jpg';
  if (clean.contains('포석정')) return '경주_포석정지.jpg';
  if (clean.contains('설화따라')) return '전설따라_설화따라-경주시.jpg';
  
  // Dynamic fallback for any other spot (e.g. 괘릉, 무열왕릉, 김유신묘, 양동마을)
  return '경주_${clean.replaceAll(' ', '_')}.jpg';
}

Future<void> main() async {
  final spots = PreloadedSpots.data['ko'] ?? [];
  final dir = Directory('assets/images/spots');
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }

  print('Scanning spots to check/download images...');
  int downloaded = 0;
  int existing = 0;
  int failed = 0;

  for (var spot in spots) {
    final title = spot['title'] ?? '';
    final imageUrl = spot['firstimage'] ?? '';
    if (imageUrl.isEmpty) {
      print('Spot "$title" has no image URL. Skipping.');
      continue;
    }

    final filename = getSanitizedFilename(title);
    final file = File('${dir.path}/$filename');

    if (file.existsSync()) {
      print('Image for "$title" already exists at ${file.path}.');
      existing++;
    } else {
      print('Downloading image for "$title" from $imageUrl...');
      try {
        final response = await http.get(Uri.parse(imageUrl)).timeout(const Duration(seconds: 10));
        if (response.statusCode == 200) {
          await file.writeAsBytes(response.bodyBytes);
          print('Successfully saved image for "$title" to ${file.path}');
          downloaded++;
        } else {
          print('Failed to download image for "$title". Status code: ${response.statusCode}');
          failed++;
        }
      } catch (e) {
        print('Error downloading image for "$title": $e');
        failed++;
      }
    }
  }

  print('\nSummary:');
  print(' - Existing files: $existing');
  print(' - Downloaded files: $downloaded');
  print(' - Failed downloads: $failed');
}
