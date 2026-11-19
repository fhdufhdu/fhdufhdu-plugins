# 개발 도구와 대용량 앱 데이터

개발자 Mac에서는 `~/Library/Containers`, `~/Library/Caches`, `~/Library/Application Support`, 홈 폴더의 도구 캐시가 사용량의 대부분을 차지하는 경우가 많다. 이 항목들은 폴더를 직접 지우기보다 **도구가 제공하는 정리 명령**을 먼저 쓴다. 도구 명령은 내부 참조를 함께 정리하고, 어떤 데이터가 사용 중인지 알고 있기 때문이다.

정리 명령은 휴지통을 거치지 않고 바로 삭제되므로, 미리보기에 "즉시 삭제(되돌릴 수 없음)"라고 표시하고 사용자 승인을 받는다. 실행 전에 해당 도구 프로세스가 작업 중인지 `pgrep -lf`로 확인한다.

## 위치별 판단

| 위치 | 판단 | 정리 방법 |
| --- | --- | --- |
| `~/Library/Containers/com.docker.docker` | 폴더나 `Docker.raw`를 직접 지우지 않는다. 모든 이미지·볼륨이 사라진다. | `docker system df`로 회수 가능량을 보고, 승인 후 `docker system prune -a -f`(사용하지 않는 이미지·중지된 컨테이너·빌드 캐시). 볼륨은 데이터가 있을 수 있어 `--volumes`는 별도 승인을 받는다. 실제 회수량은 `docker system df`의 RECLAIMABLE보다 클 수 있다. |
| `~/Library/Containers/com.utmapp.UTM`, Parallels, VMware | 가상머신 디스크다. 앱 데이터이므로 후보로 표시만 하고, 삭제는 사용자가 VM 이름을 지정했을 때 앱 안에서 하도록 안내한다. | UTM 앱에서 VM 삭제, 또는 사용자가 지정한 `.utm` 번들을 휴지통으로. |
| `~/Library/Caches/JetBrains/<제품><버전>` | 설치된 IDE 버전(`/Applications/*.app/Contents/Info.plist`의 `CFBundleShortVersionString`)보다 오래된 버전의 캐시는 안전한 후보다. 현재 버전 캐시는 지우면 인덱스를 다시 만드는 비용이 크다. | 개별 버전 폴더를 휴지통으로. `IntelliJServer`·`*Client`(원격 개발)는 최근 수정이 없고 프로세스가 없을 때 후보. `~/Library/Application Support/JetBrains`는 설정이므로 보호. |
| `~/Library/Developer/Xcode/DerivedData` | 재생성 가능. Xcode가 실행 중이 아닐 때. | 휴지통으로. |
| `~/Library/Developer/Xcode/iOS DeviceSupport/<기기 버전>` | 기기를 다시 연결하면 재생성된다. 기기당 수 GB. | 개별 버전 폴더를 휴지통으로. |
| `~/Library/Developer/CoreSimulator` | 시뮬레이터 데이터. | `xcrun simctl delete unavailable`. 개별 기기 삭제는 사용자 승인. |
| `~/Library/Caches/Homebrew` | 재다운로드 가능. | `brew cleanup -s` 또는 폴더를 휴지통으로. |
| `~/Library/Caches/go-build`, `~/Library/Caches/pnpm`, `node-gyp`, `~/.npm/_cacache`, `~/.cache/uv`, `~/.cache/pip` | 패키지 매니저 캐시. 재다운로드 비용만 있다. | `go clean -cache`, `pnpm store prune`, `npm cache clean --force`, `uv cache clean`, 또는 폴더를 휴지통으로. |
| `~/.gradle/caches`, `~/.m2/repository` | 의존성 캐시. 지우면 모든 Gradle·Maven 프로젝트가 다음 빌드에서 재다운로드한다. 실행 중인 데몬이 있으면 `./gradlew --stop` 후. | 검토 항목. 오래된 `~/.gradle/caches/<버전>`·`~/.gradle/wrapper/dists/<오래된 버전>`부터. |
| `~/.rustup/toolchains` | 사용하지 않는 툴체인. | `rustup toolchain list` 확인 후 `rustup toolchain uninstall <이름>`. |
| `~/.nvm/versions/node`, `~/.sdkman/candidates`, `~/.pyenv/versions` | 런타임 버전. 프로젝트가 고정한 버전일 수 있다. | 검토 항목. 사용자가 버전을 지정하면 각 도구의 uninstall 명령. |
| `~/.cache/huggingface`, `~/.ollama/models` | 모델 파일. 재다운로드 비용이 크다. | 검토 항목. |
| 프로젝트의 Rust `target` | 최근 빌드한 프로젝트라도 크기가 수십 GB가 될 수 있다. 최근 수정으로 자동 판정에서 제외되면 사용자에게 따로 묻는다. | 승인 후 프로젝트 루트에서 `cargo clean`(즉시 삭제). 다음 빌드는 전체 재컴파일이다. |

## 프로젝트 산출물 일괄 판정

여러 프로젝트를 한 번에 볼 때는 [scan-build-artifacts.sh](../scripts/scan-build-artifacts.sh)로 후보를 모은다. 스크립트는 읽기 전용이며, 판정 기준은 [후보 선별과 보호 규칙](candidates.md)의 프로젝트 산출물 항목과 같다.

```bash
scripts/scan-build-artifacts.sh ~/project/app-a ~/project/app-b
scripts/scan-build-artifacts.sh -d 14 -m 51200 ~/project   # 최근 14일, 50MB 이상
```

판정이 `NO_MANIFEST`인 항목은 내용을 열어 보고 분류한다.

- `00`~`ff` 해시 폴더로만 이루어진 `.cache/build` 같은 폴더는 Go 빌드 캐시로 보고 `.gitignore`(`git check-ignore -v`)를 확인한 뒤 재생성 가능 후보로 제시할 수 있다.
- 커밋 해시나 버전 이름이 붙은 하위 폴더가 여러 개 있는 `dist`는 배포 패키지 보관본일 수 있다. 사용자 판단 항목으로 두고 보존을 권장한다.

## 다운로드 중이거나 마운트된 파일

- `.crdownload`(Chrome), `.download`(Safari), `.part`(Firefox)는 진행 중인 다운로드일 수 있다. 크기와 수정 시각을 한 번 기록하고 잠시 뒤 다시 확인해 변화가 없을 때만 중단된 다운로드로 판단한다.
- `.dmg`는 `hdiutil info`의 `image-path`로 마운트 여부를 확인한다. 마운트 중이면 해당 장치를 `diskutil eject /dev/diskN`으로 꺼낸 뒤 처리한다. 꺼내기에 실패하면 건너뛴다.
