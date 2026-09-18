"""python3 python_basics.py: 파일 DB를 변경하지 않는 Python 문법 예제."""
import json
import sqlite3
from contextlib import closing


def main():
    print('1. 변수와 자료형')
    student_id = 2001
    name = "O'Brien"
    credits = 12
    dept = None
    print(student_id, name, credits, dept)
    print(type(student_id).__name__, type(name).__name__, type(dept).__name__)

    print('\n2. 문자열 숫자와 정수')
    raw = '12'
    print(raw + '1', int(raw) + 1)  # 121, 13
    print(f'학번 {student_id}: {credits}학점')

    print('\n3. 조건과 들여쓰기')
    if 0 <= credits <= 200:
        print('유효한 학점')
    else:
        print('학점 범위 오류')
    print(dept is None)  # True

    print('\n4. 딕셔너리와 JSON')
    student = {'id': student_id, 'name': name, 'dept_name': dept, 'tot_cred': credits}
    print(student['name'], student.get('email', '미입력'))
    encoded = json.dumps(student, ensure_ascii=False)
    print(encoded)  # None은 JSON null로 변환된다.
    decoded = json.loads(encoded)
    print(decoded['dept_name'] is None)

    print('\n5. 리스트, 튜플, 반복')
    rows = [student, {'id': 2002, 'name': '가상학생', 'dept_name': '수학', 'tot_cred': 24}]
    for row in rows:
        print(row['id'], row['name'])
    params = (24, 2001)
    print(params, params[0], params[1])
    print(type((2001,)).__name__, type((2001)).__name__)

    print('\n6. 함수와 return')
    def valid_credits(value, maximum=200):
        return type(value) is int and 0 <= value <= maximum
    print(valid_credits(12), valid_credits('12'), valid_credits(201))

    print('\n7. 클래스와 self')
    class Student:
        def __init__(self, name):
            self.name = name
        def greeting(self):
            return f'학생: {self.name}'
    first = Student('김민지')
    second = Student('이준호')
    print(first.greeting(), second.greeting())

    print('\n8. 예외 처리')
    try:
        int('열둘')
    except ValueError:
        print('정수로 바꿀 수 없습니다.')
    finally:
        print('변환 시도 종료')

    print('\n9. 짧은 문법을 풀어 읽기')
    names = []
    for row in rows:
        names.append(row['name'])
    print(names)
    print([row['name'] for row in rows])
    display = '미정' if dept is None else dept
    print(display)
    print(not [], bool(rows))

    print('\n10. with와 SQLite 바인딩')
    # :memory:는 이 연결에서만 사용하는 메모리 DB다.
    with closing(sqlite3.connect(':memory:')) as db:
        db.execute('CREATE TABLE student(id INTEGER PRIMARY KEY, name TEXT)')
        with db:
            db.execute('INSERT INTO student VALUES (?, ?)', (2001, "O'Brien"))
        print(db.execute('SELECT name FROM student WHERE id = ?', (2001,)).fetchone())
        try:
            with db:
                db.execute('INSERT INTO student VALUES (?, ?)', (2002, '가상학생'))
                db.execute('INSERT INTO student VALUES (?, ?)', (2001, '중복학생'))
        except sqlite3.IntegrityError:
            print('PK 중복: 이번 with 블록의 두 INSERT를 롤백했습니다.')
        print('남은 행 수:', db.execute('SELECT count(*) FROM student').fetchone()[0])
    print('연결 닫힘. 파일 DB는 변경하지 않았습니다.')


if __name__ == '__main__':
    main()
