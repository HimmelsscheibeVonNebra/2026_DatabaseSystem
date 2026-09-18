# Week 3-2 · 3-tier 학생 관리 실습 v04

브라우저에서 학생 정보를 등록·조회·수정·삭제하며 화면, 애플리케이션, 데이터 계층의 역할을 확인합니다. 1분반 9/18(금), 2분반 9/17(목)용 90분 실습입니다. 모든 학생 데이터는 가상입니다.

## 시작하기

Python 3.10 이상(SQLite 모듈 포함)이 필요합니다. 별도 pip 패키지, 컴파일러, DB 서버는 필요하지 않습니다.

1. ZIP을 풀고 해당 폴더에서 터미널을 엽니다.
2. macOS/Linux는 `python3 server.py`, Windows는 `py -3 server.py`를 실행합니다.
3. 브라우저에서 http://127.0.0.1:8765/ 를 엽니다.
4. 초기 학생 5명과 화면에 표시된 SQLite 버전을 확인합니다. 종료는 터미널에서 Ctrl+C입니다.

포트가 사용 중이면 `python3 server.py --port 8766`으로 실행하고 주소도 8766으로 바꿉니다. Windows에서는 `python3` 대신 `py -3`을 사용합니다. `index.html`을 직접 열지 말고 서버 주소로 접속하세요.

첫 실행 때 `data/week3.db`를 만듭니다. 재시작은 기존 데이터를 보존합니다. 새로 연습하려면 서버를 종료한 뒤 `python3 server.py --db data/practice2.db`처럼 아직 없는 파일명을 지정하세요. 이전 주차의 DB와 기존 C 예제 DB는 사용하지 않습니다.

## 3-tier 구성

| 계층 | 구성 요소 | 담당 역할 |
|---|---|---|
| Presentation | 브라우저의 HTML·CSS·JavaScript | 입력을 받고 HTTP 요청 전송, 결과 표시 |
| Application | Python HTTP 서버와 서비스 | 요청 경로 처리, 입력 검증, CRUD 작업 선택 |
| Data | 데이터 접근 모듈과 SQLite DB | 고정 SQL 실행, 매개변수 바인딩, 제약조건·저장 |

브라우저와 서버는 HTTP/JSON으로 통신합니다. 서버가 Python `sqlite3` API를 통해 SQLite를 호출합니다. **논리적 3계층 예제**이며, SQLite 엔진은 Python 서버 프로세스 안에 임베디드되어 있습니다. 별도의 DB 서버 프로세스나 세 대의 컴퓨터를 사용하는 배포 구조는 아닙니다. 브라우저가 DB 파일을 직접 열거나 SQL을 보내지 않습니다.

이번 실습에서는 Python에 포함된 SQLite를 사용하므로 PC별 버전이 다를 수 있습니다. 별도 Parser 소스 분석 패키지는 SQLite 3.53.4를 고정해서 사용합니다. 두 실행 환경의 내부 함수나 추적 로그가 동일하다고 가정하지 않습니다.

## Python이 처음이라면

[Python 기초](PYTHON_PRIMER.md)를 먼저 읽고 `python3 python_basics.py`를 실행합니다. Windows에서는 `py -3 python_basics.py`입니다. 변수, dict·tuple, 함수, self, 예외, with를 실제 코드와 연결하며 파일 DB를 수정하지 않습니다.

## 수업 순서 · 90분

| 시간 | 활동 |
|---|---|
| 0–5분 | 환경 확인과 서버 실행 |
| 5–30분 | Python 필수 문법과 예제 실행 |
| 30–45분 | CRUD 실행과 HTTP 관찰 |
| 45–75분 | 등록 요청을 따라 애플리케이션 코드 읽기 |
| 75–85분 | 오류·롤백 확인과 코드 설명 |
| 85–90분 | 확인 문항 제출 |

[CODE_WALKTHROUGH.md](CODE_WALKTHROUGH.md)는 실제 코드 해설,
[WORKSHEET.md](WORKSHEET.md)는 학생 활동지입니다. 접두어 검색 수정은 수업 후 확장 과제로 제공합니다. SQLite 내부 Parser 분석은 별도 자료로 유지합니다.

## API 요약

| 작업 | 요청 | 본문 또는 조건 |
|---|---|---|
| 전체 조회 | GET /api/students | 없음 |
| 이름 검색 | GET /api/students?name=… | 정확히 일치, URL 인코딩 |
| 한 학생 조회 | GET /api/students/2001 | 없음 |
| 등록 | POST /api/students | id, name, dept_name, tot_cred |
| 학점 수정 | PATCH /api/students/2001 | tot_cred |
| 삭제 | DELETE /api/students/2001 | 없음 |

등록은 HTTP 201, 조회·수정·삭제는 200입니다. 잘못된 입력은 400, 없는 학생은 404, PK/FK 제약 위반은 409입니다. 학점 0~200 조건은 서버와 DB 양쪽에서 검사합니다. API 입력 검증이 먼저 적용되면 DB CHECK까지 도달하지 않습니다. 없는 학생의 수정·삭제는 SQL의 변경 행 수 0을 서버가 404로 변환한 결과입니다.

`dept_name: null`은 미정 학과, 문자열 `"NULL"`은 학과 이름으로 처리되어 FK 오류가 납니다. 허용 학과는 컴퓨터공학, 수학, 경영학입니다.

## 파일 안내

- `static/`: 화면과 요청 전송
- `server.py`, `service.py`: HTTP 처리와 입력 검증
- `repository.py`: 스키마·초기 데이터·SQL과 매개변수
- `CODE_WALKTHROUGH.md`: 실제 코드 발췌와 함수별 해설, 검색 수정 연습
- `WORKSHEET.md`: 학생용 활동과 제출 양식
- `tests/test_lab.py`: 임시 DB를 사용하는 자동 검증

검증 실행: `python3 -m unittest discover -s tests -v`

이 예제는 개인 PC의 로컬 수업용으로 실행합니다. 인증 기능은 포함하지 않습니다. SQL·매개변수를 응답에 넣는 기능은 수업 관찰용입니다. 화면에 표시하는 SQL 템플릿과 매개변수는 실제 저장 모듈이 실행에 사용한 값이며, SQLite 내부 C API trace를 재현한 것이 아닙니다.
