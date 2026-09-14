# 조회 예제 예상 결과

초기 DB 기준입니다. 행 순서는 SQL에 적힌 ORDER BY를 따릅니다.

## Q01 — 전체 학생 조회: 학번 순서로 8행

| student_id | name | email | department_id | entry_year | active |
| --- | --- | --- | --- | --- | --- |
| 1001 | Kim Minseo | minseo@example.edu | 1 | 2024 | 1 |
| 1002 | Lee Jihoon | jihoon@example.edu | 1 | 2023 | 1 |
| 1003 | Park Soyeon | soyeon@example.edu | 2 | 2024 | 1 |
| 1004 | Choi Junho | junho@example.edu | 3 | 2022 | 1 |
| 1005 | Jung Haeun | haeun@example.edu | 1 | 2022 | 1 |
| 1006 | Han Yujin | yujin@example.edu | 4 | 2023 | 1 |
| 1007 | Yoon Seojun | seojun@example.edu | 2 | 2021 | 0 |
| 1008 | Lim Chaewon | chaewon@example.edu | NULL | 2025 | 1 |

총 8행.

## Q02 — 필요한 열과 별칭: 학번·이름만 조회

| 학번 | 이름 |
| --- | --- |
| 1001 | Kim Minseo |
| 1002 | Lee Jihoon |
| 1003 | Park Soyeon |
| 1004 | Choi Junho |
| 1005 | Jung Haeun |
| 1006 | Han Yujin |
| 1007 | Yoon Seojun |
| 1008 | Lim Chaewon |

총 8행.

## Q03 — WHERE: 컴퓨터공학과(1) 학생

| student_id | name |
| --- | --- |
| 1001 | Kim Minseo |
| 1002 | Lee Jihoon |
| 1005 | Jung Haeun |

총 3행.

## Q04 — 비교: 2024년 이후 입학생

| student_id | name | entry_year |
| --- | --- | --- |
| 1001 | Kim Minseo | 2024 |
| 1003 | Park Soyeon | 2024 |
| 1008 | Lim Chaewon | 2025 |

총 3행.

## Q05 — AND: 컴퓨터공학과이면서 2023년 이후 입학

| student_id | name |
| --- | --- |
| 1001 | Kim Minseo |
| 1002 | Lee Jihoon |

총 2행.

## Q06 — 괄호·OR: 학과 1 또는 2이며 2024년 입학

| student_id | name |
| --- | --- |
| 1001 | Kim Minseo |
| 1003 | Park Soyeon |

총 2행.

## Q07 — IN: 수학과(2) 또는 물리학과(4)

| student_id | name |
| --- | --- |
| 1003 | Park Soyeon |
| 1006 | Han Yujin |
| 1007 | Yoon Seojun |

총 3행.

## Q08 — BETWEEN: 2022~2023년 입학 (양 끝 포함)

| student_id | name | entry_year |
| --- | --- | --- |
| 1002 | Lee Jihoon | 2023 |
| 1004 | Choi Junho | 2022 |
| 1005 | Jung Haeun | 2022 |
| 1006 | Han Yujin | 2023 |

총 4행.

## Q09 — LIKE: Kim으로 시작하는 이름 (%는 0개 이상의 문자)

| student_id | name |
| --- | --- |
| 1001 | Kim Minseo |

총 1행.

## Q10 — LIKE: CS 다음 정확히 세 글자인 과목 코드 (_는 문자 한 개)

| course_id | title |
| --- | --- |
| CS101 | Introduction to Programming |
| CS202 | Data Structures |
| CS301 | Database Systems |
| CS401 | Operating Systems |

총 4행.

## Q11 — DISTINCT: 입학 연도 중복 제거

| entry_year |
| --- |
| 2021 |
| 2022 |
| 2023 |
| 2024 |
| 2025 |

총 5행.

## Q12 — ORDER BY: 최신 입학 연도 우선, 같은 연도는 학번 오름차순

| student_id | name | entry_year |
| --- | --- | --- |
| 1008 | Lim Chaewon | 2025 |
| 1001 | Kim Minseo | 2024 |
| 1003 | Park Soyeon | 2024 |
| 1002 | Lee Jihoon | 2023 |
| 1006 | Han Yujin | 2023 |
| 1004 | Choi Junho | 2022 |
| 1005 | Jung Haeun | 2022 |
| 1007 | Yoon Seojun | 2021 |

총 8행.

## Q13 — LIMIT: 위 정렬의 처음 3명

| student_id | name | entry_year |
| --- | --- | --- |
| 1008 | Lim Chaewon | 2025 |
| 1001 | Kim Minseo | 2024 |
| 1003 | Park Soyeon | 2024 |

총 3행.

## Q14 — 계산식: 과목별 주당 수업시간(1학점=50분 가정)

| course_id | credits | weekly_minutes |
| --- | --- | --- |
| BA210 | 2 | 100 |
| CS101 | 3 | 150 |
| CS202 | 3 | 150 |
| CS301 | 3 | 150 |
| CS401 | 3 | 150 |
| MA101 | 4 | 200 |
| MA220 | 3 | 150 |
| PH101 | 3 | 150 |

총 8행.

## Q15 — NULL 맛보기: 소속 학과가 없는 학생

| student_id | name |
| --- | --- |
| 1008 | Lim Chaewon |

총 1행.

## Q16 — NULL 비교 실수: 오류는 없지만 0행. Q15와 비교

| student_id | name |
| --- | --- |


총 0행.

## Q17 — 부정 조건: 현재 재학하지 않는 학생

| student_id | name |
| --- | --- |
| 1007 | Yoon Seojun |

총 1행.

## Q18 — 조건과 정렬 조합: 3학점 이상 과목, 학점 내림차순·코드 오름차순

| course_id | title | credits |
| --- | --- | --- |
| MA101 | Calculus | 4 |
| CS101 | Introduction to Programming | 3 |
| CS202 | Data Structures | 3 |
| CS301 | Database Systems | 3 |
| CS401 | Operating Systems | 3 |
| MA220 | Discrete Mathematics | 3 |
| PH101 | General Physics | 3 |

총 7행.
