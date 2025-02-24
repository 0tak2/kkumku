# Changelog

모든 주요 변경점은 이 파일에 기록한다.

포맷은 [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)를 따르며,
[Semantic Versioning](https://semver.org/spec/v2.0.0.html)에 따라 버저닝한다.

## [Unreleased]

### Added

- EditView에서 키보드에 따라 bottom constraint 조정

### Changed

### Deprecated

### Removed

### Fixed

### Security

## [0.0.3] - 2025-01-26

### Changed

- 타겟을 아이폰 전용으로 변경
- 프로젝트 기본 언어를 한국어로 고정
- 꿈 추가/수정 뷰에서 꿈 본문 입력 영역이 자동으로 커지도록 개선

## [0.0.2] - 2025-01-22

### Changed

- Bug: EditView DatePicker 로케일 (#51)
- Bug: 앱이 백그라운드에서 포어그라운드로 전환되어도 EditView의 취침 시각, 기상 시각이 업데이트 되지 않음 (#52)

## [0.0.1] - 2025-01-22

### Added

- Feat: 전체 뷰 하이어아키 (#1)
- Feat: 새 꿈 (#2)
- Feat: 카드 리스트 조회, 상세조회 (#6)
- Feat: 검색 (#8)
- Feat: 검색 개선 (#12)
- Feat: 캘린더 보기 (#13)
- Feat: 설정 (#14)
- Feat: 알림 (#15)
- Design: 로고, 아이콘 (#19)
- Feat: ExploreView 개선 - 조회 결과 없는 경우 메시지 (#16)
- Feat: UserDefaults 접근 개선 #24
- Feat: 디자인 개선 #25
- Chore: Configs.plist 개선 (#28)
- Feat: 온보딩 페이지 (#31)
- Feat: 새 꿈 - 설정된 취침 시간 연동 (#32)
- Feat: 새 꿈 저장 후 탭바 Explore View로 이동 (#33)

### Fixed

- Fix: 설정 뷰 취침 시간과 기상 시간이 바뀌어 있는 문제 (#34)
- Fix: 새 꿈 추가 시, 캘린더 뷰에 반영 안됨 (#40)
- Fix: 특정 태그를 사용한 꿈이 모두 삭제되어도 태그가 남아있는 문제 (#45)

[unreleased]: https://github.com/0tak2/kkumku/compare/v0.0.3...HEAD
[0.0.3]: https://github.com/0tak2/kkumku/compare/v0.0.2...v0.0.3
[0.0.2]: https://github.com/0tak2/kkumku/compare/v0.0.1-revised...v0.0.2
[0.0.1]: https://github.com/0tak2/kkumku/releases/tag/v0.0.1-revised
