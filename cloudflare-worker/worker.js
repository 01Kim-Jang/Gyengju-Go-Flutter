// 경주고 앱의 OpenAI 프록시. Firebase Blaze(종량제) 업그레이드 없이도 OpenAI API
// 키를 클라이언트 앱 밖에 안전하게 보관하기 위한 최소한의 서버 역할을 한다.
//
// 동작 방식: 앱은 이 Worker의 URL로만 요청을 보내고, 이 Worker가 진짜 OpenAI
// API 키(Cloudflare Secret으로 저장, 코드에는 절대 포함되지 않음)를 붙여서
// OpenAI로 대신 요청을 전달한다. 앱 안에는 OpenAI 키가 전혀 남지 않는다.
//
// X-App-Secret 헤더는 완전한 인증이 아니라, URL을 우연히 알게 된 사람의
// 무분별한 남용을 막는 최소한의 방어선이다(앱을 디컴파일하면 여전히 알아낼
// 수 있음 - Mapbox/Kakao 키와 동일한 수준의 위협 모델).

const OPENAI_URL = 'https://api.openai.com/v1/chat/completions';
const OPENAI_TTS_URL = 'https://api.openai.com/v1/audio/speech';
const ODII_BASE_URL = 'https://apis.data.go.kr/B551011/Odii';
const KAKAO_LOCAL_CATEGORY_URL = 'https://dapi.kakao.com/v2/local/search/category.json';
const TAGO_STTN_URL = 'https://apis.data.go.kr/1613000/BusSttnInfoInqireService';
const TAGO_ARVL_URL = 'https://apis.data.go.kr/1613000/ArvlInfoInqireService';

function corsHeaders() {
  return {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type, X-App-Secret',
  };
}

// 경주고 웹 버전이 브라우저에서 바로 apis.data.go.kr을 호출하면 CORS에 막히므로,
// 이 Worker가 대신 호출해서 결과만 그대로 돌려준다(서비스키도 여기서만 보관).
async function handleOdii(url, env) {
  if (!env.ODII_SERVICE_KEY) {
    return new Response('Server misconfigured: ODII_SERVICE_KEY not set', {
      status: 500,
      headers: corsHeaders(),
    });
  }

  const endpoint = url.pathname.replace('/odii/', '');
  const params = new URLSearchParams(url.search);
  params.set('serviceKey', env.ODII_SERVICE_KEY);

  const odiiResponse = await fetch(`${ODII_BASE_URL}/${endpoint}?${params.toString()}`);
  const body = await odiiResponse.text();
  return new Response(body, {
    status: odiiResponse.status,
    headers: { 'Content-Type': 'application/json; charset=utf-8', ...corsHeaders() },
  });
}

// 주변 장소(맛집/약국/병원) 카테고리 검색. REST API 키는 여기서만 보관한다.
// category: 'food' | 'pharmacy' | 'hospital' 만 허용 (임의 코드로 남용되는 것 방지)
const CATEGORY_CODES = { food: 'FD6', pharmacy: 'PM9', hospital: 'HP8' };

async function handleNearbyPlaces(url, env, category) {
  if (!env.KAKAO_REST_API_KEY) {
    return new Response('Server misconfigured: KAKAO_REST_API_KEY not set', {
      status: 500,
      headers: corsHeaders(),
    });
  }

  const categoryCode = CATEGORY_CODES[category];
  if (!categoryCode) {
    return new Response('Unknown category', { status: 400, headers: corsHeaders() });
  }

  const x = url.searchParams.get('x'); // 경도
  const y = url.searchParams.get('y'); // 위도
  if (!x || !y) {
    return new Response('Missing x/y query params', { status: 400, headers: corsHeaders() });
  }

  const params = new URLSearchParams({
    category_group_code: categoryCode,
    x,
    y,
    radius: url.searchParams.get('radius') || '1000',
    sort: 'distance',
    size: '10',
  });

  const kakaoResponse = await fetch(`${KAKAO_LOCAL_CATEGORY_URL}?${params.toString()}`, {
    headers: { Authorization: `KakaoAK ${env.KAKAO_REST_API_KEY}` },
  });
  const body = await kakaoResponse.text();
  return new Response(body, {
    status: kakaoResponse.status,
    headers: { 'Content-Type': 'application/json; charset=utf-8', ...corsHeaders() },
  });
}

// TAGO(국토교통부) 버스정류소정보/버스도착정보 프록시
async function handleTagoNearbyStops(url, env) {
  if (!env.TAGO_SERVICE_KEY) {
    return new Response('Server misconfigured: TAGO_SERVICE_KEY not set', { status: 500, headers: corsHeaders() });
  }
  const lat = url.searchParams.get('lat');
  const lng = url.searchParams.get('lng');
  if (!lat || !lng) {
    return new Response('Missing lat/lng query params', { status: 400, headers: corsHeaders() });
  }
  const params = new URLSearchParams({
    serviceKey: env.TAGO_SERVICE_KEY,
    gpsLati: lat,
    gpsLong: lng,
    numOfRows: '10',
    pageNo: '1',
    _type: 'json',
  });
  const res = await fetch(`${TAGO_STTN_URL}/getCrdntPrxmtSttnList?${params.toString()}`);
  const body = await res.text();
  return new Response(body, { status: res.status, headers: { 'Content-Type': 'application/json; charset=utf-8', ...corsHeaders() } });
}

async function handleTagoArrivals(url, env) {
  if (!env.TAGO_SERVICE_KEY) {
    return new Response('Server misconfigured: TAGO_SERVICE_KEY not set', { status: 500, headers: corsHeaders() });
  }
  const cityCode = url.searchParams.get('cityCode');
  const nodeId = url.searchParams.get('nodeId');
  if (!cityCode || !nodeId) {
    return new Response('Missing cityCode/nodeId query params', { status: 400, headers: corsHeaders() });
  }
  const params = new URLSearchParams({
    serviceKey: env.TAGO_SERVICE_KEY,
    cityCode,
    nodeId,
    numOfRows: '10',
    pageNo: '1',
    _type: 'json',
  });
  const res = await fetch(`${TAGO_ARVL_URL}/getSttnAcctoArvlPrearngeInfoList?${params.toString()}`);
  const body = await res.text();
  return new Response(body, { status: res.status, headers: { 'Content-Type': 'application/json; charset=utf-8', ...corsHeaders() } });
}

// 오디오 도슨트를 기기/브라우저 내장 TTS 대신 OpenAI TTS로 생성한다
// (다국어 발음 품질이 훨씬 자연스러워 외국인 관광객 경험에 중요).
async function handleTts(request, env) {
  const appSecret = request.headers.get('X-App-Secret');
  if (!env.APP_SECRET || appSecret !== env.APP_SECRET) {
    return new Response('Unauthorized', { status: 401, headers: corsHeaders() });
  }
  if (!env.OPENAI_API_KEY) {
    return new Response('Server misconfigured: OPENAI_API_KEY not set', { status: 500, headers: corsHeaders() });
  }

  let body;
  try {
    body = await request.text();
  } catch (e) {
    return new Response('Bad Request', { status: 400, headers: corsHeaders() });
  }

  const openaiResponse = await fetch(OPENAI_TTS_URL, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json; charset=utf-8',
      Authorization: `Bearer ${env.OPENAI_API_KEY}`,
    },
    body,
  });

  if (!openaiResponse.ok) {
    const errText = await openaiResponse.text();
    return new Response(errText, { status: openaiResponse.status, headers: corsHeaders() });
  }

  const audioBytes = await openaiResponse.arrayBuffer();
  return new Response(audioBytes, {
    status: 200,
    headers: { 'Content-Type': 'audio/mpeg', ...corsHeaders() },
  });
}

export default {
  async fetch(request, env) {
    if (request.method === 'OPTIONS') {
      return new Response(null, { headers: corsHeaders() });
    }

    const url = new URL(request.url);
    if (url.pathname.startsWith('/odii/')) {
      if (request.method !== 'GET') {
        return new Response('Method Not Allowed', { status: 405, headers: corsHeaders() });
      }
      return handleOdii(url, env);
    }

    if (url.pathname === '/nearby-food') {
      if (request.method !== 'GET') {
        return new Response('Method Not Allowed', { status: 405, headers: corsHeaders() });
      }
      return handleNearbyPlaces(url, env, 'food');
    }

    if (url.pathname.startsWith('/nearby/')) {
      if (request.method !== 'GET') {
        return new Response('Method Not Allowed', { status: 405, headers: corsHeaders() });
      }
      return handleNearbyPlaces(url, env, url.pathname.replace('/nearby/', ''));
    }

    if (url.pathname === '/tago/nearby-stops') {
      if (request.method !== 'GET') {
        return new Response('Method Not Allowed', { status: 405, headers: corsHeaders() });
      }
      return handleTagoNearbyStops(url, env);
    }

    if (url.pathname === '/tago/arrivals') {
      if (request.method !== 'GET') {
        return new Response('Method Not Allowed', { status: 405, headers: corsHeaders() });
      }
      return handleTagoArrivals(url, env);
    }

    if (url.pathname === '/tts') {
      if (request.method !== 'POST') {
        return new Response('Method Not Allowed', { status: 405, headers: corsHeaders() });
      }
      return handleTts(request, env);
    }

    if (request.method !== 'POST') {
      return new Response('Method Not Allowed', { status: 405, headers: corsHeaders() });
    }

    const appSecret = request.headers.get('X-App-Secret');
    if (!env.APP_SECRET || appSecret !== env.APP_SECRET) {
      return new Response('Unauthorized', { status: 401, headers: corsHeaders() });
    }

    if (!env.OPENAI_API_KEY) {
      return new Response('Server misconfigured: OPENAI_API_KEY not set', {
        status: 500,
        headers: corsHeaders(),
      });
    }

    let body;
    try {
      body = await request.text();
    } catch (e) {
      return new Response('Bad Request', { status: 400, headers: corsHeaders() });
    }

    const openaiResponse = await fetch(OPENAI_URL, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        Authorization: `Bearer ${env.OPENAI_API_KEY}`,
      },
      body,
    });

    const responseBody = await openaiResponse.text();
    return new Response(responseBody, {
      status: openaiResponse.status,
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        ...corsHeaders(),
      },
    });
  },
};
