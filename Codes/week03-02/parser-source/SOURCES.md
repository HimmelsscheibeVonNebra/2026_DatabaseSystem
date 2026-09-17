# 출처와 고정 버전

수업 자료 작성 기준일: 2026-09-05.

## 사용자 제공 자료

- 범위: `output/course-decks/calendar-versions/database-calendar-v13-section1.pptx`의 2026년 9월 18일 week3-2. App CRUD·Binding, Source Parser.
- 디자인: `output/course-decks/week1-database-introduction-template.otp`의 오렌지색 커버, 구분, 본문 마스터. 28cm × 15.75cm.
- 실행 예제 및 실습용 데이터는 이 수업용으로 작성했습니다. 학생 이름과 기록은 가상입니다.

## SQLite 3.53.4

공식 안정 릴리스 날짜: 2026-07-24.

- [릴리스 기록](https://www.sqlite.org/releaselog/3_53_4.html)
- [공식 다운로드](https://www.sqlite.org/download.html)
- [공식 변경 이력](https://www.sqlite.org/changes.html)
- [SQLite 라이선스](https://www.sqlite.org/copyright.html): SQLite 소스는 public domain입니다. 원본 아카이브의 라이선스/헤더를 보존했습니다.

실제 실행 코드의 `sqlite3_sourceid()`:

```text
2026-07-24 19:02:57 bf7c7f30031888f4e796e429ab3978879485813aaca6f641c7b33e4e09459bcc
```

| 원본 아카이브 | SHA3-256 |
| --- | --- |
| [sqlite-amalgamation-3530400.zip](https://www.sqlite.org/2026/sqlite-amalgamation-3530400.zip) | `628a44cfe82c66aed1ccbbe85a562d2e33ebe64b3288981ed76285612227934e` |
| [sqlite-src-3530400.zip](https://www.sqlite.org/2026/sqlite-src-3530400.zip) | `b834d474b9b393d85a9e3ee4cc11f1329e007e9376a424ee740796f5c4bda3a8` |

빌드 옵션: `-O0 -g -DSQLITE_DEBUG -DSQLITE_THREADSAFE=1 -DSQLITE_OMIT_LOAD_EXTENSION=1`. 공식 안정 소스를 수정하지 않았고 관찰을 위한 디버그 옵션만 켰습니다. 시스템 설치 SQLite나 Python 내장 sqlite3는 실행 엔진으로 사용하지 않습니다.

## API와 아키텍처 문서

- [C API 소개와 문장 수명](https://www.sqlite.org/cintro.html)
- [prepare와 자동 재준비](https://www.sqlite.org/c3ref/prepare.html)
- [바인딩, 인덱스, 문자열 수명](https://www.sqlite.org/c3ref/bind_blob.html)
- [reset](https://www.sqlite.org/c3ref/reset.html)
- [clear_bindings](https://www.sqlite.org/c3ref/clear_bindings.html)
- [매개변수 최대 인덱스](https://www.sqlite.org/c3ref/bind_parameter_count.html)
- [Lemon Parser 생성기](https://www.sqlite.org/lemon.html)
- [SQLite 아키텍처](https://www.sqlite.org/arch.html)
- [parser_trace PRAGMA](https://www.sqlite.org/pragma.html#pragma_parser_trace)

소스코드 행 번호와 발췌는 `vendor/archives/sqlite-src-3530400.zip`에서 직접 확인했습니다. README의 소스 읽기 표를 참고하세요. 일부 슬라이드는 핵심 줄만 발췌했고 생략 여부를 명시했습니다. 실행 로그는 동봉 예제의 실제 결과이며 임의로 만든 출력이 아닙니다.
