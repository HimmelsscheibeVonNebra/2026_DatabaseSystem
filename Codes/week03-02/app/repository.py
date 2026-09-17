"""데이터 계층: 고정 SQL과 별도 매개변수로 SQLite에 접근한다."""
from contextlib import closing
from pathlib import Path
import sqlite3

SCHEMA = '''
CREATE TABLE IF NOT EXISTS department(dept_name TEXT PRIMARY KEY NOT NULL);
CREATE TABLE IF NOT EXISTS student(
 id INTEGER PRIMARY KEY CHECK(id > 0),
 name TEXT NOT NULL CHECK(length(trim(name)) BETWEEN 1 AND 80),
 dept_name TEXT REFERENCES department(dept_name),
 tot_cred INTEGER NOT NULL CHECK(typeof(tot_cred) = 'integer' AND tot_cred BETWEEN 0 AND 200)
);
'''
SEED = [(1001, '김민지', '컴퓨터공학', 42), (1002, '이준호', '수학', 18),
        (1003, '박서연', '경영학', 30), (1004, '최하린', '컴퓨터공학', 54),
        (1005, '정도윤', None, 0)]

class Repository:
    def __init__(self, path):
        self.path = Path(path)

    def connect(self):
        db = sqlite3.connect(self.path, timeout=3)
        db.row_factory = sqlite3.Row
        db.execute('PRAGMA foreign_keys = ON')
        return db

    def initialize(self):
        self.path.parent.mkdir(parents=True, exist_ok=True)
        with closing(self.connect()) as db, db:
            # 재시작 후 비어 있는 테이블에도 샘플을 다시 넣지 않는다.
            existed = db.execute("SELECT 1 FROM sqlite_master WHERE type='table' AND name='student'").fetchone()
            db.executescript(SCHEMA)
            if not existed:
                db.executemany('INSERT INTO department VALUES (?)', [(v,) for v in ['컴퓨터공학', '수학', '경영학']])
                db.executemany('INSERT INTO student VALUES (?, ?, ?, ?)', SEED)

    def execute(self, sql, params=(), write=False):
        with closing(self.connect()) as db, db:
            cursor = db.execute(sql, params)
            rows = [] if write else [dict(row) for row in cursor.fetchall()]
            changes = cursor.rowcount if write else 0
        return {'rows': rows, 'changes': changes,
                'database': {'sql': sql, 'parameters': list(params)}}

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
