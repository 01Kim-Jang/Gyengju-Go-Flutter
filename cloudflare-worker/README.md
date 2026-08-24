# AI 프록시 (Cloudflare Worker)

Firebase Blaze(종량제) 업그레이드 없이 OpenAI API 키를 앱 밖으로 숨기기 위한
최소한의 서버리스 프록시입니다. 무료 요금제로 신용카드 등록 없이 배포할 수
있습니다.

## 배포 방법

1. [Cloudflare](https://dash.cloudflare.com/sign-up)에서 무료 계정을 만듭니다 (카드 등록 불필요).
2. Node.js가 설치되어 있다면, 이 폴더에서 아래 명령으로 로그인 및 배포합니다.
   ```bash
   cd cloudflare-worker
   npx wrangler login      # 브라우저가 열리며 Cloudflare 계정으로 로그인
   npx wrangler deploy     # worker.js를 배포
   ```
3. 배포가 끝나면 터미널에 다음과 같은 URL이 출력됩니다. 이 URL을 기억해두세요.
   ```
   https://gyeongju-go-ai-proxy.<your-subdomain>.workers.dev
   ```
4. 두 개의 비밀 값을 Cloudflare에 등록합니다 (여기 입력한 값은 Cloudflare 서버에만 저장되고 코드/깃허브에는 절대 올라가지 않습니다).
   ```bash
   npx wrangler secret put OPENAI_API_KEY
   # 프롬프트가 뜨면 기존에 .env에 있던 실제 OpenAI API 키를 붙여넣으세요.

   npx wrangler secret put APP_SECRET
   # 임의의 긴 랜덤 문자열을 직접 만들어 입력하세요 (예: openssl rand -hex 32 로 생성).
   # 이 값은 앱의 .env에도 AI_PROXY_SECRET으로 동일하게 넣어야 합니다.
   ```
5. 프로젝트 루트의 `.env` 파일을 아래처럼 수정합니다.
   - `OPENAI_API_KEY` 줄은 **삭제**합니다 (더 이상 앱에 필요 없습니다).
   - 다음 두 줄을 추가합니다.
     ```
     AI_PROXY_URL=https://gyeongju-go-ai-proxy.<your-subdomain>.workers.dev
     AI_PROXY_SECRET=<4번에서 만든 것과 동일한 랜덤 문자열>
     ```
6. 앱을 다시 빌드하면 이제 OpenAI 키 없이도 AI 비서/번역/도슨트 기능이 정상 동작합니다.

## 왜 필요한가요?

지금까지는 OpenAI API 키가 앱의 `.env`에 직접 들어가서, 앱을 디컴파일하면
누구나 키를 추출해 마음대로 쓸 수 있는 상태였습니다. 이 Worker를 거치면
앱은 Worker의 URL만 알고 있고, 진짜 OpenAI 키는 Cloudflare 서버에만
존재하게 됩니다.

`X-App-Secret` 값도 앱 안에 포함되어 있어 완벽한 보안은 아니지만
(디컴파일하면 알아낼 수 있음 — Mapbox/Kakao 키와 동일한 수준), 최소한
"URL만 우연히 알게 된 사람이 무제한으로 OpenAI 비용을 쓰는" 상황은 막아줍니다.
추가로 OpenAI 대시보드에서 월 지출 한도를 걸어두면 더 안전합니다
(https://platform.openai.com/account/limits).
