# KUST 운영 인수인계

- 공식 저장소: https://github.com/KUST-Official/KUST
- 기본 브랜치: `v2`
- Firebase 프로젝트: `kust-88683`
- 동아리 Firebase 관리자: `kust1978office@gmail.com`
- 동아리 GitHub Organization 관리자: `kust1978office`

## 실행 및 웹 배포

```sh
git clone https://github.com/KUST-Official/KUST.git
cd KUST
flutter pub get
flutter run -d chrome
flutter build web --release
npx -y firebase-tools@latest login
npx -y firebase-tools@latest deploy --only hosting --project kust-88683
```

배포 전 로그인한 계정과 대상 프로젝트를 확인하세요. `firebase.json`의 웹 배포 경로는 `build/web`입니다.

## 공지 푸시 알림

2026-09-19에 앱에 포함되어 있던 서비스 계정 개인키를 Google Cloud에서 폐기했습니다. 공지 푸시 발송은 중단되어 있으며 공지 작성·조회 기능은 유지합니다.

푸시를 다시 사용하려면 서버에서 관리자 권한을 검증한 뒤 Firebase Admin SDK로 발송하도록 구현해야 합니다. 서비스 계정 개인키를 Flutter 코드, 웹 파일 또는 저장소에 넣지 마세요.

과거 커밋과 과거 브랜치에는 폐기된 키가 남아 있습니다. 현재 수정은 Git 기록을 재작성하지 않습니다. 기존 웹 캐시나 설치된 앱의 키도 폐기로 인해 사용할 수 없습니다.

## 개인 개발본과 운영 환경

`kingbeanstone/KUST-personal`의 현재 `v2` 브랜치는 별도 Firebase 프로젝트 `kust-personal-kingbeanstone`으로 분리했습니다. 개인 테스트 PWA 주소는 https://kust-personal-kingbeanstone.web.app 입니다. 익명화한 자료의 일회성 복사본이며 운영 데이터와 자동 동기화하지 않습니다. 개인 저장소의 과거 브랜치/태그에는 운영 설정이 남아 있으므로 그대로 실행·배포하지 마세요. 서버는 분리됐지만 개인 테스트 프로젝트는 승인받은 기존 결제 계정을 공유합니다.

## 아직 남은 운영 확인

- 결제 계정·카드 정리 (이번 작업에서 변경하지 않음)
- 동아리 담당자 환경에서 실행·업로드·배포 확인
- 확인 완료 후 기존 개인 계정 권한 축소 여부 결정
- 공용 계정의 복구 수단과 2단계 인증 인수 확인
