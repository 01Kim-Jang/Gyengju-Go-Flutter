import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/app_state.dart';
import '../services/kakao_local_service.dart';
import '../utils/translations.dart';

// 외국인 관광객을 위한 긴급/안전 정보 화면.
// 112/119/1330 즉시 전화 연결, 현재 위치 기준 근처 약국·병원 검색,
// 대사관 안내(1330 연결 + 외교부 홈페이지 링크)를 제공한다.
class SafetyInfoScreen extends StatefulWidget {
  const SafetyInfoScreen({super.key});

  @override
  State<SafetyInfoScreen> createState() => _SafetyInfoScreenState();
}

class _SafetyInfoScreenState extends State<SafetyInfoScreen> {
  bool _loadingPharmacy = false;
  bool _loadingHospital = false;
  List<Map<String, dynamic>>? _pharmacies;
  List<Map<String, dynamic>>? _hospitals;

  Future<void> _call(String number) async {
    final uri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openMofaSite() async {
    final uri = Uri.parse('https://www.mofa.go.kr/');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _searchPharmacy(AppState appState) async {
    if (appState.userLat == null || appState.userLng == null) return;
    setState(() => _loadingPharmacy = true);
    final results = await KakaoLocalService.fetchNearbyPharmacies(appState.userLat!, appState.userLng!);
    if (mounted) {
      setState(() {
        _pharmacies = results;
        _loadingPharmacy = false;
      });
    }
  }

  Future<void> _searchHospital(AppState appState) async {
    if (appState.userLat == null || appState.userLng == null) return;
    setState(() => _loadingHospital = true);
    final results = await KakaoLocalService.fetchNearbyHospitals(appState.userLat!, appState.userLng!);
    if (mounted) {
      setState(() {
        _hospitals = results;
        _loadingHospital = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final lang = appState.currentLanguage;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppTranslations.get(lang, 'safety_info')),
        backgroundColor: const Color(0xFFFDFBF7),
        foregroundColor: const Color(0xFF3E2723),
        elevation: 1,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/hanji_bg.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black12, BlendMode.darken),
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                AppTranslations.get(lang, 'safety_info_desc'),
                style: const TextStyle(fontSize: 13, color: Color(0xFF5D4037)),
              ),
              const SizedBox(height: 20),
              _sectionTitle(AppTranslations.get(lang, 'emergency_numbers')),
              const SizedBox(height: 10),
              _emergencyTile(
                icon: Icons.local_police,
                color: const Color(0xFF1F3864),
                title: AppTranslations.get(lang, 'police'),
                number: '112',
                lang: lang,
              ),
              _emergencyTile(
                icon: Icons.local_fire_department,
                color: Colors.redAccent,
                title: AppTranslations.get(lang, 'fire_ambulance'),
                number: '119',
                lang: lang,
              ),
              _emergencyTile(
                icon: Icons.support_agent,
                color: const Color(0xFFD4AF37),
                title: AppTranslations.get(lang, 'tourist_hotline'),
                subtitle: AppTranslations.get(lang, 'tourist_hotline_desc'),
                number: '1330',
                lang: lang,
              ),
              const SizedBox(height: 24),
              _sectionTitle('💊 ${AppTranslations.get(lang, 'nearby_pharmacy')}'),
              const SizedBox(height: 10),
              _nearbySearchCard(
                loading: _loadingPharmacy,
                results: _pharmacies,
                onSearch: () => _searchPharmacy(appState),
                lang: lang,
              ),
              const SizedBox(height: 24),
              _sectionTitle('🏥 ${AppTranslations.get(lang, 'nearby_hospital')}'),
              const SizedBox(height: 10),
              _nearbySearchCard(
                loading: _loadingHospital,
                results: _hospitals,
                onSearch: () => _searchHospital(appState),
                lang: lang,
              ),
              const SizedBox(height: 24),
              _sectionTitle(AppTranslations.get(lang, 'embassy_info')),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF8D6E63), width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppTranslations.get(lang, 'embassy_info_desc'),
                      style: const TextStyle(fontSize: 13, color: Color(0xFF5D4037), height: 1.5),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _openMofaSite,
                      icon: const Icon(Icons.open_in_new, size: 16),
                      label: const Text('mofa.go.kr'),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF8D6E63)),
                        foregroundColor: const Color(0xFF3E2723),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.bold,
        fontFamily: 'Serif',
        color: Color(0xFF3E2723),
      ),
    );
  }

  Widget _emergencyTile({
    required IconData icon,
    required Color color,
    required String title,
    String? subtitle,
    required String number,
    required String lang,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Text(number, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
                  ],
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 3),
                  Text(subtitle, style: const TextStyle(fontSize: 11.5, color: Colors.grey)),
                ],
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => _call(number),
            icon: const Icon(Icons.call, size: 16),
            label: Text(AppTranslations.get(lang, 'call_now'), style: const TextStyle(fontSize: 12)),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _nearbySearchCard({
    required bool loading,
    required List<Map<String, dynamic>>? results,
    required VoidCallback onSearch,
    required String lang,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF8D6E63), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: loading ? null : onSearch,
              icon: const Icon(Icons.my_location, size: 16),
              label: Text(AppTranslations.get(lang, 'find_nearby')),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF1F3864)),
                foregroundColor: const Color(0xFF1F3864),
              ),
            ),
          ),
          if (loading) ...[
            const SizedBox(height: 14),
            Center(
              child: Column(
                children: [
                  const CircularProgressIndicator(color: Color(0xFFD4AF37)),
                  const SizedBox(height: 8),
                  Text(AppTranslations.get(lang, 'searching_nearby'), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
          ] else if (results != null) ...[
            const SizedBox(height: 10),
            if (results.isEmpty)
              Text(AppTranslations.get(lang, 'no_results_nearby'), style: const TextStyle(fontSize: 12, color: Colors.grey))
            else
              ...results.take(5).map((place) {
                final name = place['place_name']?.toString() ?? '';
                final address = place['road_address_name']?.toString().isNotEmpty == true
                    ? place['road_address_name'].toString()
                    : place['address_name']?.toString() ?? '';
                final phone = place['phone']?.toString() ?? '';
                final distance = place['distance']?.toString();
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                            Text(
                              distance != null ? '$address · ${distance}m' : address,
                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      if (phone.isNotEmpty)
                        IconButton(
                          onPressed: () => _call(phone),
                          icon: const Icon(Icons.call, size: 18, color: Color(0xFF1F3864)),
                        ),
                    ],
                  ),
                );
              }),
          ],
        ],
      ),
    );
  }
}
