# Mac 파일 정리

macOS 기본 도구로 디스크 사용량을 분석하고 캐시·오래된 로그·설치 파일·빌드 산출물의 정리 후보를 찾는 Codex·Claude Code 플러그인입니다. 다운로드나 바탕화면처럼 지정한 폴더에서는 대용량 파일과 중복 후보를 찾아 분류하고, 선택한 항목을 이동하거나 휴지통으로 보낼 수 있습니다.

## 설치

[저장소 README](../../README.md)에 따라 `fhdufhdu` 마켓플레이스를 등록한 뒤 설치합니다.

**Codex CLI**

```bash
codex plugin add mac-file-cleanup@fhdufhdu
```

**Claude Code 세션**

```text
/plugin install mac-file-cleanup@fhdufhdu
```

## 사용

- Codex에서는 스킬 선택기에서 `Mac 파일 정리`를 선택하고 `다운로드 폴더의 대용량 파일과 정리 후보를 보여줘`라고 요청합니다.
- Claude Code에서는 `/mac-file-cleanup:mac-file-cleanup 다운로드 폴더의 대용량 파일과 정리 후보를 보여줘`라고 입력합니다.

후보 선별, 보호 규칙, 미리보기 후 승인 방식은 [Mole의 정리 설계](https://github.com/tw93/Mole#safety)를 참고했습니다. 파일 검사와 이동은 macOS 기본 도구와 Finder를 사용합니다.
