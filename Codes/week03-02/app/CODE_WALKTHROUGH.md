# 3-tier 예제 코드 해설 · v04

이 해설은 브라우저·Python 서버·SQLite를 연결하는 **애플리케이션 코드**를 설명합니다. SQLite 엔진의 tokenize.c·parse.y 같은 내부 소스 분석은 별도 자료에서 다룹니다.

Python이 처음이라면 [기초 설명](PYTHON_PRIMER.md)과 `python3 python_basics.py`를 먼저 진행하세요. dict·tuple·self·with를 실제 코드와 연결합니다.

## 먼저 따라갈 한 요청

학생 2001 / O'Brien / 컴퓨터공학 / 12를 등록합니다.

| 순서 | 파일·함수 | 이 지점의 데이터 |
|---|---|---|
| 1 | app.js의 add-form 이벤트 | 입력 문자열을 읽고 숫자·null로 변환 |
| 2 | app.js의 request | POST /api/students와 JSON 본문 |
| 3 | server.py의 dispatch | 메서드, sid=None, Python dict |
| 4 | service.py의 Service.run | 검증을 통과한 (2001, "O'Brien", "컴퓨터공학", 12) |
| 5 | repository.py의 add → execute | 고정 INSERT와 별도 params |
| 6 | SQLite | 제약조건 검사와 행 저장, 성공 시 커밋 |
| 7 | server.py의 send | HTTP 201과 changes=1인 JSON 응답 |
| 8 | app.js의 list → render | 후속 GET으로 목록을 읽고 표 갱신 |

숫자·문자열·NULL이 각 경계를 통과할 때 어떻게 표현되는지를 함께 봅니다.

| 화면 입력 | JS 값 | JSON | Python 값 | SQLite 값 |
|---|---|---|---|---|
| 학번 2001 | Number 2001 | 2001 | int 2001 | INTEGER |
| 이름 O'Brien | 문자열 | "O'Brien" | str | TEXT |
| 학과 미정 | null | null | None | NULL |

## 1. 시작 시 객체를 연결하는 곳

파일: [server.py](server.py), 76행부터. 실제 배포 코드 발췌입니다.

```python
def make_server(db_path, port=8765):
    repository = Repository(db_path)
    repository.initialize()
    server = ThreadingHTTPServer(('127.0.0.1', port), Handler)
    server.service = Service(repository)
    return server
```

`Repository(db_path)`는 사용할 DB 파일 경로를 기억합니다. `initialize()`는 처음 실행할 때만 샘플 데이터를 준비합니다. 학생을 모두 삭제한 DB를 다시 켰다고 샘플 5명을 복구하지는 않습니다.

`ThreadingHTTPServer`는 127.0.0.1에서 HTTP 요청을 받습니다. `Handler`는 요청 처리 클래스이며, `Service(repository)`에는 SQL 실행을 맡길 객체를 전달합니다. 이를 통해 HTTP 처리와 SQL 실행을 서로 다른 파일에서 읽을 수 있습니다.

코드 파일은 네 개지만 논리적 계층은 세 개입니다. `server.py`와 `service.py`는 애플리케이션 계층을 나누어 구현합니다. `repository.py`는 SQLite 접근을 모아 둔 모듈이며 DB 엔진은 서버 프로세스에 포함됩니다.

확인: HTTP 경로를 변경할 때와 SQL을 변경할 때 각각 어떤 파일을 먼저 열까요?

## 2. 등록 버튼에서 JavaScript 객체 만들기

파일: [static/app.js](static/app.js), 61행부터. 실제 배포 코드 발췌입니다.

```javascript
$('add-form').onsubmit = (event) => {
  event.preventDefault();
  action(async () => {
    const form = new FormData(event.target);
    await request('POST', '/api/students', {id: Number(form.get('id')), name: form.get('name'), dept_name: form.get('dept_name') || null, tot_cred: Number(form.get('tot_cred'))});
    await list(false);
    status('등록 완료 · changes=1');
  });
};
```

`onsubmit`은 등록 폼을 제출할 때 실행됩니다. `preventDefault()`는 브라우저의 기본 폼 제출과 페이지 이동을 막고 JavaScript가 요청을 보내도록 합니다.

`new FormData(event.target)`은 제출한 폼의 값을 읽습니다. 입력창의 `name="id"`와 `form.get('id')`가 연결됩니다. HTML의 number 입력도 FormData에서는 문자열이므로 `Number(...)`로 변환합니다. `dept_name`이 빈 문자열이면 `|| null`을 통해 JSON의 null을 전달합니다.

2001 / O'Brien / 컴퓨터공학 / 12를 입력하면 `{id: 2001, name: "O'Brien", dept_name: "컴퓨터공학", tot_cred: 12}`를 만듭니다. 아직 SQL을 만들지 않습니다.

`await request(...)`가 성공해야 `list(false)`를 호출합니다. 등록과 목록 조회는 **서로 다른 HTTP 요청**입니다. `false`는 아래 관찰창의 등록 기록을 자동 조회 기록으로 덮어쓰지 않는 옵션입니다.

확인: `Number()`를 제거한 문자열 학번은 어느 파일의 검사에서 거부될까요?

## 3. 객체를 JSON으로 전송하기

파일: [static/app.js](static/app.js), 8행부터. 실제 배포 코드 발췌입니다.

```javascript
async function request(method, path, body, show = true) {
  const options = {method, headers: {}};
  if (body !== undefined) {
    options.headers['Content-Type'] = 'application/json';
    options.body = JSON.stringify(body);
  }
```

`request()`는 조회·등록·수정·삭제가 공통으로 쓰는 함수입니다. `method`와 `path`는 작업의 종류와 대상을 나타냅니다.

본문이 있으면 `Content-Type: application/json`을 설정하고 `JSON.stringify(body)`로 JavaScript 객체를 JSON 문자열로 바꿉니다. JSON의 작은따옴표는 일반 문자이므로 O'Brien을 따로 SQL용으로 이스케이프하지 않습니다. GET 요청은 본문을 보내지 않습니다.

매개변수 `show`는 화면의 관찰창 표시만 제어하며 서버가 요청을 처리하는 방식에는 영향을 주지 않습니다.

## 4. fetch와 오류 응답

파일: [static/app.js](static/app.js), 19행부터. 실제 배포 코드 발췌입니다.

```javascript
  const response = await fetch(path, options);
  const data = await response.json();
  if (show) {
    $('response').textContent = `HTTP ${response.status}\n${pretty(data)}`;
    $('database').textContent = data.database
      ? `SQL\n${data.database.sql}\n\n매개변수\n${pretty(data.database.parameters)}`
      : `실패 단계: ${data.stage ?? 'HTTP'}\n${data.error ?? '오류'}`;
  }
  if (!response.ok) throw new Error(`HTTP ${response.status} · ${data.error}`);
  return data;
}
```

`fetch(path, options)`는 HTTP 요청을 보냅니다. `await response.json()`은 응답 본문을 JavaScript 객체로 읽습니다. 이때 요청의 JS 객체와 서버의 Python dict가 같은 메모리 객체인 것은 아닙니다. 두 프로세스 사이에는 JSON 바이트가 오갑니다.

HTTP 400이나 409 응답을 받아도 `fetch` 자체는 보통 정상적으로 완료됩니다. 그래서 `response.ok`를 따로 검사하고 실패 상태면 `throw new Error(...)`로 오류를 전달합니다. 네트워크 연결 자체가 실패할 때는 fetch에서 예외가 발생할 수 있습니다.

`data.database.sql`과 `parameters`는 서버가 실행에 사용한 템플릿과 값입니다. 이 표시는 교육용이며 SQLite C API의 내부 trace는 아닙니다.

확인: `response.ok` 검사를 지우면 중복 등록을 성공으로 표시할 가능성이 생기는 이유는 무엇인가요?

## 5. HTTP 요청을 dispatch로 연결하기

파일: [server.py](server.py), 74행부터. 실제 배포 코드 발췌입니다.

```python
do_GET = do_POST = do_PATCH = do_DELETE = dispatch
```

`BaseHTTPRequestHandler`는 GET 요청이면 `do_GET`, POST 요청이면 `do_POST`를 호출합니다. 이 한 줄은 네 메서드를 모두 동일한 `dispatch` 함수에 연결합니다. dispatch 안에서는 `self.command`로 실제 메서드를 구분합니다.

브라우저에서 `/`로 처음 접속하는 요청은 HTML 파일을 받는 GET이고, `/api/students`는 학생 데이터를 받는 GET입니다. dispatch의 정적 파일 분기와 API 분기는 서로 다른 응답을 만듭니다.

## 6. URL에서 학번 추출하기

파일: [server.py](server.py), 42행부터. 실제 배포 코드 발췌입니다.

```python
route = re.fullmatch(r'/api/students(?:/([0-9]+))?', url.path)
if not route:
    self.send(404, {'ok': False, 'error': '경로를 찾을 수 없습니다.', 'stage': 'HTTP'})
    return
sid = int(route[1]) if route[1] else None
if (self.command == 'POST' and sid is not None) or (self.command in ('PATCH', 'DELETE') and sid is None):
    self.send(405, {'ok': False, 'error': '메서드와 경로가 맞지 않습니다.', 'stage': 'HTTP'})
    return
```

정규식의 앞부분은 `/api/students`와 일치합니다. 괄호 안의 숫자 부분은 선택 사항이므로 `/api/students/2001`도 허용합니다. 정규식 자체를 외우기보다 경로를 분류하는 역할을 이해하면 됩니다.

목록 경로라면 `sid=None`, 개별 경로라면 `sid=2001`입니다. `int(...)`는 URL의 문자열을 정수로 바꿉니다. POST는 목록 경로로, PATCH·DELETE는 개별 학생 경로로 제한합니다. 잘못된 경로는 404, 이 예제에서 메서드와 경로 조합이 맞지 않으면 405로 응답합니다.

## 7. JSON 읽기와 서비스 호출

파일: [server.py](server.py), 56행부터. 실제 배포 코드 발췌입니다.

```python
    length = int(self.headers.get('Content-Length', '0'))
    if not 0 < length <= 8192:
        raise InputError('요청 본문은 1~8192바이트여야 합니다.')
    body = json.loads(self.rfile.read(length))
query = parse_qs(url.query, keep_blank_values=True)
if set(query) - {'name'} or len(query.get('name', [])) > 1:
    raise InputError('검색에는 name을 한 번만 사용합니다.')
result = self.server.service.run(self.command, sid, body, query.get('name', [None])[0])
result.update(ok=True)
self.send(201 if self.command == 'POST' else 200, result)
```

`Content-Length`만큼 요청 바이트를 읽고 `json.loads()`로 Python dict를 만듭니다. JS의 숫자는 여기서 Python 숫자로, JSON null은 `None`으로 바뀝니다. 앞의 코드에서는 Content-Type도 확인합니다.

`parse_qs()`는 `?name=...`를 읽습니다. 검색 이름을 여러 번 주거나 다른 쿼리 필드를 주면 입력 오류로 처리합니다. 이어서 `Service.run(메서드, 학번, 본문, 검색이름)`을 호출합니다.

등록이 성공하면 HTTP 201, 다른 성공 작업이면 200입니다. `result.update(ok=True)`는 응답 dict에 성공 표시를 추가합니다. 모든 처리에서 200을 반환하면 오류와 성공을 구분하기 어려워집니다.

## 8. 서버가 입력을 다시 검증하는 이유

파일: [service.py](service.py), 8행부터. 실제 배포 코드 발췌입니다.

```python
def integer(value, label, minimum, maximum):
    if type(value) is not int or not minimum <= value <= maximum:
        raise InputError(f'{label}: {minimum}~{maximum} 범위의 정수가 필요합니다.')
    return value
```

브라우저의 HTML min/max 검사는 입력 편의를 위한 것입니다. 개발자 도구나 다른 HTTP 클라이언트가 서버에 직접 요청할 수 있으므로 서버도 검증합니다.

`type(value) is not int`는 문자열 "12", 실수 12.5, 불리언 true를 거부합니다. Python의 bool은 int의 하위 타입이므로 이 예제에서는 `isinstance(value, int)` 대신 정확한 타입을 확인합니다. 범위를 벗어나면 `InputError`를 던지고 SQL 실행은 시작하지 않습니다.

학점은 0~200, 학번은 1~2147483647 범위로 검사합니다. DB에도 CHECK 제약이 있어서 다른 경로로 DB를 수정할 때 기준을 유지합니다. 같은 규칙이라도 어느 단계에서 먼저 거부됐는지를 구분해야 합니다.

## 9. 등록 처리의 검증과 위임

파일: [service.py](service.py), 32행부터. 실제 배포 코드 발췌입니다.

```python
if method in ('POST', 'PATCH'):
    if not isinstance(body, dict):
        raise InputError('JSON 객체가 필요합니다.')
    required = {'id', 'name', 'dept_name', 'tot_cred'} if method == 'POST' else {'tot_cred'}
    if set(body) != required:
        raise InputError('요청 필드가 맞지 않습니다: ' + ', '.join(sorted(required)))
    credits = integer(body['tot_cred'], '이수 학점', 0, 200)
    if method == 'POST':
        sid = integer(body['id'], '학번', 1, 2147483647)
        name = text(body['name'], '이름')
        dept = body['dept_name']
        if dept is not None:
            dept = text(dept, '학과')
        return self.repository.add((sid, name, dept, credits))
```

POST와 PATCH는 JSON 객체인지, 필드 이름이 정확한지, 학점이 범위 안인지 먼저 확인합니다. 등록에서는 학번·이름·학과까지 읽습니다. `dept is not None`일 때만 문자열 검사를 하므로 학과 미정은 허용합니다.

검증을 통과하면 `(sid, name, dept, credits)` 튜플을 `repository.add()`에 전달합니다. 튜플의 순서는 INSERT의 열 순서와 일치해야 합니다. 서비스는 HTTP 응답을 쓰거나 SQL을 조립하지 않고 등록 규칙을 처리합니다.

학과 이름이 존재하는지는 DB의 외래키 제약이 검사합니다. 문자열 형식이 맞는 '없는학과'가 서비스의 문자열 검사에는 통과해도 DB에서 실패하는 이유입니다.

## 10. SQLite 연결과 외래키 설정

파일: [repository.py](repository.py), 23행부터. 실제 배포 코드 발췌입니다.

```python
def connect(self):
    db = sqlite3.connect(self.path, timeout=3)
    db.row_factory = sqlite3.Row
    db.execute('PRAGMA foreign_keys = ON')
    return db
```

`sqlite3.connect(self.path, timeout=3)`는 DB 파일에 대한 연결을 엽니다. timeout은 잠금이 걸린 DB에서 대기할 시간이며 모든 SQL의 실행 시간 제한은 아닙니다.

`row_factory = sqlite3.Row`를 지정하면 조회한 행을 열 이름으로 다룰 수 있습니다. 뒤에서 `dict(row)`로 JSON에 담기 좋은 객체로 변환합니다.

`PRAGMA foreign_keys = ON`은 **새 연결마다** 실행합니다. 설정이 DB 파일에 영구 저장된다고 가정하면 외래키 실험 결과가 달라질 수 있습니다. 실행 함수가 연결을 매번 열고 닫으므로 이 설정도 연결 함수에 둡니다.

## 11. SQL 실행, 커밋, 롤백, 연결 해제

파일: [repository.py](repository.py), 39행부터. 실제 배포 코드 발췌입니다.

```python
def execute(self, sql, params=(), write=False):
    with closing(self.connect()) as db, db:
        cursor = db.execute(sql, params)
        rows = [] if write else [dict(row) for row in cursor.fetchall()]
        changes = cursor.rowcount if write else 0
    return {'rows': rows, 'changes': changes,
            'database': {'sql': sql, 'parameters': list(params)}}
```

가장 중요한 줄은 `cursor = db.execute(sql, params)`입니다. SQL 텍스트와 값을 별도 인자로 전달합니다. 문자열을 합쳐 SQL을 만들지 않습니다.

`with closing(self.connect()) as db, db:`에는 두 컨텍스트 관리자가 있습니다. 내부의 `db`는 정상 종료 시 열린 트랜잭션을 커밋하고 예외가 전파되면 롤백합니다. 바깥 `closing(...)`은 마지막에 연결을 닫습니다. **연결의 with만으로 연결이 닫히는 것은 아닙니다.** 여기서의 동작은 예제처럼 별도의 autocommit 옵션을 지정하지 않은 연결 기준입니다.

`write=False`인 SELECT는 `fetchall()`로 행을 읽고 dict로 변환합니다. `write=True`인 INSERT/UPDATE/DELETE는 `rowcount`를 changes로 돌려줍니다. 이 read/write 구분은 호출자가 지정하는 예제 규칙이며 SQL 문장을 자동 판독하는 기능이 아닙니다.

이 함수의 with 블록이 끝난 뒤 결과 dict를 반환합니다. DB 오류는 여기서 삼키지 않으므로 서비스 호출을 거쳐 HTTP 처리기의 except까지 전달됩니다.

## 12. CRUD마다 달라지는 SQL과 튜플

파일: [repository.py](repository.py), 47행부터. 실제 배포 코드 발췌입니다.

```python
def list(self, name=None):
    sql = 'SELECT id, name, dept_name, tot_cred FROM student'
    return self.execute(sql + (' WHERE name = ?' if name is not None else '') + ' ORDER BY id',
                        (name,) if name is not None else ())

def get(self, student_id):
    return self.execute('SELECT id, name, dept_name, tot_cred FROM student WHERE id = ?', (student_id,))

def add(self, values):
    return self.execute('INSERT INTO student(id, name, dept_name, tot_cred) VALUES (?, ?, ?, ?)', values, True)

def update(self, student_id, credits):
    return self.execute('UPDATE student SET tot_cred = ? WHERE id = ?', (credits, student_id), True)

def delete(self, student_id):
    return self.execute('DELETE FROM student WHERE id = ?', (student_id,), True)
```

전체 조회와 이름 검색은 같은 list 함수를 사용합니다. 이름이 있으면 개발자가 정한 `WHERE name = ?` 절을 붙이고 실제 이름은 `(name,)`으로 바인딩합니다. SQL 조각을 조건부로 연결하는 것과 사용자 입력을 SQL에 연결하는 것은 다릅니다.

`(student_id,)`의 쉼표는 원소 하나짜리 튜플을 만듭니다. `(student_id)`는 단순 괄호식이므로 같은 의미가 아닙니다.

UPDATE의 첫 번째 `?`는 credits, 두 번째는 student_id입니다. 학번 2001을 24학점으로 바꿀 때 매개변수는 **(24, 2001)**입니다. 순서를 바꾸면 학번 24를 대상으로 2001학점을 넣으려 하므로 의도한 동작과 달라집니다.

DELETE는 WHERE로 학번을 한정합니다. 다른 CRUD에서도 같은 execute 함수를 사용하므로 연결·커밋·오류 처리 방식을 반복해서 작성하지 않습니다.

확인: 아래 세 요청에 전달할 params를 직접 적으세요. 이름 김민지 검색 / 2001의 학점을 24로 수정 / 2001 삭제.

## 13. 0행 수정과 DB 오류의 차이

파일: [service.py](service.py), 47행부터. 실제 배포 코드 발췌입니다.

```python
elif method == 'DELETE':
    result = self.repository.delete(student_id)
else:
    raise InputError('지원하지 않는 요청입니다.')
if not result['changes']:
    raise NotFound('해당 학생이 없습니다.')
return result
```

존재하지 않는 학번을 UPDATE나 DELETE해도 SQLite가 반드시 오류를 내는 것은 아닙니다. 실행은 성공하고 변경 행 수가 0일 수 있습니다. 이 서비스는 changes가 0이면 `NotFound`를 발생시켜 HTTP 404로 바꿉니다.

따라서 '없는 학번 수정'과 '중복 학번 등록'은 다릅니다. 전자는 서비스가 0행을 해석한 결과이고, 후자는 SQLite가 PK 위반 예외를 낸 결과입니다.

## 14. 예외를 HTTP 응답으로 바꾸기

파일: [server.py](server.py), 66행부터. 실제 배포 코드 발췌입니다.

```python
except (InputError, ValueError, UnicodeDecodeError) as error:
    self.send(404 if isinstance(error, NotFound) else 400,
              {'ok': False, 'error': str(error), 'stage': '애플리케이션'})
except sqlite3.IntegrityError as error:
    self.send(409, {'ok': False, 'error': str(error), 'stage': '데이터베이스'})
except sqlite3.OperationalError:
    self.send(503, {'ok': False, 'error': 'DB를 사용할 수 없습니다. 잠시 후 다시 실행하세요.', 'stage': '데이터베이스'})
```

입력 검증에서 발생한 오류는 400, `NotFound`는 404, SQLite 제약조건 위반은 409로 반환합니다. `NotFound`도 ValueError를 상속하므로 첫 번째 except에서 잡은 뒤 isinstance로 분류합니다.

`sqlite3.IntegrityError`는 중복 PK나 FK·CHECK 위반처럼 데이터 무결성 제약이 깨진 경우입니다. `sqlite3.OperationalError`에는 잠금 등 DB 실행 환경의 실패가 포함됩니다. 이 수업 예제는 OperationalError를 상세 분류하지 않고 503으로 표시합니다.

실패 응답의 stage는 사용자가 오류가 생긴 계층을 관찰하도록 붙인 수업용 필드입니다. 앞단의 경로·본문 형식 검사에서 반환하는 HTTP 오류도 있습니다.

## 15. JSON 응답을 브라우저에 쓰기

파일: [server.py](server.py), 15행부터. 실제 배포 코드 발췌입니다.

```python
def send(self, status, value, content_type='application/json; charset=utf-8'):
    data = json.dumps(value, ensure_ascii=False).encode() if isinstance(value, dict) else value
    self.send_response(status)
    self.send_header('Content-Type', content_type)
    self.send_header('Content-Length', str(len(data)))
    self.send_header('Cache-Control', 'no-store')
    self.send_header('X-Content-Type-Options', 'nosniff')
    self.send_header('Content-Security-Policy', "default-src 'self'; frame-ancestors 'none'")
    self.end_headers()
    self.wfile.write(data)
```

`json.dumps(..., ensure_ascii=False)`는 Python dict를 JSON 문자열로 만들고 `encode()`가 UTF-8 바이트로 바꿉니다. `Content-Length`는 글자 수가 아닌 **바이트 수**를 사용합니다. 한글이 들어간 응답에서 특히 구분해야 합니다.

HTTP 상태 줄, 헤더, 빈 줄 뒤에 본문을 씁니다. `end_headers()`가 헤더 종료를 알리고 `wfile.write(data)`가 실제 본문을 전송합니다. HTML·JS·CSS 응답은 이미 바이트이므로 dict 변환을 거치지 않습니다.

## 16. 응답을 표로 그리기

파일: [static/app.js](static/app.js), 30행부터. 실제 배포 코드 발췌입니다.

```javascript
function render(rows) {
  $('students').replaceChildren();
  $('count').textContent = `${rows.length}명`;
  for (const row of rows) {
    const tr = document.createElement('tr');
    for (const key of ['id', 'name', 'dept_name', 'tot_cred']) {
      const td = document.createElement('td');
      if (key === 'id') {
        const button = document.createElement('button');
        button.className = 'secondary';
        button.textContent = row.id;
        button.setAttribute('aria-label', `${row.id} 학생 선택`);
        button.onclick = () => { $('target-id').value = row.id; status(`${row.id} 학생을 선택했습니다.`); };
        td.append(button);
      } else td.textContent = row[key] === null ? '미정 (NULL)' : row[key];
      tr.append(td);
    }
    $('students').append(tr);
  }
}
```

`replaceChildren()`은 이전 조회의 행을 지웁니다. `rows` 배열의 각 객체에 대해 tr과 td를 만들고 열 순서대로 값을 넣습니다. `NULL`은 JSON에서는 null이므로 `row[key] === null`로 확인해 '미정 (NULL)'으로 보여 줍니다.

`textContent`는 받은 값을 텍스트로 표시합니다. 이름에 `<script>`가 있어도 HTML로 해석하지 않습니다. SQL 바인딩이 DB 쿼리의 문법을 보호하고 textContent가 HTML 해석을 피하도록 하는 것은 서로 다른 경계에서의 처리입니다.

학번 버튼은 `target-id` 입력창에 학번을 복사할 뿐 이 시점에 DB를 수정하지 않습니다. 등록·수정·삭제 후의 화면 갱신은 별도의 GET 조회를 거쳐 이 함수가 실행되는 결과입니다.

## 17. 중복 클릭과 예외 처리

파일: [static/app.js](static/app.js), 55행부터. 실제 배포 코드 발췌입니다.

```javascript
async function action(work) {
  if (busy) return;
  busy = true;
  try { await work(); } catch (error) { status(error.message, true); }
  finally { busy = false; }
}
```

`busy`는 현재 화면에서 한 작업이 진행되는 동안 다른 버튼 작업을 겹쳐 시작하지 않도록 합니다. `try` 안에서 전달받은 비동기 작업을 기다리고 실패하면 catch에서 오류를 화면에 표시합니다. finally는 성공·실패와 관계없이 busy를 해제합니다.

이 변수는 한 브라우저 화면에만 적용됩니다. 다른 브라우저의 요청이나 DB 트랜잭션의 동시성을 제어하는 잠금은 아닙니다. 데이터 무결성은 서버 검사와 DB 제약이 담당합니다.

## 18. 직접 수정하는 연습: 정확한 이름 검색을 접두어 검색으로

수업 후 선택 확장 과제는 한 곳의 SQL 변경입니다. 원본을 복사하고 `Repository.list()`에서 `WHERE name = ?`를 아래처럼 바꿉니다. 다른 계층의 함수 이름과 API 경로는 그대로 사용합니다.

```python
WHERE substr(name, 1, length(?)) = ?
```

조건이 있으면 두 매개변수에 같은 이름을 전달해야 하므로 `(name,)`을 `(name, name)`으로 바꿉니다. `?` 개수와 값의 개수를 함께 확인하세요. 학번·학점 데이터는 변경하지 않습니다.

예상 결과(초기 데이터): `김` 검색은 김민지 1명, `최` 검색은 최하린 1명, `없는이름`은 0명입니다. 이름을 그대로 비교하는 접두어 검색이므로 `%`와 `_`를 와일드카드로 쓰지 않습니다. 검색 설명·완료 메시지도 '이름으로 시작하는 학생'으로 고쳐 화면과 동작을 일치시키세요. API가 바뀐 것은 아니므로 서버를 재시작하고 브라우저를 새로고침하면 됩니다.

질문: WHERE만 바꾸고 params를 한 개 그대로 두면 왜 실패하나요? 이 경우는 바인딩 개수 불일치에 따른 ProgrammingError이며, 현재 예제의 HTTP 예외 매핑에는 포함하지 않습니다. 원인을 확인한 뒤 두 값으로 수정합니다.

선택 확장: 이름 검색 조건에 맞는 학생만 학번 역순으로 정렬하도록 `ORDER BY id DESC`를 사용하고 결과를 확인합니다. 원래 함수는 완전 일치 검색임을 기억하고 변경 내용을 제출합니다.

## 19. 실행 순서 확인 문제

1. 등록 후 Network 탭에 POST 다음 GET이 나타나는 이유는 무엇인가요?
2. JSON null은 Python과 SQLite에서 각각 무엇이 되나요?
3. 학점 201의 실패가 DB CHECK보다 먼저 일어나는 경로를 적으세요.
4. 없는 학번 삭제가 SQL 오류가 아니어도 HTTP 404가 되는 이유를 설명하세요.
5. 연결의 with와 closing은 각각 무엇을 마무리하나요?
6. SQL 바인딩과 textContent는 각각 어느 경계에서 입력값을 다루나요?
7. UPDATE의 params가 (24, 2001)인 이유를 ? 순서와 연결하세요.

제출: 기존 실습지에 위 문제 중 1·2·4·5·7의 답, 접두어 검색을 선택한 경우 변경 코드와 실행 결과를 추가합니다.
