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
- `용량이 부족해 정리 좀 하자`처럼 Mac 전반을 요청하면 데이터 볼륨 여유 공간부터 확인하고, 라이브러리·다운로드·개발 도구 캐시를 크기순으로 조사합니다.
- `~/project 아래 빌드 산출물 정리해줘`처럼 프로젝트 루트를 알려 주면 `node_modules`, `target`, `build`, `.venv` 등을 매니페스트·Git 추적·최근 수정 기준으로 판정합니다. 판정만 따로 실행할 수도 있습니다.

  ```bash
  skills/mac-file-cleanup/scripts/scan-build-artifacts.sh ~/project
  ```

## 정리 방식

- 후보는 **바로 정리 가능 / 사용자 판단 필요 / 건너뜀** 세 묶음으로 보여 주고, 고른 번호만 처리합니다.
- 파일과 폴더는 휴지통으로 옮깁니다. 휴지통은 비우지 않으므로, 실제 공간을 확보하려면 Finder에서 직접 비워야 합니다.
- Docker 이미지(`docker system prune`)나 Rust 빌드 결과(`cargo clean`)처럼 도구 명령으로 정리하는 항목은 즉시 삭제되며, 따로 승인을 받은 뒤에만 실행합니다.

후보 선별, 보호 규칙, 미리보기 후 승인 방식은 [Mole의 정리 설계](https://github.com/tw93/Mole#safety)를 참고했습니다. 파일 검사와 이동은 macOS 기본 도구와 Finder를 사용합니다.
