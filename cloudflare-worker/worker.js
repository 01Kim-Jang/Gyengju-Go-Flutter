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

function corsHeaders() {
  return {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type, X-App-Secret',
  };
}

export default {
  async fetch(request, env) {
    if (request.method === 'OPTIONS') {
      return new Response(null, { headers: corsHeaders() });
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
