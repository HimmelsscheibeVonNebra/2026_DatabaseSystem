# 3주차 SQLite SQL 실습

목표: 테이블 생성, 데이터 추가·수정·삭제, 조건 조회, 중복 제거, 정렬, 제약조건 오류를 직접 확인합니다.
모든 인물·이메일은 가상이며 대학 수강관리 상황을 단순화했습니다.

## 1. 시작하기

GitHub에서 저장소를 내려받은 뒤 `Codes/week03-01` 폴더의 `university.db`를 SQLite 실행 도구에서 여세요.
개별 파일을 받는 경우 DB 파일은 GitHub의 Download raw로 다운로드하세요.
SQLite 3.37.0 이상을 사용하세요. 다음 두 문장은 하나씩 실행합니다.

```sql
SELECT sqlite_version();
PRAGMA foreign_keys = ON;
```

이어서 `PRAGMA foreign_keys;`의 결과가 **1**인지 확인합니다.
외래 키 설정은 DB 파일에 영구 저장되지 않으므로 새 연결마다 켜야 합니다.
도구가 자동으로 트랜잭션을 시작한다면 먼저 해당 트랜잭션을 종료한 뒤 설정합니다.

SQLite CLI가 설치되어 있다면 이 폴더에서:

```sh
sqlite3 university.db
```

CLI 안에서 보기 설정 후 실습 파일을 읽을 수 있습니다.

```text
.headers on
.mode column
.read 01_select.sql
```

GUI 도구에서는 SQL 파일을 열어 실행할 블록만 선택하세요. `.read` 등 점으로 시작하는 명령은 CLI 전용입니다.

## 2. 실습 순서

| 파일 | 내용 | 실행 방법 |
|---|---|---|
| university.db | 준비된 샘플 DB | 이 파일을 열면 바로 시작 |
| 00_reset.sql | 스키마·데이터 초기화 | 처음에는 불필요. 복구할 때 전체 실행 |
| 01_select.sql | SELECT, WHERE, 별칭, AND/OR, IN, BETWEEN, LIKE, DISTINCT, ORDER BY, LIMIT, NULL | Q01~Q18을 한 블록씩 |
| 02_create_insert_update_delete.sql | CREATE, INSERT, UPDATE, DELETE, ROLLBACK | STEP 1부터 순서대로 |
| 03_errors.sql | PK, NOT NULL, UNIQUE, FK, CHECK, 자료형, 이름·문법 오류 | 반드시 E01~E08을 하나씩 |
| 04_exercises.sql | 직접 풀 문제 12개 | 주석 아래에 SQL 작성 |
| 05_expected_results.md | Q01~Q18의 전체 예상 결과 | 먼저 예측·실행한 뒤 비교 |

## 3. 데이터 사전

- `department` — 4행. department_id: 학과 번호(PK), name: 학과명, building: 건물, budget: 예산.
- `student` — 8행. student_id: 학번(PK), name: 이름, email: 중복 불가 이메일,
  department_id: 소속 학과(FK, 미정이면 NULL), entry_year: 입학 연도, active: 재학 여부(1=재학, 0=비재학).
- `course` — 8행. course_id: 과목 코드(PK), title: 과목명, credits: 학점, department_id: 개설 학과(FK).
- `enrollment` — 13행. student_id·course_id·semester: 복합 PK, grade: 성적(NULL=미확정).
- 학과 번호: 1=Computer Science, 2=Mathematics, 3=Business, 4=Physics.
- `practice_student`는 02 파일에서 생성합니다. 처음 DB에는 없습니다.

관계: department → student/course, student/course → enrollment.
오늘은 단일 테이블 조회에 집중합니다. 수강 데이터는 이후 JOIN·서브쿼리 실습에도 사용할 수 있습니다.

## 4. 실습 규칙과 복구

1. 실행 전에 예상 행 수와 값을 적습니다.
2. 각 조회는 정렬 조건까지 확인합니다. ORDER BY가 없으면 행 순서를 가정하지 않습니다.
3. 문자열은 작은따옴표로, NULL은 따옴표 없이 씁니다. NULL 검사는 IS NULL을 사용합니다.
4. UPDATE/DELETE는 같은 WHERE의 SELECT로 대상을 먼저 확인합니다.
5. 수정 연습은 practice_student에서 합니다. 원본 데이터를 바꾸면 예상 결과와 달라질 수 있습니다.
6. 03 파일은 오류 자체가 실습 결과입니다. 오류 원인과 수정 방법을 적습니다.

완전 초기화는 진행 중인 트랜잭션을 종료한 뒤 **수업용 DB에서만** `00_reset.sql`을 실행합니다.
이 파일은 5개 실습 테이블을 삭제하고 원본 4개를 다시 만듭니다. 제출할 SQL은 별도 저장하세요.
CLI에서는 `.read 00_reset.sql`을 실행합니다. 이후 02를 실행하면 practice_student도 다시 만들어집니다.

본 자료는 STRICT 테이블을 사용합니다. INTEGER 열에 'hello'처럼 변환할 수 없는 문자열을 넣으면 실패합니다.
숫자로 변환 가능한 문자열까지 모두 거부한다는 뜻은 아닙니다.

## 5. 제출

`학번_week03.sql`에 P01~P11 답안을 번호별로 적고, P12의 오류 원인과 수정문은 주석으로 작성하세요.
P09~P11은 02 실습을 마친 상태에서 순서대로 실행합니다. 다시 풀 때는 02부터 실행하세요.
