# 4주차 1차시 · JOIN과 집계 SQL

[강의 PDF · v03](../../Presentations/week04-01/week04-class01-sql-joins-aggregation-v03.pdf)에 사용하는 SQLite 예제입니다.
학생 5명, 과목 4개, 수강 5건으로 구성한 가상 데이터입니다.

## 파일

| 파일 | 내용 |
| --- | --- |
| `00_schema_data.sql` | 테이블 생성과 가상 데이터 입력 |
| `01_examples.sql` | Q01–Q24: JOIN, 집계, GROUP BY, HAVING 예제 |
| `02_exercises.sql` | E1–E3: 과목별 수강 인원, 성적 보고서, 80점 이상 과목 수 |
| `03_instructor_answers.sql` | E1–E3 정답 SQL |

## 실행

이 폴더에서 새 DB를 생성합니다. `week04.db`가 이미 있다면 다른 새 파일명을 사용합니다.

```sh
sqlite3 week04.db < 00_schema_data.sql
sqlite3 -header -column -nullvalue NULL week04.db
```

SQLite 프롬프트에서 예제 전체를 실행합니다.

```text
.read 01_examples.sql
```

DBeaver에서는 새 SQLite 연결을 만든 뒤 `00_schema_data.sql`을 전체 실행합니다.
그다음 `01_examples.sql`에서 원하는 SELECT를 선택해 실행합니다.
초기화 SQL은 DROP 문을 포함하지 않으므로 이미 테이블이 있는 DB에 재실행하지 않습니다.

## 데이터 읽기

- `student(id, name)`: 학생 정보. `id`가 기본 키입니다.
- `course(course_id, title, credits)`: 과목 정보. `course_id`가 기본 키입니다.
- `takes(student_id, course_id, score)`: 수강 정보. `(student_id, course_id)`가 복합 기본 키입니다.

김민지와 박지우는 각각 2과목을 수강합니다. 이서준은 1과목을 수강하지만 점수는 NULL입니다.
최하린과 정도윤은 수강 행이 없고, 경영통계 과목에는 수강자가 없습니다.

이전 week03 DB와 별도인 간략 모델이며 학기와 재수강은 생략했습니다.
평균 점수는 입력된 성적의 단순 평균입니다.
