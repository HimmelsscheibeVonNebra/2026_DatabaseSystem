# SQLite Parser 소스 분석 · 별도 자료 v02

3-tier 웹 실습과 분리한 SQLite 내부 소스 분석 자료입니다. 웹 실습의 필수 선행 작업이나 제출물에 포함하지 않습니다.

## 실행 준비

Python 3.10 이상과 C 컴파일러 cc가 필요합니다. macOS, Linux, Windows WSL 환경에서 실행합니다. 별도 pip 패키지는 필요하지 않습니다.

```sh
python3 setup.py
```

고정 버전 SQLite 3.53.4의 공식 아카이브를 동봉했습니다. setup.py가 해시를 검증하고 build/student_lab, build/token_probe 및 분석용 vendor 소스를 생성합니다. 처음 실행할 때 data/week3.db에 샘플 데이터를 만듭니다. 기존 DB는 보존하지만 build와 추출된 vendor 소스는 다시 생성하므로 수정 전 복사하세요.

웹 실습은 Python에 포함된 SQLite를 사용합니다. 이 분석 도구는 별도로 컴파일한 3.53.4를 사용하므로 웹 서버의 실제 실행 trace라고 해석하지 않습니다. student_lab.c에는 관찰 도구와 기존 C CRUD 예제가 함께 있지만, 이 자료에서는 parser 명령과 토큰 관찰을 사용합니다.

## 학습 순서

토큰 관찰, SELECT 문법 규칙, 매개변수 번호 결정, 이름 해석 오류, 바인딩 값 저장의 순서로 진행합니다. 수업 시간은 별도로 배정합니다.

## 실제 Parser와 토크나이저 관찰

```sh
./build/token_probe
./build/token_probe "SELECT '한글';"
./build/student_lab data/week3.db parser ok
./build/student_lab data/week3.db parser syntax
./build/student_lab data/week3.db parser name
```

`token_probe`는 예제에서 흉내 낸 토크나이저가 아니라 **동일 SQLite 3.53.4의 sqlite3GetToken**을 호출합니다. 실제 위치·길이·토큰 종류를 출력하며 SQL을 실행하지 않습니다. 관찰을 위해 `sqlite3.c`를 같은 번역 단위에 포함합니다. 내부 함수는 안정적인 공개 API가 아니므로 일반 애플리케이션에 이 설계를 사용하지 마세요. UTF-8 `'한글'`은 따옴표까지 8바이트입니다.

`parser` 명령은 `SQLITE_DEBUG`와 `PRAGMA parser_trace=ON`으로 실제 SQLite Parser의 Shift/Reduce 출력을 켭니다. 스키마 로딩을 먼저 완료한 다음 고정 SELECT를 준비합니다. 대상 SELECT에 대해 `sqlite3_step`을 호출하지 않습니다.

| 모드 | 준비하는 SQL | 예상 결과 |
| --- | --- | --- |
| ok | `SELECT name FROM student WHERE id = ?1;` | `PREPARE rc=0 parameters=1` |
| syntax | `SELECT FROM student;` | 문법 오류, 종료 코드 1 |
| name | `SELECT missing_column FROM student;` | 이름 해석 오류, 종료 코드 1 |

`syntax`와 `name`의 종료 코드 1은 실험의 예상 결과입니다. 프로그램 설치 실패가 아닙니다. 전체 실행 로그는 `examples/`에 있습니다. stdout과 stderr를 따로 캡처하여 기록했으므로 로그 파일의 두 섹션 사이에서 정확한 출력 교차 순서를 추론하지 마세요.

### 읽을 소스와 순서

빌드에는 공식 amalgamation을 사용하고, 분석은 같은 릴리스의 분리된 소스를 읽습니다. 아래 경로는 `vendor/sqlite-src-3530400/` 기준입니다. 행 번호는 다른 버전에서는 달라집니다.

| 순서 | 위치 | 질문 |
| --- | --- | --- |
| 1 | `src/prepare.c:937`, `:950` | 공개 API가 어떤 내부 함수를 호출하는가? |
| 2 | `src/prepare.c:836`, `:861`, `:682`, `:779`, `:786` | RunParser까지 어떻게 이어지는가? |
| 3 | `src/tokenize.c:273`, `:504-508` | ?1의 토큰 종류와 길이는? |
| 4 | `src/tokenize.c:600`, `:646`, `:711-715` | 토큰을 누가 Parser에 전달하는가? |
| 5 | `src/parse.y:651-655` | SELECT 문법과 의미 동작은 무엇인가? |
| 6 | `src/parse.y:1204-1208` | VARIABLE 표현식은 어떤 함수를 호출하는가? |
| 7 | `src/expr.c:1317`, `:1328-1377` | ?, ?NNN, 이름 매개변수의 번호는? |
| 8 | `src/vdbeapi.c:1788-1798`, `:1702-1738` | 실제 바인딩 값은 어디에 저장되는가? |

Lemon 관련 파일은 `tool/lemon.c`, `tool/lempar.c`입니다. `src/parse.y`가 문법 원본이고 `parse.c`, `parse.h`는 생성물입니다. 공식 amalgamation에는 생성된 Parser가 이미 포함되어 있으므로 이 실습에서 Lemon을 다시 빌드할 필요는 없습니다.

### 확인 질문과 해설

1. **?1은 언제 처리되나?** prepare 중 tokenize.c에서 TK_VARIABLE이 되고, parse.y의 의미 동작이 expr.c를 호출하여 번호를 정합니다.
2. **값 2001은 언제 전달되나?** prepare 후 `sqlite3_bind_int(stmt,1,2001)`로 전달되어 `aVar[0]`에 저장됩니다. SQL 문자열에 2001을 끼워 넣는 것이 아닙니다.
3. **prepare는 문법만 검사하나?** 아닙니다. 이름 해석과 컴파일도 포함되므로 문법이 맞아도 존재하지 않는 열 때문에 실패할 수 있습니다.
4. **prepare는 항상 딱 한 번인가?** 아닙니다. v2 문장은 스키마 변화나 일부 실행 계획 관련 바인딩 변화에 따라 step 중 자동 재준비될 수 있습니다.
5. **parse.y는 트리만 만드는가?** Expr와 Select 구조를 만드는 규칙이 있고 컴파일 동작을 호출하는 규칙도 있습니다. 파싱과 코드 생성의 연결을 함께 봐야 합니다.
6. **bind_parameter_count는 등장 횟수인가?** 가장 큰 매개변수 인덱스입니다. ?5처럼 구멍이 있으면 등장 횟수와 다릅니다. 예제는 연속 번호만 사용합니다.


## 분석 과제

1. ?1 토큰을 인식하는 함수와 문법 규칙을 찾습니다.
2. 매개변수 번호를 정하는 시점과 값을 바인딩하는 시점을 설명합니다.
3. 문법 오류와 이름 해석 오류를 각각 재현하고 메시지를 비교합니다.
4. prepare에서 RunParser까지의 호출 경로와 함수별 역할을 적습니다.

제출: 학번_parser.md. 토큰 출력, 오류 두 종류, 호출 경로와 설명을 포함합니다. 3-tier 실습 제출 파일과 별도로 제출합니다.

검증: `python3 -m unittest discover -s tests -v`
