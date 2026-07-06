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
      },
      tips: {
        'ko': '일몰 후에 은은한 야간 조명이 켜질 때 방문하시는 것을 강력히 추천합니다. 주변의 넓은 핑크뮬리 정원과 꽃밭도 훌륭한 포토존입니다.',
        'en': 'Highly recommend visiting after sunset when the soft night lights turn on. The surrounding pink muhly garden and flower fields are also great photo spots.',
        'ja': '日没後にほのかな夜間照明が点灯する時間帯の訪問を強くお勧めします。周辺の広いピンクミューリー庭園や花畑도 素晴らしいフォトスポットです。',
        'zh-chs': '强烈建议在日落后柔和的夜灯亮起时前往。周围大片的粉黛乱子草花园和花田也是极佳的拍照打卡地。',
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
      },
      tips: {
        'ko': '경주 최고의 야경 명소입니다. 매표소 대기 줄이 길 수 있으니 모바일 예매를 이용하거나 일몰 30분 전에 여유 있게 방문하세요.',
        'en': 'The absolute best night view spot in Gyeongju. The ticket line can be very long, so use mobile booking or arrive 30 minutes before sunset.',
        'ja': '慶州最高の夜景名所です。チケット売り場の列が長くなることがあるため、モバイル予約を利用するか、日没の30分前に余裕を持って訪問してください。',
        'zh-chs': '庆州公认最美的夜景名所。售票处可能会排长队，建议使用手机预订，或在日落前30分钟提前到达。',
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
      },
      tips: {
        'ko': '오전 9시 이전에 방문하면 붐비지 않고 고즈넉한 사찰의 분위기를 온전히 느낄 수 있습니다. 대웅전 뒤편의 극락전 복돼지 동상도 꼭 찾아 만져보세요.',
        'en': 'Visit before 9:00 AM to enjoy the quiet, serene temple atmosphere without crowds. Make sure to find and touch the Golden Pig statue at Geuk락jeon behind Daeungjeon.',
        'ja': '午前9時前に訪問すると混雑を避け、静かな寺院の雰囲気を十分に感じることができます。大雄殿の裏手にある極楽殿の「福豚の像」もぜひ探して触ってみてください。',
        'zh-chs': '建议在上午9点前前往，可以避开人群，尽情感受寺庙的幽静与庄严。别忘了去大雄殿后方的极乐殿寻找并摸一摸“福猪像”，以求好运。',
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
      },
      tips: {
        'ko': '불국사에서 석굴암까지 이어지는 등산로나 셔틀버스를 이용해 편리하게 이동할 수 있습니다. 석굴 내부 보호유리 너머로 본존불을 관람하게 됩니다.',
        'en': 'You can easily move from Bulguksa to Seokguram using the hiking trail or shuttle bus. The main Buddha is viewed through a protective glass wall inside the grotto.',
        'ja': '仏国寺から石窟庵へと続く登山道やシャトルバスを利用して便利に移動できます。石窟の内部は、保護ガラス越しに本尊仏を観覧することになります。',
        'zh-chs': '您可以利用从佛国寺通往石窟庵的登山步道或穿梭巴士便利地前往。您将在石窟内通过保护玻璃观看本尊佛像。',
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
      },
      tips: {
        'ko': '두 개의 봉우리가 맞닿은 황남대총 뒷길은 인스타그램에서 가장 핫한 포토존입니다. 천마총 내부에 전시된 화려한 금관 복제품을 꼭 관람해 보세요.',
        'en': 'The path behind Hwangnamdaechong, where two peaks meet, is the most popular Instagram photo spot. Be sure to check out the gorgeous replica of the golden crown inside Cheonmachong.',
        'ja': '2つの峰が隣り合う皇南大塚の裏道は、インスタグラムで大人気のフォトスポットです。天馬塚の内部に展示されている華やかな金冠のレプリカもぜひ観覧してください。',
        'zh-chs': '两座山峰相连的皇南大冢后路是社交媒体上最热门的拍照点。一定要去天马冢内部看看展出的华丽金冠复制品。',
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
      },
      tips: {
        'ko': '골목길이 좁고 유동인구가 많아 도보 여행에 최적화되어 있습니다. 황남쫀드기, 십원빵 등 길거리 간식을 먹어보는 재미가 쏠쏠합니다.',
        'en': 'The alleys are narrow and crowded, making it perfect for walking tours. Enjoy trying local street snacks like Hwangnam Jjondigi (chewy snack) and 10-Won Bread.',
        'ja': '路地が狭く人通りが多いため、徒歩旅行に最適です。「ファンナムチョンディギ」や「10ウォンパン」などのストリートフードを食べる楽しみも格別です。',
        'zh-chs': '胡同狭窄且人流量大，非常适合徒步旅游。品尝皇南拉丝条、十元饼等街头小吃是一大乐趣。',
      },
      imagePath: 'assets/images/spots/신라_역사_여행.jpg',
      stampImage: 'assets/images/spots/신라_역사_여행.jpg',
    ),
  };

  static SpotDetail? get(String rawTitle) {
    String clean = rawTitle
        .replaceAll(RegExp(r'\([^)]*\)'), '')
        .replaceAll(RegExp(r'\[[^\]]*\]'), '')
        .replaceAll(RegExp(r'^경주\s*,?\s*'), '')
        .replaceAll(RegExp(r'^Gyeongju\s*,?\s*', caseSensitive: false), '')
        .trim();
    
    // exact match
    if (db.containsKey(clean)) return db[clean];

    // partial match
    for (var key in db.keys) {
      if (clean.contains(key) || key.contains(clean)) {
        return db[key];
      }
    }
    return null;
  }
}
