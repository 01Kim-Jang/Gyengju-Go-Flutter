import 'package:flutter/material.dart';
import '../services/tago_service.dart';
import '../utils/translations.dart';
import '../components/chatbot_sheet.dart';

class BusArrivalSheet extends StatefulWidget {
  final String spotName;
  final double lat;
  final double lng;
  final String currentLang;
  final String aiPrompt;

  const BusArrivalSheet({
    super.key,
    required this.spotName,
    required this.lat,
    required this.lng,
    required this.currentLang,
    required this.aiPrompt,
  });

  @override
  State<BusArrivalSheet> createState() => _BusArrivalSheetState();
}

class _BusArrivalSheetState extends State<BusArrivalSheet> {
  NearestStopArrivals? _result;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await TagoService.fetchNearestStopArrivals(widget.lat, widget.lng);
    if (mounted) {
      setState(() {
        _result = result;
        _loading = false;
      });
    }
  }

  void _openAiChat() {
    Navigator.pop(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ChatBotSheet(initialMessage: widget.aiPrompt),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.currentLang;
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
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
          Row(
            children: [
              const Icon(Icons.directions_bus, color: Color(0xFF1F3864), size: 26),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  AppTranslations.get(lang, 'bus_info_title'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F3864),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            widget.spotName,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          Flexible(child: SingleChildScrollView(child: _buildBody(lang))),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _openAiChat,
              icon: const Icon(Icons.smart_toy, size: 18, color: Color(0xFF1F3864)),
              label: Text(
                AppTranslations.get(lang, 'ask_ai_route'),
                style: const TextStyle(color: Color(0xFF1F3864), fontWeight: FontWeight.bold),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF1F3864), width: 1.4),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(String lang) {
    if (_loading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Column(
            children: [
              const CircularProgressIndicator(color: Color(0xFFD4AF37)),
              const SizedBox(height: 12),
              Text(
                AppTranslations.get(lang, 'bus_loading'),
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    if (_result == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 30),
        child: Center(
          child: Text(
            AppTranslations.get(lang, 'bus_no_stops'),
            style: const TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final stop = _result!.stop;
    final arrivals = _result!.arrivals;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.4)),
          ),
          child: Row(
            children: [
              const Icon(Icons.pin_drop, color: Color(0xFFD4AF37), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppTranslations.get(lang, 'bus_nearest_stop'),
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    Text(
                      '${stop.nodeName} (${stop.distanceM.round()}m)',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (arrivals.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: Text(
                AppTranslations.get(lang, 'bus_no_arrivals'),
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          ...arrivals.map((a) => _buildArrivalRow(a, lang)),
      ],
    );
  }

  Widget _buildArrivalRow(BusArrival a, String lang) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFF1F3864),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              a.routeNo,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  a.vehicleType.isNotEmpty ? a.vehicleType : '-',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  '${a.stopsAway} ${AppTranslations.get(lang, "stops_before_suffix")}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Text(
            '${a.arrivalMinutes}${AppTranslations.get(lang, "min_suffix")}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFFD4AF37)),
          ),
        ],
      ),
    );
  }
}
