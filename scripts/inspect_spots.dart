import 'dart:io';
import '../lib/data/preloaded_spots.dart';

void main() {
  final data = PreloadedSpots.data['ko'] ?? [];
  print('Total spots: ${data.length}');
  
  final dir = Directory('assets/images/spots');
  final existingFiles = dir.listSync().map((f) => f.path.split('/').last.split('\\').last).toList();
  
  print('Existing files in assets/images/spots:');
  for (var f in existingFiles) {
    print(' - $f');
  }

  print('\nAnalyzing spot images:');
  for (var spot in data) {
    final title = spot['title'] ?? '';
    final imageUrl = spot['firstimage'] ?? '';
    
    // Check if we can map to a local file
    String? localFile;
    final clean = title.replaceAll(RegExp(r'\([^)]*\)'), '').replaceAll('경주, ', '').replaceAll('경주 ', '').trim();
    
    if (clean.contains('첨성대')) localFile = '경주_첨성대.jpg';
    else if (clean.contains('동궁과 월지') || clean.contains('안압지')) localFile = '동궁과_월지.jpg';
    else if (clean.contains('불국사')) localFile = '경주_불국사.jpg';
    else if (clean.contains('석굴암')) localFile = '경주_석굴암_석굴.jpg';
    else if (clean.contains('대릉원')) localFile = '경주_대릉원.jpg';
    else if (clean.contains('황리단길')) localFile = '신라_역사_여행.jpg';
    else if (clean.contains('계림')) localFile = '경주_계림.jpg';
    else if (clean.contains('월성')) localFile = '경주_월성.jpg';
    else if (clean.contains('박물관')) localFile = '국립경주박물관.jpg';
    else if (clean.contains('황룡사')) localFile = '경주_황룡사지.jpg';
    else if (clean.contains('분황사')) localFile = '분황사.jpg';
    else if (clean.contains('오릉')) localFile = '경주_오릉.jpg';
    else if (clean.contains('선덕여왕릉')) localFile = '선덕여왕릉.jpg';
    else if (clean.contains('월정교')) localFile = '월정교.jpg';
    else if (clean.contains('MCY') || clean.contains('mcy')) localFile = 'MCY_파크.jpg';
    
    if (localFile != null) {
      final exists = existingFiles.contains(localFile);
      print('Spot: $title -> mapped to $localFile (Exists: $exists)');
    } else {
      print('Spot: $title -> NO LOCAL FILE MAPPED (URL: $imageUrl)');
    }
  }
}
