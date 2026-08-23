import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/friend_profile.dart';
import '../services/friend_service.dart';
import '../utils/translations.dart';
import '../widgets/qr_code_display_sheet.dart';
import 'qr_scan_screen.dart';

class FriendsScreen extends StatefulWidget {
  final bool autoOpenAdd;

  const FriendsScreen({super.key, this.autoOpenAdd = false});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = context.read<AppState>();
      appState.loadMyProfile();
      if (widget.autoOpenAdd && mounted) {
        _showAddFriendDialog(appState.currentLanguage);
      }
    });
  }

  Future<void> _addFriendByCode(String rawScanned, String lang) async {
    final code = rawScanned.replaceFirst('gyeongjugo:friend:', '');
    final result = await FriendService.addFriendByCode(code);
    if (!mounted) return;

    String msgKey;
    switch (result) {
      case AddFriendResult.success:
        msgKey = 'friend_added_success';
        break;
      case AddFriendResult.notFound:
        msgKey = 'friend_not_found';
        break;
      case AddFriendResult.isSelf:
        msgKey = 'friend_is_self';
        break;
      case AddFriendResult.alreadyFriends:
        msgKey = 'friend_already_added';
        break;
      case AddFriendResult.notSignedIn:
      case AddFriendResult.error:
        msgKey = 'friend_code_unavailable';
        break;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppTranslations.get(lang, msgKey))),
    );
  }

  void _showAddFriendDialog(String lang) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFDFBF7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFF8D6E63), width: 1.8),
          ),
          title: Row(
            children: [
              const Icon(Icons.person_add, color: Color(0xFF1F3864), size: 24),
              const SizedBox(width: 8),
              Text(AppTranslations.get(lang, 'add_friend')),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppTranslations.get(lang, 'add_friend_desc'),
                style: const TextStyle(fontSize: 13, color: Color(0xFF5D4037)),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                textCapitalization: TextCapitalization.characters,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 4),
                decoration: InputDecoration(
                  labelText: AppTranslations.get(lang, 'enter_friend_code'),
                  counterText: '',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton.icon(
              icon: const Icon(Icons.qr_code_scanner, size: 18),
              label: Text(AppTranslations.get(lang, 'scan_qr')),
              onPressed: () async {
                Navigator.pop(dialogContext);
                final scanned = await Navigator.push<String>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => QrScanScreen(title: AppTranslations.get(lang, 'scan_qr')),
                  ),
                );
                if (scanned != null) await _addFriendByCode(scanned, lang);
              },
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                if (controller.text.trim().isNotEmpty) {
                  await _addFriendByCode(controller.text, lang);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1F3864),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(AppTranslations.get(lang, 'add_friend')),
            ),
          ],
        );
      },
    );
  }

  void _showMyQr(AppState appState, String lang) {
    final code = appState.myFriendCode;
    if (code == null || code.isEmpty) {
      // 조용히 아무 반응 없이 끝나면 "버튼이 고장남"처럼 보이므로, 원인(주로
      // 아직 Firebase/친구 서비스 연동 전이거나 프로필 로딩 중)을 알려준다.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppTranslations.get(lang, 'friend_code_unavailable'))),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => QrCodeDisplaySheet(
        title: AppTranslations.get(lang, 'my_friend_code'),
        payload: 'gyeongjugo:friend:$code',
        rawCode: code,
        currentLang: lang,
      ),
    );
  }

  void _showFriendProfile(FriendProfile friend, String lang) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFDFBF7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFF8D6E63), width: 1.8),
          ),
          title: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFFF3E0),
                  border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
                ),
                child: ClipOval(
                  child: Image.asset(
                    friend.characterPath,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => const Icon(Icons.person, color: Color(0xFF8D6E63)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  friend.nickname,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.emoji_events, color: Color(0xFFD4AF37), size: 20),
              const SizedBox(width: 8),
              Text(
                '${friend.stampCount}${AppTranslations.get(lang, "stamps_collected")}',
                style: const TextStyle(fontSize: 15),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                FriendService.removeFriend(friend.uid);
              },
              child: Text(
                AppTranslations.get(lang, 'remove_friend'),
                style: const TextStyle(color: Colors.redAccent),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(AppTranslations.get(lang, 'close'), style: const TextStyle(color: Colors.grey)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final lang = appState.currentLanguage;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppTranslations.get(lang, 'friends')),
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 10.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _showAddFriendDialog(lang),
                        icon: const Icon(Icons.person_add, size: 18),
                        label: Text(AppTranslations.get(lang, 'add_friend')),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1F3864),
                          foregroundColor: Colors.white,
                          elevation: 3,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _showMyQr(appState, lang),
                        icon: const Icon(Icons.qr_code, size: 18, color: Color(0xFF5D4037)),
                        label: Text(
                          AppTranslations.get(lang, 'show_my_qr'),
                          style: const TextStyle(color: Color(0xFF5D4037), fontWeight: FontWeight.bold),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF8D6E63), width: 1.5),
                          backgroundColor: const Color(0xFFFFFDF9),
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
              child: StreamBuilder<List<FriendProfile>>(
                stream: FriendService.watchFriends(),
                builder: (context, snapshot) {
                  // Firebase가 아직 설정 안 됐거나(watchFriends()가 빈 스트림을 반환)
                  // 로그인이 안 된 경우, 스트림이 데이터 없이 곧바로 완료되어
                  // snapshot.hasData가 영원히 false로 남는다. connectionState까지
                  // 같이 봐서, 진짜로 "아직 기다리는 중"일 때만 로딩을 보여준다.
                  final stillWaiting = snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData;
                  if (stillWaiting) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)));
                  }
                  final friends = snapshot.data ?? [];
                  if (friends.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(30),
                        child: Text(
                          AppTranslations.get(lang, 'friend_list_empty'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    itemCount: friends.length,
                    itemBuilder: (context, index) {
                      final friend = friends[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFF8D6E63), width: 1),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () => _showFriendProfile(friend, lang),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
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
                                      friend.characterPath,
                                      fit: BoxFit.cover,
                                      errorBuilder: (c, e, s) =>
                                          const Icon(Icons.person, color: Color(0xFF8D6E63)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        friend.nickname,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF333333),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${friend.stampCount}${AppTranslations.get(lang, "stamps_collected")}',
                                        style: const TextStyle(fontSize: 12, color: Color(0xFF666666)),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right, color: Color(0xFF8D6E63)),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
