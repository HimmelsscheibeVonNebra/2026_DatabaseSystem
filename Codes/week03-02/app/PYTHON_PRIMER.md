# 실습 코드를 읽기 위한 Python 기초

Python을 처음 접한다면 이 문서를 먼저 읽고 [코드 해설](CODE_WALKTHROUGH.md)로 넘어갑니다. 목표는 학생 등록 요청을 처리하는 코드를 읽고 작은 부분을 수정하는 것입니다. 문법을 모두 외울 필요는 없습니다.

## 1. 실행 위치와 언어 구분

압축을 푼 app 폴더 또는 실습 패키지 폴더에서 터미널을 엽니다.

```sh
python3 python_basics.py
```

Windows에서는 `py -3 python_basics.py`입니다. `python_basics.py`는 아래 문법 예제를 실행합니다. 마지막 DB 실험도 메모리 DB에서만 실행하므로 실습 DB 파일을 바꾸지 않습니다. 터미널의 `>>>`는 Python 대화형 모드입니다. 위 명령은 `>>>` 안이 아니라 셸 프롬프트에서 실행합니다. 대화형 모드를 종료하려면 `exit()`를 입력합니다.

| 파일 | 언어 | 실행 위치 |
|---|---|---|
| server.py, service.py, repository.py | Python | 서버 프로세스 |
| static/app.js | JavaScript | 브라우저 |
| static/index.html | HTML | 브라우저의 화면 구조 |
| SQL 문자열 | SQL | 서버가 SQLite에 전달 |

`const`, `async`, `await`, `fetch`는 이 예제의 JavaScript 코드에서 나옵니다. Python의 `def`, `self`, `None`과 구분하세요.

[전체 예상 출력](PYTHON_EXPECTED_OUTPUT.txt)과 실행 결과를 비교할 수 있습니다.

## 2. 변수, 문자열, 숫자, None

```python
student_id = 2001
name = "O'Brien"
credits = 12
dept = None
```

`=`는 오른쪽 값을 왼쪽 이름에 대입합니다. Python에서는 이 변수에 별도의 타입 선언을 쓰지 않습니다. 값에는 타입이 있습니다. 2001과 12는 int, 따옴표로 감싼 이름은 str입니다. `None`은 값이 없음을 나타내는 객체입니다. `"None"`이라는 문자열과 다릅니다.

```python
print(type(credits).__name__)  # int
print('12' + '1')              # 121
print(int('12') + 1)           # 13
print(f'학번 {student_id}: {credits}학점')
```

문자열끼리 `+`하면 이어 붙입니다. 숫자 계산은 정수로 변환한 뒤 합니다. f-string의 `{...}`에는 변수나 식의 값을 넣습니다. 이 예제에서는 안내·오류 메시지에 사용합니다. SQL 사용자 입력은 f-string에 끼워 넣지 않고 바인딩으로 전달합니다.

연결: `service.py`의 `integer()`가 숫자 12와 문자열 "12"를 구분합니다.

## 3. 들여쓰기, if, 비교

```python
if 0 <= credits <= 200:
    print('유효한 학점')
else:
    print('학점 범위 오류')
print('검사 종료')
```

콜론 `:` 뒤의 들여쓴 줄이 해당 블록입니다. 보통 공백 4칸을 쓰며 탭과 공백을 섞지 않습니다. 마지막 print는 들여쓰지 않았으므로 두 분기 중 무엇이 실행되어도 수행합니다. 잘못된 들여쓰기는 실행 오류나 다른 동작을 만들 수 있습니다.

- `=`: 대입, `==`: 값 비교, `!=`: 다름
- `and`: 두 조건 모두 참, `or`: 하나 이상 참, `not`: 참·거짓 반전
- `None` 검사는 `dept is None`, 값이 있으면 `dept is not None`
- `True`, `False`, `None`의 첫 글자는 대문자

연결: `service.py`의 `if type(value) is not int or not minimum <= value <= maximum`은 **정수가 아니거나 범위를 벗어나면 오류**라는 의미입니다. 정수가 아닌 경우 or의 뒤 조건을 평가하지 않는 단축 평가도 적용됩니다.

## 4. 딕셔너리: 이름으로 값 찾기

```python
body = {'id': 2001, 'name': "O'Brien", 'tot_cred': 12}
print(body['name'])             # O'Brien
print(body.get('email', '없음')) # 없음
body['tot_cred'] = 24
```

dict는 키와 값을 묶습니다. `body['name']`은 name 키의 값을 꺼냅니다. 없는 키를 대괄호로 읽으면 KeyError가 발생합니다. `get`은 키가 없을 때 기본값을 반환합니다. 키가 있고 값이 None인 경우에는 기본값 대신 None을 돌려줍니다.

연결: 서버가 요청 JSON을 읽으면 `body`가 dict가 되고 서비스가 `body['tot_cred']`를 읽습니다. 반환하는 `result`도 dict입니다. `result.update(ok=True)`는 `result['ok'] = True`처럼 키를 추가하거나 덮어씁니다.

## 5. 리스트와 튜플: 순서로 값 묶기

```python
rows = [{'id': 2001}, {'id': 2002}]  # 리스트 안에 딕셔너리
params = (24, 2001)                 # 튜플
print(params[0], params[1])         # 24 2001
one = (2001,)                       # 원소 하나인 튜플
```

리스트는 `[]`, 튜플은 보통 `()`와 쉼표로 표시합니다. 인덱스는 0부터 시작합니다. 리스트는 원소를 추가·교체할 수 있고 튜플은 만들어진 뒤 원소를 교체할 수 없습니다. 튜플 자체를 다시 변수에 대입하는 것은 가능합니다.

`(2001)`은 정수에 괄호만 씌운 식입니다. `(2001,)`처럼 쉼표를 붙여야 원소 하나인 튜플입니다. SQL 바인딩은 튜플뿐 아니라 리스트로도 가능하지만 이 실습은 주로 튜플을 사용합니다.

연결: `UPDATE student SET tot_cred = ? WHERE id = ?`에는 `(24, 2001)`을 전달합니다. `?` 순서와 튜플 순서를 맞춥니다.

## 6. 반복문과 리스트 컴프리헨션

```python
names = []
for row in rows:
    names.append(row['id'])
```

`for`는 rows의 원소를 하나씩 row에 넣고 들여쓴 블록을 실행합니다. append는 리스트 끝에 값을 추가합니다. 위 코드는 다음과 같이 짧게 쓸 수도 있습니다.

```python
names = [row['id'] for row in rows]
```

이 형태를 리스트 컴프리헨션이라고 부릅니다. 처음에는 긴 반복문으로 풀어 읽으면 됩니다.

연결: `[dict(row) for row in cursor.fetchall()]`은 조회 결과를 한 행씩 dict로 바꾸고 새 리스트에 담습니다.

## 7. 함수, 인자, 기본값, return

```python
def valid_credits(value, maximum=200):
    return type(value) is int and 0 <= value <= maximum

print(valid_credits(12))         # True
print(valid_credits(201))        # False
print(valid_credits(12, 10))     # False
```

`def`는 함수를 정의합니다. 정의만으로 함수 안의 코드가 실행되지는 않습니다. `valid_credits(12)`처럼 호출하면 12가 매개변수 value에 전달됩니다. 두 번째 인자를 생략하면 maximum의 기본값 200을 사용합니다.

`return`은 함수를 끝내고 호출한 곳으로 값을 돌려줍니다. `print`는 화면에 출력하는 함수입니다. 출력과 반환은 다른 일입니다. return을 쓰지 않고 끝난 함수는 None을 반환합니다.

연결: `execute(sql, params=(), write=False)`는 SQL은 필수로 받고, params와 write는 기본값을 가집니다. `execute(sql, values, True)`의 세 번째 값은 write에 대응합니다.

## 8. import와 시작 지점

```python
import json
from pathlib import Path
from repository import Repository
```

import는 다른 모듈에 있는 이름을 사용하도록 합니다. json, pathlib, sqlite3는 이 예제에서 사용하는 Python 표준 라이브러리입니다. repository는 같은 폴더의 repository.py입니다.

```python
if __name__ == '__main__':
    main()
```

파일을 직접 실행했을 때만 main을 호출하는 관용적인 시작 코드입니다. 다른 파일에서 이 모듈을 import하면 위 조건이 거짓이므로 main은 자동 호출되지 않습니다. import가 모든 코드를 실행하지 않는다는 뜻은 아닙니다. 이 조건 밖의 최상위 코드는 import 때도 실행될 수 있습니다.

연결: server.py의 마지막 부분은 명령행 옵션을 읽고 서버를 시작합니다. tests는 make_server를 import해서 테스트용 서버를 구성합니다.

## 9. 클래스, 객체, __init__, self

```python
class Student:
    def __init__(self, name):
        self.name = name

    def greeting(self):
        return f'학생: {self.name}'

first = Student('김민지')
second = Student('이준호')
print(first.greeting())  # 학생: 김민지
```

클래스는 상태와 동작을 묶는 정의입니다. first와 second는 각각 만들어진 객체입니다. `__init__`은 생성한 객체의 초기 상태를 설정합니다. `self.name`은 해당 객체에 저장하는 값입니다. 매개변수 name은 호출 중 받은 값이므로 서로 구분합니다.

`first.greeting()`을 호출하면 Python이 해당 객체 first를 self로 전달합니다. 일반적인 호출에서 self를 추가로 쓰지 않습니다. self는 예약어가 아니라 인스턴스 메서드의 첫 매개변수에 관례적으로 붙이는 이름입니다.

연결: `Repository(db_path)`는 경로를 `self.path`에 기억합니다. `Service(repository)`는 저장소를 `self.repository`에 저장하고 나중에 `self.repository.add(...)`를 호출합니다. 실제 SQLite 연결은 Repository 객체 생성 시점이 아니라 connect 호출에서 열립니다.

## 10. 예외: raise, try, except, finally

```python
try:
    credits = int('열둘')
except ValueError:
    print('정수로 바꿀 수 없습니다.')
finally:
    print('변환 시도 종료')
```

try 안에서 예외가 발생하면 해당 지점 이후의 남은 코드를 건너뛰고 맞는 except로 이동합니다. 처리한 뒤에는 계속 실행할 수 있습니다. finally는 정상 종료나 예외 처리 여부와 관계없이 마무리 코드를 실행할 때 사용합니다.

```python
class InputError(ValueError):
    pass
```

괄호 안의 ValueError를 상속해 오류 종류에 이름을 붙인 클래스입니다. pass는 아무 일도 하지 않는 문장이며, 빈 클래스·함수 본문을 문법적으로 채웁니다. `raise InputError('학점 오류')`는 오류를 발생시킵니다. return으로 정상 값을 돌려주는 것과 다릅니다.

연결: 서비스의 InputError는 server.py의 except에서 HTTP 400으로 바뀝니다. DB의 IntegrityError는 HTTP 409로 바뀝니다. 예외를 처리하지 않은 함수에서는 호출한 쪽으로 전파됩니다.

## 11. with: 정리 작업을 맡기는 블록

```python
from contextlib import closing
import sqlite3

with closing(sqlite3.connect(':memory:')) as db:
    with db:
        db.execute('CREATE TABLE sample(id INTEGER)')
        db.execute('INSERT INTO sample VALUES (?)', (1,))
```

`as db`는 with에서 사용할 객체를 db라는 이름으로 받습니다. with의 종료 동작은 **대상 객체가 정합니다**. 모든 with가 파일 닫기나 DB 커밋을 하는 것은 아닙니다.

현재 예제처럼 기본 설정으로 만든 SQLite 연결의 `with db`는 열린 트랜잭션을 정상 종료 시 커밋하고 예외 시 롤백합니다. `closing(...)`은 마지막에 연결을 닫습니다. DDL까지 항상 자동으로 하나의 트랜잭션으로 묶인다고 해석하지 않습니다.

저장소의 `with closing(self.connect()) as db, db:`는 위의 중첩 with처럼 바깥은 연결 해제, 안쪽은 트랜잭션 마무리를 담당합니다. 오른쪽 관리자가 먼저 종료됩니다. python_basics.py에서 첫 INSERT를 커밋한 뒤 두 번째 블록의 중복 PK 실패가 그 블록의 변경을 롤백하는지 확인하세요. 마지막 행 수는 1입니다.

## 12. JSON과 Python 값은 표기가 다릅니다

```python
body = {'dept_name': None, 'active': True}
wire = json.dumps(body)
print(wire)              # {"dept_name": null, "active": true}
again = json.loads(wire)
print(again['dept_name'] is None)  # True
```

JSON은 전송용 텍스트 형식이며 Python 코드가 아닙니다. JSON의 null/true/false는 Python에서 None/True/False로 읽힙니다. Python dict는 작은따옴표도 쓸 수 있지만 JSON 문자열은 키와 문자열 값에 큰따옴표를 사용합니다. json.dumps와 loads에 변환을 맡깁니다.

## 13. 실습 코드의 짧은 표현 사전 · 보충

| 표현 | 풀어 읽기 | 실습에서의 의미 |
|---|---|---|
| `[]`, `()`, `{}` | 빈 리스트·튜플·딕셔너리 | 초기 결과 또는 빈 매개변수 |
| `if not result['changes']:` | 변경 수 0이면 | 없는 학생의 UPDATE/DELETE 검사 |
| `[] if write else rows` | write가 참이면 [], 아니면 rows | 조회와 쓰기의 결과 구분 |
| `set(body) != required` | dict의 키 집합 비교 | 요청 필드가 정확한지 검사 |
| `key in body` | 키가 존재하는지 검사 | 요청 데이터 확인 |
| `result.update(ok=True)` | ok 키를 True로 설정 | 성공 응답 표시 |
| `db.execute(sql, params)` | 객체 db의 메서드를 두 인자로 호출 | SQL 템플릿과 값 분리 |
| `Path(__file__).resolve().parent` | 현재 코드 파일의 폴더 | 실행 위치와 무관하게 파일 경로 구성 |

빈 컨테이너·0·None은 조건식에서 거짓으로 취급됩니다. `if not value`는 None뿐 아니라 0과 빈 문자열도 함께 걸러냅니다. 학점 0은 유효하므로 값이 없음을 검사할 때 이런 표현을 무조건 쓰면 안 됩니다.

## 14. 따라 하기와 확인 문제

먼저 python_basics.py를 실행하고 다음 네 지점의 출력을 예측합니다.

1. `'12' + '1'`과 `int('12') + 1`의 차이는?
2. `(2001,)`과 `(2001)`의 타입은?
3. `valid_credits('12')`는 왜 False인가?
4. 첫 학생을 커밋하고 다음 블록에서 중복 PK 오류가 났을 때 왜 행 수가 1인가?

직접 수정할 때는 python_basics.py를 복사해서 연습합니다.

- `credits = 12`를 `credits = 201`로 바꾸고 if 분기 결과를 비교합니다. 아래 함수 예제의 `valid_credits(12)`는 별도의 상수 호출이므로 함께 바뀌지 않습니다.
- 딕셔너리의 학과 None을 '수학'으로 바꾸고 JSON을 확인합니다.
- Student 객체를 하나 더 만들고 greeting 결과를 확인합니다.

제출할 짧은 답: `body['tot_cred']`, `(credits, student_id)`, `self.repository.add(...)`, `with db`가 각각 무엇을 하는지 한 문장씩 적습니다. 이후 [학생 실습지](WORKSHEET.md)의 CRUD로 이어갑니다.

## 15. 수업 운영

90분 수업에서는 이 기초에 약 25분을 사용합니다. 1~5번으로 값과 자료구조를 읽고, 7·9번으로 함수와 객체 호출을 이해한 뒤, 실제 코드의 오류·DB 실행 지점에서 10·11번을 다시 연결합니다. 6번의 축약 반복문과 13번 표현 사전은 보충 자료로 활용합니다.

처음부터 전체 프로그램을 작성하도록 요구하지 않습니다. 준비된 코드를 실행하고, 한 줄의 입력·출력을 예측하고, 작은 변경을 확인하는 순서로 진행합니다. 접두어 검색 구현은 시간이 부족하면 수업 후 확장 과제로 둡니다.
