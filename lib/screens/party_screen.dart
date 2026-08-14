import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/party.dart';
import '../services/party_service.dart';
import '../utils/translations.dart';
import '../widgets/qr_code_display_sheet.dart';
import 'qr_scan_screen.dart';
import 'friends_screen.dart';

class PartyScreen extends StatefulWidget {
  const PartyScreen({super.key});

  @override
  State<PartyScreen> createState() => _PartyScreenState();
}

class _PartyScreenState extends State<PartyScreen> {
  final TextEditingController _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _showCreatePartyDialog(BuildContext context, AppState appState) {
    final currentLang = appState.currentLanguage;
    String selectedCourseId = 'c_royal';
    String selectedCourseTitle = AppTranslations.get(currentLang, 'c_royal_title');

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFFFDFBF7),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Color(0xFF8D6E63), width: 1.8),
              ),
              title: Row(
                children: [
                  const Icon(Icons.group_add, color: Color(0xFF1F3864), size: 26),
                  const SizedBox(width: 8),
                  Text(
                    AppTranslations.get(currentLang, 'create_party'),
                    style: const TextStyle(
                      fontFamily: 'Serif',
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F3864),
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppTranslations.get(currentLang, 'select_course_desc'),
                    style: const TextStyle(fontSize: 13, color: Color(0xFF5D4037)),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedCourseId,
                    decoration: InputDecoration(
                      labelText: AppTranslations.get(currentLang, 'select_course_label'),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: 'c_royal',
                        child: Text(
                          '${AppTranslations.get(currentLang, 'c_royal_title')} (${AppTranslations.get(currentLang, 'walk')})',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'c_buddha',
                        child: Text(
                          '${AppTranslations.get(currentLang, 'c_buddha_title')} (${AppTranslations.get(currentLang, 'transit')})',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'c_munmu',
                        child: Text(
                          '${AppTranslations.get(currentLang, 'c_munmu_title')} (${AppTranslations.get(currentLang, 'drive')})',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() {
                          selectedCourseId = val;
                          selectedCourseTitle = AppTranslations.get(currentLang, '${val}_title');
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppTranslations.get(currentLang, 'close'), style: const TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    final party = await appState.createParty(
                      courseId: selectedCourseId,
                      courseTitle: selectedCourseTitle,
                    );
                    if (!mounted) return;
                    if (party == null) {
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        SnackBar(content: Text(AppTranslations.get(currentLang, 'party_create_failed'))),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F3864),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(AppTranslations.get(currentLang, 'confirm_create')),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _submitJoinCode(String rawCode, String currentLang, AppState appState) async {
    final code = rawCode.replaceFirst('gyeongjugo:party:', '');
    final result = await appState.joinParty(code);
    if (!mounted) return;

    switch (result) {
      case JoinPartyResult.success:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppTranslations.get(currentLang, 'party_join_success')),
            backgroundColor: const Color(0xFF2E7D32),
          ),
        );
        break;
      case JoinPartyResult.alreadyJoined:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppTranslations.get(currentLang, 'party_already_joined'))),
        );
        break;
      case JoinPartyResult.notFound:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppTranslations.get(currentLang, 'party_not_found'))),
        );
        break;
      case JoinPartyResult.full:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppTranslations.get(currentLang, 'party_full'))),
        );
        break;
      case JoinPartyResult.notSignedIn:
      case JoinPartyResult.error:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppTranslations.get(currentLang, 'network_error'))),
        );
        break;
    }
  }

  void _showJoinPartyDialog(BuildContext context, AppState appState) {
    final currentLang = appState.currentLanguage;
    _codeController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFDFBF7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFF8D6E63), width: 1.8),
          ),
          title: Row(
            children: [
              const Icon(Icons.vpn_key, color: Color(0xFFD4AF37), size: 24),
              const SizedBox(width: 8),
              Text(
                AppTranslations.get(currentLang, 'join_party'),
                style: const TextStyle(
                  fontFamily: 'Serif',
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3E2723),
                  fontSize: 20,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppTranslations.get(currentLang, 'enter_invite_code_desc'),
                style: const TextStyle(fontSize: 13, color: Color(0xFF5D4037)),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _codeController,
                textCapitalization: TextCapitalization.characters,
                maxLength: 8,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                  color: Color(0xFF1F3864),
                ),
                decoration: InputDecoration(
                  hintText: 'SIL8K9A2',
                  counterText: '',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF1F3864), width: 2),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton.icon(
              icon: const Icon(Icons.qr_code_scanner, size: 18),
              label: Text(AppTranslations.get(currentLang, 'scan_qr')),
              onPressed: () async {
                Navigator.pop(context);
                final scanned = await Navigator.push<String>(
                  this.context,
                  MaterialPageRoute(
                    builder: (_) => QrScanScreen(title: AppTranslations.get(currentLang, 'scan_qr')),
                  ),
                );
                if (scanned != null) await _submitJoinCode(scanned, currentLang, appState);
              },
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppTranslations.get(currentLang, 'close'), style: const TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                final code = _codeController.text;
                Navigator.pop(context);
                if (code.trim().isNotEmpty) {
                  await _submitJoinCode(code, currentLang, appState);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(AppTranslations.get(currentLang, 'confirm_join')),
            ),
          ],
        );
      },
    );
  }

  String _statusLabel(String status, String lang) {
    switch (status) {
      case 'ready':
        return AppTranslations.get(lang, 'status_ready');
      case 'completed':
        return AppTranslations.get(lang, 'status_completed');
      default:
        return AppTranslations.get(lang, 'status_active');
    }
  }

  void _showPartyInviteQr(PartyModel party, String currentLang) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => QrCodeDisplaySheet(
        title: AppTranslations.get(currentLang, 'party_invite_qr'),
        payload: 'gyeongjugo:party:${party.inviteCode}',
        rawCode: party.inviteCode,
        currentLang: currentLang,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final activeParty = appState.activeParty;
    final currentLang = appState.currentLanguage;

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/hanji_bg.png'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black12, BlendMode.darken),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Title Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const FriendsScreen()),
                        ),
                        icon: const Icon(Icons.people_alt, color: Color(0xFF5D4037)),
                        tooltip: AppTranslations.get(currentLang, 'view_friend_list'),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.diversity_3, color: Color(0xFFD4AF37), size: 32),
                            const SizedBox(width: 10),
                            Text(
                              AppTranslations.get(currentLang, 'social'),
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Serif',
                                color: Color(0xFF3E2723),
                                shadows: [
                                  Shadow(color: Colors.white70, blurRadius: 2, offset: Offset(1, 1))
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const FriendsScreen(autoOpenAdd: true)),
                        ),
                        icon: const Icon(Icons.person_add, color: Color(0xFF1F3864)),
                        tooltip: AppTranslations.get(currentLang, 'add_friend'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _showCreatePartyDialog(context, appState),
                        icon: const Icon(Icons.add_circle, size: 18),
                        label: Text(AppTranslations.get(currentLang, 'create_party')),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1F3864),
                          foregroundColor: Colors.white,
                          elevation: 3,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _showJoinPartyDialog(context, appState),
                        icon: const Icon(Icons.vpn_key, size: 18, color: Color(0xFF5D4037)),
                        label: Text(
                          AppTranslations.get(currentLang, 'join_party'),
                          style: const TextStyle(color: Color(0xFF5D4037), fontWeight: FontWeight.bold),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF8D6E63), width: 1.5),
                          backgroundColor: const Color(0xFFFFFDF9).withValues(alpha: 0.9),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 4.0),
              child: Divider(color: Color(0xFF8D6E63), thickness: 1.5),
            ),

            Expanded(
              child: activeParty != null
                  ? _buildActivePartyLobby(context, appState, activeParty)
                  : _buildNoPartyWelcomeCard(context, appState),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivePartyLobby(BuildContext context, AppState appState, PartyModel party) {
    final currentLang = appState.currentLanguage;
    final progressPercent = party.completionRatio.clamp(0.0, 1.0);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          // 1. Party Code Card with QR Visual Badge
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1F3864), Color(0xFF2C4D75)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1F3864).withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${AppTranslations.get(currentLang, '${party.courseId}_title')} ${AppTranslations.get(currentLang, 'party_group_suffix')}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4AF37),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${party.members.length}/${party.maxMembers}${AppTranslations.get(currentLang, 'members_suffix')}',
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 8-Digit Invite Code Display
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppTranslations.get(currentLang, 'party_code'),
                            style: const TextStyle(color: Colors.white70, fontSize: 11),
                          ),
                          Text(
                            party.inviteCode,
                            style: const TextStyle(
                              color: Color(0xFFD4AF37),
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 4,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () => _showPartyInviteQr(party, currentLang),
                            icon: const Icon(Icons.qr_code, color: Colors.white),
                            tooltip: AppTranslations.get(currentLang, 'party_invite_qr'),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: party.inviteCode));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(AppTranslations.get(currentLang, 'code_copied')),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                            icon: const Icon(Icons.copy, size: 14),
                            label: Text(AppTranslations.get(currentLang, 'copy_code')),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD4AF37),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Progress Bar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppTranslations.get(currentLang, 'party_progress'),
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        Text(
                          '${(progressPercent * 100).toInt()}% ${AppTranslations.get(currentLang, 'percent_achieved')}',
                          style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: progressPercent,
                        minHeight: 8,
                        backgroundColor: Colors.white24,
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 2. Party Members Section Header
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '👥 ${AppTranslations.get(currentLang, 'party_members')}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Serif',
                color: Color(0xFF3E2723),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Members List Cards
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: party.members.length,
            itemBuilder: (context, index) {
              final member = party.members[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: member.isHost ? const Color(0xFFD4AF37) : const Color(0xFF8D6E63),
                    width: member.isHost ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFFFF3E0),
                        border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          member.characterPath,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.person, color: Color(0xFF8D6E63)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                member.nickname,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF333333),
                                ),
                              ),
                              if (member.isHost) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD4AF37),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    AppTranslations.get(currentLang, 'host_label'),
                                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${member.stampCount}${AppTranslations.get(currentLang, 'stamps_collected')} · '
                            '${_statusLabel(member.status, currentLang)}',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF666666)),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.location_on, color: Color(0xFF2E7D32), size: 20),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),

          // Bottom Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    appState.setCurrentTabIndex(1); // Switch to Map tab
                  },
                  icon: const Icon(Icons.map, size: 18),
                  label: Text(AppTranslations.get(currentLang, 'view_party_on_map')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F3864),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () => appState.leaveParty(),
                icon: const Icon(Icons.exit_to_app, color: Colors.redAccent, size: 18),
                label: Text(AppTranslations.get(currentLang, 'leave_party'), style: const TextStyle(color: Colors.redAccent)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.redAccent, width: 1.2),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildNoPartyWelcomeCard(BuildContext context, AppState appState) {
    final currentLang = appState.currentLanguage;
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF8D6E63), width: 1.8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.diversity_1, color: Color(0xFFD4AF37), size: 64),
            const SizedBox(height: 16),
            Text(
              AppTranslations.get(currentLang, 'party_welcome_title'),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'Serif',
                color: Color(0xFF1F3864),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              AppTranslations.get(currentLang, 'party_welcome_desc'),
              style: const TextStyle(fontSize: 14, color: Color(0xFF5D4037), height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showCreatePartyDialog(context, appState),
              icon: const Icon(Icons.group_add),
              label: Text(AppTranslations.get(currentLang, 'create_party_now')),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1F3864),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
