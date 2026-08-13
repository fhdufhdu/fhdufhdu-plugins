---
name: init
description: Feel English 학습 기록용 Git 저장소를 설정하거나 점검합니다. 저장소 URL 요청, ~/.fhdufhdu/feel-english 클론, ~/.fhdufhdu/config/feel-english.json 생성, 원격 URL 검증, 학습 디렉터리 초기화가 필요할 때 사용합니다.
---

# Feel English Init

## 저장 위치

다음 경로를 고정해 사용한다.

```text
~/.fhdufhdu/config/feel-english.json  # 로컬 설정
~/.fhdufhdu/feel-english              # 사용자의 Git 저장소 클론
```

사용자의 학습 기록은 플러그인 디렉터리가 아닌 Git 저장소를 진실의 원천으로 삼는다. 플러그인과 클론 경로에는 정식 이름인 `feel-english`를 사용한다.

## 설정 파일

`feel-english.json`에는 다음만 저장한다.

```json
{
  "repo_url": "https://github.com/user/feel-english-data.git",
  "repo_path": "/Users/name/.fhdufhdu/feel-english",
  "default_branch": "main",
  "created_at": "YYYY-MM-DDTHH:MM:SSZ",
  "updated_at": "YYYY-MM-DDTHH:MM:SSZ"
}
```

학습 내용이나 사용자 문장은 설정 파일에 넣지 않는다.

## 설정 절차

1. 설정 JSON과 클론 경로를 점검한다.
2. 설정이 없고 클론도 없으면 학습 기록을 저장할 Git 저장소 URL을 사용자에게 요청한다. 저장소를 임의로 생성하거나 기본 URL을 정하지 않는다.
3. `~/.fhdufhdu/config`를 만든다.
4. 제공받은 저장소를 `~/.fhdufhdu/feel-english`에 클론한다.
5. origin URL과 기본 브랜치를 확인한 뒤 설정 JSON을 쓴다.
6. 클론이 이미 있으면 Git 저장소인지, origin이 설정과 일치하는지 확인한다.
7. 설정은 없지만 정상적인 클론이 있으면 origin을 보여 주고 이 저장소를 사용할지 확인받은 뒤 설정을 복구한다.
8. origin 불일치나 Git이 아닌 기존 경로를 발견하면 덮어쓰지 말고 멈춘 뒤 사용자에게 선택을 묻는다.
9. 일치하는 기존 저장소는 `git pull --ff-only`로 갱신한다.
10. 다음 기록 경로를 준비한다. Git이 빈 디렉터리를 추적하지 않으므로 필요하면 `.gitkeep`을 만든다.

```text
sessions/
words/
reviews/
progress/
persistent/
```

11. 실제 파일을 생성했을 때만 커밋하고 push한다. 인증 문제로 push가 실패하면 로컬 커밋을 보존하고 정확한 실패 이유를 알린다.

## 완료 안내

```text
Feel English 학습 저장소 설정이 완료되었습니다.
설정 파일: ~/.fhdufhdu/config/feel-english.json
데이터 저장소: ~/.fhdufhdu/feel-english
```
