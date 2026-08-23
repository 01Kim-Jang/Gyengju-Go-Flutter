class SpotDetail {
  final Map<String, String> names;
  final Map<String, String> facts;
  final Map<String, String> tips;
  final String imagePath;
  final String stampImage;

  const SpotDetail({
    required this.names,
    required this.facts,
    required this.tips,
    required this.imagePath,
    required this.stampImage,
  });

  String getName(String lang) => names[lang] ?? names['ko'] ?? '';
  String getFact(String lang) => facts[lang] ?? facts['ko'] ?? '';
  String getTip(String lang) => tips[lang] ?? tips['ko'] ?? '';
}

class SpotsDB {
  static const Map<String, SpotDetail> db = {
    '첨성대': SpotDetail(
      names: {
        'ko': '첨성대',
        'en': 'Cheomseongdae',
        'ja': '瞻星台',
        'zh-chs': '瞻星台',
        'vi': 'Cheomseongdae',
        'th': 'ช็อมซ็องแด',
      },
      facts: {
        'ko': '동양에서 가장 오래된 천문 관측대로, 신라 선덕여왕 때 지어졌습니다. 365개의 돌(음력 1년)로 이루어져 있으며, 신라의 고도화된 건축 기술과 천문학적 지혜를 엿볼 수 있습니다.',
        'en': 'The oldest surviving astronomical observatory in East Asia, built during the reign of Queen Seondeok of Silla. Made of 365 stones (representing the days in a lunar year), it showcases Silla\'s advanced architectural technology and astronomical wisdom.',
        'ja': '東洋最古の天文観測台で、新羅の善徳女王의 時代에 建てられました。365個の石（太陰暦の1年）で構成されており、新羅の高度な建築技術と天文学的な知恵を垣間見ることができます。',
        'zh-chs': '这是东亚现存最古老的天文台，建于新罗善德女王时期。它由365块石头（代表阴历的一年）筑成，展示了新罗先进的建筑技术和天文学智慧。',
        'vi': 'Đài quan sát thiên văn cổ nhất còn tồn tại ở Đông Á, được xây dựng dưới thời trị vì của Nữ hoàng Seondeok của Silla. Được tạo thành từ 365 viên đá (tượng trưng cho số ngày trong một năm âm lịch), đài thể hiện kỹ thuật kiến trúc tiên tiến và trí tuệ thiên văn của Silla.',
        'th': 'หอดูดาวโบราณที่เก่าแก่ที่สุดในเอเชียตะวันออกที่ยังหลงเหลืออยู่ สร้างขึ้นในรัชสมัยของพระนางซอนด็อกแห่งอาณาจักรชิลลา ประกอบด้วยหิน 365 ก้อน (แทนจำนวนวันในหนึ่งปีตามจันทรคติ) สะท้อนให้เห็นถึงเทคโนโลยีสถาปัตยกรรมขั้นสูงและภูมิปัญญาด้านดาราศาสตร์ของชิลลา',
      },
      tips: {
        'ko': '일몰 후에 은은한 야간 조명이 켜질 때 방문하시는 것을 강력히 추천합니다. 주변의 넓은 핑크뮬리 정원과 꽃밭도 훌륭한 포토존입니다.',
        'en': 'Highly recommend visiting after sunset when the soft night lights turn on. The surrounding pink muhly garden and flower fields are also great photo spots.',
        'ja': '日没後にほのかな夜間照明が点灯する時間帯の訪問を強くお勧めします。周辺の広いピンクミューリー庭園や花畑도 素晴らしいフォトスポットです。',
        'zh-chs': '强烈建议在日落后柔和的夜灯亮起时前往。周围大片的粉黛乱子草花园和花田也是极佳的拍照打卡地。',
        'vi': 'Rất nên ghé thăm sau khi mặt trời lặn, khi ánh đèn đêm dịu nhẹ được thắp lên. Khu vườn cỏ đuôi chồn hồng và cánh đồng hoa xung quanh cũng là những điểm chụp ảnh tuyệt vời.',
        'th': 'แนะนำให้มาเยือนหลังพระอาทิตย์ตกดินเมื่อไฟส่องสว่างยามค่ำคืนอันนุ่มนวลถูกเปิดขึ้น สวนหญ้าสีชมพูและทุ่งดอกไม้โดยรอบก็เป็นจุดถ่ายรูปที่ยอดเยี่ยมเช่นกัน',
      },
      imagePath: 'assets/images/spots/경주_첨성대.jpg',
      stampImage: 'assets/images/spots/경주_첨성대.jpg',
    ),
    '동궁과 월지': SpotDetail(
      names: {
        'ko': '동궁과 월지',
        'en': 'Donggung Palace & Wolji Pond',
        'ja': '東宮と月池',
        'zh-chs': '东宫与月池',
        'vi': 'Cung điện Donggung & Ao Wolji',
        'th': 'พระราชวังทงกุงและสระทงกุง',
      },
      facts: {
        'ko': '신라 왕궁의 별궁 터로, 나라의 경사가 있을 때나 귀빈을 맞이할 때 연회를 베풀던 곳입니다. 인공 호수인 월지(안압지)와 어우러진 정원 배치는 통일신라 조경 예술의 극치를 보여줍니다.',
        'en': 'The site of a palace annex of the Silla Kingdom, used for banquets on national occasions and for welcoming important guests. The garden layout harmonizing with the artificial lake Wolji (Anapji) shows the pinnacle of Unified Silla landscape art.',
        'ja': '新羅王宮の別宮跡で、国の慶事や貴賓を迎える際に宴会を開いた場所です。人工池である月池（雁鴨池）と調和した庭園の配置は、統一新羅の造園芸術の極致を示しています。',
        'zh-chs': '这是新罗王宫的别宫遗址，曾用于举行国家庆典和接待贵宾。与人工湖月池（雁鸭池）融为一体的园林布局，展现了统一新罗时期园林艺术的极致。',
        'vi': 'Di tích của biệt cung thuộc vương triều Silla, từng được dùng để tổ chức yến tiệc vào các dịp trọng đại của đất nước và tiếp đón quý khách. Bố cục khu vườn hòa quyện với hồ nhân tạo Wolji (Anapji) thể hiện đỉnh cao nghệ thuật cảnh quan của thời kỳ Silla Thống nhất.',
        'th': 'ที่ตั้งของพระราชวังฝ่ายในของอาณาจักรชิลลา เคยใช้จัดงานเลี้ยงในโอกาสสำคัญของประเทศและต้อนรับแขกผู้มีเกียรติ การจัดวางสวนที่กลมกลืนกับสระน้ำเทียมวอลจี (อันอับจี) แสดงให้เห็นถึงจุดสูงสุดของศิลปะภูมิทัศน์ในยุคชิลลารวมชาติ',
      },
      tips: {
        'ko': '경주 최고의 야경 명소입니다. 매표소 대기 줄이 길 수 있으니 모바일 예매를 이용하거나 일몰 30분 전에 여유 있게 방문하세요.',
        'en': 'The absolute best night view spot in Gyeongju. The ticket line can be very long, so use mobile booking or arrive 30 minutes before sunset.',
        'ja': '慶州最高の夜景名所です。チケット売り場の列が長くなることがあるため、モバイル予約を利用するか、日没の30分前に余裕を持って訪問してください。',
        'zh-chs': '庆州公认最美的夜景名所。售票处可能会排长队，建议使用手机预订，或在日落前30分钟提前到达。',
        'vi': 'Điểm ngắm cảnh đêm đẹp nhất tuyệt đối tại Gyeongju. Hàng chờ mua vé có thể rất dài, vì vậy hãy đặt vé qua ứng dụng di động hoặc đến trước khi mặt trời lặn 30 phút.',
        'th': 'จุดชมวิวยามค่ำคืนที่สวยที่สุดในคยองจู แถวซื้อตั๋วอาจยาวมาก จึงควรจองผ่านมือถือล่วงหน้าหรือมาถึงก่อนพระอาทิตย์ตก 30 นาที',
      },
      imagePath: 'assets/images/spots/동궁과_월지.jpg',
      stampImage: 'assets/images/spots/동궁과_월지.jpg',
    ),
    '불국사': SpotDetail(
      names: {
        'ko': '불국사',
        'en': 'Bulguksa Temple',
        'ja': '仏国寺',
        'zh-chs': '佛国寺',
        'vi': 'Chùa Bulguksa',
        'th': 'วัดบุลกุกซา',
      },
      facts: {
        'ko': '유네스코 세계문화유산으로 지정된 사찰로, 신라 경덕왕 때 김대성이 현생의 부모를 위해 창건했습니다. 다보탑과 석가탑, 청운교와 백운교 등 불교 교리와 신라 예술이 조화를 이룬 걸작들로 가득합니다.',
        'en': 'A UNESCO World Heritage temple, founded by Kim Dae-seong during the reign of King Gyeongdeok of Silla for his parents in his present life. It is filled with masterpieces where Buddhist teachings and Silla art harmonize, including Dabotap, Seokgatap, Cheongungyo, and Baegungyo bridges.',
        'ja': 'ユネスコ世界文化遺産に登録された寺院で、新羅の景徳王の時代に金大城が現世の父母のために創建しました。多宝塔や釈迦塔、青雲橋・白雲橋など、仏教の教理と新羅芸術が調和した傑作に満ちています。',
        'zh-chs': '这是一座被列为联合国教科文组织世界文化遗产的寺庙，由新罗景德王时期的金大城为现世父母所建。庙内充满佛教教义与新罗艺术和谐融合的杰作，如多宝塔、释迦塔以及青云桥和白云桥。',
        'vi': 'Ngôi chùa được UNESCO công nhận là Di sản Văn hóa Thế giới, do Kim Dae-seong sáng lập dưới thời vua Gyeongdeok của Silla để tưởng nhớ cha mẹ ở kiếp này. Chùa chứa đầy những kiệt tác nơi giáo lý Phật giáo và nghệ thuật Silla hòa quyện, bao gồm tháp Dabotap, tháp Seokgatap và các cầu thang Cheongungyo, Baegungyo.',
        'th': 'วัดมรดกโลกที่ได้รับการขึ้นทะเบียนจากยูเนสโก ก่อตั้งโดยคิมแดซองในรัชสมัยพระเจ้ากย็องด็อกแห่งชิลลา เพื่ออุทิศแด่บิดามารดาในชาตินี้ เต็มไปด้วยผลงานชิ้นเอกที่หลักธรรมทางพุทธศาสนาและศิลปะชิลลาผสานกันอย่างลงตัว ทั้งเจดีย์ดาโบทัพ เจดีย์ซ็อกกาทัพ และสะพานช็องอุนกโย-แบกอุนกโย',
      },
      tips: {
        'ko': '오전 9시 이전에 방문하면 붐비지 않고 고즈넉한 사찰의 분위기를 온전히 느낄 수 있습니다. 대웅전 뒤편의 극락전 복돼지 동상도 꼭 찾아 만져보세요.',
        'en': 'Visit before 9:00 AM to enjoy the quiet, serene temple atmosphere without crowds. Make sure to find and touch the Golden Pig statue at Geuk락jeon behind Daeungjeon.',
        'ja': '午前9時前に訪問すると混雑を避け、静かな寺院の雰囲気を十分に感じることができます。大雄殿の裏手にある極楽殿の「福豚の像」もぜひ探して触ってみてください。',
        'zh-chs': '建议在上午9点前前往，可以避开人群，尽情感受寺庙的幽静与庄严。别忘了去大雄殿后方的极乐殿寻找并摸一摸“福猪像”，以求好运。',
        'vi': 'Hãy đến trước 9 giờ sáng để tận hưởng không khí thanh tịnh, yên bình của ngôi chùa mà không đông đúc. Đừng quên tìm và chạm vào tượng Heo Vàng tại Geungnakjeon phía sau Daeungjeon.',
        'th': 'แนะนำให้มาก่อน 9 โมงเช้าเพื่อสัมผัสบรรยากาศอันเงียบสงบของวัดโดยไม่มีฝูงชน อย่าลืมตามหาและสัมผัสรูปปั้นหมูทองคำที่กึกนักช็อนด้านหลังแดอุงจ็อน',
      },
      imagePath: 'assets/images/spots/경주_불국사.jpg',
      stampImage: 'assets/images/spots/경주_불국사.jpg',
    ),
    '석굴암': SpotDetail(
      names: {
        'ko': '석굴암',
        'en': 'Seokguram Grotto',
        'ja': '石窟庵',
        'zh-chs': '石窟庵',
        'vi': 'Động Seokguram',
        'th': 'ซ็อกกูรัม',
      },
      facts: {
        'ko': '통일신라 시대에 화강암을 다듬어 인공으로 축조한 석굴 사찰입니다. 굴 중앙에 안치된 본존불은 정교한 비례와 온화한 미소로 동양 불교 미술의 최고 정수로 손꼽힙니다.',
        'en': 'An artificial grotto temple built from carved granite during the Unified Silla period. The main Bonjonbul statue seated in the center is counted as the supreme masterpiece of East Asian Buddhist art with its exquisite proportions and gentle smile.',
        'ja': '統一新羅時代に花崗岩を加工して人工的に築造した石窟寺院です。窟の中央に安置された本尊仏は、精巧な比例と穏やかな微笑みで、東洋仏教美術の最高峰とされています。',
        'zh-chs': '这是一座在统一新罗时期用花岗岩雕刻人工砌筑的石窟寺庙。安放在石窟中央的本尊佛，以其精妙的比例和温和的微笑，被誉为东亚佛教艺术的巅峰之作。',
        'vi': 'Một ngôi chùa hang nhân tạo được xây dựng từ đá granite chạm khắc vào thời Silla Thống nhất. Tượng Phật chính đặt ở trung tâm được xem là kiệt tác tối cao của nghệ thuật Phật giáo Đông Á nhờ tỷ lệ tinh xảo và nụ cười hiền hòa.',
        'th': 'วัดถ้ำที่สร้างขึ้นจากหินแกรนิตแกะสลักในยุคชิลลารวมชาติ พระพุทธรูปประธานที่ประดิษฐานอยู่กลางถ้ำได้รับการยกย่องว่าเป็นผลงานชิ้นเอกสูงสุดของศิลปะพุทธศาสนาในเอเชียตะวันออก ด้วยสัดส่วนที่ประณีตและรอยยิ้มอันอ่อนโยน',
      },
      tips: {
        'ko': '불국사에서 석굴암까지 이어지는 등산로나 셔틀버스를 이용해 편리하게 이동할 수 있습니다. 석굴 내부 보호유리 너머로 본존불을 관람하게 됩니다.',
        'en': 'You can easily move from Bulguksa to Seokguram using the hiking trail or shuttle bus. The main Buddha is viewed through a protective glass wall inside the grotto.',
        'ja': '仏国寺から石窟庵へと続く登山道やシャトルバスを利用して便利に移動できます。石窟の内部は、保護ガラス越しに本尊仏を観覧することになります。',
        'zh-chs': '您可以利用从佛国寺通往石窟庵的登山步道或穿梭巴士便利地前往。您将在石窟内通过保护玻璃观看本尊佛像。',
        'vi': 'Bạn có thể di chuyển dễ dàng từ Bulguksa đến Seokguram bằng đường mòn leo núi hoặc xe buýt đưa đón. Tượng Phật chính được chiêm ngưỡng qua lớp kính bảo vệ bên trong hang.',
        'th': 'สามารถเดินทางจากวัดบุลกุกซาไปยังซ็อกกูรัมได้สะดวกด้วยเส้นทางเดินป่าหรือรถรับส่ง จะได้ชมพระพุทธรูปประธานผ่านกระจกป้องกันภายในถ้ำ',
      },
      imagePath: 'assets/images/spots/경주_석굴암_석굴.jpg',
      stampImage: 'assets/images/spots/경주_석굴암_석굴.jpg',
    ),
    '대릉원': SpotDetail(
      names: {
        'ko': '대릉원',
        'en': 'Daereungwon Tomb Complex',
        'ja': '大陵苑',
        'zh-chs': '大陵苑',
        'vi': 'Khu lăng mộ Daereungwon',
        'th': 'สุสานแดลึงวอน',
      },
      facts: {
        'ko': '신라 시대의 왕과 귀족들의 거대한 고분들이 모여 있는 고분공원입니다. 유일하게 내부가 공개된 천마총을 비롯해 미추왕릉, 황남대총 등이 고즈넉한 능선을 그리고 있습니다.',
        'en': 'A tumuli park gathering huge ancient tombs of Silla kings and aristocrats. The scenic ridges are formed by Hwangnamdaechong, the Tomb of King Michu, and Cheonmachong, which is the only tomb with its interior open to the public.',
        'ja': '新羅時代の王や貴族의 巨大な古墳が集まっている古墳公園です。唯一内部が公開されている天馬塚をはじめ、味鄒王陵、皇南大塚などが静かな陵線を描いています。',
        'zh-chs': '这是一座汇集了新罗时期国王和贵族巨大古墓的古墓公园。其中包括唯一内部向公众开放的天马冢，以及味邹王陵、皇南大冢等，勾勒出幽静的陵线。',
        'vi': 'Công viên lăng mộ tập hợp những ngôi mộ cổ khổng lồ của các vị vua và quý tộc Silla. Những đường nét đồi mộ thơ mộng được tạo nên bởi Hwangnamdaechong, Lăng vua Michu và Cheonmachong — ngôi mộ duy nhất mở cửa cho khách tham quan bên trong.',
        'th': 'สวนสุสานโบราณที่รวบรวมหลุมฝังศพขนาดใหญ่ของกษัตริย์และขุนนางแห่งชิลลา สันเนินสุสานอันงดงามเกิดจากฮวังนัมแดชง สุสานพระเจ้ามีชู และช็อนมาชง ซึ่งเป็นสุสานเพียงแห่งเดียวที่เปิดให้ชมภายใน',
      },
      tips: {
        'ko': '두 개의 봉우리가 맞닿은 황남대총 뒷길은 인스타그램에서 가장 핫한 포토존입니다. 천마총 내부에 전시된 화려한 금관 복제품을 꼭 관람해 보세요.',
        'en': 'The path behind Hwangnamdaechong, where two peaks meet, is the most popular Instagram photo spot. Be sure to check out the gorgeous replica of the golden crown inside Cheonmachong.',
        'ja': '2つの峰が隣り合う皇南大塚の裏道は、インスタグラムで大人気のフォトスポットです。天馬塚の内部に展示されている華やかな金冠のレプリカもぜひ観覧してください。',
        'zh-chs': '两座山峰相连的皇南大冢后路是社交媒体上最热门的拍照点。一定要去天马冢内部看看展出的华丽金冠复制品。',
        'vi': 'Con đường phía sau Hwangnamdaechong, nơi hai đỉnh mộ gặp nhau, là điểm chụp ảnh Instagram nổi tiếng nhất. Đừng quên chiêm ngưỡng bản sao vương miện vàng lộng lẫy được trưng bày bên trong Cheonmachong.',
        'th': 'ทางเดินด้านหลังฮวังนัมแดชงที่ยอดเนินสองลูกมาบรรจบกัน เป็นจุดถ่ายรูปยอดฮิตที่สุดในอินสตาแกรม อย่าลืมชมมงกุฎทองคำจำลองอันวิจิตรที่จัดแสดงภายในช็อนมาชง',
      },
      imagePath: 'assets/images/spots/경주_대릉원.jpg',
      stampImage: 'assets/images/spots/경주_대릉원.jpg',
    ),
    '황리단길': SpotDetail(
      names: {
        'ko': '황리단길',
        'en': 'Hwangridan-gil',
        'ja': '皇理団通り',
        'zh-chs': '皇理团路',
        'vi': 'Đường Hwangridan-gil',
        'th': 'ถนนฮวังรีดันกิล',
      },
      facts: {
        'ko': '황남동 일대의 전통 한옥들을 개조하여 트렌디한 카페, 레스토랑, 독립서점, 사진관 등이 들어선 경주의 대표 문화 거리입니다. 과거와 현대의 매력이 공존하는 핫플레이스입니다.',
        'en': 'Gyeongju\'s representative cultural street where traditional Hanok houses in Hwangnam-dong have been renovated into trendy cafes, restaurants, independent bookstores, and photo studios. It is a hot place where past and present charm coexist.',
        'ja': '皇南洞一帯の伝統的な韓屋（ハノク）を改装し、トレンディなカフェ、レストラン、独立書店、写真館などが立ち並ぶ慶州を代表する文化通りです。過去と現代の魅力が共存するホットプレイスです。',
        'zh-chs': '这是庆州代表性的文化街区，将皇南洞一带的传统韩屋改造成了时尚的咖啡馆、餐厅、独立书店和照相馆。这是一个过去与现代魅力共存的网红打卡地。',
        'vi': 'Con phố văn hóa tiêu biểu của Gyeongju, nơi những ngôi nhà Hanok truyền thống ở Hwangnam-dong được cải tạo thành các quán cà phê, nhà hàng, hiệu sách độc lập và tiệm chụp ảnh thời thượng. Đây là điểm đến hot nơi vẻ đẹp quá khứ và hiện tại cùng tồn tại.',
        'th': 'ถนนวัฒนธรรมสำคัญของคยองจู ที่บ้านฮันอกแบบดั้งเดิมในย่านฮวังนัมดงถูกปรับปรุงเป็นคาเฟ่ ร้านอาหาร ร้านหนังสืออิสระ และสตูดิโอถ่ายภาพสุดทันสมัย เป็นแหล่งฮิตที่อดีตและปัจจุบันอยู่ร่วมกันอย่างมีเสน่ห์',
      },
      tips: {
        'ko': '골목길이 좁고 유동인구가 많아 도보 여행에 최적화되어 있습니다. 황남쫀드기, 십원빵 등 길거리 간식을 먹어보는 재미가 쏠쏠합니다.',
        'en': 'The alleys are narrow and crowded, making it perfect for walking tours. Enjoy trying local street snacks like Hwangnam Jjondigi (chewy snack) and 10-Won Bread.',
        'ja': '路地が狭く人通りが多いため、徒歩旅行に最適です。「ファンナムチョンディギ」や「10ウォンパン」などのストリートフードを食べる楽しみも格別です。',
        'zh-chs': '胡同狭窄且人流量大，非常适合徒步旅游。品尝皇南拉丝条、十元饼等街头小吃是一大乐趣。',
        'vi': 'Những con hẻm nhỏ và đông đúc rất phù hợp để dạo bộ. Hãy thử các món ăn vặt đường phố như Hwangnam Jjondegi (kẹo dẻo) và bánh mì 10 Won.',
        'th': 'ตรอกซอกซอยแคบและมีผู้คนพลุกพล่าน เหมาะแก่การเดินเที่ยวชม ลองชิมของว่างข้างทาง เช่น ฮวังนัมจนแดกี (ขนมเหนียว) และขนมปังสิบวอนดูสิ',
      },
      imagePath: 'assets/images/spots/신라_역사_여행.jpg',
      stampImage: 'assets/images/spots/신라_역사_여행.jpg',
    ),
    '문무대왕릉': SpotDetail(
      names: {
        'ko': '문무대왕릉',
        'en': 'Tomb of King Munmu',
        'ja': '文武大王陵',
        'zh-chs': '文武大王陵',
        'vi': 'Lăng mộ Vua Munmu',
        'th': 'สุสานพระเจ้ามุนมู',
      },
      facts: {
        'ko': '삼국통일을 완수한 신라 제30대 문무왕의 수중릉입니다. "내가 죽으면 동해의 용이 되어 나라를 지키겠다"는 유언에 따라 바다 바위 속에 장사 지낸 세계 유일의 수중 왕릉입니다.',
        'en': 'The underwater tomb of King Munmu, the 30th monarch of Silla who completed the unification of the Three Kingdoms. Per his will to become a dragon of the East Sea to protect the nation, he was buried under this marine rock.',
        'ja': '三国統一を成し遂げた新羅第30代・文武王の水中陵です。「自分が死んだら東海の竜となり国を守る」という遺言に従い、海の中の岩の下に葬られた、世界唯一の水中王陵です.',
        'zh-chs': '这是完成了三国统一大业的新罗第30代国王文武王的水中陵墓。遵照他“死后化作东海神龙以报效国家”的遗言，将其安葬在海中礁石下，是世界上唯一的水中王陵。',
        'vi': 'Lăng mộ dưới nước của vua Munmu, vị quân chủ thứ 30 của Silla, người đã hoàn thành thống nhất Tam Quốc. Theo di nguyện muốn hóa thành rồng biển Đông để bảo vệ đất nước, ông được an táng dưới tảng đá giữa biển này.',
        'th': 'สุสานใต้น้ำของพระเจ้ามุนมู กษัตริย์องค์ที่ 30 แห่งชิลลาผู้ทรงรวมสามอาณาจักรเป็นหนึ่งเดียว ตามพระราชประสงค์ที่จะกลายเป็นมังกรแห่งทะเลตะวันออกเพื่อปกป้องประเทศ พระองค์จึงถูกฝังไว้ใต้แนวหินกลางทะเลแห่งนี้',
      },
      tips: {
        'ko': '봉길대보 해수욕장 백사장에서 바라볼 수 있습니다. 갈매기 떼와 푸른 바다 바위가 어우러진 해돋이 풍경은 출사 장소로도 매우 유명합니다.',
        'en': 'It can be viewed from the white sands of Bonggil Daebo Beach. The sunrise landscape harmony of seagulls and blue sea rocks is very famous for photography.',
        'ja': '奉吉大宝海水浴場の白い砂浜から望むことができます。カモメの群れと青い海の岩が調和した日の出の風景は、写真撮影のスポットとしても非常に有名です。',
        'zh-chs': '从奉吉大宝海水浴场的白沙滩上可以望见。海鸥群飞与蓝色海中礁石相映成趣的日出景观，是非常著名的摄影打卡地。',
        'vi': 'Có thể ngắm nhìn từ bãi cát trắng của bãi biển Bonggil Daebo. Khung cảnh bình minh hòa quyện giữa đàn hải âu và đá biển xanh rất nổi tiếng để chụp ảnh.',
        'th': 'สามารถชมได้จากหาดทรายขาวของชายหาดบงกิลแดโบ ทิวทัศน์พระอาทิตย์ขึ้นที่ฝูงนกนางนวลและโขดหินสีครามผสานกันอย่างลงตัว มีชื่อเสียงมากในหมู่ช่างภาพ',
      },
      imagePath: 'https://www.gyeongju.go.kr/upload/content/thumb/20200527/159056024317800.jpg',
      stampImage: 'https://www.gyeongju.go.kr/upload/content/thumb/20200527/159056024317800.jpg',
    ),
    '괘릉': SpotDetail(
      names: {
        'ko': '괘릉 (원성왕릉)',
        'en': 'Gwaereung (Tomb of King Wonseong)',
        'ja': '掛陵 (元聖王陵)',
        'zh-chs': '挂陵 (元圣王陵)',
        'vi': 'Gwaereung (Lăng vua Wonseong)',
        'th': 'แควรึง (สุสานพระเจ้าวอนซ็อง)',
      },
      facts: {
        'ko': '신라 제38대 원성왕의 능으로 추정되는 왕릉입니다. 네 모퉁이의 무인석(서역인 모습의 십이지신상)과 정교한 돌사자상이 서역과의 활발한 교류를 증명하는 대표적 유적입니다.',
        'en': 'Estimated to be the tomb of King Wonseong, the 38th monarch of Silla. The military officer statues depicting Western Asian features and exquisite stone lions prove active trade with Western regions.',
        'ja': '新羅第38代・元聖王の陵と推定される王陵です。四隅の武人像（西域人の姿）と精巧な石獅子像が、西域との活発な交流を証明しています。',
        'zh-chs': '推测为新罗第38代元圣王之陵。四角雕刻有西域人形象的文武官像与精美石狮，是与西域频繁交流的代表性遗迹。',
        'vi': 'Lăng mộ được cho là của vua Wonseong, vị quân chủ thứ 38 của Silla. Các bức tượng võ quan mang nét mặt người Tây Á ở bốn góc cùng những tượng sư tử đá tinh xảo là bằng chứng tiêu biểu cho giao lưu sôi động với vùng Tây Á.',
        'th': 'สุสานที่สันนิษฐานว่าเป็นของพระเจ้าวอนซ็อง กษัตริย์องค์ที่ 38 แห่งชิลลา รูปปั้นทหารสี่มุมที่มีลักษณะแบบชาวเอเชียตะวันตกและรูปปั้นสิงโตหินอันประณีต เป็นหลักฐานสำคัญของการแลกเปลี่ยนวัฒนธรรมอันคึกคักกับดินแดนตะวันตก',
      },
      tips: {
        'ko': '왕릉 입구에 늘어선 쾌활한 미소의 돌사자상과 서역인 이국적 무인석을 배경으로 멋진 사진을 남겨보세요.',
        'en': 'Take photos with the smiling stone lions and exotic Western warrior statues lining the entrance of the royal tomb.',
        'ja': '王陵の入り口に並ぶ微笑む石獅子像や西域人の武人像を背景に、素晴らしい写真を残してみてください。',
        'zh-chs': '建议在王陵入口排列的带笑容石狮与西域武士像前留影。',
        'vi': 'Hãy chụp những bức ảnh tuyệt đẹp với các tượng sư tử đá đang mỉm cười và tượng võ quan Tây Á kỳ lạ xếp dọc lối vào lăng mộ.',
        'th': 'ลองถ่ายภาพสวยๆ กับรูปปั้นสิงโตหินยิ้มร่าเริงและรูปปั้นทหารชาวตะวันตกที่เรียงรายอยู่บริเวณทางเข้าสุสาน',
      },
      imagePath: 'https://www.gyeongju.go.kr/upload/content/thumb/20200527/159055973719000.jpg',
      stampImage: 'https://www.gyeongju.go.kr/upload/content/thumb/20200527/159055973719000.jpg',
    ),
    '감은사지': SpotDetail(
      names: {
        'ko': '감은사지',
        'en': 'Gameunsa Temple Site',
        'ja': '感恩寺址',
        'zh-chs': '感恩寺址',
        'vi': 'Di tích chùa Gameunsa',
        'th': 'ที่ตั้งวัดคัมอึนซา',
      },
      facts: {
        'ko': '신라 신문왕이 부왕인 문무왕의 은혜에 감사하며 완성한 사찰 터입니다. 동해 용이 된 문무왕이 드나들 수 있도록 금당 바닥 밑에 통로를 만든 것이 특징이며, 웅장한 삼층석탑 쌍탑이 우뚝 서 있습니다.',
        'en': 'The temple site built by King Sinmun to thank his father, King Munmu. Features an underground passage beneath the main hall for King Munmu (who became a sea dragon) to enter, with two massive 3-story stone pagodas.',
        'ja': '神文王が父の文武王の恩に感謝して完成させた寺院の跡地です。海竜となった文武王が行き来できるよう金堂の床下に通路が作られたのが特徴です。',
        'zh-chs': '神文王为感念父王文武王之恩而修建的寺庙遗址。金堂地板下设有供化为海龙的文武王出入的通道，耸立着雄伟的双三层石塔。',
        'vi': 'Di tích ngôi chùa được vua Sinmun hoàn thành để tạ ơn phụ vương Munmu. Đặc trưng bởi lối đi ngầm dưới sàn chính điện để vua Munmu (đã hóa thành rồng biển) có thể ra vào, cùng hai tòa tháp đá ba tầng đồ sộ sừng sững.',
        'th': 'ที่ตั้งวัดที่พระเจ้าชินมุนสร้างขึ้นเพื่อตอบแทนพระคุณของพระราชบิดา พระเจ้ามุนมู มีลักษณะเด่นคือทางเดินใต้พื้นพระอุโบสถหลักสำหรับให้พระเจ้ามุนมู (ผู้กลายเป็นมังกรทะเล) เสด็จเข้าออก พร้อมด้วยเจดีย์หินสามชั้นคู่ขนาดมหึมาที่ตั้งตระหง่าน',
      },
      tips: {
        'ko': '우뚝 솟은 동·서 삼층석탑 사이에 서서 탁 트인 신라 동해 해풍을 느끼며 사진을 찍기 좋은 장소입니다.',
        'en': 'Stand between the soaring East and West pagodas to feel the fresh ocean breeze of Silla.',
        'ja': 'そびえ立つ東西の三層石塔の間に立ち、爽やかな海風を感じながら写真を撮るのに最適な場所です。',
        'zh-chs': '站在耸立的东、西三层石塔之间，感受来自新罗东海的海风，是绝佳的拍照取景地。',
        'vi': 'Đứng giữa hai tòa tháp đá Đông và Tây sừng sững để cảm nhận làn gió biển trong lành của vùng biển Đông Silla, một địa điểm tuyệt vời để chụp ảnh.',
        'th': 'ยืนอยู่ระหว่างเจดีย์หินสามชั้นฝั่งตะวันออกและตะวันตกที่ตั้งตระหง่าน สัมผัสสายลมทะเลตะวันออกอันสดชื่นของชิลลา เป็นจุดถ่ายภาพที่ยอดเยี่ยม',
      },
      imagePath: 'https://www.gyeongju.go.kr/upload/content/thumb/20200527/159055973719000.jpg',
      stampImage: 'https://www.gyeongju.go.kr/upload/content/thumb/20200527/159055973719000.jpg',
    ),
    '이견대': SpotDetail(
      names: {
        'ko': '이견대',
        'en': 'Igyeondae Pavilion',
        'ja': '利見台',
        'zh-chs': '利见台',
        'vi': 'Đình Igyeondae',
        'th': 'ศาลาอีกยอนแด',
      },
      facts: {
        'ko': '신라 신문왕이 동해의 용이 된 문무왕으로부터 만파식적(세상을 평화롭게 하는 신비한 피리)을 전달받았다고 전해지는 해안 누각입니다.',
        'en': 'A coastal pavilion where King Sinmun received the Manpasikjeok (a legendary flute bringing peace to the world) from King Munmu who became a dragon of the East Sea.',
        'ja': '神文王が東海の竜となった文武王から万波息笛（世を平和にする神秘の笛）を受け取ったと伝えられる海岸の楼閣です。',
        'zh-chs': '传说是神文王从化为东海海龙的文武王处接过万波息笛（化解世间波澜的神笛）的海滨楼阁。',
        'vi': 'Đình ven biển nơi tương truyền vua Sinmun đã nhận được cây sáo thần Manpasikjeok (cây sáo huyền thoại mang lại hòa bình cho thế gian) từ vua Munmu, người đã hóa thành rồng biển Đông.',
        'th': 'ศาลาริมทะเลที่เล่าขานกันว่าพระเจ้าชินมุนทรงได้รับขลุ่ยศักดิ์สิทธิ์มันพาชิกจ็อก (ขลุ่ยในตำนานที่นำสันติสุขมาสู่โลก) จากพระเจ้ามุนมูผู้กลายเป็นมังกรแห่งทะเลตะวันออก',
      },
      tips: {
        'ko': '이견대 누각에서 바다 건너 문무대왕릉(대왕암)이 가장 잘 조망되는 언덕입니다.',
        'en': 'The hill from which you can get the clearest view of the Tomb of King Munmu across the sea.',
        'ja': '利見台の楼閣から海を隔てて文武大王陵が最もよく見渡せる丘です。',
        'zh-chs': '利见台楼阁是隔海眺望文武大王陵的最佳高地。',
        'vi': 'Ngọn đồi từ đình Igyeondae là nơi có thể ngắm nhìn rõ nhất Lăng vua Munmu qua eo biển.',
        'th': 'เนินเขาจากศาลาอีกยอนแดเป็นจุดที่มองเห็นสุสานพระเจ้ามุนมูข้ามทะเลได้ชัดเจนที่สุด',
      },
      imagePath: 'https://www.gyeongju.go.kr/upload/content/thumb/20200527/159055973719000.jpg',
      stampImage: 'https://www.gyeongju.go.kr/upload/content/thumb/20200527/159055973719000.jpg',
    ),
    '계림': SpotDetail(
      names: {
        'ko': '경주 계림',
        'en': 'Gyeongju Gyerim Forest',
        'ja': '慶州 鷄林',
        'zh-chs': '庆州 鸡林',
        'vi': 'Rừng Gyerim Gyeongju',
        'th': 'ป่าเคริมคยองจู',
      },
      facts: {
        'ko': '경주 월성과 첨성대 사이에 위치한 신성한 숲으로, 신라 김씨 왕조의 시조인 김알지가 태어난 전설을 간직하고 있습니다. 고목들이 울창하여 고풍스러운 분위기를 자아냅니다.',
        'en': 'A sacred forest located between Wolseong and Cheomseongdae, preserving the legend of the birth of Kim Al-ji, the progenitor of the Silla Kim dynasty. It boasts dense ancient trees and a serene atmosphere.',
        'ja': '慶州月城と瞻星台の間に位置する神聖な森で、新羅の金氏王朝の始祖である金閼智が誕生したという伝説が残っています。古木が鬱蒼と茂り、趣のある雰囲気を醸し出しています。',
        'zh-chs': '位于庆州月城与瞻星台之间的神圣森林，流传着新罗金氏王朝始祖金阏智诞生的传说。古树参天，营造出古朴幽雅的气氛。',
        'vi': 'Khu rừng linh thiêng nằm giữa Wolseong và Cheomseongdae, lưu giữ truyền thuyết về sự ra đời của Kim Al-ji, thủy tổ của vương triều Kim nước Silla. Những hàng cây cổ thụ rậm rạp tạo nên bầu không khí cổ kính.',
        'th': 'ป่าศักดิ์สิทธิ์ที่ตั้งอยู่ระหว่างวอลซองและช็อมซ็องแด เป็นที่เก็บรักษาตำนานการประสูติของคิมอัลจี ผู้ให้กำเนิดราชวงศ์คิมแห่งชิลลา ต้นไม้เก่าแก่ที่หนาแน่นสร้างบรรยากาศโบราณอันน่าประทับใจ',
      },
      tips: {
        'ko': '낮에도 걷기 좋지만, 숲 사이로 햇살이 비쳐 들어오는 아침 시간대나 조명이 켜지는 밤 시간에 산책하기 매우 좋습니다.',
        'en': 'While nice to walk in the daytime, it is highly recommended to stroll in the morning when sunlight filters through the trees or at night when the lights are lit.',
        'ja': '昼間の散策も良いですが、森の隙間から陽光が差し込む朝の時間帯や、ライトアップされる夜間の散策が非常におすすめです。',
        'zh-chs': '虽然白天的散步也很棒，但强烈推荐在阳光透过树梢洒下的清晨，或是华灯初上的夜晚前往散步。',
        'vi': 'Dạo bộ ban ngày cũng rất đẹp, nhưng đặc biệt nên đi vào buổi sáng khi ánh nắng xuyên qua tán cây, hoặc buổi tối khi đèn được thắp sáng.',
        'th': 'เดินเล่นตอนกลางวันก็ดี แต่แนะนำอย่างยิ่งให้มาช่วงเช้าที่แสงแดดส่องผ่านต้นไม้ หรือยามค่ำคืนที่มีไฟส่องสว่าง',
      },
      imagePath: 'https://www.gyeongju.go.kr/upload/content/thumb/20200527/159055998188100.jpg',
      stampImage: 'https://www.gyeongju.go.kr/upload/content/thumb/20200527/159055998188100.jpg',
    ),
    '월성': SpotDetail(
      names: {
        'ko': '경주 월성',
        'en': 'Gyeongju Wolseong Palace Site',
        'ja': '慶州 月城',
        'zh-chs': '庆州 月城',
        'vi': 'Di tích cung điện Wolseong, Gyeongju',
        'th': 'ที่ตั้งพระราชวังวอลซอง คยองจู',
      },
      facts: {
        'ko': '신라 시대의 왕궁이 있던 자리로, 지형이 초승달 모양을 닮아 월성 또는 반월성이라 불렸습니다. 현재는 성터와 석빙고가 남아있으며 역사적 발굴 조사가 활발히 진행 중입니다.',
        'en': 'The site where the royal palace of Silla once stood, named Wolseong or Banwolseong due to its crescent moon shape. Today, the fortress ruins and Seokbinggo (stone ice house) remain.',
        'ja': '新羅時代の王宮があった場所で、地勢が三日月に似ていることから月城または半月城と呼ばれました。現在は城跡と石氷庫が残っており、歴史的な発掘調査が活发に行われています。',
        'zh-chs': '这里是新罗时代王宫的所在地，因地形酷似新月而被称为月城或半月城。目前保留有城墙遗址和石冰库。',
        'vi': 'Nơi từng là hoàng cung của Silla, được đặt tên Wolseong hoặc Banwolseong vì địa hình giống hình trăng lưỡi liềm. Ngày nay vẫn còn di tích thành lũy và Seokbinggo (kho đá trữ băng).',
        'th': 'สถานที่ที่เคยเป็นพระราชวังหลวงของอาณาจักรชิลลา ได้ชื่อว่าวอลซองหรือพันวอลซองเนื่องจากภูมิประเทศคล้ายพระจันทร์เสี้ยว ปัจจุบันยังคงเหลือซากป้อมปราการและซ็อกบิงโก (ห้องเก็บน้ำแข็งหิน)',
      },
      tips: {
        'ko': '성터 위에 우뚝 서 있는 조선시대의 얼음 창고인 석빙고를 꼭 방문해 보세요. 월성 위에서 바라보는 주변 경관이 탁 트여 있어 상쾌합니다.',
        'en': 'Be sure to visit Seokbinggo, a Joseon-era stone ice house standing on the fortress site. The open view looking down from Wolseong is refreshing.',
        'ja': '城跡の上にそびえ立つ朝鮮時代の氷の倉庫である石氷庫をぜひ訪れてみてください。月城から眺める周辺の景観は広々としていて爽快です。',
        'zh-chs': '一定要去看看建在城墙遗址上的朝鲜时代冰库——石冰库。从月城俯瞰周围的景色开阔宜人。',
        'vi': 'Đừng bỏ lỡ Seokbinggo, kho trữ đá thời Joseon sừng sững trên nền thành cổ. Tầm nhìn thoáng đãng từ Wolseong nhìn xuống cảnh quan xung quanh rất sảng khoái.',
        'th': 'อย่าลืมแวะชมซ็อกบิงโก ห้องเก็บน้ำแข็งหินสมัยโชซอนที่ตั้งตระหง่านอยู่บนซากป้อม วิวทิวทัศน์โดยรอบที่มองจากวอลซองนั้นโปร่งโล่งสดชื่นมาก',
      },
      imagePath: 'https://www.gyeongju.go.kr/upload/content/thumb/20200527/159055990263600.jpg',
      stampImage: 'https://www.gyeongju.go.kr/upload/content/thumb/20200527/159055990263600.jpg',
    ),
    '국립경주박물관': SpotDetail(
      names: {
        'ko': '국립경주박물관',
        'en': 'Gyeongju National Museum',
        'ja': '国立慶州博物館',
        'zh-chs': '国立庆州博物馆',
        'vi': 'Bảo tàng Quốc gia Gyeongju',
        'th': 'พิพิธภัณฑ์แห่งชาติคยองจู',
      },
      facts: {
        'ko': '신라 천년의 문화유산을 한눈에 볼 수 있는 대표적인 박물관입니다. 성덕대왕신종(에밀레종)과 황남대총 금관을 비롯하여 찬란한 불교 미술품들이 대거 전시되어 있습니다.',
        'en': 'A museum showcasing Silla\'s thousand-year cultural heritage. It exhibits the Divine Bell of King Seongdeok (Emille Bell), the golden crown of Hwangnamdaechong, and magnificent Buddhist artworks.',
        'ja': '新羅千年の文化遺産を一望できる代表的な博物館です。聖徳大王神鐘（エミレの鐘）や皇南大塚の金冠をはじめ、きらびやかな仏教美術品が多数展示されています。',
        'zh-chs': '这是可以一览新罗千年文化遗产的代表性博物馆。馆内展示有圣德大王神钟（奉德寺钟）、皇南大冢金冠以及大量灿烂的佛教艺术品。',
        'vi': 'Bảo tàng tiêu biểu trưng bày toàn cảnh di sản văn hóa nghìn năm của Silla. Nơi đây trưng bày Chuông Thần Vua Seongdeok (Chuông Emille), vương miện vàng của Hwangnamdaechong cùng vô số tác phẩm nghệ thuật Phật giáo rực rỡ.',
        'th': 'พิพิธภัณฑ์ที่สามารถชมมรดกทางวัฒนธรรมพันปีของชิลลาได้ในที่เดียว จัดแสดงระฆังศักดิ์สิทธิ์พระเจ้าซองด็อก (ระฆังเอมิลเล) มงกุฎทองคำจากฮวังนัมแดชง และงานศิลปะพุทธศาสนาอันวิจิตรงดงามมากมาย',
      },
      tips: {
        'ko': '야외 정원에 매달려 있는 성덕대왕신종은 매시간 정각마다 종소리 녹음본을 들려줍니다. 무료 관람이 가능하므로 여유롭게 둘러보세요.',
        'en': 'The Divine Bell of King Seongdeok in the outdoor garden plays its recorded sound every hour. Admission is free, so take your time exploring.',
        'ja': '屋外庭園にある聖徳大王神鐘は、毎正時に鐘の音の録音を再生します。入場料は無料ですので、ゆっくりと見学してください。',
        'zh-chs': '悬挂在室外庭院的圣德大王神钟会在每个整点播放钟声录音。博物馆可免费参观，建议悠闲地漫步欣赏。',
        'vi': 'Chuông Thần Vua Seongdeok treo trong khu vườn ngoài trời phát bản ghi âm tiếng chuông vào mỗi giờ đúng. Vào cửa miễn phí nên hãy thong thả tham quan.',
        'th': 'ระฆังศักดิ์สิทธิ์พระเจ้าซองด็อกที่แขวนอยู่ในสวนกลางแจ้งจะเปิดเสียงระฆังบันทึกเสียงทุกชั่วโมงตรง เข้าชมได้ฟรี จึงควรเดินชมอย่างสบายๆ',
      },
      imagePath: 'https://www.gyeongju.go.kr/upload/content/thumb/20200527/159056018318800.jpg',
      stampImage: 'https://www.gyeongju.go.kr/upload/content/thumb/20200527/159056018318800.jpg',
    ),
    '황룡사지': SpotDetail(
      names: {
        'ko': '황룡사지',
        'en': 'Hwangnyongsaji Temple Site',
        'ja': '皇龍寺跡',
        'zh-chs': '皇龙寺址',
        'vi': 'Di tích chùa Hwangnyongsa',
        'th': 'ที่ตั้งวัดฮวังนยองซา',
      },
      facts: {
        'ko': '신라 최대의 호국사찰이었던 황룡사의 옛 터입니다. 높이 약 80m에 달했던 거대한 황룡사 구층목탑이 있던 자리로, 웅장했던 신라 불교 문화의 규모를 실감할 수 있는 곳입니다.',
        'en': 'The ancient site of Hwangnyongsa, the largest state-patronized temple of Silla. It is the location of the colossal 9-story wooden pagoda that rose about 80 meters high, reflecting Silla\'s grand Buddhist culture.',
        'ja': '新羅最大の護国寺院であった皇龍寺の跡地です。高さ約80mに達した巨大な皇龍寺九重木塔が建てられていた場所で、壮大だった新羅仏教文化の規模を実感できます。',
        'zh-chs': '这里曾是新罗最大的护国寺庙——皇龙寺的遗址。曾建有高达80米的巨大皇龙寺九层木塔，在此可切身感受到昔日新罗佛教文化的宏大规模。',
        'vi': 'Di tích cổ của Hwangnyongsa, ngôi chùa hộ quốc lớn nhất của Silla. Đây là nơi từng tọa lạc tòa tháp gỗ chín tầng khổng lồ cao khoảng 80m, cho thấy quy mô hoành tráng của văn hóa Phật giáo Silla.',
        'th': 'ที่ตั้งโบราณของวัดฮวังนยองซา วัดคุ้มครองประเทศที่ใหญ่ที่สุดของชิลลา เป็นที่ตั้งของเจดีย์ไม้เก้าชั้นขนาดมหึมาสูงประมาณ 80 เมตร สะท้อนให้เห็นถึงความยิ่งใหญ่ของวัฒนธรรมพุทธศาสนาชิลลา',
      },
      tips: {
        'ko': '터 옆에 위치한 황룡사 역사문화관에 방문하시면 구층목탑의 1/10 복형 탑과 가상 복원 영상을 통해 당시의 웅장함을 더 생생히 느낄 수 있습니다.',
        'en': 'Visiting the Hwangnyongsa History and Culture Museum nearby allows you to view a 1/10 scale model of the 9-story wooden pagoda and virtual restoration videos.',
        'ja': '隣接する皇龍寺歴史文化館を訪れると、九重木塔の10分の1スケールの模型やバーチャル復元映像を通じて、当時の雄大さをより鮮明に感じることができます。',
        'zh-chs': '前往遗址旁的皇龙寺历史文化馆，可以通过九层木塔的十分之一比例模型及虚拟复原视频，更生动地感受当年的雄伟。',
        'vi': 'Ghé thăm Nhà văn hóa lịch sử Hwangnyongsa gần đó để xem mô hình thu nhỏ 1/10 của tòa tháp gỗ chín tầng và video phục dựng ảo, giúp cảm nhận rõ hơn sự hoành tráng thời bấy giờ.',
        'th': 'แวะชมศูนย์ประวัติศาสตร์และวัฒนธรรมฮวังนยองซาที่อยู่ใกล้ๆ เพื่อชมแบบจำลองเจดีย์ไม้เก้าชั้นย่อส่วน 1 ใน 10 และวิดีโอจำลองการบูรณะเสมือนจริง ทำให้รู้สึกถึงความยิ่งใหญ่ในอดีตได้ชัดเจนยิ่งขึ้น',
      },
      imagePath: 'https://www.gyeongju.go.kr/upload/content/thumb/20200527/159056001272600.jpg',
      stampImage: 'https://www.gyeongju.go.kr/upload/content/thumb/20200527/159056001272600.jpg',
    ),
  };

  static SpotDetail? get(String rawTitle) {
    String clean = rawTitle
        .replaceAll(RegExp(r'\([^)]*\)'), '')
        .replaceAll(RegExp(r'\[[^\]]*\]'), '')
        .replaceAll(RegExp(r'^경주\s*,?\s*'), '')
        .replaceAll(RegExp(r'^Gyeongju\s*,?\s*', caseSensitive: false), '')
        .trim()
        .toLowerCase();
    
    // 1. Check exact/partial match against Korean database keys
    for (var entry in db.entries) {
      final key = entry.key;
      final detail = entry.value;
      
      if (key.toLowerCase() == clean || 
          key.toLowerCase().contains(clean) || 
          clean.contains(key.toLowerCase())) {
        return detail;
      }
      
      // 2. Check match against any of the localized names inside the SpotDetail
      for (var name in detail.names.values) {
        final cleanName = name.toLowerCase();
        if (cleanName == clean || 
            cleanName.contains(clean) || 
            clean.contains(cleanName)) {
          return detail;
        }
      }
    }
    return null;
  }
}
