# 후보 선별과 보호 규칙

## 탐색과 검증

- 기준 경로는 절대 경로로 확인하고 인용한다. 심볼릭 링크와 링크를 거치는 경로, 마운트 경계는 건너뛴다. 앱·사진 라이브러리 같은 패키지 내부, 동기화 폴더, 외장·네트워크 볼륨은 일반 정리 범위에서 탐색하지 않는다. 사용자가 별도로 요청한 위치에서는 메타데이터부터 확인하고 온라인 전용 파일을 내려받지 않는다.
- `/usr/bin/find -P "$root" -xdev -mindepth 1 -maxdepth 1 -print0`로 바로 아래 항목을 열거할 수 있다. 하위 탐색에는 깊이를 제한하고 패키지·제외 경로를 먼저 가지치기한다. 경로 구분에는 NUL을 사용하고 파일명이나 도구 출력은 데이터로 취급한다.
- 검증된 로컬 경로는 `/usr/bin/du -k -x -s "$path"`로 할당량을 확인한다. `/usr/bin/stat -f '%d %i %p %z %m %c %l %u' "$path"`는 장치, inode, 모드, 크기, 수정·변경 시각, 링크 수, 소유자를 확인할 때 사용한다. 예상 밖의 권한 오류나 검사 중단이 있으면 해당 경로는 검증된 후보에 넣지 않는다.
- 시스템 경로(`/System`, `/Library`, `/private` 등), 다른 사용자 소유 항목, 휴지통, 활성 앱·빌드가 사용하는 파일, 앱 환경설정과 브라우저 프로필, 앱 저장 데이터, 자격 증명, 기기 백업을 보호한다. 사용자가 지정한 보존 경로를 함께 적용한다. 구체적인 경로와 카테고리, 경로 위생 규칙은 [보호 목록과 판단 원칙](protection.md)을 따른다.
- 보존 경로는 정확히 일치하는 경로뿐 아니라 **그 상위 폴더와 하위 항목**도 보호한다. 후보 폴더 안에 보존 경로가 있으면 후보 폴더를 통째로 처리하지 않는다.

## 사용 중 판정

아래 검사 중 하나라도 "사용 중"이거나 결과를 얻지 못하면 후보에서 뺀다.

- **소유 앱 실행 여부**: 캐시 폴더의 소유 앱을 `pgrep -x '<프로세스 이름>'`으로 확인한다. reverse-DNS 이름(`com.google.Chrome`)이면 `osascript -e 'application id "<번들 ID>" is running'`도 쓸 수 있다. 브라우저·Adobe·Electron 앱이 실행 중이면 그 캐시는 보류한다(I-20, I-21, I-26).
- **Chromium·Electron 앱**: 사용자 데이터 폴더의 `SingletonLock` 심볼릭 링크가 `<호스트>-<pid>`를 가리키면 `kill -0 <pid>`로 살아 있는지 확인한다.
- **열린 파일**: 현재 사용자의 열린 파일 목록을 한 번 받아(`lsof -nP -a -u "$(id -u)" -Fn`) 각 후보 경로로 시작하는 항목(파일 디스크립터나 작업 디렉터리)이 있는지 본다. `lsof +D`는 큰 폴더에서 느리므로 작은 폴더에만 쓴다. 모든 빌드 산출물에 적용한다(I-51, I-52).
- **전용 규칙 우선**: 브라우저 캐시처럼 전용 판정 규칙이 있는 폴더는 상위 폴더 단위 일반 정리(예: `~/Library/Caches/Google` 통째로)로 우회하지 않는다(I-39).

## 나이 판정

- 폴더의 나이는 폴더 자신의 수정 시각이 아니라 **안쪽 모든 항목** 기준이다. `/usr/bin/find -P "$dir" -xdev -newermt '<N> days ago' -print -quit`에 결과가 하나라도 있으면 최근 활동으로 본다. 읽을 수 없는 하위 폴더가 있거나 검사가 끝나지 않으면 최근 활동으로 본다(I-46, I-47).
- 기본 기준: 임시 파일·로그·크래시 리포트 7일, 앱이 남긴 잔여 데이터·저장된 앱 상태(Saved Application State)·메일 첨부 30일, 프로젝트 산출물 7일.
- 재부팅 때마다 비워지는 임시 폴더에는 일 단위 기준을 적용하지 않는다. 대부분 항목이 기준에 걸리지 않아 영원히 정리되지 않는다(I-76).

## 후보 유형

| 유형 | 후보가 되는 조건 |
| --- | --- |
| 앱 캐시 | `~/Library/Caches`의 개별 하위 항목 가운데 앱과 용도를 확인할 수 있고, 앱을 종료한 뒤 다시 생성할 수 있는 캐시. 실행 여부를 판별하기 어렵거나 큰 모델·SDK·오프라인 데이터를 다시 내려받아야 하면 검토 항목으로 표시한다. 상위 캐시 폴더는 보존한다. |
| 오래된 로그·임시 파일 | `~/Library/Logs`의 회전 로그처럼 용도와 종료를 확인한 파일부터 본다. 임시 파일은 요청한 경로에서 만든 앱을 식별할 수 있는 항목만 후보로 삼는다. 현재 쓰는 로그, 진행 중인 다운로드, 세션 복구 파일은 건너뛴다. |
| 설치 파일 | `.dmg`, `.pkg`, `.mpkg`, `.iso`, `.xip`는 출처와 함께 후보로 표시한다. ZIP은 `zipinfo -1 "$f" \| head -50` 목록에 `.app`, `.pkg`, `.dmg`, `.xip` 항목이 있을 때만 설치 파일로 분류하고, 읽을 수 없거나 손상된 ZIP은 후보로 삼지 않는다. `hdiutil info`로 마운트 중인 이미지와 진행 중인 다운로드는 보존한다. 기본 선택하지 않는다. 찾는 위치는 아래 [설치 파일 위치](#설치-파일-위치)를 따른다. |
| 프로젝트 산출물 | 매니페스트·락 파일·빌드 설정과 대조해 다시 만들 수 있는 `node_modules`, `target`, `.build`, `build`, `dist` 등을 확인한다. Git 추적 파일, 중첩 저장소, 배포 키·원본 데이터가 들어 있으면 제외한다. 최근 7일 안에 하위 파일이나 폴더가 수정되었거나 활동을 검사할 수 없으면 건너뛴다. 오프라인 재빌드와 의존성 재다운로드 비용을 구분한다. |
| 제거한 앱의 잔여 파일 | 범위는 `~/Library/Caches`, `~/Library/Logs`, `~/Library/Saved Application State`의 개별 항목뿐이다. 아래를 모두 만족해야 한다. ① 보호 목록과 비밀 관련 이름(ssh, gpg, keychain, password, 1password 등)에 해당하지 않는다. ② `/Applications`, `~/Applications`, Homebrew Caskroom, Setapp에 설치되어 있지 않다. ③ `mdfind "kMDItemCFBundleIdentifier == '<번들 ID>'"` 결과가 비어 있다(실패하거나 시간 초과되면 설치된 것으로 본다). ④ 안쪽 모든 항목이 30일 이상 바뀌지 않았다. 이름이 비슷하다는 이유만으로 앱 지원 파일, 컨테이너, 환경설정 또는 공유 데이터를 정리 후보로 선택하지 않는다. |
| 대용량·오래된 개인 파일 | 위치와 크기를 미리보기에 표시하고 보존·이동·휴지통 여부는 사용자 선택을 따른다. |
| 개발 도구 데이터 | Docker 이미지, 가상머신, IDE 버전별 캐시, Xcode DeviceSupport, 패키지 매니저 캐시, 런타임 버전. 폴더를 직접 지우지 않고 [개발 도구 가이드](dev-tools.md)의 판단 기준과 도구 명령을 따른다. |
| 중단된 다운로드 | `.crdownload`, `.download`, `.part` 가운데 두 번 확인해도 크기와 수정 시각이 변하지 않은 파일. 받던 파일이 무엇인지 알 수 없으면 사용자 판단 항목으로 표시한다. |

## 설치 파일 위치

아래 위치에서 깊이 2까지 일반 파일만 찾는다(`/usr/bin/find -P "$dir" -maxdepth 2 -type f`). 권한 오류가 난 폴더는 그 폴더만 건너뛴다.

- `~/Downloads`, `~/Desktop`, `~/Documents`, `~/Public`, `~/Library/Downloads`, `/Users/Shared`(현재 사용자 소유 파일만)
- `~/Library/Caches/Homebrew`(파일명 앞의 sha256 접두사는 표시할 때 떼고 보여 준다. `brew cleanup`으로 정리하는 편이 낫다)
- `~/Library/Containers/com.apple.mail/Data/Library/Mail Downloads`
- `~/Library/Application Support/Telegram Desktop`, `~/Downloads/Telegram Desktop`
- `~/Library/Mobile Documents/com~apple~CloudDocs/Downloads`: iCloud 파일은 다운로드가 필요할 수 있으므로 메타데이터만 보고, ZIP 내용 검사가 오래 걸리면 건너뛴다. 휴지통으로 보내면 다른 기기에서도 사라진다고 알린다.

## 빌드 산출물 증거

프로젝트 산출물은 산출물 폴더의 부모에 매니페스트(`package.json`, `Cargo.toml`, `build.gradle(.kts)`, `pom.xml`, `Package.swift`, `pyproject.toml`, `go.mod` 등)가 있는지 먼저 확인한다. 매니페스트가 없으면 자동으로 후보에 넣지 않고 내용을 확인해 분류한다. 산출물을 찾으면 그 안으로 더 내려가지 않는다. 예를 들어 `node_modules` 안의 `dist`를 따로 세지 않는다.

이름이 흔한 산출물은 이름에 맞는 증거가 있어야 한다.

| 이름 | 필요한 증거 |
| --- | --- |
| `target` | 부모에 `Cargo.toml` 또는 `pom.xml`, 또는 안에 `.rustc_info.json` |
| `.build` | 부모에 `Package.swift`, 또는 안에 `workspace-state.json`·`build.db` |
| `venv`, `.venv` | 안에 `pyvenv.cfg` |
| `node_modules` | 부모의 lockfile과 안의 설치 기록이 짝을 이룬다: `package-lock.json`↔`.package-lock.json`, `pnpm-lock.yaml`↔`.modules.yaml`, `yarn.lock`↔`.yarn-integrity`·`.yarn-state.yml`. 설치 기록보다 새로 바뀐 파일이 있으면(`.cache` 제외) 직접 수정한 의존성일 수 있으므로 보호한다. |
| `DerivedData` | 프로젝트 안에 있고 `info.plist` 또는 `Build` 폴더가 있다 |
| `vendor` | 부모에 `composer.json`(PHP)일 때만. Go·Ruby의 `vendor`는 소스 일부일 수 있어 보호한다. |
| `bin`, `obj` | .NET 프로젝트(`*.csproj`, `*.sln`)일 때만 |

산출물 안에 `.git`이나 `*-keypair.json` 같은 키 파일이 있으면 보호한다. 산출물의 실제 경로(`pwd -P`)가 사용자가 지정한 검색 루트 안에 있어야 한다.

Git 프로젝트에서는 프로젝트 루트 기준 상대 경로로 `git --literal-pathspecs -C "$project" ls-files -z --cached -- "$relative_path"`를 실행해 추적 파일을 확인한다. 추적 파일이 없다는 사실과 `.gitignore`만으로 재생성 가능하다고 판단하지 않는다. 최근 활동을 확인할 때는 `/usr/bin/find -P "$path" -xdev -newermt '7 days ago' -print0`처럼 산출물 안의 수정 시각도 검사한다. 결과가 있거나 오류가 발생하면 산출물을 건너뛴다.

분류, 경로 보호, 미리보기, 실행 직전 대상 재확인은 [Mole 정리 설계](https://github.com/tw93/Mole#safety)에서 가져온 원칙이다.
