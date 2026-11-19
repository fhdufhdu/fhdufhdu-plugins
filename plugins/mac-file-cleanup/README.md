# Mac 파일 정리

로컬 macOS에서 디스크 사용량을 분석하고, [Mole](https://github.com/tw93/mole) 정리 대상의 예상 회수 용량을 확인하는 Codex·Claude Code 플러그인입니다. 다운로드나 바탕화면처럼 지정한 폴더에서는 대용량 파일과 중복 후보를 찾아 분류하고, 선택한 항목을 이동하거나 휴지통으로 보낼 수 있습니다.

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

Mole CLI(`mo`)가 있으면 디스크 분석과 캐시·설치 파일·빌드 산출물 미리보기에 사용합니다. Mole이 없는 환경에서는 macOS 기본 도구로 지정한 폴더의 사용량과 파일을 살펴봅니다. Mole의 영구 삭제 명령은 `--dry-run`으로만 실행합니다.
