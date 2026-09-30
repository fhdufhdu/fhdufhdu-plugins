# Document Driven Dev

소프트웨어 변경을 단계별 문서와 태스크 명세로 계획하고, 구현 에이전트의 결과와 검증 근거를 관리하는 Codex/Claude 플러그인입니다. 기능 추가, 기존 서비스 통합, 마이그레이션, 리팩터링에서 사용할 수 있으며 특정 프로젝트나 기술 스택에 묶이지 않습니다.

## 설치

루트 [README](../../README.md)의 방법으로 `fhdufhdu/fhdufhdu-plugins` 마켓플레이스를 등록한 뒤 `document-driven-dev`를 설치합니다. 이미 등록했다면 마켓플레이스를 갱신하세요. Codex 앱의 Plugins 화면과 Claude Code의 플러그인 설치 흐름에서 선택할 수 있습니다.

Claude Code 세션:

```text
/plugin marketplace update fhdufhdu
/plugin install document-driven-dev@fhdufhdu
```

## 스킬과 사용 예시

스킬: `document-driven-dev:orchestrate`

```text
document-driven-dev:orchestrate 스킬로 현재 프로젝트에 기존 서비스의 검색 화면을 통합할 계획을 세워줘. 각 단계와 태스크를 문서로 저장해줘. 지금은 구현하지 마.
```

```text
document-driven-dev:orchestrate 스킬로 이 프로젝트의 알림 기능을 설계부터 구현과 검증까지 진행해줘. 구현 에이전트는 GPT 6 Luna medium을 사용해줘.
```

```text
document-driven-dev:orchestrate 스킬로 docs/workflows/notification/의 계획을 읽고 실제 코드와 대조한 뒤 남은 구현을 이어서 진행해줘.
```

목표와 포함·제외 범위, 대상 프로젝트, 원본 코드 또는 참고 자료가 있으면 함께 전달합니다. 모델을 지정하지 않으면 실행 환경의 기본 모델을 사용합니다. **서브에이전트의 reasoning effort는 기본 `medium`이며, 난이도에 따라 조정합니다.** 명확한 단순 작업은 `low`, 일반 구현은 `medium`, 복잡한 상호작용이나 원인 불명의 버그는 `high`를 기준으로 선택하고, 실제 설정과 조정 이유를 태스크 문서에 남깁니다. 사용자가 명시한 수준은 우선합니다.

하위 에이전트를 사용할 수 없는 환경에서는 같은 명세에 따라 현재 에이전트가 구현할 수 있으며, 특정 모델이나 설정이 필수인 요청에서는 해당 제약을 기록합니다.

## 실행 모드

- 계획 수립: 분석·요구사항·설계·계약·태스크·검증 계획을 문서로 작성합니다.
- 전체 진행: 계획 후 구현·검토·통합 검증·최종 보고까지 수행합니다.
- 이어 진행: 기존 문서와 실제 코드를 확인하고 남은 허용 작업을 진행합니다.

계획만 작성해달라는 요청으로 구현을 시작하지 않습니다. 스킬을 호출했다는 이유만으로 배포·병합·push 등 별도 외부 작업을 수행하지 않습니다.

## 산출물

프로젝트의 문서 관례 또는 사용자가 지정한 경로를 사용합니다. 기본 경로는 `docs/workflows/<작업-slug>/`입니다.

- `00-progress.md`: 전체 단계·태스크 상태와 다음 작업
- `01-discovery.md`, `02-requirements.md`: 현황과 요구사항
- `03-architecture.md`, `04-contracts.md`: 설계와 공통 인터페이스
- `05-task-index.md`, `tasks/Txx-spec.md`: 작업 순서와 태스크 명세
- `06-validation-plan.md`: 검증 방법과 완료 기준
- `results/Txx-result.md`: 실제 변경과 검증 결과
- `07-integration-review.md`, `08-final-report.md`: 통합 검토와 최종 상태
- `decisions.md`: 주요 결정과 변경 영향

진행 상태는 `00-progress.md`에서 관리합니다. 계획 완료와 구현 완료를 구분하고, 중단 후에는 문서뿐 아니라 실제 코드와 검증 결과를 확인해 재개합니다.
