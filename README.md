# 🌐 Apocalypse Hub (아포칼립스 허브)

> **Gemma 4 E4B 멀티모달 로컬 LLM 허브 (Termux / Android S24 Ultra 최적화)**
> 
> 기기를 초기화하거나 다른 안드로이드 단말기로 옮길 때도 명령어 한 줄로 5분 만에 모든 환경을 복구할 수 있는 원클릭 셋업 환경입니다.

---

## 🚀 빠른 시작 (원클릭 설치)

안드로이드 단말기의 **Termux** 앱에서 아래 명령어를 한 줄로 복사하여 붙여넣으면 패키지 설치부터 llama.cpp Vulkan 빌드, 모델 다운로드까지 한 번에 완료됩니다.

```bash
pkg update -y && pkg install -y git && git clone https://github.com/ishuca12625-lab/apo-hub.git && cd apo-hub && chmod +x setup.sh && ./setup.sh
```

---

## 📂 저장소 구조

```plaintext
apocalypse-hub/
├── setup.sh       # 패키지 설치, llama.cpp Vulkan 컴파일, 모델 다운로드 자동화
├── run_hub.sh     # S24 Ultra 최적화 웹 서버 구동 스크립트
└── README.md      # 원클릭 설치 및 안내 문서
```

---

## ⚙️ 주요 구성 요소

### 1. `setup.sh`
- **의존성 설치**: `git`, `cmake`, `clang`, `ninja`, `python`, `vulkan-loader-android`, `vulkan-headers`, `shaderc`, `curl`
- **llama.cpp 빌드**: Adreno 750 GPU 가속을 위한 Vulkan 백엔드(`-DGGML_VULKAN=ON`)로 컴파일
- **멀티모달 모델 다운로드**: HuggingFace Unsloth 저장소에서 `gemma-4-E4B-it-Q4_K_M.gguf` 및 `mmproj-BF16.gguf` 다운로드 (이어받기 `-C -` 지원)
- **실행 링크 등록**: `~/run_hub.sh` 심볼릭 링크 자동 생성

### 2. `run_hub.sh`
- **서버 실행**: `llama-server` 구동
- **최적화 옵션**:
  - `-c 8192`: 컨텍스트 길이 8192 토큰
  - `-ngl 99`: GPU(Vulkan) 오프로딩 최대화
  - `-t 6`: 빅코어/미들코어 위주 6 스레드 할당
  - `--chat-template-kwargs '{"enable_thinking":true}'`: 사고(Thinking) 모드 활성화

---

## 🖥️ 사용 방법

### 서버 실행
설치 완료 후 언제든 홈 디렉터리에서 아래 명령어를 실행합니다:

```bash
~/run_hub.sh
```

### 웹 인터페이스 접속
브라우저를 열고 아래 주소로 접속합니다:
- **스마트폰 로컬 접속**: [http://127.0.0.1:8080](http://127.0.0.1:8080)
- **외부 기기 접속**: 기본적으로 `--host 0.0.0.0`으로 구동되므로, 동일 Wi-Fi에 연결된 PC나 태블릿 등에서도 `http://<스마트폰-IP>:8080`으로 바로 접속할 수 있습니다.

---

## 💡 팁 및 주의사항
- **절전 방지**: 스크립트 내에 `termux-wake-lock`이 포함되어 있어 백그라운드 구동 시 Termux 프로세스가 종료되지 않도록 유지합니다.
- **이어받기**: 네트워크 단절 등으로 다운로드가 중단되면 `./setup.sh`를 다시 실행해도 다운받던 지점부터 이어받습니다.
- **라인 엔딩 (CRLF vs LF)**: 윈도우 환경에서 편집 후 커밋할 때 줄바꿈이 `CRLF`로 변환되면 Termux에서 실행 시 에러가 발생할 수 있습니다. 반드시 `LF` 줄바꿈을 유지해 주세요.
